//
//  DeviceParamStatusViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-20.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"
#import "NRGridView.h"

@interface DeviceParamStatusViewController : UIViewController <NRGridViewDataSource, NRGridViewDelegate>

@property (nonatomic) XLViewDataDevice *device;

@property (nonatomic, retain) IBOutlet NRGridView *gridView;

@end
