//
//  DevicePointsViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomTableViewController.h"
#import "XLModelDataInterface.h"


@interface DevicePointsViewController : CustomTableViewController

@property (nonatomic) XLViewDataDevice *device;

@end
