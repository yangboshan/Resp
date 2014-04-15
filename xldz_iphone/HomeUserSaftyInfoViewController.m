//
//  HomeUserSaftyInfoViewController.m
//  XLApp
//
//  Created by sureone on 2/20/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "HomeUserSaftyInfoViewController.h"
#import "Navbar.h"
#import "SaftyTableViewCell.h"
#import "XLModelDataInterface.h"

@interface HomeUserSaftyInfoViewController ()
{
    NSString *notifKey;
}

@end

@implementation HomeUserSaftyInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.navigationItem setNewTitle:@"安全性"];
    
    notifKey = @"系统安全性";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [[XLModelDataInterface testData] queryAllEvents:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader endRefreshing];
            
            events = result;
            [self.tableView reloadData];
        });
    }
}

@end
