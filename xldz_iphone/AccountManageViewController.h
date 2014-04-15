//
//  AccountManageViewController.h
//  XLApp
//
//  Created by sureone on 4/1/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountManageViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UIButton  *addBtn;

@end
