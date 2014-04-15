//
//  TestPointEnergyDetailViewController.h
//  XLApp
//
//  Created by sureone on 2/25/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestPointEnergyDetailViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *viewTimeTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *viewScrollContainer;
@property (weak, nonatomic) IBOutlet UIView *viewVoltage;
@property (weak, nonatomic) IBOutlet UIView *viewBalence;
@property (weak, nonatomic) IBOutlet UIView *viewXB;

@property (copy) NSString* tpName;
@property (copy) NSString* tpNo;

@end
