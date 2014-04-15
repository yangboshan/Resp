//
//  EventData.h
//  XLApp
//
//  Created by JY on 14-4-14.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EventData : NSManagedObject

@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSString * evDetail;
@property (nonatomic, retain) NSNumber * evNo;
@property (nonatomic, retain) NSNumber * evReadFlag;
@property (nonatomic, retain) NSString * evStartEndFlag;
@property (nonatomic, retain) NSString * evTime;
@property (nonatomic, retain) NSString * evType;
@property (nonatomic, retain) NSString * evUpdateTime;
@property (nonatomic, retain) NSString * evName;

@end
