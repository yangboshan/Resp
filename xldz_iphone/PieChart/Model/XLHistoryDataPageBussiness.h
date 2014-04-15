//
//  XLHistoryDataPageBussiness.h
//  XLApp
//
//  Created by xldz on 14-4-14.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLExternals.h"
#import "XLModelDataInterface.h"

@interface XLHistoryDataPageBussiness : NSObject

@property (nonatomic) enum _XLViewPlotDataType plotDataType;
@property (nonatomic) enum _XLViewPlotTimeType plotTimeType;
@property (nonatomic) NSDictionary *msgDic;
@property(nonatomic,strong) NSDate *refDate;
@property(nonatomic) NSString* xlName;
@property(nonatomic) NSMutableDictionary* resultDict;

+(XLHistoryDataPageBussiness*)sharedXLHistoryDataPageBussiness;
-(void)requestData;


@end
