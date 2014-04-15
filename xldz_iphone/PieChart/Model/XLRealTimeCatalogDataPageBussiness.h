//
//  XLRealTimeCatalogDataPageBussiness.h
//  XLApp
//
//  Created by xldz on 14-4-9.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"

@interface XLRealTimeCatalogDataPageBussiness : NSObject

@property(nonatomic) NSDictionary *msgDic;//传过来的信息字典
@property(nonatomic) BOOL isPoint;//是否是测量点

+(XLRealTimeCatalogDataPageBussiness*)sharedXLRealTimeCatalogDataPageBussiness;
-(void)requestData;
@end
