//
//  XLSocketManager.m
//  XLDistributionBoxApp
//
//  Created by JY on 13-7-10.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//


#import "XLSocketManager.h"
#import "XL3761UnPack.h"
#import "XLParser.h"

@interface XLSocketManager()

@property (nonatomic, retain) NSOperationQueue* operatrionQueue;
@property (nonatomic, retain) NSData *frameData;
@property (nonatomic, retain) NSMutableDictionary *finalDic;
@property (nonatomic, retain) NSMutableDictionary *tempDic;

@property(nonatomic,assign) NSInteger dataTag;
@property(nonatomic,assign) NSInteger timeOut;
@end

@implementation XLSocketManager

SYNTHESIZE_SINGLETON_FOR_CLASS(XLSocketManager)

@synthesize operatrionQueue=_operatrionQueue;
@synthesize socket=_socket;
@synthesize frameData;

- (id)init
{
    if ((self = [super init]) != nil) {
        self.timeOut = 5;
        self.operatrionQueue = [[NSOperationQueue alloc] init];
        [self.operatrionQueue setMaxConcurrentOperationCount:1];
    }
    return self;
}

#pragma mark -Socket delegate Methods
/*－－－－－－－－－－－－－－－－－
 初始化并连接Socket
 －－－－－－－－－－－－－－－－－*/
-(void)connection{
    self.socket = nil;
    self.socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *err = nil;
    
    NSString *ipString  = @"10.10.2.1";
    NSInteger port = 2222;
    
    if(![self.socket connectToHost:ipString onPort:port error:&err])    {
        NSLog(@"连接错误");
    }
}

/*－－－－－－－－－－－－－－－－－
 已连接到HOST
 －－－－－－－－－－－－－－－－－*/
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"已成功连接到HOST!");
    [self.socket writeData:self.frameData withTimeout:self.timeOut tag:self.dataTag];
    [self.socket readDataWithTimeout:self.timeOut tag:self.dataTag];
}

/*－－－－－－－－－－－－－－－－－
 收到返回数据
 －－－－－－－－－－－－－－－－－*/
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"data"];
    
    NSLog(@"返回报文:%@",[data description]);
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_async(queue, ^{
        XL_SINT16 output = 0;
        unsigned short inlen = [data length];
        unsigned short outlen = 0;
        Byte *outbuff = NULL;
        int  multiFrameFlag = 0;    //多帧标志
        
        if(UnPackFrame(&output,inlen, (Byte*)[data bytes], &outlen, &outbuff,&multiFrameFlag) == 1){
            
            if (output == 1 || output == 2 || output == -1){
                [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@__spe__handle__",self.notifyName]
                                                                    object:Nil
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",output], @"key",nil]];
            } else {
                
                if (multiFrameFlag!=2) {
                    
                    XLParser *parser = [[XLParser alloc] init];
                    NSData *revData = [NSData dataWithBytes:outbuff length:outlen];
                    [parser initWithNSData:revData];
                    self.tempDic = parser.finalSet;
                    
                    [self.tempDic.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        [self.finalDic setObject:[self.tempDic valueForKey:obj] forKey:obj];
                    }];
                    
                    NSLog(@"多桢处理");
                    if (multiFrameFlag == 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:self.notifyName
                                                                            object:nil
                                                                          userInfo:self.finalDic];
                        NSLog(@"多桢发送通知");
                    }
                }
                if (multiFrameFlag == 2) {
                    
                    XLParser *parser = [[XLParser alloc] init];
                    NSData *revData = [NSData dataWithBytes:outbuff length:outlen];
                    [parser initWithNSData:revData];
                    self.finalDic = parser.finalSet;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:self.notifyName
                                                                        object:nil
                                                                      userInfo:self.finalDic];
                    NSLog(@"单桢发送通知");
                }
            }
            
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@__spe__handle__",self.notifyName]
                                                                object:Nil
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"key",nil]];
        }
    });
    
    
    [sock readDataWithTimeout:self.timeOut tag:self.dataTag];
}

/*－－－－－－－－－－－－－－－－－
 SOCKET连接已断开
 －－－－－－－－－－－－－－－－－*/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"SOCKET连接已断开");
    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@__spe__handle__",self.notifyName]
                                                        object:Nil
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"-2", @"key",nil]];
}


#pragma mark -methods..
/*－－－－－－－－－－－－－－－－－
 连接SOCKET
 －－－－－－－－－－－－－－－－－*/
-(void)packRequestFrame:(NSData*)userData{
    
    if (self.isFromBackground) {
        self.dataTag = 1;
    } else {
        self.dataTag = 0;
    }
    
    self.frameData = userData;
    self.finalDic = [NSMutableDictionary dictionary];
    if (self.frameData) {
        if (self.socket.isConnected) {
            [self.socket writeData:self.frameData withTimeout:self.timeOut tag:self.dataTag];
            [self.socket readDataWithTimeout:self.timeOut tag:self.dataTag];
        } else{
            [self connection];
        }
    }
}
@end
