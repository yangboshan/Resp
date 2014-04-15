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
#import "XLUtilities.h"
#import "XLSettingManager.h"


@interface XLSocketManager()

@property (nonatomic, strong) NSOperationQueue* operatrionQueue;
@property (nonatomic, strong) NSData *frameData;
@property (nonatomic, strong) NSMutableDictionary *finalDic;
@property (nonatomic, strong) NSMutableDictionary *tempDic;

@property(nonatomic,assign) NSInteger dataTag;
@property(nonatomic,assign) NSInteger timeOut;

@property(nonatomic,strong) NSMutableDictionary *notifyDic;

@property(nonatomic,assign) dispatch_queue_t bgQueue;
@property(nonatomic,assign) dispatch_semaphore_t semaphore;

@property(nonatomic,strong) NSString* afnType;
@end


@implementation XLSocketManager

SYNTHESIZE_SINGLETON_FOR_CLASS(XLSocketManager)

@synthesize operatrionQueue=_operatrionQueue;
@synthesize socket=_socket;
@synthesize frameData;

- (id)init
{
    if ((self = [super init]) != nil) {

        self.notifyDic = [NSMutableDictionary dictionary];
        
        self.semaphore = dispatch_semaphore_create(0);
        self.bgQueue   = dispatch_queue_create("COM.XLCOMBINE.SOCKETMANAGER", DISPATCH_QUEUE_SERIAL);
        dispatch_semaphore_signal(_semaphore);
        
        self.timeOut = 20;
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
    
    NSString *ipString  = [[XLSettingManager sharedXLSettingManager] ipString];
    NSInteger port = [[[XLSettingManager sharedXLSettingManager] port] integerValue];
    
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
    @autoreleasepool {
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        dispatch_async(queue, ^{
            
            //返回报文SEQ
            NSInteger revSEQ = [XLUtilities parseSeqFieldWithData:data];
            NSLog(@"返回报文:%@ SEQ帧序列:%d",[data description],revSEQ);
            
            
            XL_SINT16 output = 0;
            unsigned short inlen = [data length];
            unsigned short outlen = 0;
            Byte *outbuff = NULL;
            Byte afnType;
            int  multiFrameFlag = 0;    //多帧标志
            
            int seqCounter = 0;
            
            if(UnPackFrame(&output,inlen, (Byte*)[data bytes], &outlen, &outbuff,&multiFrameFlag,&afnType) == 1){
                
                self.afnType = [NSString stringWithFormat:@"%d",afnType];
                if (output == 1 || output == 2 || output == -1){
                    
                    self.notifyName = [self.notifyDic valueForKey:[NSString stringWithFormat:@"%d",revSEQ]];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@__spe__handle__",self.notifyName]
                                                                        object:Nil
                                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%d",output], @"key",nil]];
                    
                    [self.notifyDic removeObjectForKey:[NSNumber numberWithInteger:revSEQ]];
                    dispatch_semaphore_signal(_semaphore);
                    
                } else {
                    if (multiFrameFlag!=2) {
                        seqCounter++;
                        XLParser *parser = [[XLParser alloc] init];
                        NSData *revData = [NSData dataWithBytes:outbuff length:outlen];
                        [parser initWithNSData:revData];
                        self.tempDic = parser.finalSet;
                        
                        [self.tempDic.allKeys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            [self.finalDic setObject:[self.tempDic valueForKey:obj] forKey:obj];
                        }];
                        
                        NSLog(@"多桢处理");
                        if (multiFrameFlag == 0) {
                            
                            self.notifyName = [self.notifyDic valueForKey:[NSString stringWithFormat:@"%d",revSEQ - seqCounter]];
                            [[NSNotificationCenter defaultCenter] postNotificationName:self.notifyName
                                                                                object:self.afnType
                                                                              userInfo:self.finalDic];
                            seqCounter = 0;
                            NSLog(@"多桢发送");
                            [self.notifyDic removeObjectForKey:[NSNumber numberWithInteger:revSEQ]];
                            dispatch_semaphore_signal(_semaphore);
                        }
                    }
                    if (multiFrameFlag == 2) {
                        
                        self.notifyName = [self.notifyDic valueForKey:[NSString stringWithFormat:@"%d",revSEQ]];
                        
                        NSLog(@"NotifyName:%@ SEQ:%d",self.notifyName,revSEQ);
                        
                        XLParser *parser = [[XLParser alloc] init];
                        NSData *revData = [NSData dataWithBytes:outbuff length:outlen];
                        [parser initWithNSData:revData];
                        self.finalDic = parser.finalSet;
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:self.notifyName
                                                                            object:self.afnType
                                                                          userInfo:[self.finalDic copy]];
                        self.finalDic = nil;
                        [self.notifyDic removeObjectForKey:[NSNumber numberWithInteger:revSEQ]];
                        dispatch_semaphore_signal(_semaphore);
                        NSLog(@"单桢发送");
                    }
                }
                
            }
            free(outbuff);
        });
    }
    [sock readDataWithTimeout:self.timeOut tag:self.dataTag];
}

/*－－－－－－－－－－－－－－－－－
 SOCKET连接已断开
 －－－－－－－－－－－－－－－－－*/
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"SOCKET连接已断开");
//    [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@__spe__handle__",self.notifyName]
//                                                        object:Nil
//                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"-2", @"key",nil]];
}


#pragma mark -methods..
/*－－－－－－－－－－－－－－－－－
 连接SOCKET
 －－－－－－－－－－－－－－－－－*/
-(void)packRequestFrame:(NSData*)userData{

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

-(void)packRequestFrameWithData:(NSData*)userData withNotifyName:(NSString*)notify{
    
    NSInteger seq = [XLUtilities parseSeqFieldWithData:userData];
    [self.notifyDic setValue:notify forKey:[NSString stringWithFormat:@"%d",seq]];
    
    dispatch_async(self.bgQueue, ^{
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
        NSData* tempData  = userData;
        
        self.finalDic = [NSMutableDictionary dictionary];
            if (self.socket.isConnected) {
                [self.socket writeData:tempData withTimeout:self.timeOut tag:self.dataTag];
                [self.socket readDataWithTimeout:self.timeOut tag:self.dataTag];
            } else{
                self.frameData = userData;
                [self connection];
            }
    });
}
@end
