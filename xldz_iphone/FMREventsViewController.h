//
//  FMREventsViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "CustomTableViewController.h"

#import "XLModelDataInterface.h"
#import "MJRefresh.h"

@interface FMREventsViewController : CustomTableViewController
{
    MJRefreshHeaderView *refreshHeader;
    
    NSArray *events;
}

@property (nonatomic) XLViewDataDevice *device;
- (void)initData;
- (void)handleNotification:(NSNotification *)aNotification;

@end
