//
//  SwitchEventChartViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-14.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"

@interface SwitchEventChartViewController : UIViewController

@property (nonatomic) XLViewDataDevice *device;//开关设备信息
@property (nonatomic) NSDictionary *event;//事件数据信息

@end
