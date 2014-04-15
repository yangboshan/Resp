//
//  SwitchMainViewController.m
//  XLApp
//
//  Created by ttonway on 14-4-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SwitchMainViewController.h"

#import "DeviceSettingViewController.h"
#import "DataCatalogViewController.h"
#import "FMREventsViewController.h"
#import "SwitchEventsViewController.h"
#import "SwitchControlViewController.h"
#import "DeviceHelpViewController.h"

#define BORDER_COLOR [UIColor colorWithRed:52.0f/255.0f green:52.0f/255.0f blue:52.0f/255.0f alpha:1.0f];

@interface SwitchMainViewController ()
{
    NSString *notifKey;
    NSTimer *timer;
    
    NSArray *dataItems;
}

@end

@implementation SwitchMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat radius = self.circle1.bounds.size.height / 2.0;
    self.circle1.layer.cornerRadius = radius;
    self.circle2.layer.cornerRadius = radius;
    self.circle3.layer.cornerRadius = radius;
    self.circle4.layer.cornerRadius = radius;
    self.circle5.layer.cornerRadius = radius;
    
    for (UIView *child in [self.dataContainer subviews]) {
        [child removeFromSuperview];
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectInset(self.dataContainer.bounds, 1, 1) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = BORDER_COLOR;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.bounces = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //去除UITableView中多余的separator
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    self.dataContainer.backgroundColor = BORDER_COLOR;
    [self.dataContainer addSubview:self.tableView];
    
    [self.settingBtn addTarget:self action:@selector(gotoDeviceSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBtn addTarget:self action:@selector(gotoDeviceControl:) forControlEvents:UIControlEventTouchUpInside];
    [self.helpBtn addTarget:self action:@selector(gotoDeviceHelp:) forControlEvents:UIControlEventTouchUpInside];
    [self.realtimeDataBtn addTarget:self action:@selector(gotoDeviceRealtimeData:) forControlEvents:UIControlEventTouchUpInside];
    [self.eventDataBtn addTarget:self action:@selector(gotoDeviceEventData:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"设备%@-开关home界面", self.device.deviceId];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    NSLog(@"SwitchMainViewController loadData");
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device querySwitchStatics:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSDictionary *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *c1 = [result objectForKey:@"过流状态"];
            NSString *c2 = [result objectForKey:@"告警状态"];
            NSString *c3 = [result objectForKey:@"零流状态"];
            NSString *c4 = [result objectForKey:@"网络状态"];
            NSString *c5 = [result objectForKey:@"运行状态"];
            
            NSString *on = [result objectForKey:@"合分闸状态"];
            
            self.circle1.backgroundColor = [c1 isEqualToString:@"正常"] ? [UIColor greenColor] : [UIColor redColor];
            self.circle2.backgroundColor = [c2 isEqualToString:@"正常"] ? [UIColor greenColor] : [UIColor redColor];
            self.circle3.backgroundColor = [c3 isEqualToString:@"正常"] ? [UIColor greenColor] : [UIColor redColor];
            self.circle4.backgroundColor = [c4 isEqualToString:@"正常"] ? [UIColor greenColor] : [UIColor redColor];
            self.circle5.backgroundColor = [c5 isEqualToString:@"正常"] ? [UIColor greenColor] : [UIColor redColor];
            
            self.switchImageView.image = [UIImage imageNamed:([on isEqualToString:@"合"] ? @"switch-on" : @"switch-off")];
            
            dataItems = [result objectForKey:@"回线数据"];
            [self.tableView reloadData];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)gotoDeviceSetting:(id)sender
{
    DeviceSettingViewController *controller = [[DeviceSettingViewController alloc] init];
    controller.device = self.device;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)gotoDeviceControl:(id)sender
{
    if (self.device.deviceType == DeviceTypeSwitch) {
        SwitchControlViewController *controller = [[SwitchControlViewController alloc] init];
        controller.device = self.device;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (IBAction)gotoDeviceHelp:(id)sender
{
    DeviceHelpViewController *controller = [[DeviceHelpViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    
}
- (IBAction)gotoDeviceRealtimeData:(id)sender
{
    DataCatalogViewController *controller = [[DataCatalogViewController alloc] init];
    controller.device = self.device;
    controller.realtime = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
//- (IBAction)gotoDeviceHistoryData:(id)sender
//{
//    DataCatalogViewController *controller = [[DataCatalogViewController alloc] init];
//    controller.device = self.device;
//    controller.realtime = NO;
//    [self.navigationController pushViewController:controller animated:YES];
//}
- (IBAction)gotoDeviceEventData:(id)sender
{
    if (self.device.deviceType == DeviceTypeFMR) {
        FMREventsViewController *controller = [[FMREventsViewController alloc] init];
        controller.device = self.device;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (self.device.deviceType == DeviceTypeSwitch) {
        SwitchEventsViewController *controller = [[SwitchEventsViewController alloc] init];
        controller.device = self.device;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *valLabel;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor blackColor];
        cell.backgroundView = bgview;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 40, 30)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        valLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 0, 110, 30)];
        valLabel.textColor = [UIColor greenColor];
        valLabel.backgroundColor = [UIColor clearColor];
        valLabel.adjustsFontSizeToFitWidth = YES;
        
        UIView *divider1 = [[UIView alloc] initWithFrame:CGRectMake(0, 29, 180, 1)];
        divider1.backgroundColor = BORDER_COLOR;
        UIView *divider2 = [[UIView alloc] initWithFrame:CGRectMake(59, 0, 1, 30)];
        divider2.backgroundColor = BORDER_COLOR;
        [cell.contentView addSubview:divider1];
        [cell.contentView addSubview:divider2];
        
        nameLabel.tag = 551;
        valLabel.tag = 552;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:valLabel];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        valLabel = (UILabel *)[cell.contentView viewWithTag:552];
    }
    
    NSDictionary *item = [dataItems objectAtIndex:indexPath.row];
    nameLabel.text = [item objectForKey:@"名称"];
    valLabel.text = [item objectForKey:@"数据"];
    
    return cell;
}

@end
