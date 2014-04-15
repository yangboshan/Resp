//
//  XLDeviceTransParamPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-3-31.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLDeviceTransParamPageBussiness.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import "ParameterData_Terminal_Comm.h"

@interface XLDeviceTransParamPageBussiness()
//请求报文Bytes
@property(nonatomic,assign) Byte* frame;

//请求报文Data
@property(nonatomic,strong) NSData *data;

//报文输出长度
@property(nonatomic,assign) XL_UINT16 outlen;

//notifyName
@property(nonatomic) NSString *notifyName;

//用于数据库操作的context属性
@property (nonatomic,strong) NSManagedObjectContext *context;

@end

@implementation XLDeviceTransParamPageBussiness

SYNTHESIZE_SINGLETON_FOR_CLASS(XLDeviceTransParamPageBussiness);


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

NSMutableArray *wifi, *lan, *gprs;

-(void)requestData
{
    //注册消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponse:) name:@"user" object:nil];
    
    //初始化通信参数数组
    [self initNSArray];
    
    //调用查询参数组帧发送方法
    [self requestDeviceBasicParam];
}

-(void)initNSArray
{
    wifi = [NSMutableArray arrayWithObjects:
            [NSMutableDictionary paramWithName:@"SSID" value:@"" type:XLParamTypeString],
            [NSMutableDictionary paramWithName:@"端口号" value:@"" type:XLParamTypeString],
            [NSMutableDictionary paramWithName:@"密码" value:@"" type:XLParamTypeString],
            nil];
    lan = [NSMutableArray arrayWithObjects:
           [NSMutableDictionary paramWithName:@"主站IP" value:@"" type:XLParamTypeString],
           [NSMutableDictionary paramWithName:@"端口号" value:@"" type:XLParamTypeString],
           [NSMutableDictionary paramWithName:@"设备IP" value:@"" type:XLParamTypeString],
           [NSMutableDictionary paramWithName:@"子网掩码" value:@"" type:XLParamTypeString],
           [NSMutableDictionary paramWithName:@"网关" value:@"" type:XLParamTypeString],
           nil];
    gprs = [NSMutableArray arrayWithObjects:
            [NSMutableDictionary paramWithName:@"主站IP" value:@"" type:XLParamTypeString],
            [NSMutableDictionary paramWithName:@"端口号" value:@"" type:XLParamTypeString],
            [NSMutableDictionary paramWithName:@"APN" value:@"" type:XLParamTypeString],
            [NSMutableDictionary paramWithName:@"月通信流量门限" value:@"" type:XLParamTypeString],
            nil];
}

-(void)requestDeviceBasicParam
{
    //如果没连wifi，则直接返回空数据，发送通知
    if(![XLUtilities localWifiReachable])
    {
//        [self sendNotification];
        NSArray *resultArray = [self readDataFromDBWithEntityName:@"ParameterData_Terminal_Comm" withPredicate:nil];
        if([resultArray count]>0)
        {
            ParameterData_Terminal_Comm *terminalComm = (ParameterData_Terminal_Comm*)[resultArray objectAtIndex:0];
            
            NSString *temp = [terminalComm valueForKey:@"pmSSID"];
            if(temp)
            {
                [[wifi objectAtIndex:0] setObject:temp forKey:@"paramValue"];
            }
            
            temp = [terminalComm valueForKey:@"pmPassword"];
            if (temp)
            {
                [[wifi objectAtIndex:2] setObject:temp forKey:@"paramValue"];
            }
            
            [[wifi objectAtIndex:1] setObject:@"2222" forKey:@"paramValue"];
            
        }
        [self sendNotification];
    }
    else
    {
        switch (self.transportType) {
            case DeviceTransportTypeLAN://F3,F7
                [self requestDeviceBasicParamWithFn:3];
                break;
            case DeviceTransportTypeGPRS://F3,F36
                [self requestDeviceBasicParamWithFn:3];
                break;
            case DeviceTransportTypeWiFi://wifi 169
                [self requestDeviceBasicParamWithFn:170];
                break;
                
            default:
                break;
        }
        
    }
}

-(void)requestDeviceBasicParamWithFn:(NSInteger)fn
{
    
    self.frame = PackFrameWithDadt(0x0A, 0, fn, &_outlen);
    
    self.data = [NSData dataWithBytes:self.frame length:self.outlen];
    NSLog(@"%@",[self.data description]);
    NSLog(@"发送报文为：%@",[self.data description]);
    free(self.frame);
    
//    [[XLSocketManager sharedXLSocketManager] packRequestFrame:self.data];
    [[XLSocketManager sharedXLSocketManager] packRequestFrameWithData:self.data withNotifyName:self.notifyName];
}

-(void)handleResponse:(NSNotification*)notify{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
        
        NSDictionary* dcs = notify.userInfo;
        
        if ([dcs.allKeys containsObject:@"F170"]) {
            NSDictionary *dic = [dcs valueForKey:@"F170"];
            
            [self getF170Set:dic];
        }
        else if([dcs.allKeys containsObject:@"F3"]){
            NSDictionary *dic = [dcs valueForKey:@"F3"];
            
            [self getF3Set:dic];
        }
        else if([dcs.allKeys containsObject:@"F7"]){
            NSDictionary *dic = [dcs valueForKey:@"F7"];
            
            [self getF7Set:dic];
        }
        else if([dcs.allKeys containsObject:@"F36"]){
            NSDictionary *dic = [dcs valueForKey:@"F36"];
            
            [self getF36Set:dic];
        }
    });

}

//得到F3的数据显示在界面上
-(void)getF3Set:(NSDictionary *)dic
{
    NSString *ipString = @"";
    
    [ipString stringByAppendingString:[NSString stringWithFormat:@"%i",[[dic valueForKey:@"主站主用IP1段"] integerValue]]];
    [ipString stringByAppendingString:@"."];
    [ipString stringByAppendingString:[NSString stringWithFormat:@"%i",[[dic valueForKey:@"主站主用IP2段"] integerValue]]];
    [ipString stringByAppendingString:@"."];
    [ipString stringByAppendingString:[NSString stringWithFormat:@"%i",[[dic valueForKey:@"主站主用IP3段"] integerValue]]];
    [ipString stringByAppendingString:@"."];
    [ipString stringByAppendingString:[NSString stringWithFormat:@"%i",[[dic valueForKey:@"主站主用IP4段"] integerValue]]];
    
    
    
    
    if (self.transportType == DeviceTransportTypeLAN)//抄读完这个抄读F7
    {
        
        [[lan objectAtIndex:0] setObject:ipString forKey:@"主站IP"];
        
        [[lan objectAtIndex:1] setObject:[dic valueForKey:@"主站主用端口"] forKey:@"端口号"];
        
//        [self requestDeviceBasicParamWithFn:7];
        //抄读完成后发送Notification
        
        [self sendNotification];
    }
    else if(self.transportType == DeviceTransportTypeGPRS)
    {
        [[gprs objectAtIndex:0] setObject:ipString forKey:@"paramValue"];
        
        [[gprs objectAtIndex:1] setObject:[dic valueForKey:@"主站主用端口"] forKey:@"paramValue"];
        
        [[gprs objectAtIndex:2] setObject:[dic valueForKey:@"主站APN"] forKey:@"paramValue"];
        
        [self requestDeviceBasicParamWithFn:36];
    }
    
    
    
}

//得到F7的数据显示在界面上
-(void)getF7Set:(NSDictionary *)dic
{
    
    
}

//得到F36的数据显示在界面上
-(void)getF36Set:(NSDictionary *)dic
{
    [[gprs objectAtIndex:3] setObject:[dic valueForKey:@"月通信流量门限"] forKey:@"paramValue"];
    
    [self sendNotification];
}

//得到F170的数据显示在界面上
-(void)getF170Set:(NSDictionary *)dic
{
    NSString *temp = [dic valueForKey:@"WIFI SSID"];
    if(temp)
    {
        [[wifi objectAtIndex:0] setObject:temp forKey:@"paramValue"];
    }
    
    temp = [dic valueForKey:@"WIFI 密码"];
    if (temp)
    {
        [[wifi objectAtIndex:2] setObject:temp forKey:@"paramValue"];
    }
    
    [[wifi objectAtIndex:1] setObject:@"2222" forKey:@"paramValue"];
    
    [self sendNotification];
    
    [self saveDataIntoDBWithEntity:dic];
}

//发送Notification
-(void)sendNotification
{
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.transportTypeString, @"SELECTED_GROUP",
                                   @[@"WiFi", @"以太网", @"GPRS"], @"GROUPS",
                                   [wifi paramsCopy], @"WiFi",
                                   [lan paramsCopy], @"以太网",
                                   [gprs paramsCopy], @"GPRS",
                                   nil];
    
    
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.msgDic, @"parameter",
                               result, @"result",
                               nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
}

//保存数据到数据库
-(void)saveDataIntoDBWithEntity:(NSDictionary*)dic
{
    //存库之前先判断该设备是否已经存在于数据库中，查询条件为名称和所属用户与数据库中相同
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //声明实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ParameterData_Terminal_Comm"
                                              inManagedObjectContext:_context];
    
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    
    
    [fetchRequest setPredicate:nil];
    
    NSError *error;
    //返回检索结果
    NSArray *resultArray =[_context executeFetchRequest:fetchRequest error:&error];
    if([resultArray count]>0)
    {
        ParameterData_Terminal_Comm *updateTerminalComm = [resultArray objectAtIndex:0];
        
        
        NSString *temp = [dic valueForKey:@"WIFI SSID"];
        if(temp)
        {
            [updateTerminalComm setValue:temp forKey:@"pmSSID"];
        }
        
        temp = [dic valueForKey:@"WIFI 密码"];
        if (temp)
        {
            [updateTerminalComm setValue:temp forKey:@"pmPassword"];
        }
        
        [updateTerminalComm setValue:[NSNumber numberWithInt:2222] forKey:@"pmPortNumber"];
        
        
        [self.context save:nil];
    }
    else
    {
        NSEntityDescription *terminalComm =[NSEntityDescription insertNewObjectForEntityForName:@"ParameterData_Terminal_Comm" inManagedObjectContext:_context];
        
        NSString *temp = [dic valueForKey:@"WIFI SSID"];
        if(temp)
        {
            [terminalComm setValue:temp forKey:@"pmSSID"];
        }
        
        temp = [dic valueForKey:@"WIFI 密码"];
        if (temp)
        {
            [terminalComm setValue:temp forKey:@"pmPassword"];
        }
        
        [terminalComm setValue:[NSNumber numberWithInt:2222] forKey:@"pmPortNumber"];
        
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
