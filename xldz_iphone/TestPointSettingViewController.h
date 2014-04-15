//
//  TestPointSettingViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-21.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"
#import "ViewPagerController.h"

@interface TestPointSettingViewController : ViewPagerController <ViewPagerDataSource, ViewPagerDelegate>

@property (nonatomic) XLViewDataTestPoint *testPoint;

@end
