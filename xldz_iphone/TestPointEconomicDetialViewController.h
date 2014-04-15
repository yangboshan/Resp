//
//  TestPointEconomicDetialViewController.h
//  XLApp
//
//  Created by sureone on 2/23/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestPointEconomicDetialViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *viewPowerFactor;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollContainerView;
@property (strong, nonatomic) IBOutlet UIView *viewTitleTime;
@property (strong, nonatomic) IBOutlet UIView *viewBlance;
@property (strong, nonatomic) IBOutlet UIView *viewDayLoad;
@property (strong, nonatomic) IBOutlet UIView *viewLost;
@property (strong, nonatomic) IBOutlet UIView *viewCosumePower;


@property (copy) NSString* tpName;
@property (copy) NSString* tpNo;

@end
