//
//  TestPointRateDetialViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-4.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomTableViewController.h"
#import "XLModelDataInterface.h"
#import "DeviceViewController.h"

/**
 * 实时：
 * A、B、C三相电压、电流2～19次谐波有效值
 * A、B、C三相电压、电流2～19次谐波含有率
 * 历史：
 * A/B/C相2～19次谐波电流最大值及发生时间
 * A/B/C相2～19次谐波电压含有率及总畸变率最大值及发生时间
 */
@interface TestPointRateDetialViewController : CustomTableViewController <DatePickerActionSheetDelegate>

@property (nonatomic) XLViewDataTestPoint *testPoint;
@property (nonatomic) BOOL realtime;
@property (nonatomic) NSString *category;

@property (nonatomic, retain) IBOutlet UIButton *dayBtn;
@property (nonatomic, retain) IBOutlet UIButton *monthBtn;
@property (nonatomic) XLViewPlotTimeType timeType;
@property (nonatomic) NSDate *refreshDate;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;

@property (nonatomic) DatePickerActionSheet *timeActionSheet;

@end
