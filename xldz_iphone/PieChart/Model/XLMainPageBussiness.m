//
//  XLMainPageBussiness.m
//  XLApp
//
//  Created by JY on 14-3-10.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLMainPageBussiness.h"
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
#import "TempWeekData.h"
#import "TempMonthData.h"
#import "TempYearData.h"
#import "HistoryData_PowerValue.h"
#import "HistoryData_PowerNeeds.h"
#import "HistoryData_MeasurePoint_Sta.h"
#import "XLSyncDeviceBussiness.h"

#import "XLEconomicDetailPageBussiness.h"

@interface requestPlotDataParam : NSObject //定义一个类，用来存放查询数据时的变量

@property(nonatomic) NSDate* startDate;
@property(nonatomic) int numRecords;
@property(nonatomic) int tpId;

@end

@implementation requestPlotDataParam//类的实现，由于变量会自动生成getset方法，不需要额外定义

@end

@interface XLMainPageBussiness()

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

#define IsOldProtocol 1
#define RECORDSNUM 30

#define epsilon 0.000001

////requestPlotData时定义缓冲区需要用到的struct
//typedef struct
//{
//    NSDate* startDate;//开始时间
//    int numRecords;//个数
//    int tpId;//pn
//}requestPlotDataParam;


@implementation XLMainPageBussiness


SYNTHESIZE_SINGLETON_FOR_CLASS(XLMainPageBussiness)



#pragma mark - 请求数据相关

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
    
    
    [self requestPlotData:self.refDate withRecords:RECORDSNUM withTPId:1];
    
}

//发起请求数据
-(void)requestPlotData:(NSDate*)startDate withRecords:(int)numRecords withTPId:(int)tpId{
    
    if(startDate!=nil){
        self.refDate=startDate;
    }
    
    self.curveRecords = 0;
    
    if([[self.msgDic valueForKey:@"xl-name"] isEqualToString:@"plotdata-detail"])
    {
        switch (self.plotTimeType)
        {
            case XLViewPlotTimeNone:
                self.curveRecords = 0;
                break;
            case XLViewPlotTimeWeek:
                self.curveRecords = 7;
                break;
            case XLViewPlotTimeMonth:
            {
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSRange rng = [cal rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:self.refDate];
                NSUInteger numberOfDaysInMonth = rng.length;
                self.curveRecords = numberOfDaysInMonth;
            }
                break;
            case XLViewPlotTimeYear:
                self.curveRecords = 366;//12个月
                break;
            case XLViewPlotTime1Min:
                self.curveRecords = 1;//curRecords最多为2天
                break;
            case XLViewPlotTime5Min:
                self.curveRecords = 1;//最多为2天
                break;
            case XLViewPlotTime15Min:
                self.curveRecords = 1;//最多2天
                break;
            case XLViewPlotTime30Min:
                self.curveRecords = 1;//最多2天
                break;
            case XLViewPlotTime60Min:
                self.curveRecords = 1;//最多3天
                break;
            default:
                self.curveRecords = 1;
                break;
        }
    }
    else
    {
        switch (self.plotTimeType)
        {
            case XLViewPlotTimeNone:
                self.curveRecords = 0;
                break;
            case XLViewPlotTimeWeek:
                self.curveRecords = 7*RECORDSNUM;
                break;
            case XLViewPlotTimeMonth:
                self.curveRecords = 30*RECORDSNUM;
                break;
            case XLViewPlotTimeYear:
                self.curveRecords = 365*RECORDSNUM;
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
                self.curveRecords = RECORDSNUM;
                break;
        }
    }
    
    
    NSLog(@"数据类型为:%d",self.plotDataType);
    
    //是否已连接终端WIFI
    BOOL flag = [XLUtilities localWifiReachable];
    
    //已连接终端 补齐召测并存库
    if (flag)
    {
        //先从数据库读取数据，然后再计算是否有未抄读的数据，有的话调用后台抄表程序
        [self renderChartFromDB];
        //获取需请求数据列表
//        [self getDiffDateArray];
    
        XLEconomicDetailPageBussiness *xlEconomicDetailPageBussiness = [XLEconomicDetailPageBussiness sharedXLEconomicDetailPageBussiness];
        [xlEconomicDetailPageBussiness judgeEconomic];
        //有未请求的数据
        if ([self.requestDateArray count]!=0//需抄读日期不为0
            || [self.requestMonthArray count] != 0)//需抄读月份不为0
        {
            //从设备补召数据，发消息给后台抄表
            //            [self requestSocketDataFromBg];
            //由于后台抄读的接口尚未完善，故此处先不进行后台抄读，而是直接从数据库读取.接口完善后则发消息给后台抄读程序开始抄读
            
        }
    }
    else
    {
        
        [self renderChartFromDB];
    }
}

#pragma mark - 抄读数据相关
-(void)requestSocketDataFromBg
{
    //注册通知，接收后台抄完之后发送的通知，并刷新列表
    
    //组织fnpn
    [self initFnPnArray];
    //组织要抄读的数据参数,参数格式为directory，key为0：实时/1：历史，value:{(key:0曲线/1日/2月,value:array((array同一天同一测量点的放在一起)))}
    
    //根据抄读数据self.plotTimeType，判断是实时还是历史
    
    //遍历日期表
    
    __block NSMutableArray *allCurveDateArrays = [[NSMutableArray alloc] init];
    __block NSMutableArray *allDayDateArrays = [[NSMutableArray alloc] init];
    __block NSMutableArray *allMonthDateArrays = [[NSMutableArray alloc] init];
    
    //遍历日期
    [self.requestDateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setDateFormat: @"yyyy-MM-dd"];
        NSString *dateString = [NSString stringWithFormat:@"%d-%02d-%02d",[[obj valueForKey:@"year"] integerValue],[[obj valueForKey:@"month"] integerValue],[[obj valueForKey:@"day"] integerValue]];
        
        NSDate *destDate= [dateFormatter dateFromString:dateString];
        
        NSMutableArray *sameDateArrays = [[NSMutableArray alloc]init];
        NSMutableArray *sameDayDateArrays = [[NSMutableArray alloc]init];
        
        for(int i=0;i<[self.curveMtrFnPnArray count];i++)
        {
            
            NSArray *fnPnDateArray = [NSArray arrayWithObjects:
                                      [self.curveMtrFnPnArray objectAtIndex:i],
                                      self.mtrNo,
                                      destDate,
                                      nil];
            [sameDateArrays addObject:fnPnDateArray];
            
        }
        for(int i=0;i<[self.dayMtrFnPnArray count];i++)
        {
            NSArray *fnPnDateArray = [NSArray arrayWithObjects:
                                      [self.dayMtrFnPnArray objectAtIndex:i],
                                      self.mtrNo,
                                      destDate,
                                      nil];
            [sameDayDateArrays addObject:fnPnDateArray];
        }
        
        [allCurveDateArrays addObject:sameDateArrays];
        [allDayDateArrays addObject:sameDayDateArrays];
    }];
    
    //遍历月份
    [self.requestMonthArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //将日期string转换成nsdate
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM"];
        NSString *dateString = [NSString stringWithFormat:@"%d-%02d",[[obj valueForKey:@"year"] integerValue],[[obj valueForKey:@"month"] integerValue]];
        NSDate *destDate= [dateFormatter dateFromString:dateString];
        
        NSMutableArray *sameDateArrays = [[NSMutableArray alloc]init];
        
        for(int i=0;i<[self.monthMtrFnPnArray count];i++)
        {
            
            NSArray *fnPnDateArray = [NSArray arrayWithObjects:
                                      [self.monthMtrFnPnArray objectAtIndex:i],
                                      self.mtrNo,
                                      destDate,
                                      nil];
            [sameDateArrays addObject:fnPnDateArray];
        }
        //将同一日期的数组加入到总的数组中
        [allMonthDateArrays addObject:sameDateArrays];
    }];
    
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         allCurveDateArrays,@"0",//曲线
                         allDayDateArrays,@"1",//日冻结
                         allMonthDateArrays,@"2",//月冻结
                         nil];//曲线/日/月
    NSString *finalDicKey=@"";
    
    switch (self.plotTimeType) {
        case XLViewPlotTime60Min:
        case XLViewPlotTime30Min:
        case XLViewPlotTime15Min:
        case XLViewPlotTime5Min:
        case XLViewPlotTime1Min:
            finalDicKey = @"0";
            break;
        case XLViewPlotTimeYear:
        case XLViewPlotTimeWeek:
        case XLViewPlotTimeMonth:
        case XLViewPlotTimeDay:
            finalDicKey = @"1";
            break;
            
        default:
            break;
    }
    
    NSDictionary *finalDic = [NSDictionary dictionaryWithObject:dic forKey:finalDicKey];
    
    //发送通知给后台抄表程序
    [[NSNotificationCenter defaultCenter] postNotificationName:@"requestForeGroundData" object:nil userInfo:finalDic];
}

#pragma mark - 日期处理相关
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

-(void)initFnPnArray
{
    //曲线fnpn组合
    self.curveMtrFnPnArray = [NSArray arrayWithObjects:
                              @"F81",//有功功率
                              @"F82",
                              @"F83",
                              @"F84",
                              @"F85",//无功功率
                              @"F86",
                              @"F87",
                              @"F88",
                              @"F89",//电压
                              @"F90",
                              @"F91",
                              @"F92",//电流
                              @"F93",
                              @"F94",
                              @"F105",//功率因数
                              @"F106",
                              @"F107",
                              @"F108",
                              nil];
    
    
    //日数据fnpn组合
    self.dayMtrFnPnArray = [NSArray arrayWithObjects:@"F3",
                            @"F5",
                            @"F25",
                            @"F26",
                            @"F45",nil];
    
    //月数据fnpn组合
    self.monthMtrFnPnArray = [NSArray arrayWithObjects:@"F33",
                              @"F21",
                              @"F46",
                              @"F34", nil];
    
    //测量点号，默认为1
    self.mtrNo = @"1";
    
}

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


//当前日一年中的第几天
-(NSInteger)dayOfYear{
    
    NSCalendar *gregorian =
    [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger dayOfYear =
    [gregorian ordinalityOfUnit:NSDayCalendarUnit
                         inUnit:NSYearCalendarUnit
                        forDate:[NSDate date]];
    
    return dayOfYear;
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

-(NSArray*)getFormatDateSetWithStartDate:(NSDate*)startDate withDayCount:(NSInteger)dayCount
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    for(int i=0;i<dayCount;i++)
    {
        NSDate *tempDate =[self nsdateAddDayWithDate:startDate withDiff:i withType:self.plotTimeType];
        [resultArray addObject:[NSString stringWithFormat:@"%d-%02d-%02d",[self getYearWithDate:tempDate],[self getMonthWithDate:tempDate],[self getDayWithDate:tempDate]]];
        //        NSLog(@"时间：%@",[resultArray objectAtIndex:i]);
    }
    
    return resultArray;
    
    
    //    return [NSArray arrayWithObjects:@"2013-09-09", nil];
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

-(NSArray*) getMonthSet:(NSArray*)dateArray{
    NSMutableArray *resultDicArray=[[NSMutableArray alloc] init];
    [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([resultDicArray count]==0)
        {
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            [temp setObject:[obj valueForKey:@"year"] forKey:@"year"];
            [temp setObject:[obj valueForKey:@"month"] forKey:@"month"];
            
            [resultDicArray addObject:temp];
        }
        [resultDicArray enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
            
            if(([[obj valueForKey:@"year"] integerValue] == [[[resultDicArray objectAtIndex:idx1] valueForKey:@"year"] integerValue])
               && ([[obj valueForKey:@"month"] integerValue] == [[[resultDicArray objectAtIndex:idx1] valueForKey:@"month"] integerValue]))
            {
                *stop1 = YES;
            }
            else if(idx1 == [resultDicArray count]-1)
            {
                
                NSMutableDictionary *temp = [NSMutableDictionary dictionary];
                [temp setObject:[obj valueForKey:@"year"] forKey:@"year"];
                [temp setObject:[obj valueForKey:@"month"] forKey:@"month"];
                [resultDicArray addObject:temp];
                *stop1 = YES;
            }
            
        }];
        
    }];
    return resultDicArray;
}


-(NSArray*) getFormatMonthSet:(NSArray*)dateArray{
    NSMutableArray *resultDicArray=[[NSMutableArray alloc] init];
    [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([resultDicArray count]==0)
        {
            NSMutableDictionary *temp = [NSMutableDictionary dictionary];
            [temp setObject:[obj valueForKey:@"year"] forKey:@"year"];
            [temp setObject:[obj valueForKey:@"month"] forKey:@"month"];
            
            [resultDicArray addObject:temp];
        }
        [resultDicArray enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
            
            if(([[obj valueForKey:@"year"] integerValue] == [[[resultDicArray objectAtIndex:idx1] valueForKey:@"year"] integerValue])
               && ([[obj valueForKey:@"month"] integerValue] == [[[resultDicArray objectAtIndex:idx1] valueForKey:@"month"] integerValue]))
            {
                *stop1 = YES;
            }
            else if(idx1 == [resultDicArray count]-1)
            {
                
                NSMutableDictionary *temp = [NSMutableDictionary dictionary];
                [temp setObject:[obj valueForKey:@"year"] forKey:@"year"];
                [temp setObject:[obj valueForKey:@"month"] forKey:@"month"];
                [resultDicArray addObject:temp];
                *stop1 = YES;
            }
            
        }];
        
    }];
    NSMutableArray *resultArray=[[NSMutableArray alloc] init];
    for(int i= 0;i<[resultDicArray count];i++)
    {
        NSString *temp = [NSString stringWithFormat:@"%04d-%02d",
                          [[[resultDicArray objectAtIndex:i] valueForKey:@"year"] integerValue],
                          [[[resultDicArray objectAtIndex:i] valueForKey:@"month"] integerValue]];
        [resultArray addObject:temp];
    }
    return resultArray;
}


//得到月份集合，直接用开始时间，往后数30个月
-(NSArray*) getFormatMonthSet{
    NSMutableArray *resultArray=[[NSMutableArray alloc] init];
    NSInteger startYear = [self getYearWithDate:self.refDate];
    NSInteger startMonth = [self getMonthWithDate:self.refDate];
    for(int i=0;i<30;i++)
    {
        NSInteger tempYear = 0;
        NSInteger tempMonth = 0;
        if((startMonth + i)%12 == 0)
        {
            tempYear = startYear + (startMonth+i)/12 -1;
            tempMonth = 12;
        }
        else
        {
            tempYear =startYear + (startMonth+i)/12;
            tempMonth =(startMonth + i)%12;
        }
        NSString *temp = [NSString stringWithFormat:@"%04d-%02d",
                          tempYear,
                          tempMonth];
        [resultArray addObject:temp];
        
    }
    return resultArray;
}

//得到抄读的数据所在月份的集合，用于存储月数据时用
-(NSArray*) getYearSet:(NSArray*)dateArray{
    NSMutableArray *resultArray=[[NSMutableArray alloc] init];
    [dateArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if([resultArray count]==0)
        {
            NSString *year;
            year=[obj valueForKey:@"year"];
            [resultArray addObject:year];
        }
        [resultArray enumerateObjectsUsingBlock:^(id obj1, NSUInteger idx1, BOOL *stop1) {
            
            if([[obj valueForKey:@"year"] integerValue] == [[resultArray objectAtIndex:idx1] integerValue])
            {
                *stop1 = YES;
            }
            else if(idx1 == [resultArray count]-1)
            {
                NSString *year;
                year = [obj valueForKey:@"year"];
                [resultArray addObject:year];
            }
            
        }];
        
    }];
    return resultArray;
}

//得到抄读的数据所在月份的集合，用于存储月数据时用
-(NSArray*) getYearSet
{
    NSMutableArray *resultArray=[[NSMutableArray alloc] init];
    
    NSInteger startYear = [self getYearWithDate:self.refDate];
    for(int i=0;i<30;i++)
    {
        NSInteger tempYear = startYear + i;
        [resultArray addObject:[NSNumber numberWithInteger:tempYear]];
    }
    return resultArray;
}


//获取当前请求的数据日期集合与数据库已有数据的差集
-(void)getDiffDateArray{
    
    self.requestDateArray = [NSMutableArray array];
    NSArray *currDatelist = [self getDateSet];
    __block NSDictionary *dic;
    __block NSString *date;
    
    [currDatelist enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        //        NSLog(@"%@",[NSString stringWithFormat:@"遍历List%d次",idx+1]);
        NSMutableDictionary* percentDict2 = [[NSMutableDictionary alloc]init];
        [percentDict2 setObject:[NSString stringWithFormat:@"%f", idx*1.0/[currDatelist count]] forKey:@"percent"];
        [percentDict2 setObject:self.xlName forKey:@"xl-name"];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewProgressPercent object:nil userInfo:percentDict2];
        
        
        dic = (NSDictionary*)obj;
        date = [NSString stringWithFormat:@"%04d-%02d-%02d",[[dic valueForKey:@"year"] integerValue],
                [[dic valueForKey:@"month"] integerValue],
                [[dic valueForKey:@"day"] integerValue]];
        
        //判断date是否为当前date，如果是则直接加入到抄读列表中
        //当前时间
        NSString* nowDateString;
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        nowDateString = [formatter stringFromDate:[NSDate date]];
        
        if([date isEqualToString:nowDateString])
        {
            [self.requestDateArray addObject:dic];
        }
        else
        {
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
            
            XL_UINT8 i=0;//循环变量
            for(int i=0;i<[entityNameArray count];i++)
            {
                
                //判断如果没有抄到数据，则break，否则继续
                NSPredicate *predicate =[NSPredicate predicateWithFormat:[predicateStringArray objectAtIndex:i]];
                if(![self readDataFromDBWithEntityName:[entityNameArray objectAtIndex:i] withPredicate:predicate])
                {
                    break;
                }
            }
            //判断循环变量如果小于[entityNameArray count]-1,则说明有缺失的表数据，则将该日期加入到diffDate中
            if(i<([entityNameArray count]-1))
            {
                [self.requestDateArray addObject:dic];
            }
            
            
        }
        
    }];
    //如果是月数据抄读，则判断该月月冻结数据是否已经抄读，如果没有抄读
    if(self.plotTimeType == XLViewPlotTimeMonth
       || self.plotTimeType == XLViewPlotTimeYear)
    {
        
        NSArray *monthList = [self getMonthSet:currDatelist];
        [monthList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            dic =(NSDictionary*)obj;
            NSString *month =[NSString stringWithFormat:@"%04d-%02d",[[dic valueForKey:@"year"] integerValue],[[dic valueForKey:@"month"] integerValue]];
            
            NSArray *entityNameArray =[NSArray arrayWithObjects:
                                       @"HistoryData_PowerNeeds",
                                       @"HistoryData_PowerValue",
                                       @"HistoryData_MeasurePoint_Sta",
                                       nil];
            NSArray *predicateStringArray =[NSArray arrayWithObjects:
                                            [NSString stringWithFormat:@"hdDataType = 2 and hdDataTime = %@",month],
                                            [NSString stringWithFormat:@"hdDataType = 2 and hdDataTime = %@",month],
                                            [NSString stringWithFormat:@"hdDataType = 2 and hdDataTime = %@",month],
                                            nil];
            
            XL_UINT8 i=0;//循环变量
            for(int i=0;i<[entityNameArray count];i++)
            {
                
                //判断如果没有抄到数据，则break，否则继续
                NSPredicate *predicate = [NSPredicate predicateWithFormat:[predicateStringArray objectAtIndex:i]];
                if(![self readDataFromDBWithEntityName:[entityNameArray objectAtIndex:i] withPredicate:predicate])
                {
                    break;
                }
            }
            //判断循环变量如果小于[entityNameArray count]-1,则说明有缺失的表数据，则将该日期加入到diffDate中
            if(i<([entityNameArray count]-1))
            {
                [self.requestMonthArray addObject:dic];
            }
        }];
        
    }
    
}

//根据年月日得到星期几，星期日，返回值为1
-(NSInteger)dayOfWeekWithYear:(NSInteger)year WithMonth:(NSInteger)month WithDay:(NSInteger)day
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat : @"yyyy-MM-dd"];
    NSString *stringTime = [NSString stringWithFormat:@"%04d-%02d-%02d",year,month,day];
    NSDate *dateTime = [formatter dateFromString:stringTime];
    NSDateComponents*comps;
    NSCalendar*calendar = [NSCalendar currentCalendar];
    
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
            
                       fromDate:dateTime];
    
    //NSInteger week = [comps week]; // 今年的第几周
    
    NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
    
    //NSInteger weekdayOrdinal = [comps weekdayOrdinal]; // 这个月的第几周
    
    //NSLog(@"week:%d weekday: %d weekday ordinal: %d", week, weekday, weekdayOrdinal);
    return weekday;
}

//根据年月日string得到星期几,日期格式为"yyyy-M-d"，星期日，返回值为1
-(NSInteger)dayOfWeekWithDateString:(NSString*)dateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat : @"yyyy-MM-dd"];
    //    NSLog(@"StringTime=%@",dateString);
    NSDate *dateTime = [formatter dateFromString:dateString];
    NSDateComponents*comps;
    NSCalendar*calendar = [NSCalendar currentCalendar];
    
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
            
                       fromDate:dateTime];
    
    //NSInteger week = [comps week]; // 今年的第几周
    
    NSInteger weekday = [comps weekday]; // 星期几（注意，周日是“1”，周一是“2”。。。。）
    
    //NSInteger weekdayOrdinal = [comps weekdayOrdinal]; // 这个月的第几周
    
    //NSLog(@"week:%d weekday: %d weekday ordinal: %d", week, weekday, weekdayOrdinal);
    return weekday;
}

//计算两个日期格式的差别天数
-(NSInteger)getDaysCountFromDBWithEndDate:(NSString*)dateString
{
    NSInteger time = 0;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hdDataType = 1 and hdDataTime < %@",dateString];
    
    NSArray *result1 = [self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:predicate];
    
    predicate = [NSPredicate predicateWithFormat:@"hdDataType = 1 and hdDataTime BEGINSWITH[c] %@",dateString];
    NSArray *result2 = [self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:predicate];
    
    if(result1 !=nil)
    {
        time += [result1 count];
    }
    if(result2 != nil)
    {
        
        time += [result2 count];
    }
    
    return time;
}


#pragma mark - SQLite数据库相关
//保存召测回的数据


//根据检索条件和表名进行数据检索
-(NSArray*)readDataFromDBWithEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    //声明数据库实例
    
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



//从数据库获取曲线数据,curveType:总,a,b,c
-(NSArray*)getCurveDataFromArrayWithArray:(NSArray*)curveArray WithPlotDataType:(XLViewPlotDataType)type WithPhaseType:(XLPhaseType)phaseType
{
    
    int count = [curveArray count];
    
    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
    for(int i=0;i<count;i++)
    {
        CurveData* temp;
        temp=(CurveData*)[curveArray objectAtIndex:i];
        
        XL_UINT8 curveType = 0;
        
        switch (type)
        {
            case XLViewPlotDataSumAndTPPowerFactor://功率因数K线
            case XLViewPlotDataSumAndTPPowerFactorScatter://功率因数曲线
            {
                curveType = 105+phaseType;
                
            }
                break;
            case XLViewPlotDataSumAndTPReactivePower://无功功率K线
            case XLViewPlotDataSumAndTPReactivePowerScatter://无功功率曲线
            {
                curveType = 85 + phaseType;
                
            }
                break;
            case XLViewPlotDataSumAndTPRealPower://有功功率K线
            case XLViewPlotDataSumAndTPRealPowerScatter://有功功率曲线
            {
                curveType = 81 + phaseType;
                
            }
                break;
            case XLViewPlotDataTPCurr://电流
            {
                if(phaseType == XLPhaseZ)
                {
                    curveType = 0;
                }
                else
                {
                    curveType = 92+(phaseType-1);
                }
            }
                break;
            case XLViewPlotDataTPVolt://电压
            {
                if(phaseType == XLPhaseZ)
                {
                    curveType = 0;
                }
                else
                {
                    curveType = 89+(phaseType-1);
                }
            }
                break;
                
            default:
                break;
        }
        
        if((NSInteger)[[temp valueForKey:@"cvCurveType"] integerValue] == curveType)
        {
            [resultArray addObject:temp];
        }
    }
    return resultArray;
}

//从数据库获取曲线数据
-(NSArray*)getCurveDataFromArrayWithArray:(NSArray*)curveArray WithCurvetype:(NSInteger)curveType{
    
    int count = [curveArray count];
    
    NSMutableArray* resultArray = [[NSMutableArray alloc]init];
    for(int i=0;i<count;i++)
    {
        CurveData* temp;
        temp=(CurveData*)[curveArray objectAtIndex:i];
        if((NSInteger)[[temp valueForKey:@"cvCurveType"] integerValue] == curveType)
        {
            [resultArray addObject:temp];
        }
    }
    return resultArray;
}


//计算出数组的平均值
-(double)computeMonthAvgWithArray:(NSArray*)curveArray
{
    double sum = 0.0;
    
    for(int i=0;i<[curveArray count];i++)
    {
        sum +=  [[(CurveData*)[curveArray objectAtIndex:i] cvAvg] doubleValue];
    }
    return  sum/[curveArray count];
}



//从数据库中得到数据列表
-(NSMutableArray*)getRtDataResultList:(XLViewPlotDataType)type{
    
    NSMutableArray *resultlist =[[NSMutableArray alloc] init];
    
    //查询该日曲线数据
    NSArray *dataTimeScale =[self getFormatDateSetWithStartDate:self.refDate withDayCount:self.curveRecords];
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@" cvDataTime in %@",dataTimeScale];
    
    NSArray *requestCurveResult = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
    //电能示值类数据
    predicate =[NSPredicate predicateWithFormat:@"hdDataTime in %@",dataTimeScale];
    NSArray *powerValueResult =[self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:predicate];
    //需量类数据
    predicate =[NSPredicate predicateWithFormat:@"hdDataTime in %@",dataTimeScale];
    NSArray *powerNeedsResult =[self readDataFromDBWithEntityName:@"HistoryData_PowerNeeds" withPredicate:predicate];
    
    NSArray *maxminArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithCurvetype:81];//功率最大最小值
    NSArray *pfArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithCurvetype:105];//功率因数平均值
    
    //总、abc三相数组
    NSArray *totalArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseZ];
    NSArray *axArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseA];
    NSArray *bxArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseB];
    NSArray *cxArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseC];
    
    if([axArray count]>0
       && [bxArray count]>0
       && [cxArray count]>0)
    {
        switch (self.plotTimeType) {
            case XLViewPlotTime1Min:
            case XLViewPlotTime5Min:
            case XLViewPlotTime15Min://只抄曲线数据
            {
                
                NSInteger startPoint = [self getHourWithDate:self.refDate]*4+([self getMinuteWithDate:self.refDate]/15+1);
                
                for(int i=0;i<30;i++)
                {
                    if([axArray count]>0 )
                    {
                        XL_UINT8 index = ((startPoint+i)%96==0 ? 0: (startPoint+i)/96);//索引，最多有两天的数据，所以索引值为0或者1
                        XL_UINT8 cvPoint = ((startPoint+i)%96==0 ? 96:(startPoint + i)%96);//在该索引下，曲线点。
                        
                        if(index >= [axArray count] || index >= [bxArray count] || index >= [cxArray count])
                        {
                            break;
                        }
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        if([totalArray count]>0)
                        {
                            if(index >= [totalArray count])
                            {
                                continue;
                            }
                            [dic setValue:[self parseVaildWithData:[(CurveData*)[totalArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint]] ] forKey:@"pj"];
                        }
                        
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[axArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"ax"];
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[bxArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"bx"];
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[cxArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"cx"];
                        [resultlist addObject:dic];
                    }
                }
            }
                
                break;
            case XLViewPlotTime30Min://需要计算大小,起始和结束值
            {
                
                NSInteger startPoint = [self getHourWithDate:self.refDate]*4+([self getMinuteWithDate:self.refDate]/15)+1;
                
                for(int i=0;i<30;i++)
                {
                    if([axArray count] >0)
                    {
                        int index = ((startPoint+i*2)%96==0 ? 0: (startPoint+i*2)/96);//索引，最多有两天的数据，所以索引值为0或者1
                        int cvPoint = ((startPoint+i*2)%96==0 ? 96:(startPoint + i*2)%96);//在该索引下，曲线点。
                        
                        int index2 = ((startPoint+i*2+1)%96==0 ? 0: (startPoint+i*2+1)/96);//索引，最多有两天的数据，所以索引值为0或者1
                        int cvPoint2 = ((startPoint+i*2+1)%96==0 ? 96:(startPoint + i*2 +1)%96);//在该索引下，曲线点。
                        
                        //要读取的数据index大于totalArray的最大下标，则break
                        if(index >= [axArray count] || index >= [bxArray count] || index >= [cxArray count])
                        {
                            break;
                        }
                        
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        //                        if(totalArray != nil)
                        if([totalArray count]>0)
                        {
                            if(index >= [totalArray count])
                            {
                                continue;
                            }
                            [dic setObject:[[totalArray objectAtIndex:0] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ] forKey:@"pj"];
                            
                            //high:最大值
                            //low:最小值
                            if(index2 < [totalArray count])
                            {
                                if([[[totalArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint]] floatValue]
                                   > [[[totalArray objectAtIndex:index2] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint2]] floatValue])
                                {
                                    [dic setObject:[self parseVaildWithData:[[totalArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"high"];
                                    [dic setObject:[self parseVaildWithData:[[totalArray objectAtIndex:index2] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint2] ]] forKey:@"low"];
                                }
                                else
                                {
                                    [dic setObject:[[totalArray objectAtIndex:index2] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint2] ] forKey:@"high"];
                                    [dic setObject:[[totalArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ] forKey:@"low"];
                                }
                                //open:开始值
                                //close:结束值
                                
                                [dic setObject:[self parseVaildWithData:[[totalArray objectAtIndex:index2] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint2] ]] forKey:@"close"];
                            }
                            [dic setObject:[self parseVaildWithData:[[totalArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"open"];
                            
                        }
                        
                        //最大负荷，最小负荷(CurveData,F81),查找当天的最大最小负荷(CurveData),最大需量(HistoryData_PowerNeeds),功率因数(CurveData,PFAvg)，有功损耗(PowerValue)
                        
                        [dic setObject:[self parseVaildWithData:[(CurveData*)[maxminArray objectAtIndex:index] valueForKey:@"cvMax"]] forKey:@"zdfh"];
                        [dic setObject:[self parseVaildWithData:[(CurveData*)[maxminArray objectAtIndex:index] valueForKey:@"cvMin"]] forKey:@"zxfh"];
                        [dic setObject:[self parseVaildWithData:[(CurveData*)[maxminArray objectAtIndex:index] valueForKey:@"cvMaxTime"]] forKey:@"zdfhfssj"];
                        [dic setObject:[self parseVaildWithData:[(CurveData*)[maxminArray objectAtIndex:index] valueForKey:@"cvMinTime"]] forKey:@"zxfhfssj"];
                        
                        [dic setObject:[self parseVaildWithData:[(CurveData*)[pfArray objectAtIndex:index] valueForKey:@"cvAvg"]] forKey:@"glys"];
                        [dic setObject:[self parseVaildWithData:[(HistoryData_PowerValue*)[powerValueResult objectAtIndex:index] valueForKey:@"hdIronLossAEValueZ"]] forKey:@"ygsh"];
                        [dic setObject:[self parseVaildWithData:[(HistoryData_PowerNeeds*)[powerNeedsResult objectAtIndex:index] valueForKey:@"hdADMaxZ"]] forKey:@"zdxl"];
                        [dic setObject:[self parseVaildWithData:[(HistoryData_PowerNeeds*)[powerNeedsResult objectAtIndex:index] valueForKey:@"hdADMaxZTm"]] forKey:@"zdxlfssj"];
                        
                        //电量
                        [dic setObject:[self parseVaildWithData:[(HistoryData_PowerValue*)[powerValueResult objectAtIndex:index] valueForKey:@"hdPowerValuePosAEZ"]] forKey:@"dl"];
                        
                        
                        [dic setObject:[self parseVaildWithData:[[axArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"ax"];
                        [dic setObject:[self parseVaildWithData:[[bxArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"bx"];
                        [dic setObject:[self parseVaildWithData:[[cxArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"cx"];
                        
                        [resultlist addObject:dic];
                    }
                    
                }
                
                
            }
                break;
            case XLViewPlotTime60Min://需要计算大小,起始和结束值
            {
                
                NSInteger startPoint = [self getHourWithDate:self.refDate]*4+([self getMinuteWithDate:self.refDate]/15+1);
                
                
                for(int i=0;i<30;i++)
                {
                    
                    XL_UINT8 index = (startPoint+i*4)%96==0 ? 0: (startPoint+i*4)/96;//索引，最多有两天的数据，所以索引值为0或者1
                    XL_UINT8 cvPoint = (startPoint+i*4)%96==0 ? 96:(startPoint + i*4)%96;//在该索引下，曲线点。
                    
                    //                    XL_UINT8 index2 = (startPoint+i*4+1)%96==0 ? 0: (startPoint+i*4+1)/96;//索引，最多有两天的数据，所以索引值为0或者1
                    //                    XL_UINT8 cvPoint2 = (startPoint+i*4+1)%96==0 ? 96:(startPoint + i*4 +1)%96;//在该索引下，曲线点。
                    if(index >= [axArray count] || index >= [bxArray count] || index >= [cxArray count])
                    {
                        break;
                    }
                    
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    
                    //                    if(totalArray != nil)
                    if([totalArray count]>0)
                    {
                        if(index >= [totalArray count])
                        {
                            continue;
                        }
                        [dic setObject:[self parseVaildWithData:[(CurveData*)[totalArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"pj"];
                    }
                    
                    
                    [dic setObject:[self parseVaildWithData:[(CurveData*)[axArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"ax"];
                    [dic setObject:[self parseVaildWithData:[(CurveData*)[bxArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"bx"];
                    [dic setObject:[self parseVaildWithData:[(CurveData*)[cxArray objectAtIndex:index] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",cvPoint] ]] forKey:@"cx"];
                    
                    
                    [resultlist addObject:dic];
                }
                
            }
                break;
                
            default:
                break;
        }
        
    }
    
    return resultlist;
}

//判读数据是否合法
-(id)parseVaildWithData:(id)data
{
    if(fabs([data floatValue]-ERRORFLOATPARSE)<epsilon)//如果是非法数据
    {
        return @"";
    }
    else
    {
        return data;
    }
}

-(NSDictionary*)computeMaxMinWithCurveArray:(NSArray*)curveArray
{
    NSString *maxValue=@"";
    NSString *maxValueTimeString =@"";
    double maxValueTime=0;
    NSString *minValue=@"";
    NSString *minValueTimeString =@"";
    double minValueTime=0;
    
    for (int i=0; i<[curveArray count]; i++)
    {
        if([@"" isEqualToString:maxValue])
        {
            maxValue = [self parseVaildWithData:[(CurveData*)[curveArray objectAtIndex:i] valueForKey:@"cvAvg"]];
            maxValueTimeString =[(CurveData*)[curveArray objectAtIndex:i] valueForKey:@"cvDataTime"];

        }
        else
        {
            id temp =[self parseVaildWithData:[(CurveData*)[curveArray objectAtIndex:i] valueForKey:@"cvAvg"]];
            if(![@"" isEqualToString:temp])
            {
                if([temp floatValue] > [maxValue floatValue])
                {
                    maxValue = temp;
                    
                    maxValueTimeString =[(CurveData*)[curveArray objectAtIndex:i] valueForKey:@"cvDataTime"];

                }
            }
        }
        if([@"" isEqualToString:minValue])
        {
            minValue = [self parseVaildWithData:[(CurveData*)[curveArray objectAtIndex:i] valueForKey:@"cvAvg"]];
            
            minValueTimeString =[(CurveData*)[curveArray objectAtIndex:i] valueForKey:@"cvDataTime"];
            

        }
        else
        {
            id temp =[self parseVaildWithData:[(CurveData*)[curveArray objectAtIndex:i] valueForKey:@"cvAvg"]];
            if(![@"" isEqualToString:temp])
            {
                if([temp floatValue] < [minValue floatValue])
                {
                    minValue = temp;
                    
                    minValueTimeString =[(CurveData*)[curveArray objectAtIndex:i] valueForKey:@"cvDataTime"];

                }
            }
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
    NSDate *destDate= [dateFormatter dateFromString:maxValueTimeString];
    
    maxValueTime =[destDate timeIntervalSince1970];
    
    destDate= [dateFormatter dateFromString:minValueTimeString];
    minValueTime =[destDate timeIntervalSince1970];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         maxValue,@"maxValue",
                         [NSNumber numberWithDouble:maxValueTime],@"maxValueTime",
                         minValue,@"minValue",
                         [NSNumber numberWithDouble:minValueTime],@"minValueTime",
                         nil];
    return dic;
}

-(NSString*)computeAvgWithCurveArray:(NSArray*)curveArray WithKey:(NSString*)key
{
    int validCount = 0;
    double sum = 0.0;
    for(int i=0;i<[curveArray count];i++)
    {
        if(fabs(ERRORFLOATPARSE-[[(CurveData*)[curveArray objectAtIndex:i] valueForKey:key] floatValue])<epsilon)
        {
            //非法数据
            continue;
        }
        else
        {
            sum +=[[(CurveData*)[curveArray objectAtIndex:i] valueForKey:key] floatValue];
            validCount++;
        }
    }
    
    return [self parseVaildWithData:[NSString stringWithFormat:@"%f",(validCount == 0? ERRORFLOATPARSE:sum/validCount*1.0)]];
}

-(NSArray*)renderCharDataWithType:(XLViewPlotDataType)type{
    
    //XLCoreData *coreData = [XLCoreData sharedXLCoreData];
    //NSManagedObjectContext *context = [coreData managedObjectContext];
    __block NSMutableArray *resultlist = [NSMutableArray array];
    
    switch (self.plotTimeType)
    {
        case XLViewPlotTime1Min:
        case XLViewPlotTime5Min:
        case XLViewPlotTime15Min:
        case XLViewPlotTime30Min:
        case XLViewPlotTime60Min:
            //由于大数据还没有做好，所以1分钟、5分钟、15分钟、30分钟、60分钟都按60分钟进行显示
            resultlist = [self getRtDataResultList:type];
            break;
        case XLViewPlotTimeDay:
        {
            
            if([[self.msgDic valueForKey:@"xl-name"] isEqualToString:@"plotdata-detail"])//详细数据 页面
            {
                //查询该日曲线数据
                NSPredicate *predicate =[NSPredicate predicateWithFormat:@" cvDataTime = %@",[NSString stringWithFormat:@"%04d-%02d-%02d", [self getYearWithDate:self.refDate],[self getMonthWithDate:self.refDate],[self getDayWithDate:self.refDate]]];
                
                NSArray *requestCurveResult = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
                
                //总、abc三相数组
                NSArray *totalArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseZ];
                NSArray *axArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseA];
                NSArray *bxArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseB];
                NSArray *cxArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseC];
                if([axArray count]>0
                   && [bxArray count]>0
                   && [cxArray count]>0)
                {
                    for(int i=1;i<=30;i++)
                    {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        
                        if([totalArray count]>0)//功率、功率因数
                        {
                            [dic setValue:[self parseVaildWithData:[(CurveData*)[totalArray objectAtIndex:0] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",i]] ] forKey:@"pj"];
                        }
                        
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[axArray objectAtIndex:0] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",i] ]] forKey:@"ax"];
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[bxArray objectAtIndex:0] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",i] ]] forKey:@"bx"];
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[cxArray objectAtIndex:0] valueForKey:[NSString stringWithFormat:@"%@%d" ,@"cvPoint",i] ]] forKey:@"cx"];
                        
                        [resultlist addObject:dic];
                    }
                }
            }
            else
            {
                //日数据图表默认返回30条数据 空缺的部分写NULL
                //__block NSMutableArray *resultlist = [NSMutableArray array];
                //resultlist = [NSMutableArray array];
                
                [[self getFormatDateSet] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    
                    NSString *date = (NSString*)obj;
                    NSLog(@"renderdata:日数据");
                    //查询该日曲线数据
                    NSPredicate *predicate =[NSPredicate predicateWithFormat:@" cvDataTime = %@",date];
                    NSArray *requestCurveResult = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
                    
                    NSArray *totalArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseZ];//总
                    NSArray *axArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseA];//A相
                    NSArray *bxArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseB];//B相
                    NSArray *cxArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithPlotDataType:type  WithPhaseType:XLPhaseC];//C相
                    NSArray *maxminArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithCurvetype:81];//功率最大最小值
                    NSArray *pfArray = [self getCurveDataFromArrayWithArray:requestCurveResult WithCurvetype:105];//功率因数平均值
                    //电能示值电能量array
                    predicate =[NSPredicate predicateWithFormat:@"hdDataTime = %@",date];
                    NSArray *powerValueArray = [self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:predicate];
                    //需量array
                    predicate =[NSPredicate predicateWithFormat:@"hdDataTime = %@",date];
                    NSArray *powerNeedsArray = [self readDataFromDBWithEntityName:@"HistoryData_PowerNeeds" withPredicate:predicate];
                    
                    //用于存储dic
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    
                    //电量从powervalue中获取,high,low从totalArray获得,aPower,bPower,cPower从axArray...获得,open,close是totalArray第一个和最后一个值,zdxl从powerNeeds中获得,ygsh:powervalue,glys:pfArray
                    if([powerNeedsArray count]>0)
                    {
                        HistoryData_PowerNeeds *powerNeeds = (HistoryData_PowerNeeds*)[powerNeedsArray objectAtIndex:0];
                        
                        [dic setValue:[self parseVaildWithData:[powerNeeds valueForKey:@"hdADMaxZ"]] forKey:@"zdxl"];
                        
                        [dic setValue:[self parseVaildWithData:[powerNeeds valueForKey:@"hdADMaxZTm"]] forKey:@"zdxlfssj"];
                    }
                    
                    if([powerValueArray count]> 0)
                    {
                        HistoryData_PowerValue *powerValue = (HistoryData_PowerValue*)[powerValueArray objectAtIndex:0];
                        
                        [dic setValue:[self parseVaildWithData:[powerValue valueForKey:@"hdPowerValuePosAEZ"]] forKey:@"dl"];
//                        [dic setValue:[self parseVaildWithData:[powerValue valueForKey:@"hdIronLossAEValueZ"]] forKey:@"ygsh"];
                        
                    }
                    
                    if([pfArray count] > 0)
                    {
                        CurveData* pfCurve = (CurveData*)[pfArray objectAtIndex:0];
                        
                        [dic setValue:[self parseVaildWithData:[pfCurve valueForKey:@"cvAvg"]] forKey:@"glys"];
                    }
                    
                    if([totalArray count]>0)
                    {
                        CurveData* curve = (CurveData*)[totalArray objectAtIndex:0];
                        
                        [dic setValue:[self parseVaildWithData:[curve valueForKey:@"cvMax"]] forKey:@"high"];
                        [dic setValue:[self parseVaildWithData:[curve valueForKey:@"cvMin"]] forKey:@"low"];
                        [dic setValue:[self parseVaildWithData:[curve valueForKey:@"cvPoint1"]] forKey:@"open"];
                        [dic setValue:[self parseVaildWithData:[curve valueForKey:@"cvPoint96"]] forKey:@"close"];
                        [dic setValue:[self parseVaildWithData:[curve valueForKey:@"cvAvg"]] forKey:@"pj"];
                    }
                    if([axArray count]>0)
                    {
                        CurveData* curve = (CurveData*)[axArray objectAtIndex:0];
                        [dic setValue:[self parseVaildWithData:[curve valueForKey:@"cvAvg"]] forKey:@"ax"];
                    }
                    if([bxArray count]>0)
                    {
                        CurveData* curve = (CurveData*)[bxArray objectAtIndex:0];
                        [dic setValue:[self parseVaildWithData:[curve valueForKey:@"cvAvg"]] forKey:@"bx"];
                    }
                    if([cxArray count]>0)
                    {
                        CurveData* curve = (CurveData*)[cxArray objectAtIndex:0];
                        [dic setValue:[self parseVaildWithData:[curve valueForKey:@"cvAvg"]] forKey:@"cx"];
                    }
                    
                    if([maxminArray count]>0)
                    {
                        CurveData *powerValue = (CurveData*)[maxminArray objectAtIndex:0];
                        [dic setValue:[self parseVaildWithData:[powerValue valueForKey:@"cvMax"]] forKey:@"zdfh"];
                        [dic setValue:[self parseVaildWithData:[powerValue valueForKey:@"cvMaxTime"]] forKey:@"zdfhfssj"];
                        [dic setValue:[self parseVaildWithData:[powerValue valueForKey:@"cvMin"]] forKey:@"zxfh"];
                        [dic setValue:[self parseVaildWithData:[powerValue valueForKey:@"cvMinTime"]] forKey:@"zxfhfssj"];
                    }
                    
                    if([dic count]>0)
                    {
                        
                        [dic setValue:[NSNumber numberWithInteger:[self getDaysCountFromDBWithEndDate:date]] forKey:@"aqrxsj"];
                        
                        [dic setValue:date forKey:@"dataTime"];
                    }
                    //            [dic setValue:@"5" forKey:@"ed"];
                    
                    
                    if ([dic count]>0)
                    {
                        [resultlist addObject:dic];
                        
                        //没有写Null
                    }
                    else
                    {
                        [resultlist addObject:[NSNull null]];
                    }
                }];
            }
            
        }
            break;
        case XLViewPlotTimeMonth://查询类型为月数据
        {
            if([[self.msgDic valueForKey:@"xl-name"] isEqualToString:@"plotdata-detail"])//详细数据
            {
                for(int daysIndex=1;daysIndex<=self.curveRecords;daysIndex++)
                {
                    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"cvDataTime BEGINSWITH[c] %@",[NSString stringWithFormat:@"%04d-%02d-%02d",[self getYearWithDate:self.refDate],[self getMonthWithDate:self.refDate],daysIndex]];
                    NSArray *curveArray = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
                    
                    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"cvDataTime" ascending:YES];
                    curveArray = [curveArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                    
                    NSArray *totalCurveArray =[self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseZ];
                    NSArray *axCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseA];
                    NSArray *bxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseB];
                    NSArray *cxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseC];
                    if([axCurveArray count]>0
                       && [bxCurveArray count]>0
                       && [cxCurveArray count]>0)
                    {
                        for(int i=0;i<[axCurveArray count];i++)
                        {
                            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                            
                            if([totalCurveArray count]>0)//功率、功率因数
                            {
                                [dic setValue:[self parseVaildWithData:[(CurveData*)[totalCurveArray objectAtIndex:i] valueForKey:@"cvAvg"] ] forKey:@"pj"];
                            }
                            
                            [dic setValue:[self parseVaildWithData:[(CurveData*)[axCurveArray objectAtIndex:i] valueForKey:@"cvAvg" ]] forKey:@"ax"];
                            [dic setValue:[self parseVaildWithData:[(CurveData*)[bxCurveArray objectAtIndex:i] valueForKey:@"cvAvg" ]] forKey:@"bx"];
                            [dic setValue:[self parseVaildWithData:[(CurveData*)[cxCurveArray objectAtIndex:i] valueForKey:@"cvAvg" ]] forKey:@"cx"];
                            
                            [resultlist addObject:dic];
                        }
                    }
                    else
                    {
                        [resultlist addObject:[NSNull null]];
                    }
                }
                
                
            }
            else
            {
                //需要用到curve,powervalue,powerNeeds
                //算出来需要用到的月份
                //            NSArray *monthArray = [self getFormatMonthSet:[self getDateSet]];
                NSArray *monthArray = [self getFormatMonthSet];
                
                [monthArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    //根据月份查询curve,powervalue,powerNeeds
                    NSString *month = (NSString*)obj;
                    
                    NSLog(@"renderdata:月数据");
                    
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    
                    //需要计算的是:和:dl(powerValue),比较大小:high/low/zdfh/zxfh(curve),取值:open/close(curve),平均值:ax/bx/cx/pj/glys(curve),
                    
                    //ygsh:monthPowerValue,zdxl(monthpowerNeeds)
                    
                    //powerValue每天
                    //powerValue月
                    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"hdDataType = 2 and hdDataTime =%@",month];
                    NSArray *powerValueMonthArray = [self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:predicate];
                    
                    predicate =[NSPredicate predicateWithFormat:@"hdDataType = 2 and hdDataTime = %@",month];
                    NSArray *powerNeedsMonthArray = [self readDataFromDBWithEntityName:@"HistoryData_PowerNeeds" withPredicate:predicate];
                    
                    predicate =[NSPredicate predicateWithFormat:@"cvDataTime BEGINSWITH[c] %@",month];
                    NSArray *curveArray = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
                    
                    NSArray *totalCurveArray =[self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseZ];
                    NSArray *axCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseA];
                    NSArray *bxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseB];
                    NSArray *cxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseC];
                    NSArray *powerValueCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithCurvetype:81];//有功功率曲线
                    NSArray *pfCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithCurvetype:105];//功率因数曲线
                    
                    if([powerValueMonthArray count]>0)
                    {
                        HistoryData_PowerValue *powerValueMonth = (HistoryData_PowerValue*)[powerValueMonthArray objectAtIndex:0];
                        
                        [dic setValue:[self parseVaildWithData:[powerValueMonth valueForKey:@"hdPowerValuePosAEZ"]] forKey:@"dl"];
                    }
                    
                    if([totalCurveArray count]>0)
                    {
                        CurveData *curveStart = (CurveData*)[totalCurveArray objectAtIndex:0];
                        CurveData *curveEnd = (CurveData*)[totalCurveArray objectAtIndex:[totalCurveArray count]-1];
                        
                        [dic setValue:[self parseVaildWithData:[curveStart valueForKey:@"cvAvg"]] forKey:@"open"];
                        [dic setValue:[self parseVaildWithData:[curveEnd valueForKey:@"cvAvg"]] forKey:@"close"];
                        [dic setValue:[self parseVaildWithData:[self computeAvgWithCurveArray:totalCurveArray WithKey:@"cvAvg"]] forKey:@"pj"];//平均功率
                        
                    }
                    
                    if([axCurveArray count]>0)
                    {
                        [dic setValue:[self computeAvgWithCurveArray:axCurveArray WithKey:@"cvAvg"] forKey:@"ax"];
                    }
                    if([bxCurveArray count]>0)
                    {
                        [dic setValue:[self computeAvgWithCurveArray:bxCurveArray WithKey:@"cvAvg"] forKey:@"bx"];
                    }
                    if([cxCurveArray count]>0)
                    {
                        [dic setValue:[self computeAvgWithCurveArray:cxCurveArray WithKey:@"cvAvg"] forKey:@"cx"];
                    }
                    
                    
                    if([powerNeedsMonthArray count]>0)
                    {
                        HistoryData_PowerNeeds *powerNeeds = [powerNeedsMonthArray objectAtIndex:0];
                        [dic setValue:[self parseVaildWithData:[powerNeeds valueForKey:@"hdADMaxZ"]] forKey:@"zdxl"];
                        [dic setValue:[self parseVaildWithData:[powerNeeds valueForKey:@"hdADMaxZTm"]] forKey:@"zdxlfssj"];
                    }
                    if([powerValueMonthArray count]>0)
                    {
                        HistoryData_PowerValue *powerValue = [powerValueMonthArray objectAtIndex:0];
                        [dic setValue:[self parseVaildWithData:[powerValue valueForKey:@"hdIronLossAEValueZ"]] forKey:@"ygsh"];
                    }
                    
                    if([pfCurveArray count]>0)
                    {
                        //                    CurveData *curve = (CurveData*)[pfCurveArray objectAtIndex:0];
                        [dic setValue:[self parseVaildWithData:[self computeAvgWithCurveArray:pfCurveArray WithKey:@"cvAvg"] ]forKey:@"glys"];
                    }
                    
                    
                    if([dic count]>0)
                    {
                        
                        //                    [dic setValue:[NSNumber numberWithDouble:500] forKey:@"aqrxsj"];
                        [dic setValue:[NSNumber numberWithInteger:[self getDaysCountFromDBWithEndDate:month]] forKey:@"aqrxsj"];
                        
                        [dic setValue:month forKey:@"dataTime"];
                        
                        NSDictionary *maxminDic = [self computeMaxMinWithCurveArray:totalCurveArray];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValue"]] forKey:@"high"];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValue"]] forKey:@"low"];
                        
                        maxminDic = [self computeMaxMinWithCurveArray:powerValueCurveArray];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValue"]] forKey:@"zdfh"];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValue"]] forKey:@"zxfh"];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValueTime"]] forKey:@"zdfhfssj"];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValueTime"]] forKey:@"zxfhfssj"];
                    }
                    //                NSLog(@" 月数据 一次");
                    
                    if ([dic count]>0)
                    {
                        [resultlist addObject:dic];
                        
                        //没有写Null
                    }
                    else
                    {
                        [resultlist addObject:[NSNull null]];
                    }
                    
                }];
            }
            
        }
            break;
        case XLViewPlotTimeYear:
        {
            if([[self.msgDic valueForKey:@"xl-name"] isEqualToString:@"plotdata-detail"])//详细数据
            {
                for(int i=1;i<=12;i++)
                {
                    //第i个月的曲线数据cvavg进行平均值计算
                    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"cvDataTime BEGINSWITH[c] %@",[NSString stringWithFormat:@"%04d-%02d",[self getYearWithDate:self.refDate],i]];
                    NSArray *curveArray = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
                    
                    NSArray *totalCurveArray =[self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseZ];
                    NSArray *axCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseA];
                    NSArray *bxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseB];
                    NSArray *cxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseC];
                    if([axCurveArray count]>0
                       && [bxCurveArray count]>0
                       && [cxCurveArray count]>0)
                    {
                        double sumT = 0.0;
                        double sumA = 0.0;
                        double sumB = 0.0;
                        double sumC = 0.0;
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        for(int i=0;i<[axCurveArray count];i++)
                        {
                            
                            if([totalCurveArray count]>0)//功率、功率因数
                            {
                                if(![[self parseVaildWithData:[(CurveData*)[totalCurveArray objectAtIndex:i] valueForKey:@"cvAvg"]] isEqualToString:@""])
                                {
                                    sumT +=[[(CurveData*)[totalCurveArray objectAtIndex:i] valueForKey:@"cvAvg"] floatValue];
                                }
                            }
                            
                            if(![[self parseVaildWithData:[(CurveData*)[axCurveArray objectAtIndex:i] valueForKey:@"cvAvg"]] isEqualToString:@""])
                            {
                                sumA +=[[(CurveData*)[totalCurveArray objectAtIndex:i] valueForKey:@"cvAvg"] floatValue];
                            }
                            
                            if(![[self parseVaildWithData:[(CurveData*)[bxCurveArray objectAtIndex:i] valueForKey:@"cvAvg"]] isEqualToString:@""])
                            {
                                sumB +=[[(CurveData*)[totalCurveArray objectAtIndex:i] valueForKey:@"cvAvg"] floatValue];
                            }
                            
                            if(![[self parseVaildWithData:[(CurveData*)[cxCurveArray objectAtIndex:i] valueForKey:@"cvAvg"]] isEqualToString:@""])
                            {
                                sumC +=[[(CurveData*)[totalCurveArray objectAtIndex:i] valueForKey:@"cvAvg"] floatValue];
                            }
                        }
                        
                        
                        [dic setValue:[NSString stringWithFormat:@"%f",sumT/12.] forKey:@"pj"];
                        [dic setValue:[NSString stringWithFormat:@"%f",sumA/12.] forKey:@"ax"];
                        [dic setValue:[NSString stringWithFormat:@"%f",sumB/12.] forKey:@"bx"];
                        [dic setValue:[NSString stringWithFormat:@"%f",sumC/12.] forKey:@"cx"];
                        
                        [resultlist addObject:dic];
                    }

                }
            }
            else
            {
                //计算需要抄读的年String集合
                NSLog(@"年数据 计算年之前");
                //            NSArray *yearArray = [self getYearSet:[self getDateSet]];
                NSArray *yearArray = [self getYearSet];
                
                NSLog(@"年数据 计算年之后");
                
                [yearArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    //根据月份查询curve,powervalue,powerNeeds
                    NSString *year = (NSString*)obj;
                    
                    NSLog(@"renderdata:年数据");
                    
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    
                    //需要计算的是:和:dl(powerValue),比较大小:high/low/zdfh/zxfh(curve),取值:open/close(curve),平均值:ax/bx/cx/pj/glys(curve),
                    
                    //ygsh:monthPowerValue,zdxl(monthpowerNeeds)
                    
                    //powerValue每天
                    //powerValue月
                    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"hdDataType = 2 and hdDataTime BEGINSWITH[c] %@",[NSString stringWithFormat:@"%@-",year]];
                    NSArray *powerValueMonthArray = [self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:predicate];
                    
                    predicate =[NSPredicate predicateWithFormat:@"hdDataType = 2 and hdDataTime BEGINSWITH[c] %@",[NSString stringWithFormat:@"%@-",year]];
                    NSArray *powerNeedsMonthArray = [self readDataFromDBWithEntityName:@"HistoryData_PowerNeeds" withPredicate:predicate];
                    
                    predicate =[NSPredicate predicateWithFormat:@"cvDataTime BEGINSWITH[c] %@ ",[NSString stringWithFormat:@"%@-",year]];
                    NSArray *curveArray = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
                    
                    NSArray *totalCurveArray =[self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseZ];
                    NSArray *axCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseA];
                    NSArray *bxCurveArray = [self getCurveDataFromArrayWithArray:curveArray  WithPlotDataType:type WithPhaseType:XLPhaseB];
                    NSArray *cxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseC];
                    NSArray *powerValueCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithCurvetype:81];//有功功率曲线
                    NSArray *pfCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithCurvetype:105];//功率因数曲线
                    
                    //电量,12个月电量总和
                    if([powerValueMonthArray count]>0)
                    {
                        int validCount = 0;
                        double sum = 0.0;
                        for(int i=0;i<[powerValueMonthArray count];i++)
                        {
                            HistoryData_PowerValue *powerValueMonth = (HistoryData_PowerValue*)[powerValueMonthArray objectAtIndex:i];
                            if(![@"" isEqualToString:[self parseVaildWithData:[powerValueMonth valueForKey:@"hdPowerValuePosAEZ"]]])
                            {
                                validCount++;
                                sum+=[[self parseVaildWithData:[powerValueMonth valueForKey:@"hdPowerValuePosAEZ"]] floatValue];
                            }
                            
                        }
                        sum = (validCount == 0? ERRORFLOATPARSE:sum);
                        [dic setValue:[self parseVaildWithData:[NSString stringWithFormat:@"%f",sum]] forKey:@"dl"];
                    }
                    
                    if([totalCurveArray count]>0)
                    {
                        CurveData *curveStart = (CurveData*)[totalCurveArray objectAtIndex:0];
                        CurveData *curveEnd = (CurveData*)[totalCurveArray objectAtIndex:[totalCurveArray count]-1];
                        
                        [dic setValue:[self parseVaildWithData:[curveStart valueForKey:@"cvAvg"]] forKey:@"open"];
                        [dic setValue:[self parseVaildWithData:[curveEnd valueForKey:@"cvAvg"]] forKey:@"close"];
                        [dic setValue:[self parseVaildWithData:[self computeAvgWithCurveArray:totalCurveArray WithKey:@"cvAvg"]] forKey:@"pj"];//平均值
                        
                    }
                    
                    if([axCurveArray count]>0)
                    {
                        [dic setValue:[self computeAvgWithCurveArray:axCurveArray WithKey:@"cvAvg"] forKey:@"ax"];
                    }
                    if([bxCurveArray count]>0)
                    {
                        [dic setValue:[self computeAvgWithCurveArray:bxCurveArray WithKey:@"cvAvg"] forKey:@"bx"];
                    }
                    if([cxCurveArray count]>0)
                    {
                        [dic setValue:[self computeAvgWithCurveArray:cxCurveArray WithKey:@"cvAvg"] forKey:@"cx"];
                    }
                    
                    
                    //12个月的最大需量进行比较
                    if([powerNeedsMonthArray count]>0)
                    {
                        NSString *max =@"";
                        NSString *maxTimeString =@"";
                        double maxTime = 0;
                        for(int i= 0;i<[powerValueMonthArray count];i++)
                        {
                            HistoryData_PowerNeeds *powerNeeds = [powerNeedsMonthArray objectAtIndex:i];
                            if([@"" isEqualToString:max])
                            {
                                max = [self parseVaildWithData:[powerNeeds valueForKey:@"hdADMaxZ"]];
                                maxTimeString = [powerNeeds valueForKey:@"hdDataTime"];
                            }
                            else
                            {
                                if(![@"" isEqualToString:[powerNeeds valueForKey:@"hdADMaxZ"]])
                                {
                                    if([[powerNeeds valueForKey:@"hdADMaxZ"] floatValue]> [max floatValue])
                                    {
                                        max =[powerNeeds valueForKey:@"hdADMaxZ"];
                                        maxTimeString = [powerNeeds valueForKey:@"hdDataTime"];
                                    }
                                }
                            }
                        }
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                        
                        [dateFormatter setDateFormat: @"yyyy-MM"];
                        NSDate *destDate= [dateFormatter dateFromString:maxTimeString];
                        
                        
                        maxTime =[destDate timeIntervalSince1970];
                        
                        [dic setValue:max forKey:@"zdxl"];
                        [dic setValue:[NSNumber numberWithDouble:maxTime] forKey:@"zdxlfssj"];
                    }
                    //12个月有功损耗平均值
                    if([powerValueMonthArray count]>0)
                    {
                        int validCount = 0;
                        double sum = 0.0;
                        for(int i=0;i<[powerValueMonthArray count];i++)
                        {
                            HistoryData_PowerValue *powerValue = [powerValueMonthArray objectAtIndex:i];
                            if(![@"" isEqualToString:[self parseVaildWithData:[powerValue valueForKey:@"hdIronLossAEValueZ"]]])
                            {
                                validCount++;
                                sum+=[[self parseVaildWithData:[powerValue valueForKey:@"hdIronLossAEValueZ"]] floatValue];
                            }
                            
                        }
                        sum = (validCount == 0? ERRORFLOATPARSE:sum/validCount*1.0);
                        [dic setValue:[self parseVaildWithData:[NSString stringWithFormat:@"%f",sum]] forKey:@"ygsh"];
                    }
                    
                    if([pfCurveArray count]>0)
                    {
                        //                    CurveData *curve = (CurveData*)[pfCurveArray objectAtIndex:0];
                        [dic setValue:[self parseVaildWithData:[self computeAvgWithCurveArray:pfCurveArray WithKey:@"cvAvg"] ]forKey:@"glys"];
                    }
                    
                    if([dic count]>0)
                    {
                        NSDictionary *maxminDic = [self computeMaxMinWithCurveArray:totalCurveArray];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValue"]] forKey:@"high"];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValue"]] forKey:@"low"];
                        
                        maxminDic = [self computeMaxMinWithCurveArray:powerValueCurveArray];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValue"]] forKey:@"zdfh"];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValue"]] forKey:@"zxfh"];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValueTime"]] forKey:@"zdfhfssj"];
                        [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValueTime"]] forKey:@"zxfhfssj"];
                        
                        //                    [dic setValue:[NSNumber numberWithDouble:500] forKey:@"aqrxsj"];
                        [dic setValue:[NSNumber numberWithInteger:[self getDaysCountFromDBWithEndDate:[NSString stringWithFormat:@"%@-",year]]] forKey:@"aqrxsj"];
                        
                        [dic setValue:year forKey:@"dataTime"];
                    }
                    
                    //                NSLog(@" 年数据 一次");
                    
                    if ([dic count]>0)
                    {
                        [resultlist addObject:dic];
                        
                        //没有写Null
                    }
                    else
                    {
                        [resultlist addObject:[NSNull null]];
                    }
                }];
            }
            
        }
            break;
        case XLViewPlotTimeWeek://查询类型为周数据
        {
            
            NSArray *weekDateSet = [self getFormatDateSet];
            
            if([[self.msgDic valueForKey:@"xl-name"] isEqualToString:@"plotdata-detail"])//详细数据
            {
                NSPredicate *predicate =[NSPredicate predicateWithFormat:@"cvDataTime in %@",weekDateSet];
                NSArray *curveArray = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"cvDataTime" ascending:YES];
                curveArray = [curveArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
                
                NSArray *totalCurveArray =[self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseZ];
                NSArray *axCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseA];
                NSArray *bxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseB];
                NSArray *cxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseC];
                if([axCurveArray count]>0
                   && [bxCurveArray count]>0
                   && [cxCurveArray count]>0)
                {
                    for(int i=0;i<[axCurveArray count];i++)
                    {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        
                        if([totalCurveArray count]>0)//功率、功率因数
                        {
                            [dic setValue:[self parseVaildWithData:[(CurveData*)[totalCurveArray objectAtIndex:i] valueForKey:@"cvAvg"] ] forKey:@"pj"];
                        }
                        
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[axCurveArray objectAtIndex:i] valueForKey:@"cvAvg" ]] forKey:@"ax"];
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[bxCurveArray objectAtIndex:i] valueForKey:@"cvAvg" ]] forKey:@"bx"];
                        [dic setValue:[self parseVaildWithData:[(CurveData*)[cxCurveArray objectAtIndex:i] valueForKey:@"cvAvg" ]] forKey:@"cx"];
                        
                        [resultlist addObject:dic];
                    }
                }
            }
            else
            {
                
                //            [[self getFormatDateSet] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                for(int idx = 0;idx <[weekDateSet count];idx++)
                {
                    NSLog(@"renderdata:周数据：%@",(NSString*)[weekDateSet objectAtIndex:idx]);
                    //遍历到的日期String类型
                    NSString *dateString = (NSString*)[weekDateSet objectAtIndex:idx];
                    //将String类型的日期转换为NSDate类型
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat: @"yyyy-MM-dd"];
                    NSDate *date= [dateFormatter dateFromString:dateString];
                    
                    if([self dayOfWeekWithDateString:dateString] == 2)//星期一
                    {
                        //查询7天的数据
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        
                        //需要计算的是:和:dl(powerValue),比较大小:high/low/zdfh/zxfh(curve),取值:open/close(curve),平均值:ax/bx/cx/pj/glys(curve),
                        
                        //ygsh:monthPowerValue,zdxl(monthpowerNeeds)
                        
                        
                        //powerValue每天
                        NSArray *dateScale =[self getFormatDateSetWithStartDate:date withDayCount:7];
                        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"hdDataType = 1 and hdDataTime  in  %@ ",dateScale];
                        NSArray *powerValueDayArray =[self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:predicate];
                        
                        predicate =[NSPredicate predicateWithFormat:@"hdDataType = 1 and hdDataTime  in %@  ",dateScale];
                        NSArray *powerNeedsDayArray =[self readDataFromDBWithEntityName:@"HistoryData_PowerNeeds" withPredicate:predicate];
                        
                        predicate =[NSPredicate predicateWithFormat:@"cvDataTime in %@",dateScale];
                        NSArray *curveArray = [self readDataFromDBWithEntityName:@"CurveData" withPredicate:predicate];
                        
                        
                        NSArray *totalCurveArray =[self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseZ];
                        NSArray *axCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseA];
                        NSArray *bxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseB];
                        NSArray *cxCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithPlotDataType:type  WithPhaseType:XLPhaseC];
                        NSArray *powerValueCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithCurvetype:81];//有功功率曲线
                        NSArray *pfCurveArray = [self getCurveDataFromArrayWithArray:curveArray WithCurvetype:105];//功率因数曲线
                        
                        //7天电量相加
                        if([powerValueDayArray count]>0)
                        {
                            HistoryData_PowerValue *powerValueMonth = (HistoryData_PowerValue*)[powerValueDayArray objectAtIndex:0];
                            
                            [dic setValue:[self parseVaildWithData:[powerValueMonth valueForKey:@"hdPowerValuePosAEZ"]] forKey:@"dl"];
                        }
                        
                        if([totalCurveArray count]>0)
                        {
                            CurveData *curveStart = (CurveData*)[totalCurveArray objectAtIndex:0];
                            CurveData *curveEnd = (CurveData*)[totalCurveArray objectAtIndex:[totalCurveArray count]-1];
                            
                            [dic setValue:[self parseVaildWithData:[curveStart valueForKey:@"cvAvg"]] forKey:@"open"];
                            [dic setValue:[self parseVaildWithData:[curveEnd valueForKey:@"cvAvg"]] forKey:@"close"];
                            [dic setValue:[self computeAvgWithCurveArray:totalCurveArray WithKey:@"cvAvg"] forKey:@"pj"];
                            
                        }
                        
                        //需要计算平均值
                        if([axCurveArray count]>0)
                        {
                            [dic setValue:[self computeAvgWithCurveArray:axCurveArray WithKey:@"cvAvg"] forKey:@"ax"];
                        }
                        if([bxCurveArray count]>0)
                        {
                            [dic setValue:[self computeAvgWithCurveArray:bxCurveArray WithKey:@"cvAvg"] forKey:@"bx"];
                        }
                        if([cxCurveArray count]>0)
                        {
                            [dic setValue:[self computeAvgWithCurveArray:cxCurveArray WithKey:@"cvAvg"] forKey:@"cx"];
                        }
                        
                        
                        //计算最大值
                        if([powerNeedsDayArray count]>0)
                        {
                            NSString *max =@"";
                            NSString *maxTimeString =@"";
                            double maxTime = 0;
                            for(int i= 0;i<[powerNeedsDayArray count];i++)
                            {
                                HistoryData_PowerNeeds *powerNeeds = [powerNeedsDayArray objectAtIndex:i];
                                if([@"" isEqualToString:max])
                                {
                                    max = [self parseVaildWithData:[powerNeeds valueForKey:@"hdADMaxZ"]];
                                    
                                    maxTimeString =[powerNeeds valueForKey:@"hdDataTime"];
                                }
                                else
                                {
                                    if(![@"" isEqualToString:[powerNeeds valueForKey:@"hdADMaxZ"]])
                                    {
                                        if([[powerNeeds valueForKey:@"hdADMaxZ"] floatValue]> [max floatValue])
                                        {
                                            max =[powerNeeds valueForKey:@"hdADMaxZ"];
                                            maxTimeString = [powerNeeds valueForKey:@"hdDataTime"];
                                        }
                                    }
                                }
                            }
                            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                            
                            [dateFormatter setDateFormat: @"yyyy-MM-dd"];
                            NSDate *destDate= [dateFormatter dateFromString:maxTimeString];
                            
                            
                            maxTime =[destDate timeIntervalSince1970];
                            
                            [dic setValue:max forKey:@"zdxl"];
                            [dic setValue:[NSNumber numberWithDouble:maxTime] forKey:@"zdxlfssj"];
                        }
                        //有功损耗计算平均值
                        if([powerValueDayArray count]>0)
                        {
                            int validCount = 0;
                            double sum = 0.0;
                            for(int i=0;i<[powerNeedsDayArray count];i++)
                            {
                                HistoryData_PowerValue *powerValue = [powerValueDayArray objectAtIndex:i];
                                if(![@"" isEqualToString:[self parseVaildWithData:[powerValue valueForKey:@"hdIronLossAEValueZ"]]])
                                {
                                    validCount++;
                                    sum+=[[self parseVaildWithData:[powerValue valueForKey:@"hdIronLossAEValueZ"]] floatValue];
                                }
                                
                            }
                            sum = (validCount == 0? ERRORFLOATPARSE:sum/validCount*1.0);
                            [dic setValue:[self parseVaildWithData:[NSString stringWithFormat:@"%f",sum]] forKey:@"ygsh"];
                            
                        }
                        
                        //功率因数计算平均值
                        if([pfCurveArray count]>0)
                        {
                            [self computeAvgWithCurveArray:pfCurveArray WithKey:@"cvAvg"];
                        }
                        
                        if([dic count]>0)
                        {
                            
                            [dic setValue:[NSNumber numberWithDouble:500] forKey:@"aqrxsj"];
                            
                            //日期转换格式
                            NSDateFormatter *dateFormatter = [[ NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                            
                            NSDate *mondayDate = [dateFormatter dateFromString:dateString];
                            NSDate *endDate = [NSDate dateWithTimeInterval:7*24*3600 sinceDate:mondayDate];
                            NSString *endDateString = [NSString stringWithFormat:@"%04d-%02d-%02d",[self getYearWithDate:endDate],[self getMonthWithDate:endDate],[self getDayWithDate:endDate]];
                            [dic setValue:[NSNumber numberWithInteger:[self getDaysCountFromDBWithEndDate:endDateString]] forKey:@"aqrxsj"];
                            //
                            [dic setValue:dateString forKey:@"dataTime"];
                            
                            NSDictionary *maxminDic = [self computeMaxMinWithCurveArray:totalCurveArray];
                            [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValue"]] forKey:@"high"];
                            [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValue"]] forKey:@"low"];
                            
                            maxminDic = [self computeMaxMinWithCurveArray:powerValueCurveArray];
                            [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValue"]] forKey:@"zdfh"];
                            [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValue"]] forKey:@"zxfh"];
                            [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"maxValueTime"]] forKey:@"zdfhfssj"];
                            [dic setValue:[self parseVaildWithData:[maxminDic valueForKey:@"minValueTime"]] forKey:@"zxfhfssj"];
                        }
                        
                        //                    NSLog(@" 周数据 一次");
                        
                        if ([dic count]>0)
                        {
                            [resultlist addObject:dic];
                            
                            //没有写Null
                        }
                        else
                        {
                            [resultlist addObject:[NSNull null]];
                        }
                        
                    }
                    
                    //            }];
                    idx+=6;
                }
                
            }
            }
            
            
            break;
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
    
    self.plotArray1 = [self renderCharDataWithType:self.plotDataType];
    
    if(![[self.msgDic valueForKey:@"xl-name"] isEqualToString:@"plotdata-detail"])
    {
        if (self.plotDataType == XLViewPlotDataTPVolt || self.plotDataType == XLViewPlotDataTPCurr) {
            
            if (self.plotDataType == XLViewPlotDataTPVolt) {
                self.plotArray2 = [self renderCharDataWithType:XLViewPlotDataTPCurr];
            }
            if (self.plotDataType == XLViewPlotDataTPCurr) {
                self.plotArray2 = [self renderCharDataWithType:XLViewPlotDataTPVolt];
            }
        }
    }
    
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
    NSLog(@"向界面发送消息");
    
    self.requestFinishFlg = YES;
    
}



@end
