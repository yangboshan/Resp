//
//  XLUtils.m
//  XLApp
//
//  Created by ttonway on 14-2-20.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLUtils.h"

@implementation XLUtils


+ (UIImage *) imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
