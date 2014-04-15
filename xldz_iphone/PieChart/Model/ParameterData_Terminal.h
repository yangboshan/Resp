//
//  ParameterData_Terminal.h
//  XLApp
//
//  Created by xldz on 14-4-9.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ParameterData_Terminal : NSManagedObject

@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSString * pmConnGroups;
@property (nonatomic, retain) NSString * pmCoolingWay;
@property (nonatomic, retain) NSString * pmEpAddress;
@property (nonatomic, retain) NSString * pmEpName;
@property (nonatomic, retain) NSString * pmEpNo;
@property (nonatomic, retain) NSNumber * pmEpType;
@property (nonatomic, retain) NSData * pmHostAddrFlag;
@property (nonatomic, retain) NSString * pmIndustryName;
@property (nonatomic, retain) NSString * pmInsulationGrade;
@property (nonatomic, retain) NSString * pmInsulationLevel;
@property (nonatomic, retain) NSNumber * pmLatitude;
@property (nonatomic, retain) NSNumber * pmLongitude;
@property (nonatomic, retain) NSString * pmManufactureDate;
@property (nonatomic, retain) NSNumber * pmPhaseNum;
@property (nonatomic, retain) NSNumber * pmRatedCurrent;
@property (nonatomic, retain) NSNumber * pmRatedFrequency;
@property (nonatomic, retain) NSNumber * pmRatedLoad;
@property (nonatomic, retain) NSNumber * pmRatedVoltage;
@property (nonatomic, retain) NSData * pmRegionNumber;
@property (nonatomic, retain) NSData * pmTerminalAddr;
@property (nonatomic, retain) NSData * pmTerminalStatus;
@property (nonatomic, retain) NSString * pmUpdateTime;
@property (nonatomic, retain) NSString * pmUserName;
@property (nonatomic, retain) NSString * pmWireName;
@property (nonatomic, retain) NSNumber * pmTemperatureRise;

@end
