//
//  DeviceEventParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-25.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceEventParamViewController.h"

#import "UIButton+Bootstrap.h"
#import "JMWhenTapped.h"
#import "SSCheckBoxView.h"
#import "MySectionHeaderView.h"
#import "Toast+UIView.h"
#import "MJRefresh.h"

@interface DeviceEventParamViewController ()
{
    NSString *notifKey;
}

@property (nonatomic) NSArray *paramArray;

@end

@implementation DeviceEventParamViewController

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
    notifKey = [NSString stringWithFormat:@"设备%@-事件参数", self.device.deviceId];
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryEventParams:dic];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    //label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"事件名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 60, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"一般";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"重要";

    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label3];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicParamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    SSCheckBoxView *cbv1, *cbv2;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor listItemBgColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 180, 44)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        cbv1 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(200 + 13, 0, 34, 44)
                                               style:kSSCheckBoxViewStyleCircle
                                             checked:NO];
        cbv2 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 34, 44)
                                               style:kSSCheckBoxViewStyleCircle
                                             checked:NO];
        
        nameLabel.tag = 551;
        cbv1.tag = 552;
        cbv2.tag = 553;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:cbv1];
        [cell.contentView addSubview:cbv2];
        
//        [cbv1 setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
//        [cbv2 setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
        [cbv1 whenTapped:^{
            [self checkBoxViewChangedState:cbv1];
        }];
        [cbv2 whenTapped:^{
            [self checkBoxViewChangedState:cbv2];
        }];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        cbv1 = (SSCheckBoxView *)[cell.contentView viewWithTag:552];
        cbv2 = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    }
    
    NSMutableDictionary *param = [self.paramArray objectAtIndex:indexPath.row];
    DeviceEventLevel level = (DeviceEventLevel)[param.paramValue unsignedIntegerValue];

    nameLabel.text = param.paramName;
    cbv1.checked = level == DeviceEventLevelNormal;
    cbv2.checked = level == DeviceEventLevelImportant;
    
    cbv1.userInteractionEnabled = self.isEditing;
    cbv2.userInteractionEnabled = self.isEditing;
    
    return cell;
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        DeviceEventLevel level = cbv.tag == 552 ? DeviceEventLevelNormal : DeviceEventLevelImportant;
        NSMutableDictionary *param = [self.paramArray objectAtIndex:indexPath.row];
        param.paramValue = [NSNumber numberWithUnsignedInteger:level];

        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)saveParam:(id)sender
{
    [super saveParam:sender];
    
    [self.device saveEventParams:self.paramArray];
}

@end
