//
//  XLSyncDeviceBussiness.m
//  XLApp
//
//  后台抄表
//
//  Created by JY on 14-3-28.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLSyncDeviceBussiness.h"
#import "SynthesizeSingleton.h"

#import "XLUtilities.h"
#import "XLCoreData.h"
#import <CoreData/CoreData.h>
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "CurveData.h"
#import "EventData.h"
#import "HistoryData_PowerNeeds.h"
#import "HistoryData_PowerValue.h"
#import "HistoryData_MeasurePoint_Sta.h"
#import "HistoryData_MeasurePoint_Sta_Harmonic.h"


@interface XLSyncDeviceBussiness()

//抄表起始日期
@property (nonatomic,strong) NSDate *startDate;
//抄表结束日期
@property (nonatomic,strong) NSDate *endDate;
//请求报文Bytes
@property (nonatomic,assign) Byte* frame;
//请求报文Data
@property (nonatomic,strong) NSData *data;
//报文输出长度
@property (nonatomic,assign) XL_UINT16 outlen;
//日冻结数据时间集合
@property (nonatomic,strong) NSArray *dayDateSet;
//月冻结数据时间集合
@property (nonatomic,strong) NSArray *monthDateSet;
//请求报文Offset
@property (nonatomic,assign) NSInteger requestOffset;
//实际请求FN数
@property (nonatomic,assign) NSInteger actualRequestFnCount;

//曲线请求数据集合
@property (nonatomic,strong) NSArray *curveRequestArray;
//日冻结请求数据集合
@property (nonatomic,strong) NSArray *afnDDayRequestArray;
//月冻结请求数据集合
@property (nonatomic,strong) NSArray *afnDMonthRequestArray;
//实时数据请求数据集合
@property (nonatomic,strong) NSArray *afnCRequestArray;
//参数请求数据集合
@property (nonatomic,strong) NSArray *afnARequestArray;


@property (nonatomic,strong) NSString  *notifyName;

@property (nonatomic,assign) NSInteger counter;
@property (nonatomic,assign) float totalCount;

//@property (nonatomic,assign) NSInteger preRequestOffset;
//@property (nonatomic,assign) NSInteger preCounter;

@property (nonatomic,strong) NSManagedObjectContext *contextParent;
@property (nonatomic,strong) NSManagedObjectContext *context;

@property (nonatomic,strong) NSArray *tempAfnDDaySubTypeArray;
@property (nonatomic,strong) NSArray *tempAfnDMonthSubTypeArray;

@property (nonatomic,assign) dispatch_semaphore_t semaphore;
@property (nonatomic,assign) dispatch_queue_t bgQueue;
@property (nonatomic,assign) dispatch_queue_t emgQueue;



//重要事件计数器
@property (nonatomic,assign) NSInteger ec1Count;

//一般事件计数器
@property (nonatomic,assign) NSInteger ec2Count;

@end

@implementation XLSyncDeviceBussiness

//曲线每次请求DADT数目
#define CURVESINGLECOUNT 2.0
//日数据每次请求DADT数目
#define AFNDDAYSINGLECOUNT 6.0
//月数据每次请求DADT数目
#define AFNDMONTHSINGLECOUNT 7.0
//实时数据每次请求DADT数目
#define AFNCSINGLECOUNT 1.0
//参数每次请求DADT数目
#define AFNASINGLECOUNT 1.0

//事件每次读取条数
#define AFNESINGLECOUNT 10.0

//曲线类型
#define CURVEDATA 0
//日冻结
#define AFNDDAYDATA 1
//月冻结
#define AFNDMONTHDATA 2
//实时数据
#define AFNCDATA 3
//事件
#define AFNEDATA 4
//参数
#define AFNADATA 5


PACKITEM array[10];

//SYNTHESIZE_SINGLETON_FOR_CLASS(XLSyncDeviceBussiness)

#pragma mark - 抄表入口

-(id)init{
    if (self = [super init]) {
        
        self.contextParent = [[XLCoreData sharedXLCoreData] managedObjectContext];
        self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        [self.context setParentContext:self.contextParent];
        
        self.notifyName = [NSString stringWithFormat:@"__%@__notify__%d",[self class],arc4random()];
        self.startDate = [self getNewDateWithDate:[NSDate date] withDiff:0 withType:0];
        self.endDate = [NSDate date];
        
        self.counter = 0;
        self.requestOffset = 0;
        
        //注册接受数据通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDataResponse:)
                                                     name:self.notifyName
                                                   object:nil];
        //注册异常处理通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(speHandleResponse:)
                                                     name:[NSString stringWithFormat:@"%@__spe__handle__",
                                                           self.notifyName]
                                                   object:nil];
        
        //注册前台请求数据通知
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(foreGroundRequest:)
        //                                                     name:@"requestForeGroundData"                                                       object:nil];
        
        //信号量
        self.semaphore = dispatch_semaphore_create(0);
        
        //抄表队列
        self.bgQueue   = dispatch_queue_create("COM.XLCOMBINE.BGQUEUE", DISPATCH_QUEUE_SERIAL);
        
        //高优先级请求队列
        //        self.emgQueue  = dispatch_queue_create("COM.XLCOMBINE.EMGQUEUE", DISPATCH_QUEUE_SERIAL);
        //
        //        dispatch_set_target_queue(self.bgQueue, self.emgQueue);
        
        
    }
    return self;
}

//开始从终端同步数据
-(void)beginSync{
    
    BOOL wifiFlag = [XLUtilities localWifiReachable];
    
    //是否已连接终端WIFI
    if (wifiFlag) {
        
        NSLog(@"抄表开始------------>>");
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self prepareDataForSync];
        [self requestAsyncData];
    }
}

-(void)beginSyncWithStartDate:(NSDate*)start withEndDate:(NSDate*)end{
    
    self.startDate = start;
    self.endDate = end;
    [self beginSync];
}


-(void)prepareDataForSync{
    
    [self buildRequestDateSet];
    
    if (!self.isTempRead) {
        [self buildDaDtSet];
    }
    
    
    self.curveRequestArray     = [NSMutableArray array];
    self.afnDDayRequestArray   = [NSMutableArray array];
    self.afnDMonthRequestArray = [NSMutableArray array];
    
    self.afnCRequestArray =      [NSMutableArray array];
    self.afnARequestArray =      [NSMutableArray array];
    
    self.curveRequestArray     = [self getRequestDataSetWithType:
                                  CURVEDATA];
    
    self.afnDDayRequestArray   = [self getRequestDataSetWithType:
                                  AFNDDAYDATA];
    
    self.afnDMonthRequestArray = [self getRequestDataSetWithType:
                                  AFNDMONTHDATA];
    
    self.afnARequestArray = [self getRequestDataSetForAFNCAndAFNAWithType:
                             AFNADATA];
    
    self.afnCRequestArray = [self getRequestDataSetForAFNCAndAFNAWithType:
                             AFNCDATA];
    
    self.totalCount = [self.curveRequestArray count] + [self.afnDDayRequestArray count] + [self.afnDMonthRequestArray count] + [self.afnARequestArray count] + [self.afnCRequestArray count];
}

//生成请求数据队列
-(void)requestAsyncData{
    
    //给队列添加任务
    dispatch_semaphore_signal(self.semaphore);
    
    for(int i = 0; i<ceil([self.curveRequestArray count]/CURVESINGLECOUNT);i++){
        dispatch_async(self.bgQueue, ^{
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            [self requestSocketDataWithRequestArray:self.curveRequestArray
                                           withType:CURVEDATA withReadOffset:CURVESINGLECOUNT];
        });
    }
    
    for(int i = 0; i<ceil([self.afnDDayRequestArray count]/AFNDDAYSINGLECOUNT);i++){
        dispatch_async(self.bgQueue, ^{
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            [self requestSocketDataWithRequestArray:self.afnDDayRequestArray
                                           withType:AFNDDAYDATA withReadOffset:AFNDDAYSINGLECOUNT];
        });
    }
    
    for(int i = 0; i<ceil([self.afnDMonthRequestArray count]/AFNDMONTHSINGLECOUNT);i++){
        dispatch_async(self.bgQueue, ^{
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            [self requestSocketDataWithRequestArray:self.afnDMonthRequestArray
                                           withType:AFNDMONTHDATA withReadOffset:AFNDMONTHSINGLECOUNT];
        });
    }
    
    for(int i = 0; i<ceil([self.afnCRequestArray count]/AFNCSINGLECOUNT);i++){
        dispatch_async(self.bgQueue, ^{
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            [self requestSocketDataWithRequestArray:self.afnCRequestArray
                                           withType:AFNCDATA withReadOffset:AFNCSINGLECOUNT];
        });
    }
    for(int i = 0; i<ceil([self.afnARequestArray count]/AFNASINGLECOUNT);i++){
        dispatch_async(self.bgQueue, ^{
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            [self requestSocketDataWithRequestArray:self.afnARequestArray
                                           withType:AFNADATA withReadOffset:AFNASINGLECOUNT];
        });
    }
    
    if (NO) {
        self.ec1Count = 10;
        self.ec2Count = 10;
        
        for(int i = 0; i<ceil(self.ec1Count/AFNESINGLECOUNT);i++){
            dispatch_async(self.bgQueue, ^{
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
                [self requestSocketDataForAFNEWithType:1 withOffset:i];
                
            });
        }
        
        for(int i = 0; i<ceil(self.ec2Count/AFNESINGLECOUNT);i++){
            dispatch_async(self.bgQueue, ^{
                dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
                [self requestSocketDataForAFNEWithType:2 withOffset:i];
            });
        }
    }
    
    
    dispatch_async(self.bgQueue, ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSLog(@"抄表结束------------>>");
        
        if (self.isTempRead) {
            [[NSNotificationCenter defaultCenter] postNotificationName:self.subViewNotifyName object:nil userInfo:nil];
        }
    });
}


#pragma mark - 回调函数
//请求报文回调函数
-(void)handleDataResponse:(NSNotification*)notify{
    
    NSString* afnType = [notify object];
    NSDictionary* dcs        = notify.userInfo;
    
    if (!self.isTempRead) {
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        [dic setObject:[NSNumber numberWithFloat:self.counter/self.totalCount] forKey:@"percent"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XLViewUpdatePercent"
                                                            object:nil
                                                          userInfo:dic];
    }
    
    if ([afnType integerValue] == AFN0D) {
        if ([self.curveDTArray containsObject:[dcs.allKeys objectAtIndex:0]]){
            [self saveCurveDataWithDic:dcs];
        } else {
            [self saveResponseDataWithType:AFN0D withDic:dcs];
        }
    }
    
    if ([afnType integerValue] == AFN0C) {
        [self saveResponseDataWithType:AFN0C withDic:dcs];
    }
    
    if ([afnType integerValue] == AFN0E) {
        [self saveResponseDataWithType:AFN0E withDic:dcs];
    }
    
    if ([afnType integerValue] == AFN0A) {
        
    }
    
    dispatch_semaphore_signal(self.semaphore);
}


//异常处理回调函数

// flagRet = -2 Socket连接断开
// flagRet = -1 ERROR
// flagRet = 1 确认帧
// flagRet = 2 否认帧
-(void)speHandleResponse:(NSNotification*)notify{
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //检查是否已抄完数据 没有则执行补抄
    //    if (!self.isMainTaskFinished) {
    //        NSDictionary *dcs = notify.userInfo;
    //
    //        NSInteger flagRet = [[dcs valueForKey:@"key"] integerValue];
    //
    //        //socket连接断开
    //        if (flagRet == -2) {
    //            [self beginSync];
    //        }
    //    }
    
    //..........其他异常处理在这
}



//收到临时高优先级请求任务
-(void)foreGroundRequest:(NSNotification*)notify{
    
    return;
    
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        NSDictionary* dcs  = notify.userInfo;
    //
    //        NSMutableArray* curveArray = [NSMutableArray array];
    //        NSMutableArray* afnDDayArray = [NSMutableArray array];
    //        NSMutableArray* afnDMonthArray = [NSMutableArray array];
    //
    //        float counter1 = SINGLECOUNT;
    //        float counter2 = 0;
    //        float counter3 = 0;
    //
    //        //isRealOrNot = 0 属实时显示数据 需先执行清空数据表
    //        //isRealOrNot = 1 非实时显示数据
    //        NSInteger isRealOrNot = [[dcs.allKeys objectAtIndex:0] integerValue];
    //
    //        NSDictionary *requestData = [dcs valueForKey:[dcs.allKeys objectAtIndex:0]];
    //
    //        //3种类型 曲线 0  日冻结 1 月冻结2
    //        for(int i = 0;i<[[requestData allKeys] count];i++){
    //
    //            //temp为 all date array
    //            NSArray* temp= [requestData valueForKey:[requestData.allKeys objectAtIndex:i]];
    //            NSInteger requestDataType = [[requestData.allKeys objectAtIndex:i] integerValue];
    //
    //            //array 为同一日期 同一测量点的请求集合
    //            for(NSArray* array in temp){
    //                for(NSArray* subArray in array){
    //
    //                    if (requestDataType == 0) {
    //                        [curveArray addObject:subArray];
    //
    //                        //实时请求时 先清除已有数据 保证实时更新
    //                        if (isRealOrNot == 0) {
    //                            [self deleteRealTimeCurveDataFromDBWithFn:[subArray objectAtIndex:0] withPn:[subArray objectAtIndex:1] withDate:[subArray objectAtIndex:2]];
    //                        }
    //                    }
    //                    if (requestDataType == 1) {
    //                        counter2 = [array count];
    //                        [afnDDayArray addObject:subArray];
    //                    }
    //                    if (requestDataType == 2) {
    //                        counter3 = [array count];
    //                        [afnDMonthArray addObject:subArray];
    //                    }
    //                }
    //            }
    //        }
    //
    //        //保存状态变量
    //        self.preRequestOffset = self.requestOffset;
    //        self.preCounter = self.counter;
    //
    //        //暂停抄表主队列
    //
    //        dispatch_suspend(bgQueue);
    //        NSLog(@"临时抄表任务开始--------->>");
    //        double delayInSeconds = 1.0;
    //        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //        dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    //
    //            //给队列添加任务
    //            if ([curveArray count]>0) {
    //                for(int i = 0; i<floor([curveArray count]/counter1 + 0.5);i++){
    //                    dispatch_async(emgQueue, ^{
    //                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //                        [self requestSocketDataWithCurveArray:curveArray withAfnDDayArray:afnDDayArray withAfnDMonthArray:afnDMonthArray withType:CURVEDATA withReadOffset:counter1];
    //                    });
    //                }
    //            }
    //            if ([afnDDayArray count]>0) {
    //                for(int i = 0; i<floor([afnDDayArray count]/counter2 + 0.5);i++){
    //                    dispatch_async(emgQueue, ^{
    //                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //                        [self requestSocketDataWithCurveArray:curveArray withAfnDDayArray:afnDDayArray withAfnDMonthArray:afnDMonthArray withType:AFNDDAYDATA withReadOffset:counter2];
    //                    });
    //                }
    //            }
    //
    //            if ([afnDMonthArray count]>0) {
    //                for(int i = 0; i<floor([afnDMonthArray count]/counter3 + 0.5);i++){
    //                    dispatch_async(emgQueue, ^{
    //                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //                        [self requestSocketDataWithCurveArray:curveArray withAfnDDayArray:afnDDayArray withAfnDMonthArray:afnDMonthArray withType:AFNDMONTHDATA withReadOffset:counter3];
    //                    });
    //                }
    //            }
    //
    //            dispatch_async(emgQueue, ^{
    //                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    //
    //                self.requestOffset = self.preRequestOffset;
    //                self.counter = self.preCounter;
    //                NSLog(@"临时抄表结束------------>>");
    //
    //                //临时队列处理完成 恢复主队列
    //                dispatch_resume(bgQueue);
    //            });
    //        });
    //    });
}


#pragma mark - 请求报文相关
//Build 376.1请求报文DADT
-(void)buildRequestFrameWithRequestArray:(NSArray*)requestArray
                                withType:(NSInteger)type
                          withReadOffset:(NSInteger)readOffset
{
    
    BOOL breakFlag = NO;
    NSArray *requestItem;
    self.actualRequestFnCount = 0;
    
    
    for(int i = 0; i < readOffset && !breakFlag;i++){
        
        //曲线DADT组成
        //FN PN 分时日月年 冻结密度 数据点数
        if (type == CURVEDATA) {
            
            if (self.requestOffset < [requestArray count]) {
                requestItem = [requestArray objectAtIndex:
                               self.requestOffset];
                
                PACKITEM item;
                item.fn = [[[requestItem objectAtIndex:0] substringFromIndex:1]
                           integerValue];
                item.pn = [[requestItem objectAtIndex:1] integerValue];
                item.datalen = 7;
                item.data[0] = 0;item.data[1] = 0;
                
                item.data[2] = [self getDayWithDate:
                                [requestItem objectAtIndex:2]];
                item.data[3] = [self getMonthWithDate:
                                [requestItem objectAtIndex:2]];
                item.data[4] = [self getYearWithDate:
                                [requestItem objectAtIndex:2]]%2000;
                item.data[5] = 1; item.data[6] =60;
                item.shouldUseByte = 0;
                array[self.actualRequestFnCount++] = item;
            }
        }
        
        //二类数据日冻结DADT组成
        //FN PN 日月年
        if (type == AFNDDAYDATA) {
            if (self.requestOffset < [requestArray count]) {
                requestItem = [requestArray objectAtIndex:
                               self.requestOffset];
                
                PACKITEM item;
                item.fn = [[[requestItem objectAtIndex:0] substringFromIndex:1]
                           integerValue];
                item.pn = [[requestItem objectAtIndex:1] integerValue];
                item.datalen = 3;
                
                item.data[0] = [self getDayWithDate:
                                [requestItem objectAtIndex:2]];
                item.data[1] = [self getMonthWithDate:
                                [requestItem objectAtIndex:2]];
                item.data[2] = [self getYearWithDate:
                                [requestItem objectAtIndex:2]]%2000;
                item.shouldUseByte = 0;
                array[self.actualRequestFnCount++] = item;
            }
        }
        
        //二类数据月冻结DADT组成
        //FN PN 月年
        if (type == AFNDMONTHDATA) {
            if (self.requestOffset < [requestArray count]) {
                requestItem = [requestArray objectAtIndex:
                               self.requestOffset];
                
                PACKITEM item;
                item.fn = [[[requestItem objectAtIndex:0] substringFromIndex:1]
                           integerValue];
                item.pn = [[requestItem objectAtIndex:1] integerValue];
                item.datalen = 2;
                item.data[0] = [self getMonthWithDate:
                                [requestItem objectAtIndex:2]];
                item.data[1] = [self getYearWithDate:
                                [requestItem objectAtIndex:2]]%2000;
                item.shouldUseByte = 0;
                array[self.actualRequestFnCount++] = item;
            }
        }
        
        if (type == AFNCDATA||type == AFNADATA) {
            if (self.requestOffset < [requestArray count]) {
                requestItem = [requestArray objectAtIndex:
                               self.requestOffset];
                PACKITEM item;
                item.fn = [[[requestItem objectAtIndex:0] substringFromIndex:1]
                           integerValue];
                item.pn = [[requestItem objectAtIndex:1] integerValue];
                item.datalen = 0;
                item.shouldUseByte = 0;
                array[self.actualRequestFnCount++] = item;
            }
        }
        
        self.requestOffset++;
        if (self.requestOffset >= [requestArray count]) {
            breakFlag = YES;
            self.requestOffset = 0;
        }
        self.counter++;
    }
}

-(void)requestSocketData4AFNE{
    
    NSLog(@"事件计数1%d",self.ec1Count);
    NSLog(@"事件计数2%d",self.ec2Count);
    dispatch_semaphore_signal(self.semaphore);
    
}

-(void)requestSocketDataForAFNEWithType:(NSInteger)type withOffset:(NSInteger)offset{
    NSInteger pm = offset*AFNESINGLECOUNT;
    NSInteger pn = pm + AFNESINGLECOUNT;
    self.counter++;
    self.frame = PackFrameForEvent(AFN0E, 0, type, pm, pn, &_outlen);
    self.data = [NSData dataWithBytes:self.frame length:self.outlen];
    free(self.frame);
    
    NSLog(@"请求数据报文:%@ 类型:%d 次数:%d SEQ帧序列:%d",[self.data description],
          AFNEDATA,
          self.requestOffset,
          [XLUtilities parseSeqFieldWithData:self.data]);
    [[XLSocketManager sharedXLSocketManager] packRequestFrameWithData:self.data
                                                       withNotifyName:self.notifyName];
}

//发送请求报文
-(void)requestSocketDataWithRequestArray:(NSArray*)requestArray
                                withType:(NSInteger)type
                          withReadOffset:(NSInteger)readOffset
{
    
    [self buildRequestFrameWithRequestArray:requestArray
                                   withType:type
                             withReadOffset:readOffset];
    
    Byte afn;
    
    if (type == CURVEDATA || type == AFNDDAYDATA || type == AFNDMONTHDATA) {
        afn = AFN0D;
    }
    if (type == AFNCDATA) {
        afn = AFN0C;
    }
    if (type == AFNADATA) {
        afn = AFN0A;
    }
    self.frame = PackFrame(afn, array, self.actualRequestFnCount,&_outlen);
    
    self.data = [NSData dataWithBytes:self.frame length:self.outlen];
    free(self.frame);
    
    NSLog(@"请求数据报文:%@ 类型:%d 次数:%d SEQ帧序列:%d",[self.data description],
          type,
          self.requestOffset,
          [XLUtilities parseSeqFieldWithData:self.data]);
    [[XLSocketManager sharedXLSocketManager] packRequestFrameWithData:self.data
                                                       withNotifyName:self.notifyName];
}

//获取请求数据FN PN 日期集合
-(NSArray*)getRequestDataSetWithType:(NSInteger)type{
    
    __block NSString *fnCode = @"";
    __block NSInteger pnCode;
    __block NSDate *requestDate;
    
    NSArray *enumerArray;
    NSArray *dateArray;
    
    NSMutableArray *requestArray = [NSMutableArray array];
    
    if (type == CURVEDATA) {
        enumerArray = self.curveDTArray;
        dateArray = self.dayDateSet;
    }
    
    if (type == AFNDDAYDATA) {
        enumerArray = self.afnDDayDTArray;
        dateArray = self.dayDateSet;
    }
    
    if (type == AFNDMONTHDATA) {
        enumerArray = self.afnDMonthDTArray;
        dateArray = self.monthDateSet;
    }
    
    //日期数组
    [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        requestDate = (NSDate*)obj;
        
        //测量点数组
        [self.terDAArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            pnCode = [obj integerValue];
            
            //Fn数组
            [enumerArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                fnCode = (NSString*)obj;
                
                //曲线类型此处检查数据库是否已有对应记录
                if (YES) {
                    if (![self checkIfDataIsExistwithFn:[[fnCode substringFromIndex:1] integerValue]
                                             withPnCode:pnCode
                                        withRequestDate:requestDate
                                          withCheckType:type withSubType:nil]) {
                        
                        [requestArray addObject:[NSArray arrayWithObjects:
                                                 fnCode,
                                                 [NSNumber numberWithInteger:pnCode],
                                                 requestDate,nil]];
                    }
                }
            }];
        }];
    }];
    
    return requestArray;
}


-(NSArray*)getRequestDataSetForAFNCAndAFNAWithType:(NSInteger)type{
    
    NSMutableArray *requestArray = [NSMutableArray array];
    NSArray *dtArray;
    
    if (type == AFNCDATA) {
        dtArray = self.afnCDTArray;
    }
    if (type == AFNADATA) {
        dtArray = self.afnADTArray;
    }
    
    [self.terDAArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger mp = [obj integerValue];
        
        [dtArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString* fnCode = (NSString*)obj;
            [requestArray addObject:[NSArray arrayWithObjects:
                                     fnCode,
                                     [NSNumber numberWithInteger:mp],nil]];
        }];
    }];
    
    return requestArray;
}



//生成DADT集合
-(void)buildDaDtSet{
    
    //曲线DT集合
    self.curveDTArray = [NSArray arrayWithObjects:
                         //有功功率总及三相
                         @"F81",@"F82",@"F83",@"F84",
                         //无功功率总及三相
                         @"F85",@"F86",@"F87",@"F88",
                         //功率因数总及三相
                         @"F105",@"F106",@"F107",@"F108",
                         //电压三相
                         @"F89",@"F90",@"F91",
                         //电流三相
                         @"F92",@"F93",@"F94",
                         @"F234",nil];
    
    
    
    //二类数据日冻结DT集合
    self.afnDDayDTArray   = [NSArray arrayWithObjects:
                             @"F3",@"F26",               //需量
                             @"F5",@"F6",@"F45",         //电能示值
                             @"F25",@"F27",@"F28",@"F43",//测量点统计
                             @"F121",@"F122",@"F123",nil];
    
//    self.tempAfnDDaySubTypeArray = [NSArray arrayWithObjects:
//                                    @"1",@"1",
//                                    @"0",@"0",@"0",
//                                    @"2",@"2",@"2",@"2",
//                                    @"3",@"3",@"3",
//                                    nil];
    //二类数据月冻结DT集合
    self.afnDMonthDTArray = [NSArray arrayWithObjects:
                             @"F34",                           //需量
                             @"F21",@"F46",                    //电能示值
                             @"F33",@"F35",@"F36",@"F44", nil];//测量点统计
    
//    self.tempAfnDMonthSubTypeArray = [NSArray arrayWithObjects:
//                                      @"1",
//                                      @"0",@"0",
//                                      @"2",@"2",@"2",@"2",
//                                      nil];
    
    //一类数据DT集合
    self.afnCDTArray = [NSArray arrayWithObjects:@"F7", nil];
    
    //查询参数DT集合
    self.afnADTArray = [NSArray arrayWithObjects:@"F25", nil];
    
    //设备测量点集合
    [self getDAArray];
    
}

//获取设备测量点集合
-(void)getDAArray{
    
    //TD..
    self.terDAArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], nil];
}




#pragma mark - 日期处理相关

//获取请求日期集合
-(void)buildRequestDateSet{
    
    //根据起始日期结束日期获取日期集合
    NSMutableArray *dateSet = [NSMutableArray array];
    
    NSDate *tempDate = self.startDate;
    
    
    while ([tempDate timeIntervalSince1970] <= [self.endDate timeIntervalSince1970]) {
        [dateSet addObject:tempDate];
        
        tempDate = [self getNewDateWithDate:tempDate
                                   withDiff:1 withType:0];
    }
    self.dayDateSet = [[dateSet reverseObjectEnumerator] allObjects];
    
    dateSet = [NSMutableArray array];
    
    NSInteger months = [[[NSCalendar currentCalendar] components: NSMonthCalendarUnit
                                                        fromDate: self.startDate
                                                          toDate: self.endDate
                                                         options: 0] month];
    
    if (months == 0) {
        if (([self getMonthWithDate:self.startDate]!=[self getMonthWithDate:self.endDate])) {
            months+=2;
        }else{
            months++;
        }
    } else {
        months++;
    }
    tempDate = self.startDate;
    while (months > 0) {
        [dateSet addObject:tempDate];
        tempDate = [self getNewDateWithDate:tempDate
                                   withDiff:1
                                   withType:1];
        months--;
    }
    self.monthDateSet = [[dateSet reverseObjectEnumerator] allObjects];
}


//获取格式化日期字符串
-(NSString*)getFormatDateStringWithDate:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:date];
}

//从字符串获取日期
-(NSDate*)getDateFromFormatString:(NSString*)date{
    
    if ([date length]<=7) {
        date = [NSString stringWithFormat:@"%@-01",date];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    return [dateFormatter dateFromString:date];
}

//根据时间间隔计算日期
-(NSDate*)getNewDateWithDate:(NSDate*)date withDiff:(NSInteger)num withType:(NSInteger)type{
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    switch (type) {
        case 0:
            [dateComponents setDay:num];
            break;
        case 1:
            [dateComponents setMonth:num];
        default:
            break;
    }
    
    NSDate *newDate = [[NSCalendar currentCalendar]
                       dateByAddingComponents:dateComponents
                       toDate:date options:0];
    
    return newDate;
}


//获取指定日期天
-(NSInteger)getDayWithDate:(NSDate*)_date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit)
                                               fromDate:_date];
    
    return [components day];
}


//获取指定日期月
-(NSInteger)getMonthWithDate:(NSDate*)_date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSMonthCalendarUnit)
                                               fromDate:_date];
    
    return [components month];
}

//获取指定日期年
-(NSInteger)getYearWithDate:(NSDate*)_date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit)
                                               fromDate:_date];
    
    return [components year];
}

//格式化数据时标 输入14年3月29日
-(NSString*)getDataTime:(NSString*)date{
    
    NSInteger year,month,day;
    year   = [[date substringToIndex:2] intValue];
    
    month =[[date substringWithRange:NSMakeRange([date rangeOfString:@"年"].location+1,
                                                 ([date rangeOfString:@"月"].location - [date rangeOfString:@"年"].location)-1)] intValue];
    
    day =[[date substringWithRange:NSMakeRange([date rangeOfString:@"月"].location+1,
                                               ([date rangeOfString:@"日"].location - [date rangeOfString:@"月"].location)-1)] intValue];
    
    return [NSString stringWithFormat:@"20%02d-%02d-%02d",year,month,day];
}

//格式化数据时标 输入14年3月
-(NSString*)getDataTime1:(NSString*)date{
    
    NSInteger year,month;
    year   = [[date substringToIndex:2] intValue];
    
    month =[[date substringWithRange:NSMakeRange([date rangeOfString:@"年"].location+1,
                                                 ([date rangeOfString:@"月"].location - [date rangeOfString:@"年"].location)-1)] intValue];
    
    return [NSString stringWithFormat:@"20%02d-%02d",year,month];
}


//获取日期的timeInterval Since1970
-(NSInteger)getDateIntervalWithType:(NSInteger)type withDate:(NSString*)date
                           withHour:(NSInteger)hour
                         withMinute:(NSInteger)minute{
    
    NSString *dateString = [NSString stringWithFormat:@"%@ %d:%d:00",
                            date,hour,minute];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return [destDate timeIntervalSince1970];
}

//输入 @"2014-1-1" @"3月31日21时48分"
-(NSInteger)getDateIntervalWithDateString1:(NSString*)date1 withDateString2:(NSString*)date2{
    
    NSInteger hour   = [[date2 substringWithRange:NSMakeRange([date2 rangeOfString:@"日"].location+1,
                                                              ([date2 rangeOfString:@"时"].location - [date2 rangeOfString:@"日"].location)-1)] intValue];
    
    NSInteger mimute =[[date2 substringWithRange:NSMakeRange([date2 rangeOfString:@"时"].location+1,
                                                             ([date2 rangeOfString:@"分"].location - [date2 rangeOfString:@"时"].location)-1)] intValue];
    
    NSString *dateString = [NSString stringWithFormat:@"%@ %d:%d:00",
                            date1,hour,mimute];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return [destDate timeIntervalSince1970];
}

//输入 @"2013-2" @"3月31日21时48分"
-(NSInteger)getDateIntervalWithDateString2:(NSString*)date1 withDateString2:(NSString*)date2{
    
    NSInteger day   = [[date2 substringWithRange:NSMakeRange([date2 rangeOfString:@"月"].location+1,
                                                             ([date2 rangeOfString:@"日"].location - [date2 rangeOfString:@"月"].location)-1)] intValue];
    
    
    NSInteger hour   = [[date2 substringWithRange:NSMakeRange([date2 rangeOfString:@"日"].location+1,
                                                              ([date2 rangeOfString:@"时"].location - [date2 rangeOfString:@"日"].location)-1)] intValue];
    
    NSInteger mimute =[[date2 substringWithRange:NSMakeRange([date2 rangeOfString:@"时"].location+1,
                                                             ([date2 rangeOfString:@"分"].location - [date2 rangeOfString:@"时"].location)-1)] intValue];
    
    NSString *dateString = [NSString stringWithFormat:@"%@-%d %d:%d:00",
                            date1,day,hour,mimute];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    
    return [destDate timeIntervalSince1970];
}

#pragma mark - 数据库操作相关

//保存曲线数据
-(void)saveCurveDataWithDic:(NSDictionary*)dcs{
    
    double total = 0.0;
    double temp = 0.0;
    //最小值，最大值
    double itemMinValue = 0.0;double itemMaxValue= 0.0;
    
    //最大值/最小值发生的曲线点1～96
    NSInteger maxPointHour = 0; NSInteger maxPointMinute = 0;
    NSInteger minPointHour = 0; NSInteger minPointMinute = 0;
    
    NSString *key;
    
    for(int i = 0; i < [dcs.allKeys count];i++){
        total = 0;
        key = [dcs.allKeys objectAtIndex:i];
        CurveData *item = [NSEntityDescription insertNewObjectForEntityForName:@"CurveData"
                                                        inManagedObjectContext:self.context];
        
        for(int j = 0; j < 96;j++){
            
            temp = [[[dcs valueForKey:key] valueForKey:[NSString stringWithFormat:@"%d", 4 + j]]
                    doubleValue];
            
            //如果是功率曲线 出现负数处理
            if (   [key isEqualToString:@"F81"] || [key isEqualToString:@"F85"]
                || [key isEqualToString:@"F82"] || [key isEqualToString:@"F86"]
                || [key isEqualToString:@"F83"] || [key isEqualToString:@"F87"]
                || [key isEqualToString:@"F84"] || [key isEqualToString:@"F88"]) {
                
                if (temp<0) {
                    temp = 80 - temp;
                }
            }
            
            //如果是功率因数，存入数据库时进行/100的计算
            if (   [key isEqualToString:@"F105"] || [key isEqualToString:@"F106"]
                || [key isEqualToString:@"F107"] || [key isEqualToString:@"F108"]) {
                
                temp = temp/100.0;
            }
            total += temp;
            [item setValue:[NSNumber numberWithDouble:temp]
                    forKey:[NSString stringWithFormat:@"cvPoint%d",j+1]];
            
            if (j==0) {
                itemMinValue =temp;
                itemMaxValue =temp;
                maxPointHour = 0;
                maxPointMinute = 0;
            }
            
            if (temp < itemMinValue) {
                itemMinValue = temp;
                minPointHour = j/4;
                minPointMinute = (i%4)*15;
            }
            
            if (temp>itemMaxValue) {
                itemMaxValue = temp;
                maxPointHour = j/4;
                maxPointMinute = (j%4)*15;
            }
        }
        
        [item setValue:[NSNumber numberWithInt:[[key substringFromIndex:1] intValue]]
                forKey:@"cvCurveType"];
        [item setValue:[NSNumber numberWithDouble:total/96.0]
                forKey:@"cvAvg"];
        [item setValue:[NSNumber numberWithDouble:itemMaxValue]
                forKey:@"cvMax"];
        [item setValue:[NSNumber numberWithDouble:itemMinValue]
                forKey:@"cvMin"];
        [item setValue:[self getDataTime:[[dcs valueForKey:key] valueForKey:@"日期"]]
                forKey:@"cvDataTime"];
        [item setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:key] valueForKey:@"测量点号"]
                                                    integerValue]]
                forKey:@"cvMeasureNo"];
        
        [item setValue:[NSNumber numberWithInteger:
                        [NSNumber numberWithInteger:
                         [self getDateIntervalWithType:0 withDate:
                          [self getDataTime:[[dcs valueForKey:key] valueForKey:@"日期"]]
                                              withHour:maxPointHour
                                            withMinute:maxPointMinute]]]
                forKey:@"cvMaxTime"];
        
        [item setValue:[NSNumber numberWithInteger:
                        [NSNumber numberWithInteger:
                         [self getDateIntervalWithType:0 withDate:
                          [self getDataTime:[[dcs valueForKey:key] valueForKey:@"日期"]]
                                              withHour:minPointHour
                                            withMinute:minPointMinute]]]
                forKey:@"cvMinTime"];
        
        
        //        if (![self checkIfDataIsExistwithFn:[[key substringFromIndex:1] integerValue]
        //                                 withPnCode:[[[dcs valueForKey:key] valueForKey:@"测量点号"] integerValue]
        //                            withRequestDate:[self getDateFromFormatString:[self getDataTime:[[dcs valueForKey:key] valueForKey:@"日期"]]]
        //                              withCheckType:CURVEDATA withSubType:0]) {
        
        if (YES) {
            [self.context save:nil];
            
            [self.contextParent performBlock:^{
                [self.contextParent save:nil];
            }];
        }
        
    }
    
}


-(void)saveResponseDataWithType:(NSInteger)type withDic:(NSDictionary*)dcs{
    [dcs.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *method;
        
        if (type == AFN0D) {
            method = [NSString stringWithFormat:@"handleAFND%@:",obj];
        }
        if (type == AFN0C) {
            method = [NSString stringWithFormat:@"handleAFNC%@:",obj];
        }
        if (type == AFN0A) {
            method = [NSString stringWithFormat:@"handleAFNA%@:",obj];
        }
        if (type == AFN0E) {
            method = [NSString stringWithFormat:@"handleAFNE%@:",obj];
        }
        
        SEL selector = NSSelectorFromString(method);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored  "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:dcs];
#pragma clang diagnostic pop
        
    }];
}




//Check数据库是否包含指定数据
-(BOOL)checkIfDataIsExistwithFn:(NSInteger)fnCode withPnCode:(NSInteger)pnCode withRequestDate:(NSDate*)date
                  withCheckType:(NSInteger)type withSubType:(NSInteger)checkType{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    
    if (type == CURVEDATA) {
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurveData"
                                                  inManagedObjectContext:self.context];
        [fetchRequest setEntity:entity];
        
        //查询条件：曲线Fn 测量点号 曲线时间
        //TD 增加设备号的判断
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cvCurveType = %d  and cvMeasureNo = %d and cvDataTime = %@",
                                  fnCode,
                                  pnCode,
                                  [self getFormatDateStringWithDate:date]];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSUInteger count = [self.context countForFetchRequest:fetchRequest error:&error];
        
        if (count!=0) {
            return YES;
        }
    }
    
    if (type == AFNDDAYDATA|| type == AFNDMONTHDATA) {
        
        NSString *entityName;
        NSInteger subType;
        
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EntityConfig" ofType:@"plist"];
        NSDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *subDic = [config valueForKey:@"AFND"];
        subType = [[subDic valueForKey:[NSString stringWithFormat:@"F%d",fnCode]] integerValue];
        
        NSEntityDescription *entity;
        NSString *queryDate;
        
        if (type == AFNDDAYDATA) {
            queryDate = [self getFormatDateStringWithDate:date];
        }
        if (type == AFNDMONTHDATA) {
            queryDate = [[self getFormatDateStringWithDate:date] substringToIndex:7];
        }
 
        switch (subType) {
            case 0:
                entityName = @"HistoryData_PowerValue";
                break;
            case 1:
                entityName = @"HistoryData_PowerNeeds";
                break;
            case 2:
                entityName = @"HistoryData_MeasurePoint_Sta";
                break;
            case 3:
                entityName = @"HistoryData_MeasurePoint_Sta_Harmonic";
                break;
            default:
                break;
        }
        entity = [NSEntityDescription entityForName:entityName
                                 inManagedObjectContext:self.context];
        
        [fetchRequest setEntity:entity];
        
        //查询条件:日月数据类型 测量点号 数据时标
        //TD....设备号
        NSPredicate *predicate;
        
        if (checkType == 1) {
            predicate = [NSPredicate predicateWithFormat:@"hdDataType = %d  and hdMeasureNo = %d and hdDataTime = %@",
                         type,
                         pnCode,
                         queryDate];
            
        } else {
            NSString* temp = [NSString stringWithFormat:@"hdDataType == %d  and hdMeasureNo == %d and hdDataTime == '%@' and hdF%dFilled == 1",type,pnCode,queryDate,fnCode];
            
            predicate = [NSPredicate predicateWithFormat:temp];
            
        }
        
        if (subType == 3) {
            
            predicate = [NSPredicate predicateWithFormat:@"hdDataType = %d  and hdMeasureNo = %d and hdDataTime = %@ and hdPhaseType = %d",
                         type,
                         pnCode,
                         queryDate,fnCode];
        }
        
        [fetchRequest setPredicate:predicate];
        
        NSUInteger count = [self.context countForFetchRequest:fetchRequest error:nil];
        
        if (count!=0) {
            return YES;
        }
    }
    return NO;
}


-(id)getEntityFromDBwithFnCode:(NSInteger)fnCode withPnCode:(NSInteger)pnCode withRequestDate:(NSDate*)date
                 withCheckType:(NSInteger)type{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    if (type == AFNDDAYDATA|| type == AFNDMONTHDATA) {
        
        NSString *entityName;
        NSInteger subType;
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"EntityConfig" ofType:@"plist"];
        NSDictionary *config = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        NSDictionary *subDic = [config valueForKey:@"AFND"];
        subType = [[subDic valueForKey:[NSString stringWithFormat:@"F%d",fnCode]] integerValue];
        
        NSEntityDescription *entity;
        NSString *queryDate;
        
        if (type == AFNDDAYDATA) {
            queryDate = [self getFormatDateStringWithDate:date];
        }
        if (type == AFNDMONTHDATA) {
            queryDate = [[self getFormatDateStringWithDate:date] substringToIndex:7];;
        }
        
        switch (subType) {
            case 0:
                entityName = @"HistoryData_PowerValue";
                break;
            case 1:
                entityName = @"HistoryData_PowerNeeds";
                break;
            case 2:
                entityName = @"HistoryData_MeasurePoint_Sta";
                break;
            case 3:
                entityName = @"HistoryData_MeasurePoint_Sta_Harmonic";
                break;
            default:
                break;
        }
        entity = [NSEntityDescription entityForName:entityName
                             inManagedObjectContext:self.context];
        
        
        [fetchRequest setEntity:entity];
        
        //查询条件:日月数据类型 测量点号 数据时标
        //TD....设备号
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hdDataType = %d  and hdMeasureNo = %d and hdDataTime = %@",
                                  type,
                                  pnCode,
                                  queryDate];
        
        if (subType == 3) {
            
            predicate = [NSPredicate predicateWithFormat:@"hdDataType = %d  and hdMeasureNo = %d and hdDataTime = %@ and hdPhaseType = %d",
                         type,
                         pnCode,
                         queryDate,fnCode];
        }
        
        [fetchRequest setPredicate:predicate];
        
        NSError* error;
        NSArray* array = [self.context executeFetchRequest:fetchRequest error:&error];
        
        return [array objectAtIndex:0];
    }
    return nil;
}

//因为实时数据需要实时更新 故每次查询前清掉已有数据
//删除DB 当日曲线数据条目
-(void)deleteRealTimeCurveDataFromDBWithFn:(NSString*)fnCode withPn:(NSString*)pnCode withDate:(NSDate*)date{
    
    
    //    NSManagedObjectContext *contextParent = [[XLCoreData sharedXLCoreData] managedObjectContext];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurveData" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    //查询条件：曲线Fn 测量点号 曲线时间
    //TD 增加设备号的判断
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cvCurveType = %d  and cvMeasureNo = %d and cvDataTime = %@",
                              [[fnCode substringFromIndex:1] integerValue],
                              [pnCode integerValue],
                              [self getFormatDateStringWithDate:date]];
    
    [fetchRequest setPredicate:predicate];
    
    NSArray* array = [context executeFetchRequest:fetchRequest error:nil];
    if ([array count]!=0) {
        [context deleteObject:[array objectAtIndex:0]];
    }
}
#pragma mark - 一类数据存储
-(void)handleAFNCF7:(NSDictionary*)dcs{
    self.ec1Count = [[[dcs valueForKey:@"F7"] valueForKey:@"当前重要事件计数器EC1值"] integerValue];
    self.ec2Count = [[[dcs valueForKey:@"F7"] valueForKey:@"当前一般事件计数器EC2值"] integerValue];
}

#pragma mark - 参数存储



#pragma mark - 事件存储
-(void)handleAFNEF1:(NSDictionary*)dcs{
    
    [self saveAFNEWithType:1 withDic:dcs];
}

-(void)saveAFNEWithType:(NSInteger)type withDic:(NSDictionary*)dcs{
    
    NSString* eventType = [NSString stringWithFormat:@"F%d",type];
    NSDictionary* dic = [dcs valueForKey:eventType];
    [dic.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        EventData *eventData;
        
        if (![obj isEqualToString:@"测量点号"]) {
            
            eventData = [NSEntityDescription insertNewObjectForEntityForName:@"EventData"
                                                      inManagedObjectContext:self.context];
            NSString* eventDesc = [dic valueForKey:obj];
            NSArray* array = [ eventDesc componentsSeparatedByString:@"@@"];
            
            
            
            [eventData setValue:[array objectAtIndex:0] forKey:@"evName"];
            [eventData setValue:[array objectAtIndex:1] forKey:@"evTime"];
            [eventData setValue:[array objectAtIndex:2] forKey:@"evStartEndFlag"];
            [eventData setValue:[array objectAtIndex:3] forKey:@"evType"];
            [eventData setValue:[array objectAtIndex:4] forKey:@"evDetail"];
            [eventData setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"测量点号"] integerValue]]
                         forKey:@"evNo"];
            
        }
        [self.context save:nil];
        [self.contextParent performBlock:^{
            [self.contextParent save:nil];
        }];
    }];
}

-(void)handleAFNEF2:(NSDictionary*)dcs{
    [self saveAFNEWithType:2 withDic:dcs];
}

#pragma mark - 二类数据存储
//日冻结正向有／无功最大需量及发生时间 F3－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF3:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F3"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F3"] valueForKey:@"日数据时标"]];
    
    HistoryData_PowerNeeds *hdPowerNeeds;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:3
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerNeeds = [self getEntityFromDBwithFnCode:3
                                            withPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdPowerNeeds = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerNeeds"
                                                     inManagedObjectContext:self.context];
        
        //测量点号
        [hdPowerNeeds setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F3"] valueForKey:@"测量点号"]
                                                            integerValue]]
                        forKey:@"hdMeasureNo"];
        //数据时标
        [hdPowerNeeds setValue:[self getDataTime:[[dcs valueForKey:@"F3"] valueForKey:@"日数据时标"]]
                        forKey:@"hdDataTime"];
        //日月数据类型
        [hdPowerNeeds setValue:[NSNumber numberWithInteger:1]
                        forKey:@"hdDataType"];
    }
    
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:1] forKey:@"hdF3Filled"];
    
    //正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"正向有功总最大需量"]doubleValue]] forKey:@"hdPosADMaxZ"];
    //正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F3"] valueForKey:@"正向有功总最大需量发生时间"]]]
                    forKey:@"hdPosADMaxZTm"];
    
    //费率1正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"费率1正向有功最大需量"] doubleValue]]
                    forKey:@"hdPosADMax1"];
    //费率1正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F3"] valueForKey:@"费率1正向有功最大需量发生时间"]]]
                    forKey:@"hdPosADMax1Tm"];
    //费率2正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"费率2正向有功最大需量"] doubleValue]]
                    forKey:@"hdPosADMax2"];
    //费率2正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F3"] valueForKey:@"费率2正向有功最大需量发生时间"]]]
                    forKey:@"hdPosADMax2Tm"];
    
    //费率3正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"费率3正向有功最大需量"] doubleValue]]
                    forKey:@"hdPosADMax3"];
    //费率3正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F3"] valueForKey:@"费率3正向有功最大需量发生时间"]]]
                    forKey:@"hdPosADMax3Tm"];
    
    //费率4正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"费率4正向有功最大需量"] doubleValue]]
                    forKey:@"hdPosADMax4"];
    //费率4正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F3"] valueForKey:@"费率4正向有功最大需量发生时间"]]]
                    forKey:@"hdPosADMax4Tm"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}


//日冻结总及分相最大需量及发生时间 F26－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF26:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F26"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F26"] valueForKey:@"日数据时标"]];
    
    HistoryData_PowerNeeds *hdPowerNeeds;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:26
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerNeeds = [self getEntityFromDBwithFnCode:26
                                            withPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
        
    } else {
        
        //不存在新建
        hdPowerNeeds = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerNeeds"
                                                     inManagedObjectContext:self.context];
        
        //测量点号
        [hdPowerNeeds setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F26"] valueForKey:@"测量点号"]
                                                            integerValue]]
                        forKey:@"hdMeasureNo"];
        //数据时标
        [hdPowerNeeds setValue:[self getDataTime:[[dcs valueForKey:@"F26"] valueForKey:@"日数据时标"]]
                        forKey:@"hdDataTime"];
        //日月数据类型
        [hdPowerNeeds setValue:[NSNumber numberWithInteger:1]
                        forKey:@"hdDataType"];
    }
    
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:1] forKey:@"hdF26Filled"];
    
    //三相总有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
                                                        valueForKey:@"三相总有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxZ"];
    //三相总有功最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F26"] valueForKey:@"三相总有功最大需量发生时间"]]]
                    forKey:@"hdADMaxZTm"];
    
    //A相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
                                                        valueForKey:@"A相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxA"];
    //A相有功最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F26"] valueForKey:@"A相有功最大需量发生时间"]]]
                    forKey:@"hdADMaxATm"];
    //B相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
                                                        valueForKey:@"B相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxB"];
    
    //B相有功最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F26"] valueForKey:@"B相有功最大需量发生时间"]]]
                    forKey:@"hdADMaxBTm"];
    //C相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
                                                        valueForKey:@"C相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxC"];
    //C相有功最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString1:dataTime withDateString2:[[dcs valueForKey:@"F26"] valueForKey:@"C相有功最大需量发生时间"]]]
                    forKey:@"hdADMaxCTm"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//月冻结总及分相有功最大需量及发生时间 F34－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF34:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F34"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F34"] valueForKey:@"月数据时标"]];
    
    HistoryData_PowerNeeds *hdPowerNeeds;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:34
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerNeeds = [self getEntityFromDBwithFnCode:34
                                            withPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDMONTHDATA];
    } else {
        
        //不存在新建
        hdPowerNeeds = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerNeeds"
                                                     inManagedObjectContext:self.context];
        
        //测量点号
        [hdPowerNeeds setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F34"] valueForKey:@"测量点号"]
                                                            integerValue]]
                        forKey:@"hdMeasureNo"];
        //数据时标
        [hdPowerNeeds setValue:[self getDataTime1:[[dcs valueForKey:@"F34"] valueForKey:@"月数据时标"]]
                        forKey:@"hdDataTime"];
        //日月数据类型
        [hdPowerNeeds setValue:[NSNumber numberWithInteger:2]
                        forKey:@"hdDataType"];
    }
    
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:1] forKey:@"hdF34Filled"];
    
    //三相总有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
                                                        valueForKey:@"三相总有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxZ"];
    //三相总有功最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString2:dataTime withDateString2:[[dcs valueForKey:@"F34"] valueForKey:@"三相总有功最大需量发生时间"]]]
                    forKey:@"hdADMaxZTm"];
    
    //A相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
                                                        valueForKey:@"A相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxA"];
    //A相有功最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString2:dataTime withDateString2:[[dcs valueForKey:@"F34"] valueForKey:@"A相有功最大需量发生时间"]]]
                    forKey:@"hdADMaxATm"];
    //B相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
                                                        valueForKey:@"B相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxB"];
    //B相有功最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString2:dataTime withDateString2:[[dcs valueForKey:@"F34"] valueForKey:@"B相有功最大需量发生时间"]]]
                    forKey:@"hdADMaxBTm"];
    //C相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
                                                        valueForKey:@"C相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxC"];
    //C相有功最大需量发生时间
    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[self getDateIntervalWithDateString2:dataTime withDateString2:[[dcs valueForKey:@"F34"] valueForKey:@"C相有功最大需量发生时间"]]]
                    forKey:@"hdADMaxCTm"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//日冻结正向有功电能量 F5 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF5:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F5"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F5"] valueForKey:@"数据时标"]];
    
    
    HistoryData_PowerValue *hdPowerValue;
    
    //是否已存在
    //是否已存在
    if ([self checkIfDataIsExistwithFn:5
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerValue = [self getEntityFromDBwithFnCode:5
                                            withPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
                                                     inManagedObjectContext:self.context];
        
        //测量点号
        [hdPowerValue setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F5"] valueForKey:@"测量点号"]
                                                            integerValue]]
                        forKey:@"hdMeasureNo"];
        //数据时标
        [hdPowerValue setValue:[self getDataTime:[[dcs valueForKey:@"F5"] valueForKey:@"数据时标"]]
                        forKey:@"hdDataTime"];
        //日月数据类型
        [hdPowerValue setValue:[NSNumber numberWithInteger:1]
                        forKey:@"hdDataType"];
    }
    
    
    
    [hdPowerValue setValue:[NSNumber numberWithInteger:1] forKey:@"hdF5Filled"];
    
    //日正向有功总电能量
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F5"] valueForKey:@"日正向有功总电能量"] doubleValue]]
                    forKey:@"hdPowerValuePosAEZ"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}

//日冻结正向无功点能量 F6－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF6:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F6"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F6"] valueForKey:@"数据时标"]];
    
    
    HistoryData_PowerValue *hdPowerValue;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:6
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerValue = [self getEntityFromDBwithFnCode:6
                                            withPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
                                                     inManagedObjectContext:self.context];
        
        //测量点号
        [hdPowerValue setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F6"] valueForKey:@"测量点号"]
                                                            integerValue]]
                        forKey:@"hdMeasureNo"];
        //数据时标
        [hdPowerValue setValue:[self getDataTime:[[dcs valueForKey:@"F6"] valueForKey:@"数据时标"]]
                        forKey:@"hdDataTime"];
        //日月数据类型
        [hdPowerValue setValue:[NSNumber numberWithInteger:1]
                        forKey:@"hdDataType"];
    }
    
    
    
    [hdPowerValue setValue:[NSNumber numberWithInteger:1] forKey:@"hdF6Filled"];
    
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F6"] valueForKey:@"日正向无功总电能量"] doubleValue]]
                    forKey:@"hdPowerValuePosREZ"];
    
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}

//日冻结铜损铁损有功电能示值 F45 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF45:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F45"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F45"] valueForKey:@"日数据时标"]];
    
    
    HistoryData_PowerValue *hdPowerValue;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:45
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerValue = [self getEntityFromDBwithFnCode:45
                                            withPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
                                                     inManagedObjectContext:self.context];
        
        //测量点号
        [hdPowerValue setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F45"] valueForKey:@"测量点号"]
                                                            integerValue]]
                        forKey:@"hdMeasureNo"];
        //数据时标
        [hdPowerValue setValue:[self getDataTime:[[dcs valueForKey:@"F45"] valueForKey:@"日数据时标"]]
                        forKey:@"hdDataTime"];
        //日月数据类型
        [hdPowerValue setValue:[NSNumber numberWithInteger:1]
                        forKey:@"hdDataType"];
    }
    
    
    
    [hdPowerValue setValue:[NSNumber numberWithInteger:1] forKey:@"hdF45Filled"];
    
    //铜损总电能
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F45"]
                                                        valueForKey:@"铜损有功总电能示值"]
                                                       doubleValue]]
                    forKey:@"hdCopperLossAEValueZ"];
    
    //铁损总电能
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F45"]
                                                        valueForKey:@"铁损有功总电能示值"]
                                                       doubleValue]]
                    forKey:@"hdIronLossAEValueZ"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}


-(void)handleAFNDF21:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F21"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F21"] valueForKey:@"数据时标"]];
    
    
    HistoryData_PowerValue *hdPowerValue;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:21
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerValue = [self getEntityFromDBwithFnCode:21
                                            withPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDMONTHDATA];
    } else {
        
        //不存在新建
        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
                                                     inManagedObjectContext:self.context];
        
        //测量点号
        [hdPowerValue setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F21"] valueForKey:@"测量点号"]
                                                            integerValue]]
                        forKey:@"hdMeasureNo"];
        //数据时标
        [hdPowerValue setValue:[self getDataTime1:[[dcs valueForKey:@"F21"] valueForKey:@"数据时标"]]
                        forKey:@"hdDataTime"];
        //日月数据类型
        [hdPowerValue setValue:[NSNumber numberWithInteger:2]
                        forKey:@"hdDataType"];
    }
    
    [hdPowerValue setValue:[NSNumber numberWithInteger:1] forKey:@"hdF21Filled"];
    
    //月正向有功总电能量
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F21"] valueForKey:@"月正向有功总电能量"] doubleValue]]
                    forKey:@"hdPowerValuePosAEZ"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//月冻结铜损铁损有功电能示值 F46 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF46:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F46"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F46"] valueForKey:@"月数据时标"]];
    
    HistoryData_PowerValue *hdPowerValue;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:46
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerValue = [self getEntityFromDBwithFnCode:46
                                            withPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDMONTHDATA];
    } else {
        
        //不存在新建
        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
                                                     inManagedObjectContext:self.context];
        
        //测量点号
        [hdPowerValue setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F46"] valueForKey:@"测量点号"]
                                                            integerValue]]
                        forKey:@"hdMeasureNo"];
        //数据时标
        [hdPowerValue setValue:[self getDataTime1:[[dcs valueForKey:@"F46"] valueForKey:@"月数据时标"]]
                        forKey:@"hdDataTime"];
        //日月数据类型
        [hdPowerValue setValue:[NSNumber numberWithInteger:2]
                        forKey:@"hdDataType"];
    }
    
    
    
    [hdPowerValue setValue:[NSNumber numberWithInteger:1] forKey:@"hdF46Filled"];
    
    //铜损总电能
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F46"]
                                                        valueForKey:@"铜损有功总电能示值"]
                                                       doubleValue]]
                    forKey:@"hdCopperLossAEValueZ"];
    
    //铁损总电能
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F46"]
                                                        valueForKey:@"铁损有功总电能示值"]
                                                       doubleValue]]
                    forKey:@"hdIronLossAEValueZ"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}

//日冻结总及分相最大有功功率及发生时间 有功功率为零时间 F25－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF25:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F25"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F25"] valueForKey:@"日数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:25
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithFnCode:25
                                                 withPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"测量点号"]
                                                                 integerValue]]
                             forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointSta setValue:[self getDataTime:[[dcs valueForKey:@"F25"] valueForKey:@"日数据时标"]]
                             forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1]
                             forKey:@"hdDataType"];
    }
    
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1] forKey:@"hdF25Filled"];
    
    //三相总最大有功功率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F25"] valueForKey:@"三相总最大有功功率"] doubleValue]]
                         forKey:@"hdAPMaxZ"];
    //三相总最大有功功率发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F25"] valueForKey:@"三相总最大有功功率发生时间"]
                         forKey:@"hdAPMaxZTm"];
    //A相最大有功功率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F25"] valueForKey:@"A相最大有功功率"] doubleValue]]
                         forKey:@"hdAPMaxA"];
    //A相最大有功功率发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F25"] valueForKey:@"A相最大有功功率发生时间"]
                         forKey:@"hdAPMaxATm"];
    //B相最大有功功率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F25"] valueForKey:@"B相最大有功功率"] doubleValue]]
                         forKey:@"hdAPMaxB"];
    //B相最大有功功率发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F25"] valueForKey:@"B相最大有功功率发生时间"]
                         forKey:@"hdAPMaxBTm"];
    
    //C相最大有功功率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F25"] valueForKey:@"C相最大有功功率"] doubleValue]]
                         forKey:@"hdAPMaxC"];
    //C相最大有功功率发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F25"] valueForKey:@"C相最大有功功率发生时间"]
                         forKey:@"hdAPMaxCTm"];
    
    //三相总有功功率为零时间
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"三相总有功功率为零时间"] integerValue]]
                         forKey:@"hdAPZeroAccTmZ"];
    //A相有功功率为零时间
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"A相有功功率为零时间"] integerValue]]
                         forKey:@"hdAPZeroAccTmA"];
    //B相有功功率为零时间
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"B相有功功率为零时间"] integerValue]]
                         forKey:@"hdAPZeroAccTmB"];
    //C相有功功率为零时间
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"C相有功功率为零时间"] integerValue]]
                         forKey:@"hdAPZeroAccTmC"];
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}

//月冻结总及分相最大有功功率及发生时间 有功功率为零时间 F33－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF33:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F33"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F33"] valueForKey:@"月数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:33
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithFnCode:33
                                                 withPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDMONTHDATA];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"测量点号"]
                                                                 integerValue]]
                             forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointSta setValue:[self getDataTime1:[[dcs valueForKey:@"F33"] valueForKey:@"月数据时标"]]
                             forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:2]
                             forKey:@"hdDataType"];
    }
    
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1] forKey:@"hdF33Filled"];
    
    
    //三相总最大有功功率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F33"] valueForKey:@"三相总最大有功功率"] doubleValue]]
                         forKey:@"hdAPMaxZ"];
    //三相总最大有功功率发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F33"] valueForKey:@"三相总最大有功功率发生时间"]
                         forKey:@"hdAPMaxZTm"];
    //A相最大有功功率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F33"] valueForKey:@"A相最大有功功率"] doubleValue]]
                         forKey:@"hdAPMaxA"];
    //A相最大有功功率发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F33"] valueForKey:@"A相最大有功功率发生时间"]
                         forKey:@"hdAPMaxATm"];
    //B相最大有功功率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F33"] valueForKey:@"B相最大有功功率"] doubleValue]]
                         forKey:@"hdAPMaxB"];
    //B相最大有功功率发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F33"] valueForKey:@"B相最大有功功率发生时间"]
                         forKey:@"hdAPMaxBTm"];
    
    //C相最大有功功率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F33"] valueForKey:@"C相最大有功功率"] doubleValue]]
                         forKey:@"hdAPMaxC"];
    //C相最大有功功率发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F33"] valueForKey:@"C相最大有功功率发生时间"]
                         forKey:@"hdAPMaxCTm"];
    
    //三相总有功功率为零时间
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"三相总有功功率为零时间"] integerValue]]
                         forKey:@"hdAPZeroAccTmZ"];
    //A相有功功率为零时间
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"A相有功功率为零时间"] integerValue]]
                         forKey:@"hdAPZeroAccTmA"];
    //B相有功功率为零时间
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"B相有功功率为零时间"] integerValue]]
                         forKey:@"hdAPZeroAccTmB"];
    //C相有功功率为零时间
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"C相有功功率为零时间"] integerValue]]
                         forKey:@"hdAPZeroAccTmC"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}



//日冻结电压统计数据 F27－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF27:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F27"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F27"] valueForKey:@"日数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:27
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithFnCode:27
                                                 withPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F27"] valueForKey:@"测量点号"]
                                                                 integerValue]]
                             forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointSta setValue:[self getDataTime:[[dcs valueForKey:@"F27"] valueForKey:@"日数据时标"]]
                             forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1]
                             forKey:@"hdDataType"];
    }
    
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1] forKey:@"hdF27Filled"];
    
    //A相电压越上上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压越上上限日累计时间"] doubleValue]]
                         forKey:@"hdAVoltOverHHAccTm"];
    //A相电压越下下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压越下下限日累计时间"] doubleValue]]
                         forKey:@"hdAVoltDownLLAccTm"];
    //A相电压越上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压越上限日累计时间"] doubleValue]]
                         forKey:@"hdAVoltOverHAccTm"];
    //A相电压越下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压越下限日累计时间"] doubleValue]]
                         forKey:@"hdAVoltDownLAccTm"];
    //A相电压合格日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压合格日累计时间"] doubleValue]]
                         forKey:@"hdAVoltRegularAccTm"];
    
    
    
    //B相电压越上上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压越上上限日累计时间"] doubleValue]]
                         forKey:@"hdBVoltOverHHAccTm"];
    //B相电压越下下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压越下下限日累计时间"] doubleValue]]
                         forKey:@"hdBVoltDownLLAccTm"];
    //B相电压越上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压越上限日累计时间"] doubleValue]]
                         forKey:@"hdBVoltOverHAccTm"];
    //B相电压越下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压越下限日累计时间"] doubleValue]]
                         forKey:@"hdBVoltDownLAccTm"];
    //B相电压合格日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压合格日累计时间"] doubleValue]]
                         forKey:@"hdBVoltRegularAccTm"];
    
    
    //C相电压越上上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压越上上限日累计时间"] doubleValue]]
                         forKey:@"hdCVoltOverHHAccTm"];
    //C相电压越下下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压越下下限日累计时间"] doubleValue]]
                         forKey:@"hdCVoltDownLLAccTm"];
    //C相电压越上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压越上限日累计时间"] doubleValue]]
                         forKey:@"hdCVoltOverHAccTm"];
    //C相电压越下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压越下限日累计时间"] doubleValue]]
                         forKey:@"hdCVoltDownLAccTm"];
    //C相电压合格日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压合格日累计时间"] doubleValue]]
                         forKey:@"hdCVoltRegularAccTm"];
    //A相电压最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压最大值"] doubleValue]]
                         forKey:@"hdAVoltMax"];
    //A相电压最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F27"] valueForKey:@"A相电压最大值发生时间"]
                         forKey:@"hdAVoltMaxTm"];
    //A相电压最小值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压最小值"] doubleValue]]
                         forKey:@"hdAVoltMin"];
    //A相电压最小值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F27"] valueForKey:@"A相电压最小值发生时间"]
                         forKey:@"hdAVoltMinTm"];
    
    //B相电压最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压最大值"] doubleValue]]
                         forKey:@"hdBVoltMax"];
    //B相电压最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F27"] valueForKey:@"B相电压最大值发生时间"]
                         forKey:@"hdBVoltMaxTm"];
    //B相电压最小值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压最小值"] doubleValue]]
                         forKey:@"hdBVoltMin"];
    //B相电压最小值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F27"] valueForKey:@"B相电压最小值发生时间"]
                         forKey:@"hdBVoltMinTm"];
    
    //C相电压最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压最大值"] doubleValue]]
                         forKey:@"hdCVoltMax"];
    //C相电压最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F27"] valueForKey:@"C相电压最大值发生时间"]
                         forKey:@"hdCVoltMaxTm"];
    //C相电压最小值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压最小值"] doubleValue]]
                         forKey:@"hdCVoltMin"];
    //C相电压最小值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F27"] valueForKey:@"C相电压最小值发生时间"]
                         forKey:@"hdCVoltMinTm"];
    
    //A相平均电压
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相平均电压"] doubleValue]]
                         forKey:@"hdAVoltAvg"];
    //B相平均电压
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相平均电压"] doubleValue]]
                         forKey:@"hdBVoltAvg"];
    //C相平均电压
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相平均电压"] doubleValue]]
                         forKey:@"hdCVoltAvg"];
    
    //A相电压越上限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压越上限率"] doubleValue]]
                         forKey:@"hdAVoltOverHRate"];
    //A相电压越下限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压越下限率"] doubleValue]]
                         forKey:@"hdAVoltDownLRate"];
    //A相电压越合格率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"A相电压合格率"] doubleValue]]
                         forKey:@"hdAVoltRegularRate"];
    
    //B相电压越上限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压越上限率"] doubleValue]]
                         forKey:@"hdBVoltOverHRate"];
    //B相电压越下限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压越下限率"] doubleValue]]
                         forKey:@"hdBVoltDownLRate"];
    //B相电压越合格率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"B相电压合格率"] doubleValue]]
                         forKey:@"hdBVoltRegularRate"];
    
    //C相电压越上限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压越上限率"] doubleValue]]
                         forKey:@"hdCVoltOverHRate"];
    //C相电压越下限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压越下限率"] doubleValue]]
                         forKey:@"hdCVoltDownLRate"];
    //C相电压越合格率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F27"] valueForKey:@"C相电压合格率"] doubleValue]]
                         forKey:@"hdCVoltRegularRate"];
    
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}

//月冻结月电压统计数据  F35－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF35:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F35"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F35"] valueForKey:@"月数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:35
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithFnCode:35
                                                 withPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDMONTHDATA];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F35"] valueForKey:@"测量点号"]
                                                                 integerValue]]
                             forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointSta setValue:[self getDataTime1:[[dcs valueForKey:@"F35"] valueForKey:@"月数据时标"]]
                             forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:2]
                             forKey:@"hdDataType"];
    }
    
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1] forKey:@"hdF35Filled"];
    
    //A相电压越上上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压越上上限月累计时间"] doubleValue]]
                         forKey:@"hdAVoltOverHHAccTm"];
    //A相电压越下下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压越下下限月累计时间"] doubleValue]]
                         forKey:@"hdAVoltDownLLAccTm"];
    //A相电压越上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压越上限月累计时间"] doubleValue]]
                         forKey:@"hdAVoltOverHAccTm"];
    //A相电压越下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压越下限日累计时间"] doubleValue]]
                         forKey:@"hdAVoltDownLAccTm"];
    //A相电压合格日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压合格月累计时间"] doubleValue]]
                         forKey:@"hdAVoltRegularAccTm"];
    
    
    
    //B相电压越上上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压越上上限月累计时间"] doubleValue]]
                         forKey:@"hdBVoltOverHHAccTm"];
    //B相电压越下下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压越下下限月累计时间"] doubleValue]]
                         forKey:@"hdBVoltDownLLAccTm"];
    //B相电压越上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压越上限月累计时间"] doubleValue]]
                         forKey:@"hdBVoltOverHAccTm"];
    //B相电压越下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压越下限月累计时间"] doubleValue]]
                         forKey:@"hdBVoltDownLAccTm"];
    //B相电压合格日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压合格月累计时间"] doubleValue]]
                         forKey:@"hdBVoltRegularAccTm"];
    
    
    //C相电压越上上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压越上上限月累计时间"] doubleValue]]
                         forKey:@"hdCVoltOverHHAccTm"];
    //C相电压越下下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压越下下限月累计时间"] doubleValue]]
                         forKey:@"hdCVoltDownLLAccTm"];
    //C相电压越上限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压越上限月累计时间"] doubleValue]]
                         forKey:@"hdCVoltOverHAccTm"];
    //C相电压越下限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压越下限月累计时间"] doubleValue]]
                         forKey:@"hdCVoltDownLAccTm"];
    //C相电压合格日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压合格月累计时间"] doubleValue]]
                         forKey:@"hdCVoltRegularAccTm"];
    //A相电压最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压最大值"] doubleValue]]
                         forKey:@"hdAVoltMax"];
    //A相电压最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F35"] valueForKey:@"A相电压最大值发生时间"]
                         forKey:@"hdAVoltMaxTm"];
    //A相电压最小值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压最小值"] doubleValue]]
                         forKey:@"hdAVoltMin"];
    //A相电压最小值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F35"] valueForKey:@"A相电压最小值发生时间"]
                         forKey:@"hdAVoltMinTm"];
    
    //B相电压最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压最大值"] doubleValue]]
                         forKey:@"hdBVoltMax"];
    //B相电压最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F35"] valueForKey:@"B相电压最大值发生时间"]
                         forKey:@"hdBVoltMaxTm"];
    //B相电压最小值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压最小值"] doubleValue]]
                         forKey:@"hdBVoltMin"];
    //B相电压最小值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F35"] valueForKey:@"B相电压最小值发生时间"]
                         forKey:@"hdBVoltMinTm"];
    
    //C相电压最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压最大值"] doubleValue]]
                         forKey:@"hdCVoltMax"];
    //C相电压最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F35"] valueForKey:@"C相电压最大值发生时间"]
                         forKey:@"hdCVoltMaxTm"];
    //C相电压最小值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压最小值"] doubleValue]]
                         forKey:@"hdCVoltMin"];
    //C相电压最小值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F35"] valueForKey:@"C相电压最小值发生时间"]
                         forKey:@"hdCVoltMinTm"];
    
    //A相平均电压
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相平均电压"] doubleValue]]
                         forKey:@"hdAVoltAvg"];
    //B相平均电压
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相平均电压"] doubleValue]]
                         forKey:@"hdBVoltAvg"];
    //C相平均电压
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相平均电压"] doubleValue]]
                         forKey:@"hdCVoltAvg"];
    
    //A相电压越上限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压越上限率"] doubleValue]]
                         forKey:@"hdAVoltOverHRate"];
    //A相电压越下限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压越下限率"] doubleValue]]
                         forKey:@"hdAVoltDownLRate"];
    //A相电压越合格率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"A相电压合格率"] doubleValue]]
                         forKey:@"hdAVoltRegularRate"];
    
    //B相电压越上限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压越上限率"] doubleValue]]
                         forKey:@"hdBVoltOverHRate"];
    //B相电压越下限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压越下限率"] doubleValue]]
                         forKey:@"hdBVoltDownLRate"];
    //B相电压越合格率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"B相电压合格率"] doubleValue]]
                         forKey:@"hdBVoltRegularRate"];
    
    //C相电压越上限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压越上限率"] doubleValue]]
                         forKey:@"hdCVoltOverHRate"];
    //C相电压越下限率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压越下限率"] doubleValue]]
                         forKey:@"hdCVoltDownLRate"];
    //C相电压越合格率
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F35"] valueForKey:@"C相电压合格率"] doubleValue]]
                         forKey:@"hdCVoltRegularRate"];
    
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}


//日冻结日不平衡度越限累计时间 F28－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF28:(NSDictionary*)dcs{
    
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F28"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F28"] valueForKey:@"日数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:28
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithFnCode:28
                                                 withPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F28"] valueForKey:@"测量点号"]
                                                                 integerValue]]
                             forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointSta setValue:[self getDataTime:[[dcs valueForKey:@"F28"] valueForKey:@"日数据时标"]]
                             forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1]
                             forKey:@"hdDataType"];
    }
    
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1] forKey:@"hdF28Filled"];
    
    //电流不平衡度越限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F28"] valueForKey:@"电流不平衡度越限日累计时间"] doubleValue]]
                         forKey:@"hdCurUnbalOLmtAccTm"];
    //电压不平衡度越限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F28"] valueForKey:@"电压不平衡度越限日累计时间"] doubleValue]]
                         forKey:@"hdVoltUnbalOLmtAccTm"];
    
    //电流不平衡最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F28"] valueForKey:@"电流不平衡最大值"] doubleValue]]
                         forKey:@"hdCurUnbalMax"];
    //电流不平衡最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F28"] valueForKey:@"电流不平衡最大值发生时间"]
                         forKey:@"hdCurUnbalMaxTm"];
    //电压不平衡最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F28"] valueForKey:@"电压不平衡最大值"] doubleValue]]
                         forKey:@"hdVoltUnbalMax"];
    //电压不平衡最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F28"] valueForKey:@"电压不平衡最大值发生时间"]
                         forKey:@"hdVoltUnbalMaxTm"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}
//月冻结月不平衡度越限累计时间  F36－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF36:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F36"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F36"] valueForKey:@"月数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:36
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithFnCode:36
                                                 withPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDMONTHDATA];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F36"] valueForKey:@"测量点号"]
                                                                 integerValue]]
                             forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointSta setValue:[self getDataTime1:[[dcs valueForKey:@"F36"] valueForKey:@"月数据时标"]]
                             forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:2]
                             forKey:@"hdDataType"];
    }
    
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1] forKey:@"hdF36Filled"];
    
    //电流不平衡度越限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F36"] valueForKey:@"电流不平衡度越限月累计时间"] doubleValue]]
                         forKey:@"hdCurUnbalOLmtAccTm"];
    //电压不平衡度越限日累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F36"] valueForKey:@"电压不平衡度越限月累计时间"] doubleValue]]
                         forKey:@"hdVoltUnbalOLmtAccTm"];
    
    //电流不平衡最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F36"] valueForKey:@"电流不平衡最大值"] doubleValue]]
                         forKey:@"hdCurUnbalMax"];
    //电流不平衡最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F36"] valueForKey:@"电流不平衡最大值发生时间"]
                         forKey:@"hdCurUnbalMaxTm"];
    //电压不平衡最大值
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F36"] valueForKey:@"电压不平衡最大值"] doubleValue]]
                         forKey:@"hdVoltUnbalMax"];
    //电压不平衡最大值发生时间
    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F36"] valueForKey:@"电压不平衡最大值发生时间"]
                         forKey:@"hdVoltUnbalMaxTm"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}



//日冻结日功率因数区段累计时间 F43－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF43:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F43"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F43"] valueForKey:@"日数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:43
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithFnCode:43
                                                 withPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F43"] valueForKey:@"测量点号"]
                                                                 integerValue]]
                             forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointSta setValue:[self getDataTime:[[dcs valueForKey:@"F43"] valueForKey:@"日数据时标"]]
                             forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1]
                             forKey:@"hdDataType"];
    }
    
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1] forKey:@"hdF43Filled"];
    
    //区段1 累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F43"] valueForKey:@"区段1累计时间（功率因数＜定值1）"] doubleValue]]
                         forKey:@"hdPfSector1AccTm"];
    //区段2 累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F43"] valueForKey:@"区段2累计时间（定值1≤功率因数＜定值2）"] doubleValue]]
                         forKey:@"hdPfSector2AccTm"];
    //区段3 累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F43"] valueForKey:@"区段3累计时间（功率因数≥定值2）"] doubleValue]]
                         forKey:@"hdPfSector3AccTm"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//月冻结月功率因数区段累计时间 F44－－－－－－－－－－－－－－－－－－－－－－－－－
-(void)handleAFNDF44:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F44"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F44"] valueForKey:@"月数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:44
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithFnCode:44
                                                 withPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDMONTHDATA];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F44"] valueForKey:@"测量点号"]
                                                                 integerValue]]
                             forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointSta setValue:[self getDataTime1:[[dcs valueForKey:@"F44"] valueForKey:@"月数据时标"]]
                             forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointSta setValue:[NSNumber numberWithInteger:2]
                             forKey:@"hdDataType"];
    }
    
    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1] forKey:@"hdF44Filled"];
    
    //区段1 累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F44"] valueForKey:@"区段1累计时间（功率因数＜定值1）"] doubleValue]]
                         forKey:@"hdPfSector1AccTm"];
    //区段2 累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F44"] valueForKey:@"区段2累计时间（定值1≤功率因数＜定值2）"] doubleValue]]
                         forKey:@"hdPfSector2AccTm"];
    //区段3 累计时间
    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F44"] valueForKey:@"区段3累计时间（功率因数≥定值2）"] doubleValue]]
                         forKey:@"hdPfSector3AccTm"];
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//日冻结测量点A相谐波越限日统计数据
-(void)handleAFNDF121:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F121"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F121"] valueForKey:@"日数据时标"]];
    
    HistoryData_MeasurePoint_Sta_Harmonic *hdMeasurePointStaHar;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:121
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointStaHar = [self getEntityFromDBwithFnCode:121
                                                    withPnCode:pnCode
                                               withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdMeasurePointStaHar = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta_Harmonic"
                                                             inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F121"] valueForKey:@"测量点号"]
                                                                    integerValue]]
                                forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointStaHar setValue:[self getDataTime:[[dcs valueForKey:@"F121"] valueForKey:@"日数据时标"]]
                                forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:1]
                                forKey:@"hdDataType"];
        
        //类型 A B C
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:121]
                                forKey:@"hdPhaseType"];
    }
    
    //A相总畸变电压含有率越限日累计时间
    [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F121"] valueForKey:@"A相总畸变电压含有率越限日累计时间"] doubleValue]]
                            forKey:@"hdHarmoVoltOverLimitZTm"];
    
    NSString *keyDesc;
    NSString *keyValue;
    
    for(int i = 2;i<=19;i++){
        keyDesc = [NSString stringWithFormat:@"A相%d次谐波电压含有率越限日累计时间",i];
        keyValue = [NSString stringWithFormat:@"hdHarmoVoltOverLimit%dTm",i];
        
        [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F121"] valueForKey:keyDesc] doubleValue]]
                                forKey:keyValue];
        
    }
    
    //A相总畸变电流含有率越限日累计时间
    [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F121"] valueForKey:@"A相总畸变电流含有率越限日累计时间"] doubleValue]]
                            forKey:@"hdHarmoCurOverLimitZTm"];
    
    for(int i = 2;i<=19;i++){
        keyDesc = [NSString stringWithFormat:@"A相%d次谐波电流含有率越限日累计时间",i];
        keyValue = [NSString stringWithFormat:@"hdHarmoCurOverLimit%dTm",i];
        
        [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F121"] valueForKey:keyDesc] doubleValue]]
                                forKey:keyValue];
    }
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}

//日冻结测量点B相谐波越限日统计数据
-(void)handleAFNDF122:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F122"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F122"] valueForKey:@"日数据时标"]];
    
    HistoryData_MeasurePoint_Sta_Harmonic *hdMeasurePointStaHar;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:122
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointStaHar = [self getEntityFromDBwithFnCode:122
                                                    withPnCode:pnCode
                                               withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdMeasurePointStaHar = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta_Harmonic"
                                                             inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F122"] valueForKey:@"测量点号"]
                                                                    integerValue]]
                                forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointStaHar setValue:[self getDataTime:[[dcs valueForKey:@"F122"] valueForKey:@"日数据时标"]]
                                forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:1]
                                forKey:@"hdDataType"];
        
        //类型 A B C
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:122]
                                forKey:@"hdPhaseType"];
    }
    
    //B相总畸变电压含有率越限日累计时间
    [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F122"] valueForKey:@"B相总畸变电压含有率越限日累计时间"] doubleValue]]
                            forKey:@"hdHarmoVoltOverLimitZTm"];
    
    NSString *keyDesc;
    NSString *keyValue;
    
    for(int i = 2;i<=19;i++){
        keyDesc = [NSString stringWithFormat:@"B相%d次谐波电压含有率越限日累计时间",i];
        keyValue = [NSString stringWithFormat:@"hdHarmoVoltOverLimit%dTm",i];
        
        [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F122"] valueForKey:keyDesc] doubleValue]]
                                forKey:keyValue];
        
    }
    
    //B相总畸变电流含有率越限日累计时间
    [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F122"] valueForKey:@"B相总畸变电流含有率越限日累计时间"] doubleValue]]
                            forKey:@"hdHarmoCurOverLimitZTm"];
    
    for(int i = 2;i<=19;i++){
        keyDesc = [NSString stringWithFormat:@"B相%d次谐波电流含有率越限日累计时间",i];
        keyValue = [NSString stringWithFormat:@"hdHarmoCurOverLimit%dTm",i];
        
        [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F122"] valueForKey:keyDesc] doubleValue]]
                                forKey:keyValue];
    }
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}

//日冻结测量点C相谐波越限日统计数据
-(void)handleAFNDF123:(NSDictionary*)dcs{
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F123"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F123"] valueForKey:@"日数据时标"]];
    
    HistoryData_MeasurePoint_Sta_Harmonic *hdMeasurePointStaHar;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:123
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdMeasurePointStaHar = [self getEntityFromDBwithFnCode:123
                                                    withPnCode:pnCode
                                               withRequestDate:[self getDateFromFormatString:dataTime] withCheckType:AFNDDAYDATA];
    } else {
        
        //不存在新建
        hdMeasurePointStaHar = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta_Harmonic"
                                                             inManagedObjectContext:self.context];
        
        //测量点号
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F123"] valueForKey:@"测量点号"]
                                                                    integerValue]]
                                forKey:@"hdMeasureNo"];
        //数据时标
        [hdMeasurePointStaHar setValue:[self getDataTime:[[dcs valueForKey:@"F123"] valueForKey:@"日数据时标"]]
                                forKey:@"hdDataTime"];
        //日月数据类型
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:1]
                                forKey:@"hdDataType"];
        
        //类型 A B C
        [hdMeasurePointStaHar setValue:[NSNumber numberWithInteger:123]
                                forKey:@"hdPhaseType"];
    }
    
    //B相总畸变电压含有率越限日累计时间
    [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F123"] valueForKey:@"C相总畸变电压含有率越限日累计时间"] doubleValue]]
                            forKey:@"hdHarmoVoltOverLimitZTm"];
    
    NSString *keyDesc;
    NSString *keyValue;
    
    for(int i = 2;i<=19;i++){
        keyDesc = [NSString stringWithFormat:@"C相%d次谐波电压含有率越限日累计时间",i];
        keyValue = [NSString stringWithFormat:@"hdHarmoVoltOverLimit%dTm",i];
        
        [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F123"] valueForKey:keyDesc] doubleValue]]
                                forKey:keyValue];
        
    }
    
    //C相总畸变电流含有率越限日累计时间
    [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F123"] valueForKey:@"C相总畸变电流含有率越限日累计时间"] doubleValue]]
                            forKey:@"hdHarmoCurOverLimitZTm"];
    
    for(int i = 2;i<=19;i++){
        keyDesc = [NSString stringWithFormat:@"C相%d次谐波电流含有率越限日累计时间",i];
        keyValue = [NSString stringWithFormat:@"hdHarmoCurOverLimit%dTm",i];
        
        [hdMeasurePointStaHar setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F123"] valueForKey:keyDesc] doubleValue]]
                                forKey:keyValue];
    }
    
    [self.context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
}

//-(void)saveAfnDDayDataWithDic:(NSDictionary*)dcs{
//
////    NSManagedObjectContext *contextParent = [[XLCoreData sharedXLCoreData] managedObjectContext];
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
//    [context setParentContext:self.contextParent];
//
//
//    //测量点号
//    NSInteger pnCode = [[[dcs valueForKey:@"F3"] valueForKey:@"测量点号"]
//                        integerValue];
//    //数据时标
//    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F3"]
//                                            valueForKey:@"日数据时标"]];
//
//    HistoryData_PowerNeeds *hdPowerNeeds;
//
//    //是否已存在
//    if ([self checkIfDataIsExistwithFn:nil
//                            withPnCode:pnCode
//                       withRequestDate:[self getDateFromFormatString:dataTime]
//                         withCheckType:AFNDDAYDATA
//                           withSubType:1]) {
//        //已存在获取已有实体
//        hdPowerNeeds = [self getEntityFromDBwithPnCode:pnCode
//                                       withRequestDate:[self getDateFromFormatString:dataTime]
//                                         withCheckType:AFNDDAYDATA
//                                           withSubType:1];
//    } else {
//
//        //不存在新建
//        hdPowerNeeds = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerNeeds"
//                                                     inManagedObjectContext:context];
//    }
//
//    //日冻结正向有／无功最大需量及发生时间 F3－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //测量点号
//    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F3"] valueForKey:@"测量点号"]
//                                                        integerValue]]
//                    forKey:@"hdMeasureNo"];
//    //数据时标
//    [hdPowerNeeds setValue:[self getDataTime:[[dcs valueForKey:@"F3"] valueForKey:@"日数据时标"]]
//                    forKey:@"hdDataTime"];
//    //日月数据类型
//    [hdPowerNeeds setValue:[NSNumber numberWithInteger:1]
//                    forKey:@"hdDataType"];
//
//    //正向有功总最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
//                                                        valueForKey:@"正向有功总最大需量"]doubleValue]] forKey:@"hdPosADMaxZ"];
//    //正向有功总最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"正向有功总最大需量发生时间"]
//                    forKey:@"hdPosADMaxZTm"];
//
//    //费率1正向有功总最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
//                                                        valueForKey:@"费率1正向有功最大需量"] doubleValue]]
//                    forKey:@"hdPosADMax1"];
//    //费率1正向有功总最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"费率1正向有功最大需量发生时间"]
//                    forKey:@"hdPosADMax1Tm"];
//    //费率2正向有功总最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
//                                                        valueForKey:@"费率2正向有功最大需量"] doubleValue]]
//                    forKey:@"hdPosADMax2"];
//    //费率2正向有功总最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"费率2正向有功最大需量发生时间"]
//                    forKey:@"hdPosADMax2Tm"];
//
//    //费率3正向有功总最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
//                                                        valueForKey:@"费率3正向有功最大需量"] doubleValue]]
//                    forKey:@"hdPosADMax3"];
//    //费率3正向有功总最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"费率3正向有功最大需量发生时间"]
//                    forKey:@"hdPosADMax3Tm"];
//
//    //费率4正向有功总最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
//                                                        valueForKey:@"费率4正向有功最大需量"] doubleValue]]
//                    forKey:@"hdPosADMax4"];
//    //费率4正向有功总最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"费率4正向有功最大需量发生时间"]
//                    forKey:@"hdPosADMax4Tm"];
//
//
//    //日冻结总及分相最大需量及发生时间 F26－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //三相总有功最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
//                                                        valueForKey:@"三相总有功最大需量"] doubleValue]]
//                    forKey:@"hdADMaxZ"];
//    //三相总有功最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F26"] valueForKey:@"三相总有功最大需量发生时间"]
//                    forKey:@"hdADMaxZTm"];
//
//    //A相有功最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
//                                                        valueForKey:@"A相有功最大需量"] doubleValue]]
//                    forKey:@"hdADMaxA"];
//    //A相有功最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F26"] valueForKey:@"A相有功最大需量发生时间"]
//                    forKey:@"hdADMaxATm"];
//    //B相有功最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
//                                                        valueForKey:@"B相有功最大需量"] doubleValue]]
//                    forKey:@"hdADMaxB"];
//    //B相有功最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F26"] valueForKey:@"B相有功最大需量发生时间"]
//                    forKey:@"hdADMaxBTm"];
//    //C相有功最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
//                                                        valueForKey:@"C相有功最大需量"] doubleValue]]
//                    forKey:@"hdADMaxC"];
//    //C相有功最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F26"] valueForKey:@"C相有功最大需量发生时间"]
//                    forKey:@"hdADMaxCTm"];
//
////    [context save:nil];
////    [self.contextParent performBlock:^{
////        [self.contextParent save:nil];
////    }];
//
//    //**********************************************************************************************************************
//
//    //测量点号
//    pnCode = [[[dcs valueForKey:@"F5"] valueForKey:@"测量点号"]
//              integerValue];
//    //数据时标
//    dataTime = [self getDataTime:[[dcs valueForKey:@"F5"]
//                                  valueForKey:@"数据时标"]];
//
//    HistoryData_PowerValue *hdPowerValue;
//
//    //是否已存在
//    if ([self checkIfDataIsExistwithFn:nil
//                            withPnCode:pnCode
//                       withRequestDate:[self getDateFromFormatString:dataTime]
//                         withCheckType:AFNDDAYDATA
//                           withSubType:0]) {
//        //已存在获取已有实体
//        hdPowerValue = [self getEntityFromDBwithPnCode:pnCode
//                                       withRequestDate:[self getDateFromFormatString:dataTime]
//                                         withCheckType:AFNDDAYDATA
//                                           withSubType:0];
//    } else {
//
//        //不存在新建
//        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
//                                                     inManagedObjectContext:context];
//    }
//
//    //日冻结正向有功电能量 F5 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //测量点号
//    [hdPowerValue setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F5"] valueForKey:@"测量点号"]
//                                                        integerValue]]
//                    forKey:@"hdMeasureNo"];
//    //数据时标
//    [hdPowerValue setValue:[self getDataTime:[[dcs valueForKey:@"F5"] valueForKey:@"数据时标"]]
//                    forKey:@"hdDataTime"];
//    //日月数据类型
//    [hdPowerValue setValue:[NSNumber numberWithInteger:1]
//                    forKey:@"hdDataType"];
//
//    //日正向有功总电能量
//    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F5"] valueForKey:@"日正向有功总电能量"] doubleValue]]
//                    forKey:@"hdPowerValuePosAEZ"];
//
//    //日冻结正向无功点能量 F6－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//
//    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F6"] valueForKey:@"日正向无功总电能量"] doubleValue]]
//                    forKey:@"hdPowerValuePosREZ"];
//
//
//    //日冻结铜损铁损有功电能示值 F45 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //铜损总电能
//    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F45"]
//                                                        valueForKey:@"铜损有功总电能示值"]
//                                                       doubleValue]]
//                    forKey:@"hdCopperLossAEValueZ"];
//
//    //铁损总电能
//    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F45"]
//                                                        valueForKey:@"铁损有功总电能示值"]
//                                                       doubleValue]]
//                    forKey:@"hdIronLossAEValueZ"];
//
////    [context save:nil];
////    [self.contextParent performBlock:^{
////        [self.contextParent save:nil];
////    }];
//
//
//    //**********************************************************************************************************************
//    //日冻结总及分相最大有功功率及发生时间 有功功率为零时间 F25－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //测量点号
//    pnCode = [[[dcs valueForKey:@"F25"] valueForKey:@"测量点号"]
//              integerValue];
//    //数据时标
//    dataTime = [self getDataTime:[[dcs valueForKey:@"F25"]
//                                  valueForKey:@"日数据时标"]];
//
//    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
//
//    //是否已存在
//    if ([self checkIfDataIsExistwithFn:nil
//                            withPnCode:pnCode
//                       withRequestDate:[self getDateFromFormatString:dataTime]
//                         withCheckType:AFNDDAYDATA
//                           withSubType:2]) {
//        //已存在获取已有实体
//        hdMeasurePointSta = [self getEntityFromDBwithPnCode:pnCode
//                                            withRequestDate:[self getDateFromFormatString:dataTime]
//                                              withCheckType:AFNDDAYDATA
//                                                withSubType:2];
//    } else {
//
//        //不存在新建
//        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
//                                                          inManagedObjectContext:context];
//    }
//
//    //测量点号
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"测量点号"]
//                                                             integerValue]]
//                         forKey:@"hdMeasureNo"];
//    //数据时标
//    [hdMeasurePointSta setValue:[self getDataTime:[[dcs valueForKey:@"F25"] valueForKey:@"日数据时标"]]
//                         forKey:@"hdDataTime"];
//    //日月数据类型
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:1]
//                         forKey:@"hdDataType"];
//
//    //三相总最大有功功率
//    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F25"] valueForKey:@"三相总最大有功功率"] doubleValue]]
//                         forKey:@"hdAPMaxZ"];
//    //三相总最大有功功率发生时间
//    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F25"] valueForKey:@"三相总最大有功功率发生时间"]
//                         forKey:@"hdAPMaxZTm"];
//    //A相最大有功功率
//    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F25"] valueForKey:@"A相最大有功功率"] doubleValue]]
//                         forKey:@"hdAPMaxA"];
//    //A相最大有功功率发生时间
//    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F25"] valueForKey:@"A相最大有功功率发生时间"]
//                         forKey:@"hdAPMaxATm"];
//    //B相最大有功功率
//    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F25"] valueForKey:@"B相最大有功功率"] doubleValue]]
//                         forKey:@"hdAPMaxB"];
//    //B相最大有功功率发生时间
//    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F25"] valueForKey:@"B相最大有功功率发生时间"]
//                         forKey:@"hdAPMaxBTm"];
//
//    //C相最大有功功率
//    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F25"] valueForKey:@"C相最大有功功率"] doubleValue]]
//                         forKey:@"hdAPMaxC"];
//    //C相最大有功功率发生时间
//    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F25"] valueForKey:@"C相最大有功功率发生时间"]
//                         forKey:@"hdAPMaxCTm"];
//
//    //三相总有功功率为零时间
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"三相总有功功率为零时间"] integerValue]]
//                         forKey:@"hdAPZeroAccTmZ"];
//    //A相有功功率为零时间
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"A相有功功率为零时间"] integerValue]]
//                         forKey:@"hdAPZeroAccTmA"];
//    //B相有功功率为零时间
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"B相有功功率为零时间"] integerValue]]
//                         forKey:@"hdAPZeroAccTmB"];
//    //C相有功功率为零时间
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F25"] valueForKey:@"C相有功功率为零时间"] integerValue]]
//                         forKey:@"hdAPZeroAccTmC"];
//    [context save:nil];
//    [self.contextParent performBlock:^{
//        [self.contextParent save:nil];
//    }];
//}
//
//
//
//
////保存月冻结数据
////一个基本月冻结数据表可能包含多个F项的数据
////先判断数据条目是否存在 如存在则更新子F项内容 不存在则创建
//
//-(void)saveAfnDMonthDataWithDic:(NSDictionary*)dcs{
//
////    NSManagedObjectContext *contextParent = [[XLCoreData sharedXLCoreData] managedObjectContext];
//    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
//    [context setParentContext:self.contextParent];
//
//    //测量点号
//    NSInteger pnCode = [[[dcs valueForKey:@"F21"] valueForKey:@"测量点号"]
//                        integerValue];
//    //数据时标
//    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F21"]
//                                             valueForKey:@"数据时标"]];
//
//    //测量点号
//    pnCode = [[[dcs valueForKey:@"F21"] valueForKey:@"测量点号"]
//              integerValue];
//    //数据时标
//    dataTime = [self getDataTime1:[[dcs valueForKey:@"F21"]
//                                   valueForKey:@"数据时标"]];
//
//    HistoryData_PowerValue *hdPowerValue;
//
//    //是否已存在
//    if ([self checkIfDataIsExistwithFn:nil
//                            withPnCode:pnCode
//                       withRequestDate:[self getDateFromFormatString:dataTime]
//                         withCheckType:AFNDMONTHDATA
//                           withSubType:0]) {
//        //已存在获取已有实体
//        hdPowerValue = [self getEntityFromDBwithPnCode:pnCode
//                                       withRequestDate:[self getDateFromFormatString:dataTime]
//                                         withCheckType:AFNDMONTHDATA
//                                           withSubType:0];
//    } else {
//
//        //不存在新建
//        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
//                                                     inManagedObjectContext:context];
//    }
//
//    //日冻结正向有功电能量 F5 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //测量点号
//    [hdPowerValue setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F21"] valueForKey:@"测量点号"]
//                                                        integerValue]]
//                    forKey:@"hdMeasureNo"];
//    //数据时标
//    [hdPowerValue setValue:[self getDataTime1:[[dcs valueForKey:@"F21"] valueForKey:@"数据时标"]]
//                    forKey:@"hdDataTime"];
//    //日月数据类型
//    [hdPowerValue setValue:[NSNumber numberWithInteger:2]
//                    forKey:@"hdDataType"];
//
//    //日正向有功总电能量
//    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F21"] valueForKey:@"月正向有功总电能量"] doubleValue]]
//                    forKey:@"hdPowerValuePosAEZ"];
//
//    //日冻结铜损铁损有功电能示值 F46 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //铜损总电能
//    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F46"]
//                                                        valueForKey:@"铜损有功总电能示值"]
//                                                       doubleValue]]
//                    forKey:@"hdCopperLossAEValueZ"];
//
//    //铁损总电能
//    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F46"]
//                                                        valueForKey:@"铁损有功总电能示值"]
//                                                       doubleValue]]
//                    forKey:@"hdIronLossAEValueZ"];
//
////    [context save:nil];
////    [self.contextParent performBlock:^{
////        [self.contextParent save:nil];
////    }];
////
//
//    //**********************************************************************************************************************
//    //月冻结总及分相最大有功功率及发生时间 有功功率为零时间 F33－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //测量点号
//    pnCode = [[[dcs valueForKey:@"F33"] valueForKey:@"测量点号"]
//              integerValue];
//    //数据时标
//    dataTime = [self getDataTime1:[[dcs valueForKey:@"F33"]
//                                   valueForKey:@"月数据时标"]];
//
//    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
//
//    //是否已存在
//    if ([self checkIfDataIsExistwithFn:nil
//                            withPnCode:pnCode
//                       withRequestDate:[self getDateFromFormatString:dataTime]
//                         withCheckType:AFNDMONTHDATA
//                           withSubType:2]) {
//        //已存在获取已有实体
//        hdMeasurePointSta = [self getEntityFromDBwithPnCode:pnCode
//                                            withRequestDate:[self getDateFromFormatString:dataTime]
//                                              withCheckType:AFNDMONTHDATA
//                                                withSubType:2];
//    } else {
//
//        //不存在新建
//        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
//                                                          inManagedObjectContext:context];
//    }
//
//    //测量点号
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"测量点号"]
//                                                             integerValue]]
//                         forKey:@"hdMeasureNo"];
//    //数据时标
//    [hdMeasurePointSta setValue:[self getDataTime1:[[dcs valueForKey:@"F33"] valueForKey:@"月数据时标"]]
//                         forKey:@"hdDataTime"];
//    //日月数据类型
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:2]
//                         forKey:@"hdDataType"];
//
//    //三相总最大有功功率
//    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F33"] valueForKey:@"三相总最大有功功率"] doubleValue]]
//                         forKey:@"hdAPMaxZ"];
//    //三相总最大有功功率发生时间
//    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F33"] valueForKey:@"三相总最大有功功率发生时间"]
//                         forKey:@"hdAPMaxZTm"];
//    //A相最大有功功率
//    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F33"] valueForKey:@"A相最大有功功率"] doubleValue]]
//                         forKey:@"hdAPMaxA"];
//    //A相最大有功功率发生时间
//    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F33"] valueForKey:@"A相最大有功功率发生时间"]
//                         forKey:@"hdAPMaxATm"];
//    //B相最大有功功率
//    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F33"] valueForKey:@"B相最大有功功率"] doubleValue]]
//                         forKey:@"hdAPMaxB"];
//    //B相最大有功功率发生时间
//    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F33"] valueForKey:@"B相最大有功功率发生时间"]
//                         forKey:@"hdAPMaxBTm"];
//
//    //C相最大有功功率
//    [hdMeasurePointSta setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F33"] valueForKey:@"C相最大有功功率"] doubleValue]]
//                         forKey:@"hdAPMaxC"];
//    //C相最大有功功率发生时间
//    [hdMeasurePointSta setValue:[[dcs valueForKey:@"F33"] valueForKey:@"C相最大有功功率发生时间"]
//                         forKey:@"hdAPMaxCTm"];
//
//    //三相总有功功率为零时间
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"三相总有功功率为零时间"] integerValue]]
//                         forKey:@"hdAPZeroAccTmZ"];
//    //A相有功功率为零时间
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"A相有功功率为零时间"] integerValue]]
//                         forKey:@"hdAPZeroAccTmA"];
//    //B相有功功率为零时间
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"B相有功功率为零时间"] integerValue]]
//                         forKey:@"hdAPZeroAccTmB"];
//    //C相有功功率为零时间
//    [hdMeasurePointSta setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F33"] valueForKey:@"C相有功功率为零时间"] integerValue]]
//                         forKey:@"hdAPZeroAccTmC"];
////    [context save:nil];
////    [self.contextParent performBlock:^{
////        [self.contextParent save:nil];
////    }];
//
//
//    HistoryData_PowerNeeds *hdPowerNeeds;
//
//    //是否已存在
//    if ([self checkIfDataIsExistwithFn:nil
//                            withPnCode:pnCode
//                       withRequestDate:[self getDateFromFormatString:dataTime]
//                         withCheckType:AFNDMONTHDATA
//                           withSubType:1]) {
//        //已存在获取已有实体
//        hdPowerNeeds = [self getEntityFromDBwithPnCode:pnCode
//                                       withRequestDate:[self getDateFromFormatString:dataTime]
//                                         withCheckType:AFNDMONTHDATA
//                                           withSubType:1];
//    } else {
//
//        //不存在新建
//        hdPowerNeeds = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerNeeds"
//                                                     inManagedObjectContext:context];
//    }
//
//    //月冻结总及分相有功最大需量及发生时间 F34－－－－－－－－－－－－－－－－－－－－－－－－－－－－
//
//    //测量点号
//    [hdPowerNeeds setValue:[NSNumber numberWithInteger:[[[dcs valueForKey:@"F34"] valueForKey:@"测量点号"]
//                                                        integerValue]]
//                    forKey:@"hdMeasureNo"];
//    //数据时标
//    [hdPowerNeeds setValue:[self getDataTime1:[[dcs valueForKey:@"F34"] valueForKey:@"月数据时标"]]
//                    forKey:@"hdDataTime"];
//    //日月数据类型
//    [hdPowerNeeds setValue:[NSNumber numberWithInteger:2]
//                    forKey:@"hdDataType"];
//
//
//    //三相总有功最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
//                                                        valueForKey:@"三相总有功最大需量"] doubleValue]]
//                    forKey:@"hdADMaxZ"];
//    //三相总有功最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F34"] valueForKey:@"三相总有功最大需量发生时间"]
//                    forKey:@"hdADMaxZTm"];
//
//    //A相有功最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
//                                                        valueForKey:@"A相有功最大需量"] doubleValue]]
//                    forKey:@"hdADMaxA"];
//    //A相有功最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F34"] valueForKey:@"A相有功最大需量发生时间"]
//                    forKey:@"hdADMaxATm"];
//    //B相有功最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
//                                                        valueForKey:@"B相有功最大需量"] doubleValue]]
//                    forKey:@"hdADMaxB"];
//    //B相有功最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F34"] valueForKey:@"B相有功最大需量发生时间"]
//                    forKey:@"hdADMaxBTm"];
//    //C相有功最大需量
//    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
//                                                        valueForKey:@"C相有功最大需量"] doubleValue]]
//                    forKey:@"hdADMaxC"];
//    //C相有功最大需量发生时间
//    [hdPowerNeeds setValue:[[dcs valueForKey:@"F34"] valueForKey:@"C相有功最大需量发生时间"]
//                    forKey:@"hdADMaxCTm"];
//    
//    [context save:nil];
//    [self.contextParent performBlock:^{
//        [self.contextParent save:nil];
//    }];
//}
//


@end



