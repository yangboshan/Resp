//
//  SystemInfo.m
//  XLApp
//
//  Created by JY on 14-3-6.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SystemInfo.h"


@implementation SystemInfo

@dynamic id;
@dynamic name;
@dynamic desc;
@dynamic updateTime;

-(void)setName:(NSString *)name{
    [self setPrimitiveValue:name forKey:@"name"];
}

-(void)setDesc:(NSString *)desc{
    [self setPrimitiveValue:desc forKey:@"desc"];
}

@end
