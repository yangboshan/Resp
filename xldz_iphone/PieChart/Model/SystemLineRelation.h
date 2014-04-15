//
//  SystemLineRelation.h
//  XLApp
//
//  Created by JY on 14-4-9.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SystemLineRelation : NSManagedObject

@property (nonatomic, retain) NSString * childid;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * updateTime;

@end
