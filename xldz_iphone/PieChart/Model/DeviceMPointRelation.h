//
//  DeviceMPointRelation.h
//  XLApp
//
//  Created by JY on 14-3-6.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DeviceMPointRelation : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * childid;
@property (nonatomic, retain) NSString * updateTime;

@end
