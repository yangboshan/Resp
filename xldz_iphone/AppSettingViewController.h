//
//  AppSettingViewController.h
//  XLApp
//
//  Created by sureone on 4/1/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSettingViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
