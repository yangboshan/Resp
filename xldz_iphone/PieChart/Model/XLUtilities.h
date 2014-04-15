//
//  XLUtilities.h
//  XLApp
//
//  Created by JY on 14-3-8.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLUtilities : NSObject

+(BOOL)localWifiReachable;
+(NSInteger)parseSeqFieldWithData:(NSData*)data;
@end
