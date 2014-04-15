//
//  XLDeviceEventParamPageBussiness.h
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"
#import "XLParamInterface.h"

@interface XLDeviceEventParamPageBussiness : NSObject

@property(nonatomic) NSDictionary *msgDic;//传过来的信息字典

+(XLDeviceEventParamPageBussiness*)sharedXLDeviceEventParamPageBussiness;
-(void)requestData;

@end
