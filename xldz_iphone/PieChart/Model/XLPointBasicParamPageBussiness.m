//
//  XLPointBasicParamPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-3-31.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLPointBasicParamPageBussiness.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import "ParameterData_MeasurePoint.h"

@interface XLPointBasicParamPageBussiness()
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

@implementation XLPointBasicParamPageBussiness

SYNTHESIZE_SINGLETON_FOR_CLASS(XLPointBasicParamPageBussiness);


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
    [self requestPointBasicParam];
}

-(void)initNSArray
{
    self.resultArray = [NSMutableArray arrayWithObjects:
                        [NSMutableDictionary paramWithName:@"名称" value:self.pointName type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"测量点号" value:self.pointNo type:XLParamTypeString],
                        [[NSMutableDictionary paramWithName:@"所属设备" value:self.device.deviceName type:XLParamTypeString] uneditable],
                        [[NSMutableDictionary paramWithName:@"所属线路" value:self.user.line.lineName type:XLParamTypeString] uneditable],
                        [NSMutableDictionary paramWithName:@"PT"    value:@""  type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"CT" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"额定电压" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"额定电流" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"电源接线方式" value:@"" type:XLParamTypeString],
                        nil];
}

-(void)requestPointBasicParam
{
    
    //如果没连wifi，则直接返回空数据，发送通知
    if(![XLUtilities localWifiReachable])
    {
        NSArray *dbResult = [self readDataFromDBWithEntityName:@"ParameterData_MeasurePoint" withPredicate:nil];
        
        if([dbResult count]>0)
        {
            ParameterData_MeasurePoint *measurePoint = (ParameterData_MeasurePoint*)[dbResult objectAtIndex:0];
            
            [[self.resultArray objectAtIndex:4] setObject:[NSString stringWithFormat:@"%d",[[measurePoint valueForKey:@"pmPTRatio"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:5] setObject:[NSString stringWithFormat:@"%d",[[measurePoint valueForKey:@"pmCTRatio"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:6] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmRatedVoltage"] floatValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:7] setObject:[NSString stringWithFormat:@"%f",[[measurePoint valueForKey:@"pmRatedCurrent"] floatValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:8] setObject:[measurePoint valueForKey:@"pmPowerConnWay"] forKey:@"paramValue"];
            
        }
        [self sendNotification];
    }
    else
    {
        
        
        self.frame = PackFrameWithDadt(AFN0A, [ self.pointNo integerValue], 25, &_outlen);
        
        
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
        
        if ([dcs.allKeys containsObject:@"F25"]) {
            NSDictionary *dic = [dcs valueForKey:@"F25"];
            
            [[self.resultArray objectAtIndex:4] setObject:[dic valueForKey:@"电压互感器倍率"] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:5] setObject:[dic valueForKey:@"电流互感器倍率"] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:6] setObject:[dic valueForKey:@"额定电压"] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:7] setObject:[dic valueForKey:@"额定电流"] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:8] setObject:[dic valueForKey:@"电源接线方式"] forKey:@"paramValue"];
            
            [self sendNotification];
            [self saveDataIntoDBWithEntity:dic];
        }
        
    });
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ParameterData_MeasurePoint"
                                              inManagedObjectContext:_context];
    
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    
    
    [fetchRequest setPredicate:nil];
    
    NSError *error;
    //返回检索结果
    NSArray *resultArray =[_context executeFetchRequest:fetchRequest error:&error];
    if([resultArray count]>0)
    {
        ParameterData_MeasurePoint *updateMeasurePoint = [resultArray objectAtIndex:0];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"电压互感器倍率"] integerValue]] forKey:@"pmPTRatio"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"电流互感器倍率"] integerValue]] forKey:@"pmCTRatio"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"额定电压"] floatValue]] forKey:@"pmRatedVoltage"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"额定电流"] floatValue]] forKey:@"pmRatedCurrent"];
        
        [updateMeasurePoint setValue:[dic valueForKey:@"电源接线方式"] forKey:@"pmPowerConnWay"];

        
        
        [self.context save:nil];
    }
    else
    {
        NSEntityDescription *terminalComm =[NSEntityDescription insertNewObjectForEntityForName:@"ParameterData_MeasurePoint" inManagedObjectContext:_context];
        
        
        [terminalComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"电压互感器倍率"] integerValue]] forKey:@"pmPTRatio"];
        
        [terminalComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"电流互感器倍率"] integerValue]] forKey:@"pmCTRatio"];
        
        [terminalComm setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"额定电压"] floatValue]] forKey:@"pmRatedVoltage"];
        
        [terminalComm setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"额定电流"] floatValue]] forKey:@"pmRatedCurrent"];
        
        [terminalComm setValue:[dic valueForKey:@"电源接线方式"] forKey:@"pmPowerConnWay"];
        
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
