//
//  XLHistoryDataPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-4-14.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLHistoryDataPageBussiness.h"
#import <objc/message.h>
#import "XLUtilities.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "CurveData.h"
#import <CoreData/CoreData.h>
#import "TempDalilyData.h"
#import "CurveDataNew.h"
#import "XLSyncDeviceBussiness.h"

@interface XLHistoryDataPageBussiness()


//当前请求曲线记录天数
@property(nonatomic,assign) NSInteger curveRecords;

//当前请求Socket的日期列表
@property(nonatomic,strong) NSMutableArray *requestDateArray;

//当前请求Socket的月份列表
@property(nonatomic,assign) NSMutableArray *requestMonthArray;


@property(nonatomic,retain) NSArray *plotArray1;

@property(nonatomic,retain) NSArray *plotArray2;


@property(nonatomic) XLCoreData *coreData;

//pn为测量点号的曲线的fnpn组合
@property(nonatomic) NSArray *curveMtrFnPnArray;

//日数据的fnpn组合
@property(nonatomic) NSArray *dayMtrFnPnArray;

//月数据的fnpn组合
@property(nonatomic) NSArray *monthMtrFnPnArray;

//测量点号
@property(nonatomic) NSString *mtrNo;

//用于数据库操作的context属性
@property (nonatomic,strong) NSManagedObjectContext *context;

@end

@implementation XLHistoryDataPageBussiness

SYNTHESIZE_SINGLETON_FOR_CLASS(XLHistoryDataPageBussiness)


-(id)init{
    if (self = [super init]) {
       self.context = [[XLCoreData sharedXLCoreData] managedObjectContext];
    }
    return self;
    
}

-(void)requestData{
    
    NSLog(@"requestData执行一次");
    
    NSMutableDictionary* percentDict2 = [[NSMutableDictionary alloc]init];
    [percentDict2 setObject:[NSString stringWithFormat:@"%f", 0.0] forKey:@"percent"];
    [percentDict2 setObject:self.xlName forKey:@"xl-name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewProgressPercent object:nil userInfo:percentDict2];
    
    self.curveRecords = 0;
    
    self.requestDateArray = nil;
    
    
    self.plotArray1 = nil;
    self.plotArray2 = nil;
    
    self.resultDict = nil;
    

    //历史数据
    [self requestPlotData:self.refDate withRecords:[[self.msgDic valueForKey:@"num-records"] integerValue] withTPId:1];
    
}


//发起请求数据
-(void)requestPlotData:(NSDate*)startDate withRecords:(int)numRecords withTPId:(int)tpId{
    
    if(startDate!=nil){
        self.refDate=startDate;
    }
    
    self.curveRecords = 0;
    
    switch (self.plotTimeType)
    {
        case XLViewPlotTimeNone:
            self.curveRecords = 0;
            break;
        case XLViewPlotTimeWeek:
            self.curveRecords = 7*numRecords;
            break;
        case XLViewPlotTimeMonth:
            self.curveRecords = 30*numRecords;
            break;
        case XLViewPlotTimeYear:
            self.curveRecords = 365*numRecords;
            break;
        case XLViewPlotTime1Min:
            self.curveRecords = 2;//curRecords最多为2天
            break;
        case XLViewPlotTime5Min:
            self.curveRecords = 2;//最多为2天
            break;
        case XLViewPlotTime15Min:
            self.curveRecords = 2;//最多2天
            break;
        case XLViewPlotTime30Min:
            self.curveRecords = 2;//最多2天
            break;
        case XLViewPlotTime60Min:
            self.curveRecords = 3;//最多3天
            break;
        default:
            self.curveRecords = numRecords;
            break;
    }
    
    NSLog(@"数据类型为:%d",self.plotDataType);
    
    //是否已连接终端WIFI
    BOOL flag = [XLUtilities localWifiReachable];
    
    [self requestSocketDataFromBg];
    //已连接终端 补齐召测并存库
    if (flag)
    {
        //先从数据库读取数据，然后再计算是否有未抄读的数据，有的话调用后台抄表程序
        [self renderChartFromDB];
        //获取需请求数据列表
        [self getDiffDateArray];
        
        //有未请求的数据
        if ([self.requestDateArray count]!=0//需抄读日期不为0
            || [self.requestMonthArray count] != 0)//需抄读月份不为0
        {
            //从设备补召数据，发消息给后台抄表
            [self requestSocketDataFromBg];
            //由于后台抄读的接口尚未完善，故此处先不进行后台抄读，而是直接从数据库读取.接口完善后则发消息给后台抄读程序开始抄读
            
        }
    }
    else
    {
        
        [self renderChartFromDB];
    }
}

//根据fn，从曲线表中取cvCurveType = fn的cvAvg的值
-(NSArray*)readCurveDataFromDBwithFn:(NSInteger)fn withDate:(NSString*)dateString
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //声明实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CurveData"
                                              inManagedObjectContext:_context];
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"cvCurveType = %d and dataTime = %@",fn,dateString];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    //返回检索结果
    return (NSArray*)[_context executeFetchRequest:fetchRequest error:&error];
}


#pragma mark - 抄读数据相关
-(void)requestSocketDataFromBg
{
    //注册通知，接收后台抄完之后发送的通知，并刷新列表
    XLSyncDeviceBussiness *syncDeviceBussiness = [[XLSyncDeviceBussiness alloc] init];

    NSArray *curveDTArray = [NSArray arrayWithObjects:@"F223", nil];
    syncDeviceBussiness.curveDTArray = curveDTArray;
    syncDeviceBussiness.isTempRead = YES;
    syncDeviceBussiness.terDAArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], nil];
    [syncDeviceBussiness beginSyncWithStartDate:self.refDate withEndDate:self.refDate];
    
    
}



#pragma mark - 日期处理相关

//获取指定日期分
-(NSInteger)getMinuteWithDate:(NSDate*)_date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSMinuteCalendarUnit)
                                               fromDate:_date];
    
    return [components minute];
}

//获取指定日期时
-(NSInteger)getHourWithDate:(NSDate*)_date{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit)
                                               fromDate:_date];
    
    return [components hour];
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

//生成日期数组集合
-(NSArray*)getDateSet{
    
    NSMutableArray *dateSet = [NSMutableArray array];
    
    //开始抄读时间
    NSDate *newDate = self.refDate;
    
    //当前时间
    NSString* nowDateString;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    nowDateString = [formatter stringFromDate:[NSDate date]];
    
    //开始计算时间
    for(int i = 0;i<self.curveRecords;i++)//共抄self.curveRecords天数据
    {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[NSNumber numberWithInteger:[self getYearWithDate:newDate]]
               forKey:@"year"];
        
        [dic setValue:[NSNumber numberWithInteger:[self getMonthWithDate:newDate]]
               forKey:@"month"];
        
        [dic setValue:[NSNumber numberWithInteger:[self getDayWithDate:newDate]]
               forKey:@"day"];
        
        NSString *tempDateString = [NSString stringWithFormat:@"%04d-%02d-%02d",[[dic valueForKey:@"year"] integerValue],[[dic valueForKey:@"month"] integerValue],[[dic valueForKey:@"day"] integerValue]];
        
        //用来判断时间是否超过了手机当前时间，如果超过了，则不再继续计算
        NSDate *nowDate = [formatter dateFromString:nowDateString];
        NSDate *tempDate = [formatter dateFromString:tempDateString];
        
        if([tempDate compare:nowDate] == NSOrderedDescending)
        {
            break;
        }
        
        [dateSet addObject:dic];
        
        
        newDate = [self nsdateAddDayWithDate:newDate withDiff:1 withType:self.plotTimeType];
    }
    //返回从self.refDate开始，最多self.curveRecords个数据
    return dateSet;
}

//根据时间间隔计算日期
-(NSDate*)nsdateAddDayWithDate:(NSDate*)date withDiff:(NSInteger)num withType:(NSInteger)type{
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    switch (type) {
            
        case XLViewPlotTimeDay:
            [dateComponents setDay:num];
            break;
            
        case XLViewPlotTimeWeek:
            //[dateComponents setWeek:num];
            //在进行周数据处理时，先把所有日的抄读完成并存库后再进行周数据的统计
            [dateComponents setDay:num];
            break;
            
        case XLViewPlotTimeMonth:
            [dateComponents setDay:num];
            break;
            
        case XLViewPlotTimeYear:
            [dateComponents setDay:num];
            break;
        case XLViewPlotTime1Min:
        case XLViewPlotTime5Min:
        case XLViewPlotTime15Min:
        case XLViewPlotTime30Min:
        case XLViewPlotTime60Min:
            [dateComponents setDay:num];
            break;
        default:
            break;
    }
    
    NSDate *newDate = [[NSCalendar currentCalendar]
                       dateByAddingComponents:dateComponents
                       toDate:date options:0];
    
    return newDate;
}



-(NSArray*)getFormatDateSet{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSArray* array = [self getDateSet];
    if (array) {
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary* dic = (NSDictionary*)obj;
            [resultArray addObject:[NSString stringWithFormat:@"%4d-%02d-%02d",
                                    [[dic valueForKey:@"year"] integerValue],
                                    [[dic valueForKey:@"month"] integerValue],
                                    [[dic valueForKey:@"day"] integerValue]]];
        }];
    }
    return resultArray;
}

//获取当前请求的日期数据在数据库中是否不存在
-(void)getDiffDateArray{
    
    NSString *date = [NSString stringWithFormat:@"%04d-%02d-%02d",[self getYearWithDate:self.refDate],[self getMonthWithDate:self.refDate],[self getDayWithDate:self.refDate]];
    //进行检查数据库里面是否有该日的数据，要检查的表有：曲线表、终端统计数据表等
    NSArray *entityNameArray =[NSArray arrayWithObjects:
                               @"CurveData",
                               @"HistoryData_PowerNeeds",
                               @"HistoryData_PowerValue",
                               @"HistoryData_MeasurePoint_Sta",
                               nil];
    NSArray *predicateStringArray =[NSArray arrayWithObjects:
                                    [NSString stringWithFormat:@"cvDataTime = %@",date],
                                    [NSString stringWithFormat:@"hdDataTime = %@",date],
                                    [NSString stringWithFormat:@"hdDataTime = %@",date],
                                    [NSString stringWithFormat:@"hdDataTime = %@",date],
                                    nil];
    
    for(int i=0;i<[entityNameArray count];i++)
    {
        
        //判断如果没有抄到数据，则break，否则继续
        NSPredicate *predicate =[NSPredicate predicateWithFormat:[predicateStringArray objectAtIndex:i]];
        if(![self readDataFromDBWithEntityName:[entityNameArray objectAtIndex:i] withPredicate:predicate])
        {
            [self.requestDateArray addObject:self.refDate];
            break;
        }
    }
}


#pragma mark -数据库相关

//根据检索条件和表名进行数据检索
-(NSArray*)readDataFromDBWithEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    //声明数据库实例
    //    self.coreData = [XLCoreData sharedXLCoreData];
    //
    //    NSManagedObjectContext *context = [self.coreData managedObjectContext];
    //    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    //    [context setParentContext:self.contextParent];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //声明实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:_context];
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    //设置检索条件
    //    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    //返回检索结果
    return (NSArray*)[_context executeFetchRequest:fetchRequest error:&error];
}


//历史数据页面查询数据库
-(NSArray*)renderCharDataWithType:(XLViewPlotDataType)type withPlotName:(NSString*)plotName withPlotType:(XLViewPlotTimeType)timeType
{
    
    //查询结果集合
    __block NSMutableArray *resultlist = [NSMutableArray array];
    
    //根据名称确定f项
    if([plotName isEqualToString:@"油温(℃)"])
    {
        [[self getFormatDateSet] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSString *dateString = (NSString*)obj;
            NSMutableArray *dataMapKeys = [self.msgDic valueForKey:@"data-map-keys"];
            if([dataMapKeys count]>0)
            {
                NSString* key = [dataMapKeys objectAtIndex:0];
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                NSArray *result = [self readCurveDataFromDBwithFn:223 withDate:dateString];
                if([result count]>0)
                {
                    [map setObject:[(CurveData*)[result objectAtIndex:0] valueForKey:@"cvAvg"] forKey:key];
                }
                else
                {
                    [map setObject:@"" forKey:key];
                }
                
                [resultlist addObject:map];
            }
        }];
    }
    
    if([plotName isEqualToString:@"ABC相绕组温度(℃)"])
    {
        [[self getFormatDateSet] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSString *dateString = (NSString*)obj;
            NSMutableArray *dataMapKeys = [self.msgDic valueForKey:@"data-map-keys"];
            if([dataMapKeys count]>0)
            {
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                for(int i=0;i<[dataMapKeys count];i++)
                {
                    
                    NSString* key = [dataMapKeys objectAtIndex:i];
                    
                    NSArray *result = [self readCurveDataFromDBwithFn:224+i withDate:dateString];
                    
                    if([result count]>0)
                    {
                        [map setObject:[(CurveData*)[result objectAtIndex:0] valueForKey:@"cvAvg"] forKey:key];
                    }
                    else
                    {
                        [map setObject:@"" forKey:key];
                    }
                    
                    [resultlist addObject:map];
                }
                
            }
        }];
    }
    
    
    if([plotName isEqualToString:@"ABC三相电压(V)"])
    {
        [[self getFormatDateSet] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSString *dateString = (NSString*)obj;
            NSMutableArray *dataMapKeys = [self.msgDic valueForKey:@"data-map-keys"];
            if([dataMapKeys count]>0)
            {
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                for(int i=0;i<[dataMapKeys count];i++)
                {
                    
                    NSString* key = [dataMapKeys objectAtIndex:i];
                    
                    NSArray *result = [self readCurveDataFromDBwithFn:89+i withDate:dateString];
                    
                    if([result count]>0)
                    {
                        [map setObject:[(CurveData*)[result objectAtIndex:0] valueForKey:@"cvAvg"] forKey:key];
                    }
                    else
                    {
                        [map setObject:@"" forKey:key];
                    }
                    
                    [resultlist addObject:map];
                }
                
            }
        }];
    }

    
    
    if(resultlist)
    {
        NSInteger resultlistCount = [resultlist count];
        if(resultlistCount<30)
        {
            for(int i=0;i<30-resultlistCount;i++)
            {
                [resultlist addObject:[NSNull null]];
            }
        }
        
        return resultlist;
    }
    else
    {
        
        return nil;
    }
}

//从Sqlite加载数据并刷新图表
-(void)renderChartFromDB{
    self.plotArray1 = [self renderCharDataWithType:self.plotDataType withPlotName:[self.msgDic valueForKey:@"plot-name"] withPlotType:[[self.msgDic valueForKey:@"time-type"] integerValue]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"移除通知");
    
    //调用代理
    //[self.delegate chartDataDidReadyWithChartArray1:self.plotArray1 withChartArray2:self.plotArray2];
    //改代理机制了
    self.resultDict = [NSMutableDictionary dictionary];
    if((!(self.plotArray1==nil))&&([self.plotArray1 count]!=0))
    {
        [self.resultDict setObject:self.plotArray1 forKey:@"array1"];
        if(self.plotArray2)
        {
            [self.resultDict setObject:self.plotArray2 forKey:@"array2"];
        }
        else
        {
            
        }
    }
    
    NSMutableDictionary* percentDict2 = [[NSMutableDictionary alloc]init];
    [percentDict2 setObject:[NSString stringWithFormat:@"%f", 1.0] forKey:@"percent"];
    
    [percentDict2 setObject:self.xlName forKey:@"xl-name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewProgressPercent object:nil userInfo:percentDict2];
    
    [self.resultDict setObject:self.msgDic forKey:@"parameter"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:self.resultDict];
}

@end
