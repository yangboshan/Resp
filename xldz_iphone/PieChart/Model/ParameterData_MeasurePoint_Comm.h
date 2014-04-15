//
//  ParameterData_MeasurePoint_Comm.h
//  XLApp
//
//  Created by xldz on 14-4-9.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ParameterData_MeasurePoint_Comm : NSManagedObject

@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSString * pmCommAddr;
@property (nonatomic, retain) NSNumber * pmCommPort;
@property (nonatomic, retain) NSNumber * pmCommPrtlType;
@property (nonatomic, retain) NSNumber * pmCommSpeed;
@property (nonatomic, retain) NSNumber * pmDecimalNum;
@property (nonatomic, retain) NSNumber * pmFeeNum;
@property (nonatomic, retain) NSNumber * pmIntegerNum;
@property (nonatomic, retain) NSNumber * pmMeasureNo;
@property (nonatomic, retain) NSNumber * pmMtrDeviceNo;
@property (nonatomic, retain) NSString * pmUpdateTime;

@end
