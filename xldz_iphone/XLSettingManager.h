//
//  XLSettingManager.h
//  XLApp
//
//  Created by JY on 14-3-31.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLSettingManager : NSObject


/*IP*/
@property (nonatomic,copy) NSString *ipString;

/*端口*/
@property (nonatomic,copy) NSString *port;

/*通知前缀*/
@property (nonatomic,copy) NSString *notifyPrefix;

/*设备Token*/
@property (nonatomic,copy) NSString *deviceToken;

+ (XLSettingManager *)sharedXLSettingManager;
@end
