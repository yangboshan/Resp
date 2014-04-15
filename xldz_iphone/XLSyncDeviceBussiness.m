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
#import "HistoryData_PowerNeeds.h"
#import "HistoryData_PowerValue.h"
#import "HistoryData_MeasurePoint_Sta.h"

@interface XLSyncDeviceBussiness()

//抄表起始日期
@property (nonatomic,strong) NSDate *startDate;

//抄表结束日期
@property (nonatomic,strong) NSDate *endDate;

//请求报文Bytes
@property(nonatomic,assign) Byte* frame;

//请求报文Data
@property(nonatomic,strong) NSData *data;

//报文输出长度
@property(nonatomic,assign) XL_UINT16 outlen;

//日冻结数据时间集合
@property (nonatomic,strong) NSArray *dayDateSet;

//月冻结数据时间集合
@property (nonatomic,strong) NSArray *monthDateSet;


//测量点集合
@property (nonatomic,strong) NSArray *terDAArray;

//曲线DT集合
@property (nonatomic,strong) NSArray *curveDTArray;

//二类数据日冻结DT集合
@property (nonatomic,strong) NSArray *afnDDayDTArray;

//二类数据月冻结DT集合
@property (nonatomic,strong) NSArray *afnDMonthDTArray;


//请求报文Offset
@property (nonatomic,assign) NSInteger requestOffset;

//实际请求FN数
@property (nonatomic,assign) NSInteger actualRequestFnCount;

//当前请求类型
@property (nonatomic,assign) NSInteger currentRequestType;

//曲线请求数据集合
@property (nonatomic,strong) NSArray *curveRequestArray;
//日冻结请求数据集合
@property (nonatomic,strong) NSArray *afnDDayRequestArray;
//月冻结请求数据集合
@property (nonatomic,strong) NSArray *afnDMonthRequestArray;

@property (nonatomic,assign) NSInteger singleRequestCount;
@property (nonatomic,strong) NSString  *notifyName;

@property (nonatomic,assign) NSInteger counter;


@property (nonatomic,assign) NSInteger preRequestOffset;
@property (nonatomic,assign) NSInteger preCounter;
@property (nonatomic,assign) BOOL isMainTaskFinished;

@end

@implementation XLSyncDeviceBussiness

#define SINGLECOUNT 2
#define CURVEDATA 0
#define AFNDDAYDATA 1
#define AFNDMONTHDATA 2
PACKITEM array[10];

SYNTHESIZE_SINGLETON_FOR_CLASS(XLSyncDeviceBussiness)

#pragma mark - 抄表入口

-(id)init{
    if (self = [super init]) {
        self.isMainTaskFinished = NO;
        self.notifyName = [NSString stringWithFormat:@"__%@__notify__%d",[self class],arc4random()];
        [[XLSocketManager sharedXLSocketManager] setIsFromBackground:YES];
        [[XLSocketManager sharedXLSocketManager] setNotifyName:self.notifyName];
        
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
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(foreGroundRequest:)
                                                     name:@"requestForeGroundData"                                                       object:nil];

        self.singleRequestCount = SINGLECOUNT;
    }
    return self;
}

//开始从终端同步数据
-(void)beginSync{
    
    //后台线程低优先级抄读数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{

        //是否已连接终端WIFI
        if ([XLUtilities localWifiReachable]) {
            
            NSLog(@"抄表开始------------>>");
            self.counter = 0;
            self.requestOffset = 0;
            self.isMainTaskFinished = NO;
            
            [self prepareDataForSync];
            [self requestAsyncData];
            
            //模拟外部抄表任务进入
//            double delayInSeconds = 2.0;
//            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
//            dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
//                [self foreGroundRequest:nil];
//            });
        }
    });
}

-(void)prepareDataForSync{
    
    self.startDate = [self getNewDateWithDate:[NSDate date] withDiff:-30 withType:0];
    self.endDate = [NSDate date];

    [self buildRequestDateSet];
    [self buildDaDtSet];
    
    self.curveRequestArray     = [self getRequestDataSetWithType:CURVEDATA];
    self.afnDDayRequestArray   = [self getRequestDataSetWithType:AFNDDAYDATA];
    self.afnDMonthRequestArray = [self getRequestDataSetWithType:AFNDMONTHDATA];
}

dispatch_semaphore_t semaphore;
dispatch_queue_t bgQueue;
dispatch_queue_t emgQueue;
-(void)requestAsyncData{
    
    //信号量
    semaphore = dispatch_semaphore_create(0);
    
    //抄表队列
    bgQueue   = dispatch_queue_create("COM.XLCOMBINE.BGQUEUE", DISPATCH_QUEUE_SERIAL);
    
    //高优先级请求队列
    emgQueue  = dispatch_queue_create("COM.XLCOMBINE.EMGQUEUE", DISPATCH_QUEUE_SERIAL);
    
    dispatch_set_target_queue(bgQueue, emgQueue);
    
    dispatch_semaphore_signal(semaphore);
    
    for(int i = 0; i<[self.curveRequestArray count]/self.singleRequestCount;i++){
        dispatch_async(bgQueue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [self requestSocketDataWithType:CURVEDATA];
        });
    }
    
    for(int i = 0; i<[self.afnDDayRequestArray count]/[self.afnDDayDTArray count];i++){
        dispatch_async(bgQueue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [self requestSocketDataWithType:AFNDDAYDATA];
        });
    }
    
    for(int i = 0; i<[self.afnDMonthRequestArray count]/[self.afnDMonthDTArray count];i++){
        dispatch_async(bgQueue, ^{
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            [self requestSocketDataWithType:AFNDMONTHDATA];
        });
    }
    dispatch_async(bgQueue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        self.isMainTaskFinished = YES;
        NSLog(@"抄表结束------------>>");
    });
}


#pragma mark - 回调函数
//请求报文回调函数
-(void)handleDataResponse:(NSNotification*)notify{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSDictionary* dcs = notify.userInfo;
        
        //如果是曲线数据
        if (self.currentRequestType == CURVEDATA) {
            
            [self saveCurveDataWithDic:dcs];
            dispatch_semaphore_signal(semaphore);
            return;
        }
        
        //如果是二类日冻结数据
        if (self.currentRequestType == AFNDDAYDATA) {
            
            [self saveAfnDDayDataWithDic:dcs];
            dispatch_semaphore_signal(semaphore);
            return;
        }
        
        //如果是二类月冻结数据
        if (self.currentRequestType == AFNDMONTHDATA) {
            
            [self saveAfnDMonthDataWithDic:dcs];
            dispatch_semaphore_signal(semaphore);
            return;
        }
    });
}


//异常处理回调函数

// flagRet = -2 Socket连接断开
// flagRet = -1 ERROR
// flagRet = 1 确认帧
// flagRet = 2 否认帧

-(void)speHandleResponse:(NSNotification*)notify{
    
    if (!self.isMainTaskFinished) {
        NSDictionary *dcs = notify.userInfo;
        
        NSInteger flagRet = [[dcs valueForKey:@"key"] integerValue];
        
        //socket连接断开 检查是否已抄完数据 没有则执行补抄
        if (flagRet == -2) {
            [self beginSync];
        }
    }

    //..........其他异常处理在这
}



//收到临时高优先级请求任务
-(void)foreGroundRequest:(NSNotification*)notify{

    NSLog(@"临时抄表任务开始--------->>");
    
    //保存状态变量
    self.preRequestOffset = self.requestOffset;
    self.preCounter = self.counter;
    
    //暂停抄表主队列
    dispatch_suspend(bgQueue);
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        //添加任务到临时抄表队列
        for(int i = 0; i<[self.afnDDayRequestArray count]/[self.afnDDayDTArray count];i++){
            
            dispatch_async(emgQueue, ^{
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
                [self requestSocketDataWithType:AFNDDAYDATA];

                if (i == [self.afnDDayRequestArray count]/[self.afnDDayDTArray count] -1) {
                    
                    NSLog(@"临时抄表任务结束--------->>");
                    //恢复状态变量
                    self.requestOffset = self.preRequestOffset;
                    self.counter = self.preCounter;
                    
                    //临时队列处理完成 恢复主队列
                    dispatch_resume(bgQueue);
                }
            });
        }
    });
}


#pragma mark - 请求报文相关
//Build 376.1请求报文DADT
-(void)buildRequestFrameWithType:(NSInteger)type{
    
    NSArray *requestItem;
    self.actualRequestFnCount = 0;

    //日月数据可一次多发几个FN不会分帧
    if (type==AFNDDAYDATA) {
        self.singleRequestCount = [self.afnDDayDTArray count];
    }
    if (type==AFNDMONTHDATA) {
        self.singleRequestCount = [self.afnDMonthDTArray count];
    }
    if (type == CURVEDATA) {
        self.singleRequestCount =  SINGLECOUNT;
    }
    
    
    for(int i = 0; i < self.singleRequestCount;i++){
        
        //曲线DADT组成
        //FN PN 分时日月年 冻结密度 数据点数
        if (type == CURVEDATA) {
 
            if (self.requestOffset < [self.curveRequestArray count]) {
                requestItem = [self.curveRequestArray objectAtIndex:
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
            
            self.requestOffset++;
            if (self.requestOffset >= [self.curveRequestArray count]) {
                self.requestOffset = 0;
            }
        }
        
        //二类数据日冻结DADT组成
        //FN PN 日月年
        if (type == AFNDDAYDATA) {
            if (self.requestOffset < [self.afnDDayRequestArray count]) {
                requestItem = [self.afnDDayRequestArray objectAtIndex:
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
            self.requestOffset++;
            if (self.requestOffset >= [self.afnDDayRequestArray count]) {
                self.requestOffset = 0;
            }
        }
        
        //二类数据月冻结DADT组成
        //FN PN 月年
        if (type == AFNDMONTHDATA) {
            if (self.requestOffset < [self.afnDMonthRequestArray count]) {
                requestItem = [self.afnDMonthRequestArray objectAtIndex:
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
            self.requestOffset++;
            if (self.requestOffset >= [self.afnDMonthRequestArray count]) {
                self.requestOffset = 0;
            }
        }
        self.counter++;
    }
}

//发送请求报文
-(void)requestSocketDataWithType:(NSInteger)type{
    
    self.currentRequestType = type;
    [self buildRequestFrameWithType:type];
    self.frame = PackFrame(AFN0D, array, self.actualRequestFnCount,&_outlen);
    self.data = [NSData dataWithBytes:self.frame length:self.outlen];
    free(self.frame);
    
    NSLog(@"请求数据报文:%@ 类型:%d 次数:%d",[self.data description],type,self.requestOffset);
    [[XLSocketManager sharedXLSocketManager] packRequestFrame:self.data];
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
    
    //Fn数组
    [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        requestDate = (NSDate*)obj;
        
        //测量点数组
        [self.terDAArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            pnCode = [obj integerValue];
            
            //日期数组
            [enumerArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                fnCode = (NSString*)obj;
                
                //曲线类型此处检查数据库是否已有对应记录
                if (type == CURVEDATA) {
                    if (![self checkIfDataIsExistwithFn:[[fnCode substringFromIndex:1] integerValue]
                                             withPnCode:pnCode
                                        withRequestDate:requestDate
                                          withCheckType:type withSubType:nil]) {
                        
                        [requestArray addObject:[NSArray arrayWithObjects:
                                                 fnCode,
                                                 [NSNumber numberWithInteger:pnCode],
                                                 requestDate,nil]];
                    }
                } else {
                    
                    [requestArray addObject:[NSArray arrayWithObjects:
                                             fnCode,
                                             [NSNumber numberWithInteger:pnCode],
                                             requestDate,nil]];
                }
            }];
        }];
    }];
    
    return requestArray;
}




//生成DADT集合
-(void)buildDaDtSet{
    
    //曲线DT集合
    self.curveDTArray = [NSArray arrayWithObjects:
                         //有功功率总及三相
                         @"F81",
                         @"F82",
                         @"F83",
                         @"F84",
                         //无功功率总及三相
                         @"F85",
                         @"F86",
                         @"F87",
                         @"F88",
                         //功率因数总及三相
                         @"F105",
                         @"F106",
                         @"F107",
                         @"F108",
                         //电压三相
                         @"F89",
                         @"F90",
                         @"F91",
                         //电流三相
                         @"F92",
                         @"F93",
                         @"F94",nil];
    
    
    //二类数据日冻结DT集合
    self.afnDDayDTArray   = [NSArray arrayWithObjects:@"F3",
                             @"F5",
                             @"F25",
                             @"F26",
                             @"F45",nil];
    
    //二类数据月冻结DT集合
    self.afnDMonthDTArray = [NSArray arrayWithObjects:@"F33",
                             @"F21",
                             @"F46",
                             @"F34", nil];
    //设备测量点集合
    [self getDAArray];
    
}

//获取设备测量点集合
-(void)getDAArray{
    
    //TD..
    self.terDAArray = [NSArray arrayWithObjects:[NSNumber numberWithInteger:1], nil];
}


#pragma mark - 数据库操作相关

//保存曲线数据
-(void)saveCurveDataWithDic:(NSDictionary*)dcs{
    
    XLCoreData *coreData = [XLCoreData sharedXLCoreData];
    NSManagedObjectContext *context = [coreData managedObjectContext];
    

    
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
                                                        inManagedObjectContext:context];
        
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
        
        
        if (![self checkIfDataIsExistwithFn:[[key substringFromIndex:1] integerValue]
                                 withPnCode:[[[dcs valueForKey:key] valueForKey:@"测量点号"] integerValue]
                            withRequestDate:[self getDateFromFormatString:[self getDataTime:[[dcs valueForKey:key] valueForKey:@"日期"]]]
                              withCheckType:CURVEDATA withSubType:0]) {
            
            [coreData saveContext];
        }
    }
}

//保存日冻结数据
//一个基本日冻结数据表可能包含多个F项的数据
//先判断数据条目是否存在 如存在则更新子F项内容 不存在则创建

-(void)saveAfnDDayDataWithDic:(NSDictionary*)dcs{
    
    XLCoreData *coreData = [XLCoreData sharedXLCoreData];
    NSManagedObjectContext *context = [coreData managedObjectContext];
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F3"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime:[[dcs valueForKey:@"F3"]
                                            valueForKey:@"日数据时标"]];
    
    HistoryData_PowerNeeds *hdPowerNeeds;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:nil
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerNeeds = [self getEntityFromDBwithPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime]
                                         withCheckType:AFNDDAYDATA
                                           withSubType:1];
    } else {
        
        //不存在新建
        hdPowerNeeds = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerNeeds"
                                                     inManagedObjectContext:context];
    }
    
    //日冻结正向有／无功最大需量及发生时间 F3－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    
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
    
    //正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"正向有功总最大需量"]doubleValue]] forKey:@"hdPosADMaxZ"];
    //正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"正向有功总最大需量发生时间"]
                    forKey:@"hdPosADMaxZTm"];
    
    //费率1正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"费率1正向有功最大需量"] doubleValue]]
                    forKey:@"hdPosADMax1"];
    //费率1正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"费率1正向有功最大需量发生时间"]
                    forKey:@"hdPosADMax1Tm"];
    //费率2正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"费率2正向有功最大需量"] doubleValue]]
                    forKey:@"hdPosADMax2"];
    //费率2正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"费率2正向有功最大需量发生时间"]
                    forKey:@"hdPosADMax2Tm"];
    
    //费率3正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"费率3正向有功最大需量"] doubleValue]]
                    forKey:@"hdPosADMax3"];
    //费率3正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"费率3正向有功最大需量发生时间"]
                    forKey:@"hdPosADMax3Tm"];
    
    //费率4正向有功总最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F3"]
                                                        valueForKey:@"费率4正向有功最大需量"] doubleValue]]
                    forKey:@"hdPosADMax4"];
    //费率4正向有功总最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F3"] valueForKey:@"费率4正向有功最大需量发生时间"]
                    forKey:@"hdPosADMax4Tm"];
    
    
    //日冻结总及分相最大需量及发生时间 F26－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    
    //三相总有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
                                                        valueForKey:@"三相总有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxZ"];
    //三相总有功最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F26"] valueForKey:@"三相总有功最大需量发生时间"]
                    forKey:@"hdADMaxZTm"];
    
    //A相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
                                                        valueForKey:@"A相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxA"];
    //A相有功最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F26"] valueForKey:@"A相有功最大需量发生时间"]
                    forKey:@"hdADMaxATm"];
    //B相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
                                                        valueForKey:@"B相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxB"];
    //B相有功最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F26"] valueForKey:@"B相有功最大需量发生时间"]
                    forKey:@"hdADMaxBTm"];
    //C相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F26"]
                                                        valueForKey:@"C相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxC"];
    //C相有功最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F26"] valueForKey:@"C相有功最大需量发生时间"]
                    forKey:@"hdADMaxCTm"];
    
    [coreData saveContext];
    
    //**********************************************************************************************************************
    
    //测量点号
    pnCode = [[[dcs valueForKey:@"F5"] valueForKey:@"测量点号"]
              integerValue];
    //数据时标
    dataTime = [self getDataTime:[[dcs valueForKey:@"F5"]
                                  valueForKey:@"数据时标"]];
    
    HistoryData_PowerValue *hdPowerValue;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:nil
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:0]) {
        //已存在获取已有实体
        hdPowerValue = [self getEntityFromDBwithPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime]
                                         withCheckType:AFNDDAYDATA
                                           withSubType:0];
    } else {
        
        //不存在新建
        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
                                                     inManagedObjectContext:context];
    }
    
    //日冻结正向有功电能量 F5 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    
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
    
    //日正向有功总电能量
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F5"] valueForKey:@"日正向有功总电能量"] doubleValue]]
                    forKey:@"hdPowerValuePosAEZ"];
    
    //日冻结铜损铁损有功电能示值 F45 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    
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
    
    [coreData saveContext];
    
    
    //**********************************************************************************************************************
    //日冻结总及分相最大有功功率及发生时间 有功功率为零时间 F25－－－－－－－－－－－－－－－－－－－－－－－－－
    
    //测量点号
    pnCode = [[[dcs valueForKey:@"F25"] valueForKey:@"测量点号"]
              integerValue];
    //数据时标
    dataTime = [self getDataTime:[[dcs valueForKey:@"F25"]
                                  valueForKey:@"日数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:nil
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDDAYDATA
                           withSubType:2]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime]
                                              withCheckType:AFNDDAYDATA
                                                withSubType:2];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:context];
    }
    
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
    [coreData saveContext];
}




//保存月冻结数据
//一个基本月冻结数据表可能包含多个F项的数据
//先判断数据条目是否存在 如存在则更新子F项内容 不存在则创建

-(void)saveAfnDMonthDataWithDic:(NSDictionary*)dcs{
    
    XLCoreData *coreData = [XLCoreData sharedXLCoreData];
    NSManagedObjectContext *context = [coreData managedObjectContext];
    
    //测量点号
    NSInteger pnCode = [[[dcs valueForKey:@"F21"] valueForKey:@"测量点号"]
                        integerValue];
    //数据时标
    NSString* dataTime = [self getDataTime1:[[dcs valueForKey:@"F21"]
                                            valueForKey:@"数据时标"]];
    
    //测量点号
    pnCode = [[[dcs valueForKey:@"F21"] valueForKey:@"测量点号"]
              integerValue];
    //数据时标
    dataTime = [self getDataTime1:[[dcs valueForKey:@"F21"]
                                  valueForKey:@"数据时标"]];
    
    HistoryData_PowerValue *hdPowerValue;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:nil
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:0]) {
        //已存在获取已有实体
        hdPowerValue = [self getEntityFromDBwithPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime]
                                         withCheckType:AFNDMONTHDATA
                                           withSubType:0];
    } else {
        
        //不存在新建
        hdPowerValue = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerValue"
                                                     inManagedObjectContext:context];
    }
    
    //日冻结正向有功电能量 F5 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    
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
    
    //日正向有功总电能量
    [hdPowerValue setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F21"] valueForKey:@"月正向有功总电能量"] doubleValue]]
                    forKey:@"hdPowerValuePosAEZ"];
    
    //日冻结铜损铁损有功电能示值 F46 －－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    
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
    
    [coreData saveContext];
    
    
    //**********************************************************************************************************************
    //月冻结总及分相最大有功功率及发生时间 有功功率为零时间 F33－－－－－－－－－－－－－－－－－－－－－－－－－
    
    //测量点号
    pnCode = [[[dcs valueForKey:@"F33"] valueForKey:@"测量点号"]
              integerValue];
    //数据时标
    dataTime = [self getDataTime1:[[dcs valueForKey:@"F33"]
                                  valueForKey:@"月数据时标"]];
    
    HistoryData_MeasurePoint_Sta *hdMeasurePointSta;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:nil
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:2]) {
        //已存在获取已有实体
        hdMeasurePointSta = [self getEntityFromDBwithPnCode:pnCode
                                            withRequestDate:[self getDateFromFormatString:dataTime]
                                              withCheckType:AFNDMONTHDATA
                                                withSubType:2];
    } else {
        
        //不存在新建
        hdMeasurePointSta = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_MeasurePoint_Sta"
                                                          inManagedObjectContext:context];
    }
    
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
    [coreData saveContext];
    
    
    HistoryData_PowerNeeds *hdPowerNeeds;
    
    //是否已存在
    if ([self checkIfDataIsExistwithFn:nil
                            withPnCode:pnCode
                       withRequestDate:[self getDateFromFormatString:dataTime]
                         withCheckType:AFNDMONTHDATA
                           withSubType:1]) {
        //已存在获取已有实体
        hdPowerNeeds = [self getEntityFromDBwithPnCode:pnCode
                                       withRequestDate:[self getDateFromFormatString:dataTime]
                                         withCheckType:AFNDMONTHDATA
                                           withSubType:1];
    } else {
        
        //不存在新建
        hdPowerNeeds = [NSEntityDescription insertNewObjectForEntityForName:@"HistoryData_PowerNeeds"
                                                     inManagedObjectContext:context];
    }
    
    //月冻结总及分相有功最大需量及发生时间 F34－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    
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
    
    
    //三相总有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
                                                        valueForKey:@"三相总有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxZ"];
    //三相总有功最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F34"] valueForKey:@"三相总有功最大需量发生时间"]
                    forKey:@"hdADMaxZTm"];
    
    //A相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
                                                        valueForKey:@"A相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxA"];
    //A相有功最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F34"] valueForKey:@"A相有功最大需量发生时间"]
                    forKey:@"hdADMaxATm"];
    //B相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
                                                        valueForKey:@"B相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxB"];
    //B相有功最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F34"] valueForKey:@"B相有功最大需量发生时间"]
                    forKey:@"hdADMaxBTm"];
    //C相有功最大需量
    [hdPowerNeeds setValue:[NSNumber numberWithDouble:[[[dcs valueForKey:@"F34"]
                                                        valueForKey:@"C相有功最大需量"] doubleValue]]
                    forKey:@"hdADMaxC"];
    //C相有功最大需量发生时间
    [hdPowerNeeds setValue:[[dcs valueForKey:@"F34"] valueForKey:@"C相有功最大需量发生时间"]
                    forKey:@"hdADMaxCTm"];
    
    [coreData saveContext];

}


//Check数据库是否包含指定数据
-(BOOL)checkIfDataIsExistwithFn:(NSInteger)fnCode withPnCode:(NSInteger)pnCode withRequestDate:(NSDate*)date
                  withCheckType:(NSInteger)type withSubType:(NSInteger)subType{
    
    XLCoreData *coreData = [XLCoreData sharedXLCoreData];
    NSManagedObjectContext *context = [coreData managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    if (type == CURVEDATA) {
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurveData"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        //查询条件：曲线Fn 测量点号 曲线时间
        //TD 增加设备号的判断
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cvCurveType = %d  and cvMeasureNo = %d and cvDataTime = %@",
                                  fnCode,
                                  pnCode,
                                  [self getFormatDateStringWithDate:date]];
        
        [fetchRequest setPredicate:predicate];
        
        NSError *error;
        NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
//        NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
        
        if (count!=0) {
            return YES;
        }
    }
    
    if (type == AFNDDAYDATA|| type == AFNDMONTHDATA) {
        
        NSEntityDescription *entity;
        NSString *queryDate;
        
        if (type == AFNDDAYDATA) {
            queryDate = [self getFormatDateStringWithDate:date];
        }
        if (type == AFNDMONTHDATA) {
            queryDate = [[self getFormatDateStringWithDate:date] substringToIndex:6];;
        }
        
        if (subType == 0) {
            entity = [NSEntityDescription entityForName:@"HistoryData_PowerValue"
                                 inManagedObjectContext:context];
        }
        if (subType == 1) {
            entity = [NSEntityDescription entityForName:@"HistoryData_PowerNeeds"
                                 inManagedObjectContext:context];
        }
        if (subType == 2){
            entity = [NSEntityDescription entityForName:@"HistoryData_MeasurePoint_Sta"
                                 inManagedObjectContext:context];
        }
        
        [fetchRequest setEntity:entity];
        
        //查询条件:日月数据类型 测量点号 数据时标
        //TD....设备号
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hdDataType = %d  and hdMeasureNo = %d and hdDataTime = %@",
                                  type,
                                  pnCode,
                                  queryDate];
        
        [fetchRequest setPredicate:predicate];
        
        NSUInteger count = [context countForFetchRequest:fetchRequest error:nil];
        
        if (count!=0) {
            return YES;
        }
    }
    return NO;
}

//查询返回指定实体
-(id)getEntityFromDBwithPnCode:(NSInteger)pnCode withRequestDate:(NSDate*)date
                 withCheckType:(NSInteger)type withSubType:(NSInteger)subType{
    XLCoreData *coreData = [XLCoreData sharedXLCoreData];
    NSManagedObjectContext *context = [coreData managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    if (type == AFNDDAYDATA|| type == AFNDMONTHDATA) {
        
        NSEntityDescription *entity;
        NSString *queryDate;
        
        if (type == AFNDDAYDATA) {
            queryDate = [self getFormatDateStringWithDate:date];
        }
        if (type == AFNDMONTHDATA) {
            queryDate = [[self getFormatDateStringWithDate:date] substringToIndex:6];;
        }
        
        if (subType == 0) {
            entity = [NSEntityDescription entityForName:@"HistoryData_PowerValue"
                                 inManagedObjectContext:context];
        }
        if (subType == 1) {
            entity = [NSEntityDescription entityForName:@"HistoryData_PowerNeeds"
                                 inManagedObjectContext:context];
        }
        if (subType == 2){
            entity = [NSEntityDescription entityForName:@"HistoryData_MeasurePoint_Sta"
                                 inManagedObjectContext:context];
        }
        
        [fetchRequest setEntity:entity];
        
        //查询条件:日月数据类型 测量点号 数据时标
        //TD....设备号
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hdDataType = %d  and hdMeasureNo = %d and hdDataTime = %@",
                                  type,
                                  pnCode,
                                  queryDate];
        
        [fetchRequest setPredicate:predicate];
        
        NSError* error;
        NSArray* array = [context executeFetchRequest:fetchRequest error:&error];
 
        return [array objectAtIndex:0];
    }
    return nil;
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

//输入 @"14年3月31日" @"3月31日21时48分"
-(NSInteger)getDateIntervalWithDateString1:(NSString*)date1 withDateString2:(NSString*)date2{
    
    //年月日
    date1 = [self getDataTime:date1];
    
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

@end



@implementation XLSyncBussinessHandler
@end


