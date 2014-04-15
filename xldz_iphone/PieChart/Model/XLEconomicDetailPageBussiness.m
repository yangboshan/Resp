//
//  XLEconomicDetailPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLEconomicDetailPageBussiness.h"
#import "XLCoreData.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import <CoreData/CoreData.h>
#import "HistoryData_PowerValue.h"
#import "HistoryData_MeasurePoint_Sta.h"
#import "ParameterData_MeasurePoint_Limit.h"

@interface XLEconomicDetailPageBussiness()

//状态数组
@property (nonatomic) NSArray *mtrNoStatusArray;

//用于数据库操作的属性
@property (nonatomic,strong) NSManagedObjectContext *context;

//测量点号
@property(nonatomic)NSInteger mtrNo;

//将查询结果写入字典中
@property(nonatomic) NSMutableDictionary *resultDic;

@end
@implementation XLEconomicDetailPageBussiness



SYNTHESIZE_SINGLETON_FOR_CLASS(XLEconomicDetailPageBussiness)

-(id)init{
    if (self = [super init]) {
        self.context = [[XLCoreData sharedXLCoreData] managedObjectContext];
        
        //获取测量点号，目前还没有
//        self.mtrNo = [self.msgDic valueForKey:@"mtrNo"];
        
        //resultDic声明
        [self initResultDic];
    }
    return self;
}

//初始化字典
-(void)initResultDic
{
    NSMutableArray* testArrayValue =
        [NSMutableArray arrayWithObjects:
    
         @"0.999",@"0.999",@"0.986",@"0.999",
         @"80分钟",@"80分钟",@"80分钟",
         @"80分钟",@"80分钟",@"80分钟",
    
         @"0.8",
         @"30%",@"20%",@"80分钟",
         @"30%",@"20%",@"80分钟",
    
         @"80%",@"80分钟",
    
         @"误差正常",
    
         @"误差正常",
         @"0kWh",@"2900kWh",@"0kWh",@"200kWh",
         
         nil];

    self.resultDic = [NSMutableDictionary dictionaryWithObjects:testArrayValue forKeys:
                      [NSArray arrayWithObjects:
                                    //功率因素
                       @"glys_ssz_z",@"glys_ssz_a",@"glys_ssz_b",@"glys_ssz_c",
                       @"rljsj_1",@"rljsj_2",@"rljsj_3",
                       @"yljsj_1",@"yljsj_2",@"yljsj_3",
                       //三相电流不平衡度越限
                       @"dlbph_ssz",
                       @"dlbph_r1",@"dlbph_r2", @"dlbph_r3",
                       @"dlbph_y1",@"dlbph_y2", @"dlbph_y3",
                       //日负载率
                       @"rfzl_pj",@"rfzl_sj",
                       //防窃电
                       @"fqd",
                       //电量／功率误差情况
                       @"wcjg",
                       @"jxygdl",@"cxygdl",@"jxwgdl",@"cxwgdl",
                       nil]];
}

-(void)requestData
{
    NSArray *powerValueArray;
    //如果是经济的,则显示最近一天的记录
    if([self judgeEconomicWithMtrNo:self.mtrNo])
    {
        //最近一天的记录
        
        powerValueArray = [self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:nil WithSort:[NSSortDescriptor sortDescriptorWithKey:@"hdDataTime" ascending:YES]];

        
    }
    else//如果是不经济的，则显示最近一天不经济的记录
    {
        //最近一天不经济的记录
        powerValueArray = [self readDataFromDBWithEntityName:@"HistoryData_PowerValue" withPredicate:nil WithSort:[NSSortDescriptor sortDescriptorWithKey:@"hdDataTime" ascending:YES]];
        
        //需要抄读功率因数日/月累计时间,三相电流不平衡度越限时间
        
        //日平均负载率(曲线负载率，F234增补项)
        
        //正向有功电能量F5，无功电能量F6
    }
    
    [self judgeEconomic];
    
    //通过得到的数据array进行设置
    [self setResultDicWithResultArray:powerValueArray WithEntityName:@"HistoryData_PowerValue"];

    
    [self sendNotification];
    
}


-(BOOL)judgeEconomicWithMtrNo:(NSInteger)mtrNo
{
    __block BOOL isMtrNoEconomic=YES;//当前测量点是否是经济的
    
    [self.mtrNoStatusArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *nowDic = (NSDictionary*)obj;
        if(self.mtrNo == [[nowDic valueForKey:@"tpNo"] integerValue])
        {
            if([@"red" isEqualToString:[nowDic valueForKey:@"tpStatus"]])
            {
                isMtrNoEconomic = NO;
            }
            *stop = YES;
        }
    }];

    return isMtrNoEconomic;
}

//判断变压器运行是否经济
-(BOOL)judgeEconomic
{
    //测量点经济性状态，不经济为red，经济为green
    NSString *tpStatus = @"";
    
    //读取功率因数区段累计时间HistoryData_MeasurePoint_Sta，hdPfSector1AccTm，hdPfSector2AccTm，hdPfSector3AccTm
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"hdDataTime" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hdDataType = 1"];
    NSArray *staDataArray = [self readDataFromDBWithEntityName:@"HistoryData_MeasurePoint_Sta" withPredicate:predicate WithSort:sortDescriptor] ;
    if([staDataArray count]>0)
    {
        HistoryData_MeasurePoint_Sta *pointStaData = (HistoryData_MeasurePoint_Sta*)[staDataArray objectAtIndex:0];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pointStaData valueForKey:@"hdPfSector1AccTm"]] forKey:@"rljsj_1"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pointStaData valueForKey:@"hdPfSector2AccTm"]] forKey:@"rljsj_2"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pointStaData valueForKey:@"hdPfSector3AccTm"]] forKey:@"rljsj_3"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pointStaData valueForKey:@"hdCurUnbalOLmtAccTm"]] forKey:@"dlbph_r3"];
    }
    
    //月测量点统计数据读取
    predicate = [NSPredicate predicateWithFormat:@"hdDataType =2"];
    staDataArray = [self readDataFromDBWithEntityName:@"HistoryData_MeasurePoint_Sta" withPredicate:predicate WithSort:sortDescriptor] ;
    
    if([staDataArray count]>0)
    {
        
        HistoryData_MeasurePoint_Sta *pointStaDataMon = (HistoryData_MeasurePoint_Sta*)[staDataArray objectAtIndex:0];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pointStaDataMon valueForKey:@"hdPfSector1AccTm"]] forKey:@"yljsj_1"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pointStaDataMon valueForKey:@"hdPfSector2AccTm"]] forKey:@"yljsj_2"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pointStaDataMon valueForKey:@"hdPfSector3AccTm"]] forKey:@"yljsj_3"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pointStaDataMon valueForKey:@"hdCurUnbalOLmtAccTm"]] forKey:@"dlbph_y3"];
    }
    
    //不平衡度参数的读取
    staDataArray = [self readDataFromDBWithEntityName:@"ParameterData_MeasurePoint_Limit" withPredicate:nil WithSort:nil] ;
    if([staDataArray count]>0)
    {
        ParameterData_MeasurePoint_Limit *pmPoint = (ParameterData_MeasurePoint_Limit*)[staDataArray objectAtIndex:0];
        
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmUnbalCurLmt"]] forKey:@"dlbph_r1"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmUnbalCurRecoverFactor"]] forKey:@"dlbph_r2"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmUnbalCurLmt"]] forKey:@"dlbph_y1"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmUnbalCurRecoverFactor"]] forKey:@"dlbph_y2"];
    }
    
    //测量点状态
    self.mtrNoStatusArray = [NSArray arrayWithObjects:
                             [NSDictionary dictionaryWithObjectsAndKeys:@"测量点1",@"tpName",@"1",@"tpNo",@"green",@"tpStatus", nil],
                             nil];
    
    return YES;
}

//根据检索条件和表名进行数据检索
-(NSArray*)readDataFromDBWithEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate WithSort:(NSSortDescriptor*)sort
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
    
    //执行检索
    NSArray *resultArray =(NSArray*)[_context executeFetchRequest:fetchRequest error:&error];
    
    //对结果排序
    if(sort)
    {
        
        resultArray = [resultArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    }
    
    //返回检索结果
    return resultArray;
}


//输出所有的测量点号和当前状态,如果mtrNoStatusArray为空，则返回空，否则返回数组，该数组在judgeEconomic时赋值
-(NSArray*)AllMtrNoStatus
{
    if([self.mtrNoStatusArray count]>0)
    {
        return self.mtrNoStatusArray;
    }
    else
    {
        return [NSArray arrayWithObjects:
                [NSDictionary dictionaryWithObjectsAndKeys:@"测量点1",@"tpName",@"1",@"tpNo",@"green",@"tpStatus", nil], nil];
    }
}

//array
-(void)setResultDicWithResultArray:(NSArray*)array WithEntityName:(NSString*)entityName
{
    if([array count]>0)
    {
        HistoryData_PowerValue *powerValue = [array objectAtIndex:0];
        
        [self.resultDic setObject:[NSString stringWithFormat:@"%@kWh",[powerValue valueForKey:@"hdPosAEPower"]] forKey:@"cxygdl"];//出线有功电能量
        [self.resultDic setObject:[NSString stringWithFormat:@"%@kWh",[powerValue valueForKey:@"hdPosREPower"]] forKey:@"cxwgdl"];//出线无功电能量
        
    }
}

//发送消息
-(void)sendNotification
{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.msgDic, @"parameter",
                               self.resultDic, @"result",
                               nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
}

@end
