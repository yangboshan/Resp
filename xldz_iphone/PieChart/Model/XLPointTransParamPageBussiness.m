//
//  XLPointTransParamPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLPointTransParamPageBussiness.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import "ParameterData_MeasurePoint_Comm.h"


@interface XLPointTransParamPageBussiness()

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
@implementation XLPointTransParamPageBussiness

SYNTHESIZE_SINGLETON_FOR_CLASS(XLPointTransParamPageBussiness);

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
    [self requestPointTransParam];
}

-(void)initNSArray
{
    self.resultArray = [NSMutableArray arrayWithObjects:
                        [NSMutableDictionary paramWithName:@"装置序号" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"测量点号" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"通信速率" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"端口号" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"通信协议类型" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"通信地址" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"费率数"  value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"示值小数位数" value:@"" type:XLParamTypeString],
                        [NSMutableDictionary paramWithName:@"示值整数位数" value:@"" type:XLParamTypeString],
                        nil];
}

-(void)requestPointTransParam
{
    
    //如果没连wifi，则直接返回空数据，发送通知
    if(![XLUtilities localWifiReachable])
    {
        NSArray *dbResult = [self readDataFromDBWithEntityName:@"ParameterData_MeasurePoint_Comm" withPredicate:nil];
        if([dbResult count]>0)
        {
            ParameterData_MeasurePoint_Comm *pointComm = (ParameterData_MeasurePoint_Comm*)[dbResult objectAtIndex:0];
            
            
            [[self.resultArray objectAtIndex:1] setObject:[NSString stringWithFormat:@"%d",[[pointComm valueForKey:@"pmMeasureNo"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:2] setObject:[NSString stringWithFormat:@"%d",[[pointComm valueForKey:@"pmCommSpeed"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:3] setObject:[NSString stringWithFormat:@"%d",[[pointComm valueForKey:@"pmCommPort"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:4] setObject:@"--" forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:5] setObject:[pointComm valueForKey:@"pmCommAddr"] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:6] setObject:[NSString stringWithFormat:@"%d",[[pointComm valueForKey:@"pmFeeNum"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:7] setObject:[NSString stringWithFormat:@"%d",[[pointComm valueForKey:@"pmDecimalNum"] integerValue]] forKey:@"paramValue"];
            
            [[self.resultArray objectAtIndex:8] setObject:[NSString stringWithFormat:@"%d",[[pointComm valueForKey:@"pmIntegerNum"] integerValue]] forKey:@"paramValue"];
            
        }
        [self sendNotification];
    }
    else
    {
        //发送f10
        
        PACKITEM dataitem;
        dataitem.fn = 10;
        dataitem.pn = 0;
        dataitem.data[0] = 1;dataitem.data[1] = 0;//1个测量点
        
        dataitem.data[2] =[self.pointNo integerValue]%256;
        dataitem.data[3] =[self.pointNo integerValue]/256;//测量点号
        
        dataitem.datalen = 4;
        dataitem.shouldUseByte = 1;
        self.frame= PackFrame(AFN0A, &dataitem, 1, &_outlen);
        
        //self.frame = PackFrameWithDadt(AFN0A, 1, 25, &_outlen);
        
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
        
        if ([dcs.allKeys containsObject:@"F10"]) {
            NSDictionary *dic = [dcs valueForKey:@"F10"];
            
            [self getF10Set:dic];
        }
        
    });
    
}

-(void)getF10Set:(NSDictionary*)dic
{
    [[self.resultArray objectAtIndex:0] setObject:[dic valueForKey:@"电能表/交流采样装置序号"] forKey:@"paramValue"];//装置序号
    
    [[self.resultArray objectAtIndex:1] setObject:[dic valueForKey:@"所属测量点号"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:2] setObject:[dic valueForKey:@"通信速率"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:3] setObject:[dic valueForKey:@"通信端口号"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:4] setObject:[dic valueForKey:@"通信协议类型"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:5] setObject:[dic valueForKey:@"通信地址"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:6] setObject:[dic valueForKey:@"电能费率个数"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:7] setObject:[dic valueForKey:@"有功电能示值小数位数"] forKey:@"paramValue"];
    
    [[self.resultArray objectAtIndex:8] setObject:[dic valueForKey:@"有功电能示值整数位数"] forKey:@"paramValue"];
    
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ParameterData_MeasurePoint_Comm"
                                              inManagedObjectContext:_context];
    
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    
    
    [fetchRequest setPredicate:nil];
    
    NSError *error;
    //返回检索结果
    NSArray *resultArray =[_context executeFetchRequest:fetchRequest error:&error];
    if([resultArray count]>0)
    {
        ParameterData_MeasurePoint_Comm *updateMeasurePoint = [resultArray objectAtIndex:0];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"电能表/交流采样装置序号"] integerValue]] forKey:@"pmMtrDeviceNo"];//装置序号
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"所属测量点号"] integerValue]] forKey:@"pmMeasureNo"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"通信速率"] integerValue]] forKey:@"pmCommSpeed"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"通信端口号"] integerValue]] forKey:@"pmCommPort"];
        
//        [updateMeasurePoint setValue:[dic valueForKey:@"通信协议类型"] forKey:@"paramValue"];
        
        [updateMeasurePoint setValue:[dic valueForKey:@"通信地址"]  forKey:@"pmCommAddr"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"电能费率个数"] integerValue]] forKey:@"pmFeeNum"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"有功电能示值小数位数"] integerValue]] forKey:@"pmDecimalNum"];
        
        [updateMeasurePoint setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"有功电能示值整数位数"] integerValue]] forKey:@"pmIntegerNum"];
        
        [self.context save:nil];
    }
    else
    {
        NSEntityDescription *measurePointComm =[NSEntityDescription insertNewObjectForEntityForName:@"ParameterData_MeasurePoint_Comm" inManagedObjectContext:_context];
        
        [measurePointComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"电能表/交流采样装置序号"] integerValue]] forKey:@"pmMtrDeviceNo"];//装置序号
        
        [measurePointComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"所属测量点号"] integerValue]] forKey:@"pmMeasureNo"];
        
        [measurePointComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"通信速率"] integerValue]] forKey:@"pmCommSpeed"];
        
        [measurePointComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"通信端口号"] integerValue]] forKey:@"pmCommPort"];
        
        //        [updateMeasurePoint setValue:[dic valueForKey:@"通信协议类型"] forKey:@"paramValue"];
        
        [measurePointComm setValue:[dic valueForKey:@"通信地址"]  forKey:@"pmCommAddr"];
        
        [measurePointComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"电能费率个数"] integerValue]] forKey:@"pmFeeNum"];
        
        [measurePointComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"有功电能示值小数位数"] integerValue]] forKey:@"pmDecimalNum"];
        
        [measurePointComm setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"有功电能示值整数位数"] integerValue]] forKey:@"pmIntegerNum"];

        
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
