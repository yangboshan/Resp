//
//  SwitchDataCatalog2ViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-18.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomTableViewController.h"
#import "XLModelDataInterface.h"

@interface SwitchDataCatalog2ViewController : CustomTableViewController

@property (nonatomic) BOOL realtime;
@property (nonatomic) XLViewDataDevice *device;
@property (nonatomic) NSString *category;

@end
