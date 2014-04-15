//
//  SwitchActionEventsViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "CustomTableViewController.h"

#import "XLModelDataInterface.h"
#import "MJRefresh.h"

@interface SwitchActionEventsViewController : CustomTableViewController
{
    NSMutableArray *events;
}

@property (nonatomic) XLViewDataDevice *device;
@property (nonatomic) NSString *eventType;

- (IBAction)saveEvents:(id)sender;
- (IBAction)refreshData:(id)sender;

@end
