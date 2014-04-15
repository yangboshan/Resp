//
//  DeviceCreateViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-25.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"
//#import "LHDropDownControlView.h"
#import "CCComboBox.h"

@protocol DeviceCreateViewControllerDelegate;

@interface DeviceCreateViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CCComboBoxDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UIButton  *okBtn;

@property (nonatomic, assign) id <DeviceCreateViewControllerDelegate> createDelegate;

@end


@protocol DeviceCreateViewControllerDelegate

@required
- (void)deviceCreateViewController:(DeviceCreateViewController *)controller onCreateDevice:(XLViewDataDevice *)device;

@end