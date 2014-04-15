//
//  SwitchMainViewController.h
//  XLApp
//
//  Created by ttonway on 14-4-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"

@interface SwitchMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) XLViewDataDevice *device;

@property (nonatomic, retain) IBOutlet UIView *circle1;
@property (nonatomic, retain) IBOutlet UIView *circle2;
@property (nonatomic, retain) IBOutlet UIView *circle3;
@property (nonatomic, retain) IBOutlet UIView *circle4;
@property (nonatomic, retain) IBOutlet UIView *circle5;

@property (nonatomic, retain) IBOutlet UIImageView *switchImageView;

@property (nonatomic, retain) IBOutlet UIView *dataContainer;
@property (nonatomic, retain) IBOutlet UILabel *label1;
@property (nonatomic, retain) IBOutlet UILabel *label2;
@property (nonatomic, retain) IBOutlet UILabel *label3;
@property (nonatomic, retain) IBOutlet UILabel *label4;
@property (nonatomic, retain) UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIButton *settingBtn;
@property (nonatomic, retain) IBOutlet UIButton *controlBtn;
@property (nonatomic, retain) IBOutlet UIButton *helpBtn;
@property (nonatomic, retain) IBOutlet UIButton *realtimeDataBtn;
//@property (nonatomic, retain) IBOutlet UIButton *historyDataBtn;
@property (nonatomic, retain) IBOutlet UIButton *eventDataBtn;

- (void)loadData;

@end
