//
//  XLPointThresholdParamPageBussiness.h
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"
#import "XLParamInterface.h"

@interface XLPointThresholdParamPageBussiness : NSObject


@property(nonatomic) NSDictionary *msgDic;//传过来的信息字典

@property (nonatomic) NSString *pointId;
@property (nonatomic) NSString *pointName;//名称
@property (nonatomic) NSString *pointNo;//测量点号



+(XLPointThresholdParamPageBussiness*)sharedXLPointThresholdParamPageBussiness;
-(void)requestData;

@end
