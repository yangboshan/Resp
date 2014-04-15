//
//  XLMainPageBussiness.h
//  XLApp
//
//  Created by JY on 14-3-10.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLExternals.h"
#import "XLModelDataInterface.h"

@protocol MainPageDelegate

-(void)chartDataDidReadyWithChartArray1:(NSArray*)array1 withChartArray2:(NSArray*)array2;

@end

@interface XLMainPageBussiness : NSObject
{

}

//相数类型，总、ABC三相
typedef enum _XLPhaseType {
    XLPhaseZ,
    XLPhaseA,
    XLPhaseB,
    XLPhaseC
}XLPhaseType;

@property (nonatomic) enum _XLViewPlotDataType plotDataType;
@property (nonatomic) enum _XLViewPlotTimeType plotTimeType;
@property (nonatomic) NSDictionary *msgDic;
@property(nonatomic,strong) NSDate *refDate;
@property(nonatomic) NSString* xlName;
@property(nonatomic) NSMutableDictionary* resultDict;
@property(nonatomic,weak) id<MainPageDelegate> delegate;
@property(nonatomic) BOOL requestFinishFlg;

+(XLMainPageBussiness*)sharedXLMainPageBussiness;
-(void)requestData;


@end
