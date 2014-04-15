//
//  DeviceSettingViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"
#import "ViewPagerController.h"

@interface DeviceSettingViewController : ViewPagerController <ViewPagerDataSource, ViewPagerDelegate>

@property (nonatomic) XLViewDataDevice *device;

@end
