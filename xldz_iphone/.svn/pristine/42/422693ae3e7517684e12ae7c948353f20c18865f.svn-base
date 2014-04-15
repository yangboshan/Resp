//
//  MyTextField.m
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "MyTextField.h"

#import "XLUtils.h"

@implementation MyTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self defaultSetup];
    }
    return self;
}

- (void)defaultSetup
{
    self.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    self.borderStyle = UITextBorderStyleNone;
    self.background = [[UIImage imageNamed:@"textfield"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.disabledBackground = [XLUtils imageFromColor:[UIColor clearColor]];
    self.backgroundColor = [UIColor clearColor];
    self.textColor = [UIColor blackColor];
    
    self.textAlignment = NSTextAlignmentLeft;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.font = [UIFont systemFontOfSize:17.0];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    self.textColor = enabled ? [UIColor blackColor] : [UIColor textWhiteColor];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, self.edgeInsets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds, self.edgeInsets);
}

@end
