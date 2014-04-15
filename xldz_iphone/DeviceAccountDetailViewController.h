//
//  DeviceAccountDetailViewController.h
//  XLApp
//
//  Created by sureone on 4/1/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceAccountDetailViewController : UIViewController

@property (nonatomic) NSString* theTitle;
@property (nonatomic) NSString* editMode;
@property (nonatomic) NSDictionary* accountDict;
@property (weak, nonatomic) IBOutlet UITextField *tvName;
@property (weak, nonatomic) IBOutlet UISwitch *swQuery;
@property (weak, nonatomic) IBOutlet UISwitch *swSetup;
@property (weak, nonatomic) IBOutlet UISwitch *swOperation;
@property (weak, nonatomic) IBOutlet UIButton *btnSave;
@property (weak, nonatomic) IBOutlet UIButton *btnDel;

@end
