//
//  XLSettingManager.m
//  XLApp
//
//  Created by JY on 14-3-31.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLSettingManager.h"
#import "SynthesizeSingleton.h"

static NSString *SETTING_FIRST_TIME_RUN = @"SETTING_FIRST_TIME_RUN";
static NSString *SETTING_VERSION_NUMBER = @"SETTING_VERSION_NUMBER";
static NSString *SETTING_IPSTRING = @"SETTING_IPSTRING";
static NSString *SETTING_PORT     = @"SETTING_PORT";
static NSString *SETTING_NOTIFY_PREFIX     = @"SETTING_NOTIFY_PREFIX";

@interface XLSettingManager()

@property (nonatomic, retain) NSUserDefaults *userDefaults;
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
        
        self.ipString = @"192.70.2.1";
        self.port = @"5678";
        
        
        /*－－－－－－－－－－－－－－－
         APP是否初次运行 做一些配置
         －－－－－－－－－－－－－－－*/
        
        NSObject *setting = [self.userDefaults objectForKey:SETTING_FIRST_TIME_RUN];
        if (setting == nil)
        {
            [self.userDefaults setObject:[NSNumber numberWithInt:1] forKey:SETTING_FIRST_TIME_RUN];

            
            [self.userDefaults synchronize];
        }
    }
    return self;
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
