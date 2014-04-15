//
//  CustomTableViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-28.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UIButton  *button1;
@property (nonatomic, retain) IBOutlet UIButton  *button2;
@property (nonatomic, retain) IBOutlet UIButton  *button3;
@property (nonatomic, retain) IBOutlet UIButton  *button4;

@end
