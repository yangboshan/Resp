//
//  XLSettingManager.m
//  XLApp
//
//  Created by JY on 14-3-31.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLSettingManager.h"
#import "SynthesizeSingleton.h"
#import "XLSystemBussiness.h"
#import "XLEntity.h"
#import "XLSyncDeviceBussiness.h"


static NSString *SETTING_FIRST_TIME_RUN = @"SETTING_FIRST_TIME_RUN";
static NSString *SETTING_VERSION_NUMBER = @"SETTING_VERSION_NUMBER";
static NSString *SETTING_IPSTRING = @"SETTING_IPSTRING";
static NSString *SETTING_PORT     = @"SETTING_PORT";
static NSString *SETTING_NOTIFY_PREFIX     = @"SETTING_NOTIFY_PREFIX";

@interface XLSettingManager()

@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic,strong) NSManagedObjectContext *contextParent; 
@end

@implementation XLSettingManager

SYNTHESIZE_SINGLETON_FOR_CLASS(XLSettingManager)

@dynamic ipString;
@dynamic port;
@synthesize userDefaults = _userDefaults;

/*－－－－－－－－－－－－－－－－－
 配置
 
 检测第一次运行配置环境
 复制SQLite
 初始化变量
 －－－－－－－－－－－－－－－－－*/
- (id)init
{
    if (self = [super init])
    {
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        
        self.ipString = @"10.10.2.1";
        self.port = @"2222";
        
        
        /*－－－－－－－－－－－－－－－
         APP是否初次运行 做一些配置
         －－－－－－－－－－－－－－－*/
        self.contextParent = [[XLCoreData sharedXLCoreData] managedObjectContext];
        
        NSObject *setting = [self.userDefaults objectForKey:SETTING_FIRST_TIME_RUN];
        if (setting == nil)
        {
            [self.userDefaults setObject:[NSNumber numberWithInt:1] forKey:SETTING_FIRST_TIME_RUN];
            [self.userDefaults synchronize];
            
//            [self initialAppInfo];
        }
    }
    return self;
}

-(void)beginSyncData{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        XLSyncDeviceBussiness* sync = [[XLSyncDeviceBussiness alloc] init];
        [sync beginSync];
        
//        [[XLSyncDeviceBussiness sharedXLSyncDeviceBussiness] beginSync];
    });
}

//初始化工作 第一次启动创建 默认系统 默认线路
-(void)initialAppInfo{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    
    NSString* sysId,*lineId;
    
    SystemInfo *defaultSys = (SystemInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"SystemInfo" inManagedObjectContext:context];
    
    [defaultSys setValue:@"默认系统" forKey:@"name"];
    [defaultSys setValue:@"系统描述" forKey:@"desc"];
    sysId = [[XLSystemBussiness sharedXLSystemBussiness] addSystem:defaultSys];
    
    LineInfo *defaultline = (LineInfo *)[NSEntityDescription insertNewObjectForEntityForName:@"LineInfo" inManagedObjectContext:context];
    [defaultline setValue:@"默认线路" forKey:@"name"];
    [defaultline setValue:@"线路描述" forKey:@"desc"];
    lineId = [[XLSystemBussiness sharedXLSystemBussiness] addLine:defaultline];
    
    [defaultSys setValue:sysId forKey:@"id"];
    [defaultline setValue:lineId forKey:@"id"];
 
    
    [[XLSystemBussiness sharedXLSystemBussiness] addLine:defaultline
                                               forSystem:defaultSys];
}


//从UserDefaulut获取IP地址
- (NSString*)ipString
{
    return [self.userDefaults stringForKey:SETTING_IPSTRING];
}

//保存IP地址到UserDefault
- (void)setIpString:(NSString *)ipString
{
    [self.userDefaults setObject:ipString forKey:SETTING_IPSTRING];
    [self.userDefaults synchronize];
}

//从UserDefaulut获取端口号
-(NSString*)port
{
    return [self.userDefaults stringForKey:SETTING_PORT] ;
}

//保存端口号到UserDefaulut
-(void)setPort:(NSString*)port
{
    [self.userDefaults setObject:port forKey:SETTING_PORT];
    [self.userDefaults synchronize];
}

@end
