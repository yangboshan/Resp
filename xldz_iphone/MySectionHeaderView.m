//
//  MySectionHeaderView.m
//  XLApp
//
//  Created by ttonway on 14-2-20.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "MySectionHeaderView.h"

@implementation MySectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
     CGContextRef ctx = UIGraphicsGetCurrentContext();
     //    CGFloat cornerRadius = 6.;
     //    CGContextSaveGState(ctx);
     //    UIBezierPath *roundedPath = [UIBezierPath bezierPathWithRoundedRect:[self bounds]
     //                                                           cornerRadius:cornerRadius];
     //    CGContextAddPath(ctx, [roundedPath CGPath]);
     //    CGContextRestoreGState(ctx);
     //
     //    CGContextClip(ctx);
     
     CGColorSpaceRef spaceRef = CGColorSpaceCreateDeviceRGB();
     
     CGFloat locations[2] = {0.0, 1.0};
     CGColorRef top, bottom;
     top = [[UIColor colorWithRed:64./255. green:65./255. blue:66./255. alpha:1.] CGColor];
     bottom = [[UIColor colorWithRed:55./255. green:56./255. blue:57./255. alpha:1.] CGColor];
     
     CGFloat components[8] = {CGColorGetComponents(top)[0],CGColorGetComponents(top)[1],CGColorGetComponents(top)[2],CGColorGetComponents(top)[3]
         ,CGColorGetComponents(bottom)[0],CGColorGetComponents(bottom)[1],CGColorGetComponents(bottom)[2],CGColorGetComponents(bottom)[3]};
     
     CGGradientRef gradient = CGGradientCreateWithColorComponents(spaceRef, components, locations, (size_t)2);
     CGContextDrawLinearGradient(ctx, gradient, [self bounds].origin, CGPointMake(CGRectGetMinX([self bounds]), CGRectGetMaxY([self bounds])), (CGGradientDrawingOptions)NULL);
     
     CGGradientRelease(gradient);
     CGColorSpaceRelease(spaceRef);
 }

@end
