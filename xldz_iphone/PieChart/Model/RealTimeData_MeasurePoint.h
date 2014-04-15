//
//  RealTimeData_MeasurePoint.h
//  XLApp
//
//  Created by xldz on 14-4-9.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RealTimeData_MeasurePoint : NSManagedObject

@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSNumber * rtAActivePower;
@property (nonatomic, retain) NSNumber * rtAApparentPower;
@property (nonatomic, retain) NSNumber * rtACurrent;
@property (nonatomic, retain) NSNumber * rtACurrentPhaseAngle;
@property (nonatomic, retain) NSNumber * rtAPowerFactor;
@property (nonatomic, retain) NSNumber * rtAReactivePower;
@property (nonatomic, retain) NSNumber * rtAVolt;
@property (nonatomic, retain) NSNumber * rtAVoltPhaseAngle;
@property (nonatomic, retain) NSNumber * rtBActivePower;
@property (nonatomic, retain) NSNumber * rtBApparentPower;
@property (nonatomic, retain) NSNumber * rtBCurrent;
@property (nonatomic, retain) NSNumber * rtBCurrentPhaseAngle;
@property (nonatomic, retain) NSNumber * rtBPowerFactor;
@property (nonatomic, retain) NSNumber * rtBReactivePower;
@property (nonatomic, retain) NSNumber * rtBVolt;
@property (nonatomic, retain) NSNumber * rtBVoltPhaseAngle;
@property (nonatomic, retain) NSNumber * rtCActivePower;
@property (nonatomic, retain) NSNumber * rtCApparentPower;
@property (nonatomic, retain) NSNumber * rtCCurrent;
@property (nonatomic, retain) NSNumber * rtCCurrentPhaseAngle;
@property (nonatomic, retain) NSNumber * rtCPowerFactor;
@property (nonatomic, retain) NSNumber * rtCReactivePower;
@property (nonatomic, retain) NSNumber * rtCVolt;
@property (nonatomic, retain) NSNumber * rtCVoltPhaseAngle;
@property (nonatomic, retain) NSNumber * rtMeasureNo;
@property (nonatomic, retain) NSString * rtUpdateTime;
@property (nonatomic, retain) NSNumber * rtZActivePower;
@property (nonatomic, retain) NSNumber * rtZApparentPower;
@property (nonatomic, retain) NSNumber * rtZeroSequenceCurrent;
@property (nonatomic, retain) NSNumber * rtZPowerFactor;
@property (nonatomic, retain) NSNumber * rtZReactivePower;

@end
