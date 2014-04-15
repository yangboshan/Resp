//
//  XLPointThresholdParamPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLPointThresholdParamPageBussiness.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import "ParameterData_MeasurePoint_Limit.h"

@interface XLPointThresholdParamPageBussiness()

//请求报文Bytes
@property(nonatomic,assign) Byte* frame;

//请求报文Data
@property(nonatomic,strong) NSData *data;

//报文输出长度
@property(nonatomic,assign) XL_UINT16 outlen;

@property(nonatomic) NSMutableArray *resultArray;

//notifyName
@property(nonatomic) NSString *notifyName;

//用于数据库操作的context属性
@property (nonatomic,strong) NSManagedObjectContext *context;

@end
@implementation XLPointThresholdParamPageBussiness
SYNTHESIZE_SINGLETON_FOR_CLASS(XLPointThresholdParamPageBussiness);

//初始化方法
-(id)init{
    if (self = [super init]) {
        
        
        self.context = [[XLCoreData sharedXLCoreData] managedObjectContext];
        
        self.notifyName = [NSString stringWithFormat:@"__%@__notify__%d",[self class],arc4random()];
        
        
        //注册消息通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponse:) name:self.notifyName object:nil];
    }
    return self;
}


-(void)requestData
{
    //注册消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponse:) name:@"user" object:nil];
    
    //初始化通信参数数组
    [self initNSArray];
    
    //调用查询参数组帧发送方法
    [self requestPointThresholdParam];
}

-(void)initNSArray
{
    self.resultArray = [NSMutableArray arrayWithObjects:
                        [NSMutableDictionary paramWithName:@"电压合格上限" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"电压合格下限" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"过压门限" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"过压持续时间" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"过压恢复系数" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"欠压门限" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"欠压持续时间" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"欠压恢复系数" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"相电流上上限（过流）" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"过流持续时间" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"过流恢复系数" value:@"" type:XLParamTypeString],
                        nil];
}

-(void)requestPointThresholdParam
{
    
    //如果没连wifi，则直接返回空数据，发送通知
    if(![XLUtilities localWifiReachable])
    {
        NSArray *dbResult = [self readDataFromDBWithEntityName:@"ParameterData_MeasurePoint_Limit" withPredicate:nil];
        
        if([dbResult count]>0)
        {
            ParameterData_MeasurePoint_Limit *measurePoint = (ParameterData_MeasurePoint_Limit*)[dbResult objectAtIndex:0];
            
            [[self.resultArray objectAtIndex:0] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmVoltRegularHiLmt"] floatValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:1] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmVoltRegularLoLmt"] floatValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:2] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmVoltHHLmt"] floatValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:3] setObject:[NSString stringWithFormat:@"%d",[[measurePoint valueForKey:@"pmVoltHHLmtDuration"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:4] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmVoltHHRecoverFactor"] floatValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:5] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmVoltLLLmt"] floatValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:6] setObject:[NSString stringWithFormat:@"%d",[[measurePoint valueForKey:@"pmVoltLLLmtDuration"] integerValue]] forKey:@"paramValue"];
            
//            [[self.resultArray objectAtIndex:7] setObject:[dic valueForKey:@"欠压越限恢复系数"] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:8] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmCurHHLmt"] floatValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:9] setObject:[NSString stringWithFormat:@"%d",[[measurePoint valueForKey:@"pmCurHHLmtDuration"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:10] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmCurHHRecoverFactor"] floatValue]] forKey:@"paramValue"];
            
        }
        [self sendNotification];
    }
    else
    {
        //发送f26
        self.frame = PackFrameWithDadt(AFN0A, [self.pointNo integerValue], 26, &_outlen);
        
        
        self.data = [NSData dataWithBytes:self.frame length:self.outlen];
        NSLog(@"%@",[self.data description]);
        
        free(self.frame);
        
        
//        [[XLSocketManager sharedXLSocketManager] packRequestFrame:self.data];
        [[XLSocketManager sharedXLSocketManager] packRequestFrameWithData:self.data withNotifyName:self.notifyName];
        
    }
}


-(void)handleResponse:(NSNotification*)notify
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
        
        NSDictionary* dcs = notify.userInfo;
        
        if ([dcs.allKeys containsObject:@"F26"]) {
            NSDictionary *dic = [dcs valueForKey:@"F26"];
            
            [self getF26Set:dic];
        }
        
    });
    
}

//解析F26并显示在界面上
-(void)getF26Set:(NSDictionary *)dic
{
    [[self.resultArray objectAtIndex:0] setObject:[dic valueForKey:@"电压合格上限"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:1] setObject:[dic valueForKey:@"电压合格下限"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:2] setObject:[dic valueForKey:@"电压上上限"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:3] setObject:[dic valueForKey:@"过压越限持续时间"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:4] setObject:[dic valueForKey:@"过压越限恢复系数"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:5] setObject:[dic valueForKey:@"电压下下限"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:6] setObject:[dic valueForKey:@"欠压越限持续时间"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:7] setObject:[dic valueForKey:@"欠压越限恢复系数"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:8] setObject:[dic valueForKey:@"相电流上上限"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:9] setObject:[dic valueForKey:@"过流越限持续时间" ]forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:10] setObject:[dic valueForKey:@"过流越限恢复系数"] forKey:@"paramValue"];
    [self sendNotification];

    [self saveDataIntoDBWithEntity:dic];
}

//发送Notification
-(void)sendNotification
{
    
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.msgDic, @"parameter",
                               [self.resultArray paramsCopy], @"result",
                               nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
}

//保存数据到数据库
-(void)saveDataIntoDBWithEntity:(NSDictionary*)dic
{
    //存库之前先判断该设备是否已经存在于数据库中，查询条件为名称和所属用户与数据库中相同
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //声明实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ParameterData_MeasurePoint_Limit"
                                              inManagedObjectContext:_context];
    
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    
    
    [fetchRequest setPredicate:nil];
    
    NSError *error;
    //返回检索结果
    NSArray *resultArray =[_context executeFetchRequest:fetchRequest error:&error];
    if([resultArray count]>0)
    {
        ParameterData_MeasurePoint_Limit *updateMeasurePoint = [resultArray objectAtIndex:0];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"电压合格上限"] floatValue]]forKey:@"pmVoltRegularHiLmt"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"电压合格下限"] floatValue]] forKey:@"pmVoltRegularLoLmt"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"电压上上限"] floatValue]] forKey:@"pmVoltHHLmt"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"过压越限持续时间"] integerValue]] forKey:@"pmVoltHHLmtDuration"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"过压越限恢复系数"] floatValue]] forKey:@"pmVoltHHRecoverFactor"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"电压下下限"] floatValue]] forKey:@"pmVoltLLLmt"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"欠压越限持续时间"] integerValue]] forKey:@"pmVoltLLLmtDuration"];
        
//        [updateMeasurePoint setValue:[dic valueForKey:@"欠压越限恢复系数"] forKey:@"paramValue"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"相电流上上限"] floatValue]] forKey:@"pmCurHHLmt"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"过流越限持续时间" ] integerValue]]forKey:@"pmCurHHLmtDuration"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"过流越限恢复系数"] floatValue]] forKey:@"pmCurHHRecoverFactor"];
        
        
        [self.context save:nil];
    }
    else
    {
        NSEntityDescription *measurePoint =[NSEntityDescription insertNewObjectForEntityForName:@"ParameterData_MeasurePoint_Limit" inManagedObjectContext:_context];
        
        [measurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"电压合格上限"] floatValue]]forKey:@"pmVoltRegularHiLmt"];
        
        [measurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"电压合格下限"] floatValue]] forKey:@"pmVoltRegularLoLmt"];
        
        [measurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"电压上上限"] floatValue]] forKey:@"pmVoltHHLmt"];
        
        [measurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"过压越限持续时间"] integerValue]] forKey:@"pmVoltHHLmtDuration"];
        
        [measurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"过压越限恢复系数"] floatValue]] forKey:@"pmVoltHHRecoverFactor"];
        
        [measurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"电压下下限"] floatValue]] forKey:@"pmVoltLLLmt"];
        
        [measurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"欠压越限持续时间"] integerValue]] forKey:@"pmVoltLLLmtDuration"];
        
        //        [updateMeasurePoint setValue:[dic valueForKey:@"欠压越限恢复系数"] forKey:@"paramValue"];
        
        [measurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"相电流上上限"] floatValue]] forKey:@"pmCurHHLmt"];
        
        [measurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"过流越限持续时间" ] integerValue]]forKey:@"pmCurHHLmtDuration"];
        
        [measurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"过流越限恢复系数"] floatValue]] forKey:@"pmCurHHRecoverFactor"];
        
        
        [self.context save:nil];
    }
}

//根据检索条件和表名进行数据检索
-(NSArray*)readDataFromDBWithEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //声明实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:_context];
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    //返回检索结果
    return (NSArray*)[_context executeFetchRequest:fetchRequest error:&error];
}

@end
