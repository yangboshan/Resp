//
//  XLDeviceEventPageBussiness.h
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"

@interface XLDeviceEventPageBussiness : NSObject

@property(nonatomic) NSDictionary *msgDic;//传过来的信息字典

+(XLDeviceEventPageBussiness*)sharedXLDeviceEventPageBussiness;
-(void)requestData;

@end
