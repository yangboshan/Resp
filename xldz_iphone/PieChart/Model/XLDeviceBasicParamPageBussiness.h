//
//  XLDeviceBasicParamPageBussiness.h
//  XLApp
//
//  Created by xldz on 14-3-27.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"
#import "XLParamInterface.h"

@interface XLDeviceBasicParamPageBussiness : NSObject


@property(nonatomic) NSDictionary *msgDic;//传过来的信息字典
@property (nonatomic) DeviceType deviceType;//设备名称
@property (nonatomic) NSString *deviceName;//名称
@property (nonatomic) XLViewDataUserBaiscInfo *user;//用户信息

+(XLDeviceBasicParamPageBussiness*)sharedXLDeviceBasicParamPageBussiness;
-(void)requestData;

@end
