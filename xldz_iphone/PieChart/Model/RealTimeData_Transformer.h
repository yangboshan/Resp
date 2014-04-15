//
//  RealTimeData_Transformer.h
//  XLApp
//
//  Created by xldz on 14-4-9.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RealTimeData_Transformer : NSManagedObject

@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSNumber * rtAWindingTemperature;
@property (nonatomic, retain) NSNumber * rtAWindingTemperatureMax;
@property (nonatomic, retain) NSString * rtAWindingTemperatureMaxTm;
@property (nonatomic, retain) NSNumber * rtBWindingTemperature;
@property (nonatomic, retain) NSNumber * rtBWindingTemperatureMax;
@property (nonatomic, retain) NSString * rtBWindingTemperatureTm;
@property (nonatomic, retain) NSNumber * rtCWindingTemperature;
@property (nonatomic, retain) NSNumber * rtCWindingTemperatureMax;
@property (nonatomic, retain) NSString * rtCWindingTemperatureMaxTm;
@property (nonatomic, retain) NSNumber * rtMeasureNo;
@property (nonatomic, retain) NSNumber * rtOilLevel;
@property (nonatomic, retain) NSNumber * rtOilLevelMax;
@property (nonatomic, retain) NSString * rtOilLevelTm;
@property (nonatomic, retain) NSNumber * rtOilStress;
@property (nonatomic, retain) NSNumber * rtOilStressMax;
@property (nonatomic, retain) NSString * rtOilStressTm;
@property (nonatomic, retain) NSNumber * rtOilTemperature;
@property (nonatomic, retain) NSNumber * rtOilTemperatureMax;
@property (nonatomic, retain) NSString * rtOilTemperatureMaxTm;
@property (nonatomic, retain) NSNumber * rtRealLifetime;
@property (nonatomic, retain) NSString * rtUpdateTime;
@property (nonatomic, retain) NSNumber * rtImptEventCount;
@property (nonatomic, retain) NSNumber * rtNormalEventCount;

@end
