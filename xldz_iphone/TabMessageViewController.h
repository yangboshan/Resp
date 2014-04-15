//
//  TabMessageViewController.h
//  XLApp
//
//  Created by sureone on 2/16/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "ContentViewController.h"

@interface XLSystemMessage : NSObject
@property (nonatomic) NSString *content;
@property (nonatomic) NSDate *date;
@end

@interface TabMessageViewController : ContentViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *messages;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@end
