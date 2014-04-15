//
//  XLDeviceEventParamPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLDeviceEventParamPageBussiness.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "XLUtilities.h"

@interface XLDeviceEventParamPageBussiness()

//请求报文Bytes
@property(nonatomic,assign) Byte* frame;

//请求报文Data
@property(nonatomic,strong) NSData *data;

//报文输出长度
@property(nonatomic,assign) XL_UINT16 outlen;


@property(nonatomic) NSMutableArray *resultArray;


//notifyName
@property(nonatomic) NSString *notifyName;

@end

@implementation XLDeviceEventParamPageBussiness
SYNTHESIZE_SINGLETON_FOR_CLASS(XLDeviceEventParamPageBussiness)

//初始化方法
-(id)init{
    if (self = [super init]) {
        
        
        self.notifyName = [NSString stringWithFormat:@"__%@__notify__%d",[self class],arc4random()];
        
        
        //注册消息通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponse:) name:self.notifyName object:nil];
    }
    return self;
}


DeviceEventLevel *checkBoxArray[13];
XL_UINT8 ercNumberArray[]={1,24,25,26,17,11,3,15,2,32,4,16,28};

-(void)requestData
{
    //注册消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponse:) name:@"user" object:nil];
    
    //给checkBoxArray赋初始值
    for(int i=0;i<13;i++)
    {
        checkBoxArray[i] = DeviceEventLevelNormal;
    }
    //
    for(int i=0;i<11;i++)
    {
        checkBoxArray[i] = DeviceEventLevelImportant;
    }
    
    //初始化通信参数数组
    [self initNSArray];
    
    //调用查询参数组帧发送方法
    [self requestDeviceEventParam];
}

-(void)initNSArray
{
    self.resultArray = [NSMutableArray arrayWithObjects:
                        [NSMutableDictionary paramWithName:@"初始化／版本变更" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[0]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"电压越限" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[1]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"电流越限" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[2]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"视在功率越限" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[3]] type:XLParamTypeNumber],
                        
                        [NSMutableDictionary paramWithName:@"电压／电流不平衡度越限" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[4]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"相序异常" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[5]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"参数变更记录" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[6]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"谐波越限告警" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[7]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"参数丢失记录" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[8]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"通信流量超门限" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[9]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"状态量变位" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[10]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"直流模拟量越限" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[11]] type:XLParamTypeNumber],
                        [NSMutableDictionary paramWithName:@"电能表超差" value:[NSNumber numberWithUnsignedInteger:checkBoxArray[12]] type:XLParamTypeNumber],
                        nil];
}


-(void)requestDeviceEventParam
{
    
    //如果没连wifi，则直接返回空数据，发送通知
    if(![XLUtilities localWifiReachable])
    {
        [self sendNotification];
    }
    else
    {
        //发送f9
        self.frame = PackFrameWithDadt(0x0A, 0, 9, &_outlen);
        
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
        
        if ([dcs.allKeys containsObject:@"F9"]) {
            NSDictionary *dic = [dcs valueForKey:@"F9"];
            
            [self getF9Set:dic];
        }
        
    });
    
}

-(void)getF9Set:(NSDictionary *)dic
{
    
    //事件记录有效标志位
    
    //事件重要性等级标志位,string类型
    NSString *importantFlagString = [dic valueForKey:@"事件重要性等级标志位"];
    
    NSString *stringTemp1 = @"";
    NSString *stringTemp2 = @"";
    
    for (XL_UINT8 i = 0; i<13; i++) {
        stringTemp1 = @"";
        stringTemp2 = @"";
        stringTemp1 = [stringTemp1 stringByAppendingString:[NSString stringWithFormat:@"%i",ercNumberArray[i]]];
        stringTemp1 = [stringTemp1 stringByAppendingString:@","];
        
        stringTemp2 = [stringTemp2 stringByAppendingString:@","];
        stringTemp2 = [stringTemp2 stringByAppendingString:[NSString stringWithFormat:@"%i",ercNumberArray[i]]];
        if (([importantFlagString rangeOfString:stringTemp1].length > 0) || ([importantFlagString rangeOfString:stringTemp2].length > 0))
        {
            checkBoxArray[i] = DeviceEventLevelImportant;
        }
    }
    
    [self initNSArray];
    
    [self sendNotification];
    
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



@end
