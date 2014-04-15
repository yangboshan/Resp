//
//  SwitchEventsViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ViewPagerController.h"
#import "XLModelDataInterface.h"

@interface SwitchEventsViewController : ViewPagerController <ViewPagerDataSource, ViewPagerDelegate>

@property (nonatomic) XLViewDataDevice *device;

@end
