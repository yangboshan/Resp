//
//  XLDeviceEventPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLDeviceEventPageBussiness.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import "EventData.h"

@interface XLDeviceEventPageBussiness()

//请求报文Bytes
@property(nonatomic,assign) Byte* frame;

//请求报文Data
@property(nonatomic,strong) NSData *data;

//报文输出长度
@property(nonatomic,assign) XL_UINT16 outlen;

//查询到的事件数组，用于发送消息
@property(nonatomic) NSMutableArray *resultArray;

//用于数据库操作的属性
@property (nonatomic,strong) NSManagedObjectContext *context;

//notifyName
@property(nonatomic) NSString *notifyName;

//重要事件计数器当前值
@property(nonatomic) NSInteger imptEventCount;

//一般事件计数器当前值
@property(nonatomic) NSInteger normalEventCount;

//上一次抄读事件的起始指针
@property(nonatomic) NSInteger imptEventLastPoint;
//上一次抄读事件的起始指针
@property(nonatomic) NSInteger normalEventLastPoint;

@end

@implementation XLDeviceEventPageBussiness

SYNTHESIZE_SINGLETON_FOR_CLASS(XLDeviceEventPageBussiness)

-(id)init{
    if (self = [super init]) {
        self.context = [[XLCoreData sharedXLCoreData] managedObjectContext];
        
        self.notifyName = [NSString stringWithFormat:@"__%@__notify__%d",[self class],arc4random()];
        
        //注册消息通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponse:) name:self.notifyName object:nil];
        
        //获取测量点号，目前还没有
        //        self.mtrNo = [self.msgDic valueForKey:@"mtrNo"];
        
        //resultArray声明
        self.resultArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)requestData
{
    
    //调用查询参数组帧发送方法
    [self requestDeviceEvent];
    
    [self sendNotification];
}

-(void)requestDeviceEvent
{
    //判断连接wifi，则开始抄读数据,否则读取数据库
    if([XLUtilities localWifiReachable])
    {
        //读取0x0C,F7
        self.frame = PackFrameWithDadt(0x0C, 0, 7, &_outlen);
        
        self.data = [NSData dataWithBytes:self.frame length:self.outlen];
        NSLog(@"%@",[self.data description]);
        free(self.frame);
        [[XLSocketManager sharedXLSocketManager] packRequestFrameWithData:self.data withNotifyName:self.notifyName];
    }
    
}

//回调方法 handleResponse
-(void)handleResponse:(NSNotification*)notify
{
    NSLog(@"into handleResponse:");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
        
        NSDictionary* dcs = notify.userInfo;
        
        if ([dcs.allKeys containsObject:@"F1"]) {
            NSDictionary *dic = [dcs valueForKey:@"F1"];//重要事件
            //解析
            [self saveDataIntoDBWithEntity:dic];
            //继续抄读
            if(self.imptEventLastPoint>0)
            {
                [self requestEventDataWithFn:1 withEndPoint:self.imptEventLastPoint-1];
            }
            else
            {
                
                //如果一般事件条数大于0
                if(self.normalEventCount >0)
                {
                    [self requestEventDataWithFn:2 withEndPoint:self.normalEventCount];
                }
            }
            
        }
        if ([dcs.allKeys containsObject:@"F2"]) {
            NSDictionary *dic = [dcs valueForKey:@"F2"];//一般事件
            
            if(self.imptEventLastPoint>0)
            {
                [self requestEventDataWithFn:2 withEndPoint:self.imptEventLastPoint-1];
            }
            
        }
        
        if([dcs.allKeys containsObject:@"F7"]){
            NSDictionary *dic = [dcs valueForKey:@"F7"];
            self.imptEventCount = [[dic valueForKey:@"当前重要事件计数器EC1值"] integerValue];
            self.normalEventCount = [[dic valueForKey:@"当前一般事件计数器EC2值"] integerValue];
            
            //如果重要时间条数大于0
            if(self.imptEventCount >0)
            {
                [self requestEventDataWithFn:1 withEndPoint:self.imptEventCount];
            }
        }
        
    });
}

//从终端抄读事件数据
-(void)requestEventDataWithFn:(XL_UINT8)fn withEndPoint:(XL_UINT8)endPoint
{
    //起始指针
    NSInteger startPoint = ((endPoint-10<0) ? 0 : (endPoint-10));
    if(fn == 1)
    {
        self.imptEventLastPoint = startPoint;
    }
    else if(fn == 2)
    {
        self.normalEventLastPoint = startPoint;
    }
    
    //读取0x0E,fn
    self.frame = PackFrameForEvent(AFN0E, 0, fn, startPoint, endPoint, &_outlen);
    self.data = [NSData dataWithBytes:self.frame length:self.outlen];
    NSLog(@"%@",[self.data description]);
    free(self.frame);
    [[XLSocketManager sharedXLSocketManager] packRequestFrameWithData:self.data withNotifyName:self.notifyName];
}

//数据存库
-(void)saveDataIntoDBWithEntity:(NSDictionary*)dic
{
    
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

//发送消息
-(void)sendNotification
{
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.msgDic, @"parameter",
                               self.resultArray, @"result",
                               nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
}

@end
