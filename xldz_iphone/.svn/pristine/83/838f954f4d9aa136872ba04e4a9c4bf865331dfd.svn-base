//
//  TestPointBasicParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-21.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "TestPointBasicParamViewController.h"

#import "MJRefresh.h"
#import "UIButton+Bootstrap.h"


@interface TestPointBasicParamViewController ()
{
    NSString *notifKey;
}

@property (nonatomic) NSArray *paramArray;

@end

@implementation TestPointBasicParamViewController

- (id)init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"测量点%@-基本参数", self.testPoint.pointId];
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.testPoint queryBasicParams:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader endRefreshing];
            
            self.paramArray = result;
            [self.tableView reloadData];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.paramArray.count;
}

- (NSMutableDictionary *)tableView:(UITableView *)tableView paramForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.paramArray objectAtIndex:indexPath.row];
}

- (IBAction)saveParam:(id)sender
{
    [super saveParam:sender];
    
    [self.testPoint saveBasicParams:self.paramArray];
}

@end
