//
//  TempMonthData.h
//  XLApp
//
//  Created by JY on 14-3-22.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TempMonthData : NSManagedObject

@property (nonatomic, retain) NSNumber * aPower;
@property (nonatomic, retain) NSNumber * bPower;
@property (nonatomic, retain) NSNumber * consume;
@property (nonatomic, retain) NSNumber * cPower;
@property (nonatomic, retain) NSString * dataTime;
@property (nonatomic, retain) NSNumber * dataType;
@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSNumber * maxConsume;
@property (nonatomic, retain) NSNumber * maxConsumeTime;
@property (nonatomic, retain) NSNumber * maxLoad;
@property (nonatomic, retain) NSNumber * maxLoadTime;
@property (nonatomic, retain) NSNumber * maxRealLost;
@property (nonatomic, retain) NSNumber * measureNo;
@property (nonatomic, retain) NSNumber * minLoad;
@property (nonatomic, retain) NSNumber * minLoadTime;
@property (nonatomic, retain) NSNumber * powerFactor;
@property (nonatomic, retain) NSNumber * totalPower;
@property (nonatomic, retain) NSNumber * totalPowerEnd;
@property (nonatomic, retain) NSNumber * totalPowerMax;
@property (nonatomic, retain) NSNumber * totalPowerMaxTime;
@property (nonatomic, retain) NSNumber * totalPowerMin;
@property (nonatomic, retain) NSNumber * totalPowerMinTime;
@property (nonatomic, retain) NSNumber * totalPowerRated;
@property (nonatomic, retain) NSNumber * totalPowerStart;
@property (nonatomic, retain) NSString * updateTime;

@end
