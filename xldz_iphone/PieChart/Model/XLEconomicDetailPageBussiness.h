//
//  XLEconomicDetailPageBussiness.h
//  XLApp
//
//  Created by xldz on 14-4-1.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"

@interface XLEconomicDetailPageBussiness : NSObject


@property(nonatomic) NSDictionary *msgDic;//传过来的信息字典

+(XLEconomicDetailPageBussiness*)sharedXLEconomicDetailPageBussiness;

//供详细信息页面调用的方法
-(void)requestData;

//得到所有测量点的状态
-(NSArray*)AllMtrNoStatus;

//遍历测量点判断经济性如何
-(BOOL)judgeEconomic;

@end
