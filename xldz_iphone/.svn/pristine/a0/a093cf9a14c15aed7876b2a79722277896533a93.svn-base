//
//  DeviceRemoteControlParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceRemoteControlParamViewController.h"

#import "MySectionHeaderView.h"

@interface DeviceRemoteControlParamViewController ()
{
    NSString *notifKey;
}
@property (nonatomic) NSArray *paramArray;

@end

@implementation DeviceRemoteControlParamViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"开关%@-遥控参数", self.device.deviceId];
}

- (void)initData {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryRemoteControlParams:dic];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 150, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"遥控号";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    
    return view;
}

- (NSMutableDictionary *)tableView:(UITableView *)tableView paramForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.paramArray objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    UITextField *tf = (UITextField *)[cell.contentView viewWithTag:CELL_TEXTFIELD_TAG];
    tf.textAlignment = NSTextAlignmentCenter;
    
    return cell;
}

- (IBAction)saveParam:(id)sender
{
    [super saveParam:sender];
    
    [self.device saveRemoteControlParams:self.paramArray];
}

@end
