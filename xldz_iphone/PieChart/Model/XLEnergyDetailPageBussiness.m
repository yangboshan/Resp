//
//  XLEnergyDetailPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-4-5.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLEnergyDetailPageBussiness.h"
#import "XLCoreData.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import <CoreData/CoreData.h>
#import "ParameterData_MeasurePoint_Limit.h"
#import "HistoryData_MeasurePoint_Sta.h"
#import "HistoryData_MeasurePoint_Sta_Harmonic.h"

@interface XLEnergyDetailPageBussiness()

//状态数组
@property (nonatomic) NSArray *mtrNoStatusArray;

//用于数据库操作的属性
@property (nonatomic,strong) NSManagedObjectContext *context;

//测量点号
@property(nonatomic)NSInteger mtrNo;

//谐波越限统计数据写入数组中
@property(nonatomic)NSMutableArray *staHarmonicArray;

//将查询结果写入字典中
@property(nonatomic) NSMutableDictionary *resultDic;


@end

@implementation XLEnergyDetailPageBussiness

SYNTHESIZE_SINGLETON_FOR_CLASS(XLEnergyDetailPageBussiness)

#pragma -mark -初始化操作
-(id)init{
    if (self = [super init]) {
        self.context = [[XLCoreData sharedXLCoreData] managedObjectContext];
        
        
        [self initResultDic];
    }
    return self;
}

//初始化字典
-(void)initResultDic
{
    self.staHarmonicArray = [NSMutableArray arrayWithObjects:
                             //总谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //2次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //3次谐波
                             [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //4次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //5次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //6次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //7次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //8次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //9次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //10次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //11次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //12次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //12次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //14次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //15次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //16次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //17次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //18次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
                             //19次谐波
                             [NSMutableDictionary dictionaryWithObjectsAndKeys:@"190分钟",@"va",@"190分钟",@"vb",@"190分钟",@"vc",@"190分钟",@"ca",@"190分钟",@"cb",@"190分钟",@"cc",nil],
                             
                             
                             nil];
    
    NSMutableArray* testArrayValue =
    [NSMutableArray arrayWithObjects:
     
     @"220V",@"220V",@"220V",
     @"220V",@"220V",@"95%",
     @"220V",@"220V",@"100%",
     @"220V",@"220V",@"90%",
     
     @"0.65",
     @"30%",@"20%",@"80分钟",
     @"30%",@"20%",@"80分钟",
     
     self.staHarmonicArray
     ,nil
     ];
    
    
    self.resultDic = [NSMutableDictionary dictionaryWithObjects:testArrayValue forKeys:
                      [NSArray arrayWithObjects:
                       //电压合格率
                       @"dyhgl_ssz_a",@"dyhgl_ssz_b",@"dyhgl_ssz_c",
                       @"dyhgl_hgsx_a",@"dyhgl_hgxx_a",@"dyhgl_hgl_a",
                       @"dyhgl_hgsx_b",@"dyhgl_hgxx_b",@"dyhgl_hgl_b",
                       @"dyhgl_hgsx_c",@"dyhgl_hgxx_c",@"dyhgl_hgl_c",
                       //三相电压不平衡度越限
                       @"dybph_ssz",
                       @"dybph_r1",@"dybph_r2", @"dybph_r3",
                       @"dybph_y1",@"dybph_y2", @"dybph_y3",
                       //谐波越限
                       @"xbyx",
                       nil]
                      ];

}

#pragma -mark -对外接口部分
//供电能质量详细界面调用
-(void)requestData
{
    NSArray *powerValueArray;
    //如果是经济的,则显示最近一天的记录
    if([self judgeEnergyWithMtrNo:self.mtrNo])
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
    
    [self judgeEnergy];
    
    //通过得到的数据array进行设置
    [self setResultDicWithResultArray:powerValueArray WithEntityName:@"HistoryData_PowerValue"];
    
    
    [self sendNotification];
}


//遍历测量点判断电能质量如何
-(BOOL)judgeEnergy
{
    //读取电压合格上限/下限参数 电压不平衡度越限参数--------------------------------------
    NSArray *pmPointArray = [self readDataFromDBWithEntityName:@"ParameterData_MeasurePoint_Limit" withPredicate:nil WithSort:nil];
    if([pmPointArray count]>0)
    {
        ParameterData_MeasurePoint_Limit *pmPoint = [pmPointArray objectAtIndex:0];
        //合格上限
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmVoltRegularHiLmt"] ]forKey:@"dyhgl_hgsx_a"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmVoltRegularHiLmt"] ]forKey:@"dyhgl_hgsx_b"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmVoltRegularHiLmt"] ]forKey:@"dyhgl_hgsx_c"];
        //合格下限
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmVoltRegularLoLmt"] ]forKey:@"dyhgl_hgxx_a"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmVoltRegularLoLmt"] ]forKey:@"dyhgl_hgxx_b"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmVoltRegularLoLmt"] ]forKey:@"dyhgl_hgxx_c"];
        
        //电压不平衡度参数
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmUnbalVoltLmt"] ]forKey:@"dybph_r1"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmUnbalVoltRecoverFactor"] ]forKey:@"dybph_r2"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmUnbalVoltLmt"] ]forKey:@"dybph_y1"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPoint valueForKey:@"pmUnbalVoltRecoverFactor"] ]forKey:@"dybph_y2"];
    }
    
    //电压合格率，电压不平衡度日累计时间------------------------------------------
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"hdDataTime" ascending:NO];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hdDataType = 1"];
    NSArray *staDataArray = [self readDataFromDBWithEntityName:@"HistoryData_MeasurePoint_Sta" withPredicate:predicate WithSort:sortDescriptor];
    if([staDataArray count]>0)
    {
        HistoryData_MeasurePoint_Sta *pmPointSta = (HistoryData_MeasurePoint_Sta*)[staDataArray objectAtIndex:0];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pmPointSta valueForKey:@"hdVoltUnbalOLmtAccTm"] ]forKey:@"dybph_r3"];
        
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPointSta valueForKey:@"hdAVoltRegularRate"] ]forKey:@"dyhgl_hgl_a"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPointSta valueForKey:@"hdBVoltRegularRate"] ]forKey:@"dyhgl_hgl_b"];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@",[pmPointSta valueForKey:@"hdCVoltRegularRate"] ]forKey:@"dyhgl_hgl_c"];
    }
    
    //月不平衡度累计时间--------------------------------------------------
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"hdDataTime" ascending:NO];
    predicate = [NSPredicate predicateWithFormat:@"hdDataType = 2"];
    staDataArray = [self readDataFromDBWithEntityName:@"HistoryData_MeasurePoint_Sta" withPredicate:predicate WithSort:sortDescriptor];
    if([staDataArray count]>0)
    {
        HistoryData_MeasurePoint_Sta *pmPointSta = (HistoryData_MeasurePoint_Sta*)[staDataArray objectAtIndex:0];
        [self.resultDic setObject:[NSString stringWithFormat:@"%@分",[pmPointSta valueForKey:@"hdVoltUnbalOLmtAccTm"] ]forKey:@"dybph_y3"];
    }
    
    //谐波越限累计时间---------------------------------------------------
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for(int i=0;i<3;i++)
    {
        sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"hdDataTime" ascending:NO];
        predicate = [NSPredicate predicateWithFormat:@"hdDataType = 1 and hdPhaseType = %d",121+i];//121:ax,122:bx,123:cx
        staDataArray = [self readDataFromDBWithEntityName:@"HistoryData_MeasurePoint_Sta_Harmonic" withPredicate:predicate WithSort:sortDescriptor];
        [resultArray addObject:staDataArray];
    }
    for (int i=0; i<[resultArray count]; i++)
    {
        NSArray *harmoArray = [resultArray objectAtIndex:0];
        
        if([harmoArray count]>0)
        {
            HistoryData_MeasurePoint_Sta_Harmonic *harmoSta = (HistoryData_MeasurePoint_Sta_Harmonic*)[harmoArray objectAtIndex:0];
            NSString *phaseType = @"";
            if(121==[[harmoSta valueForKey:@"hdPhaseType"] integerValue])
            {
                phaseType =@"a";
            }
            if(122==[[harmoSta valueForKey:@"hdPhaseType"] integerValue])
            {
                phaseType =@"b";
            }
            if(123==[[harmoSta valueForKey:@"hdPhaseType"] integerValue])
            {
                phaseType =@"c";
            }
            [(NSMutableDictionary*)[self.staHarmonicArray objectAtIndex:0] setObject:[harmoSta valueForKey:@"hdHarmoCurOverLimitZTm"] forKey:[NSString stringWithFormat:@"c%@",phaseType ]];
            [(NSMutableDictionary*)[self.staHarmonicArray objectAtIndex:0] setObject:[harmoSta valueForKey:@"hdHarmoVoltOverLimitZTm"] forKey:[NSString stringWithFormat:@"v%@",phaseType ]];
            
            for(int index=2;index<20;index++)
            {
                [(NSMutableDictionary*)[self.staHarmonicArray objectAtIndex:i-1] setObject:[harmoSta valueForKey:[NSString stringWithFormat:@"hdHarmoCurOverLimit%dTm",i]] forKey:[NSString stringWithFormat:@"c%@",phaseType ]];
                [(NSMutableDictionary*)[self.staHarmonicArray objectAtIndex:i-1] setObject:[harmoSta valueForKey:[NSString stringWithFormat:@"hdHarmoVoltOverLimit%dTm",i]] forKey:[NSString stringWithFormat:@"v%@",phaseType ]];
            }
            
        }
    }
    
    return YES;
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

#pragma -mark -检索数据库
//根据检索条件和表名进行数据检索
-(NSArray*)readDataFromDBWithEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate WithSort:(NSSortDescriptor*)sort
{
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

#pragma -mark -内部方法，数据处理
//array
-(void)setResultDicWithResultArray:(NSArray*)array WithEntityName:(NSString*)entityName
{
    
}

-(BOOL)judgeEnergyWithMtrNo:(NSInteger)mtrNo
{
    __block BOOL isMtrNoEnergy=YES;//当前测量点是否是经济的
    
    [self.mtrNoStatusArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *nowDic = (NSDictionary*)obj;
        if(self.mtrNo == [[nowDic valueForKey:@"tpNo"] integerValue])
        {
            if([@"red" isEqualToString:[nowDic valueForKey:@"tpStatus"]])
            {
                isMtrNoEnergy = NO;
            }
            stop = YES;
        }
    }];
    
    return isMtrNoEnergy;
}

#pragma -mark -发送消息
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
