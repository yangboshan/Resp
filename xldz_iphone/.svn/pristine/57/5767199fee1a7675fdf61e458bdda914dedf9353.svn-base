//
//  DeviceTelemetryParamViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-12.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "CustomParamViewController.h"

#import "EWMultiColumnTableView.h"
//#import "LHDropDownControlView.h"
#import "CCComboBox.h"

@interface DeviceTelemetryParamViewController : CustomParamViewController <EWMultiColumnTableViewDataSource>
{
    CGFloat colWidth;
    NSArray *tableColumns;
    
    MJRefreshHeaderView *ewRefreshHeader;
}

@property (nonatomic, retain) IBOutlet EWMultiColumnTableView *ewTableView;

@property (nonatomic) XLViewDataDevice *device;
@property (nonatomic) NSArray *paramArray;

- (void)handleNotification:(NSNotification *)aNotification;
- (void)saveParam;

@end
