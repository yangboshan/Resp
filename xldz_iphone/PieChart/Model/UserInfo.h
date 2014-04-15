//
//  UserInfo.h
//  XLApp
//
//  Created by JY on 14-3-6.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * industry;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * updateTime;

@end
