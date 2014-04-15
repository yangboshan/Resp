//
//  QRCodeViewController.h
//  ZXingDemo
//
//  Created by Wei on 13-3-27.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZXingWidgetController.h>
#import <QRCodeReader.h>
#import <MultiFormatOneDReader.h>

@interface QRCodeViewController : UIViewController <ZXingDelegate>

@property (nonatomic, strong) UITextView *textView;

@end
