//
//  ParameterData_Terminal_Comm.h
//  XLApp
//
//  Created by xldz on 14-4-9.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ParameterData_Terminal_Comm : NSManagedObject

@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSString * pmEpIpAddr;
@property (nonatomic, retain) NSString * pmEthernetGateway;
@property (nonatomic, retain) NSString * pmEthernetHostIp;
@property (nonatomic, retain) NSNumber * pmEthernetPort;
@property (nonatomic, retain) NSString * pmEthernetSubnetMask;
@property (nonatomic, retain) NSString * pmGprsApn;
@property (nonatomic, retain) NSNumber * pmGprsCommFlowLmt;
@property (nonatomic, retain) NSString * pmGprsHostIp;
@property (nonatomic, retain) NSNumber * pmGprsPort;
@property (nonatomic, retain) NSNumber * pmGprsRertryMaxCount;
@property (nonatomic, retain) NSNumber * pmGprsRetryInterval;
@property (nonatomic, retain) NSString * pmPassword;
@property (nonatomic, retain) NSNumber * pmPortNumber;
@property (nonatomic, retain) NSString * pmSSID;
@property (nonatomic, retain) NSString * pmUpdateTime;
@property (nonatomic, retain) NSNumber * pmWireOffTime;

@end
