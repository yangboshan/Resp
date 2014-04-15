//
//  ParameterData_MeasurePoint.h
//  XLApp
//
//  Created by xldz on 14-4-8.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ParameterData_MeasurePoint : NSManagedObject

@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSNumber * pmCTRatio;
@property (nonatomic, retain) NSString * pmEpName;
@property (nonatomic, retain) NSString * pmMeasureName;
@property (nonatomic, retain) NSNumber * pmMeasureNo;
@property (nonatomic, retain) NSString * pmPowerConnWay;
@property (nonatomic, retain) NSNumber * pmPTRatio;
@property (nonatomic, retain) NSNumber * pmRatedCurrent;
@property (nonatomic, retain) NSNumber * pmRatedVoltage;
@property (nonatomic, retain) NSString * pmUpdateTime;
@property (nonatomic, retain) NSString * pmWireName;

@end
