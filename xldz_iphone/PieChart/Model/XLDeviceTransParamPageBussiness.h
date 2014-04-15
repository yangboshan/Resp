//
//  XLDeviceTransParamPageBussiness.h
//  XLApp
//
//  Created by xldz on 14-3-31.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"
#import "XLParamInterface.h"

@interface XLDeviceTransParamPageBussiness : NSObject

@property(nonatomic) NSDictionary *msgDic;//传过来的信息字典
@property (nonatomic) DeviceType deviceType;//deviceType，开关/变压器/未定义
@property (nonatomic) NSString *transportTypeString;//当前通信类型String，用于resultDic设置参数用
//通信参数
@property (nonatomic) DeviceTransportType transportType;//当前通信类型


+(XLDeviceTransParamPageBussiness*)sharedXLDeviceTransParamPageBussiness;
-(void)requestData;

@end
