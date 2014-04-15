//
//  DeviceRemoteSignallingParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-12.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceRemoteSignallingParamViewController.h"

@interface DeviceRemoteSignallingParamViewController ()
{
    NSString *notifKey;
}

@end

@implementation DeviceRemoteSignallingParamViewController

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
	
    notifKey = [NSString stringWithFormat:@"开关%@-遥信参数", self.device.deviceId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    tableColumns = [NSArray arrayWithObjects:@"取反标志", @"发送标志", @"产生SOE标志", nil];
    [self.device queryRemoteSignallingParams:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [ewRefreshHeader endRefreshing];
            
            self.paramArray = result;
            [self.ewTableView reloadData];
        });
    }
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForCell:(UIView *)cell indexPath:(NSIndexPath *)indexPath column:(NSInteger)col {
    UITextField *textField = (UITextField *)[cell viewWithTag:1];
    CCComboBox *dropDownView = (CCComboBox *)[cell viewWithTag:2];
    
    NSString *column = [tableColumns objectAtIndex:col];
    NSMutableDictionary *param = [self.paramArray objectAtIndex:indexPath.row];
    NSString *value = [param objectForKey:column];
    
    textField.text = value;
    //dropDownView.title = value;
    
    BOOL editing = self.isEditing;
    textField.enabled = editing;
    
    if (!editing) {
        textField.hidden = NO;
        dropDownView.hidden = YES;
    } else {
        textField.hidden = YES;
        dropDownView.hidden = NO;
        
        if (col == 0 || col == 2) {
            NSArray *options = [NSArray arrayWithObjects:@"是", @"否", nil];
            //[dropDownView setSelectionOptions:options withTitles:options];
            [dropDownView setDataArray:[options mutableCopy] selected:[options indexOfObject:value]];
        } else if (col == 1) {
            NSArray *options = [NSArray arrayWithObjects:@"发送", @"不发送", nil];
            //[dropDownView setSelectionOptions:options withTitles:options];
            [dropDownView setDataArray:[options mutableCopy] selected:[options indexOfObject:value]];
        }
    }
}

- (void)selected:(CCComboBox *)comboBox atIndex:(NSUInteger)index
{
    UITableView *tableView = self.ewTableView.tblView;
    CGRect rect = [comboBox convertRect:comboBox.bounds toView:tableView];
    NSIndexPath *indexPath = [[tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSMutableDictionary *param = [self.paramArray objectAtIndex:indexPath.row];
        NSUInteger col = comboBox.superview.tag - 500;
        NSString *column = [tableColumns objectAtIndex:col];
        id selection;
        
        if (col == 0 || col == 2) {
            NSArray *options = [NSArray arrayWithObjects:@"是", @"否", nil];
            selection = [options objectAtIndex:index];
        } else if (col == 1) {
            NSArray *options = [NSArray arrayWithObjects:@"发送", @"不发送", nil];
            selection = [options objectAtIndex:index];
        }
        [param setObject:selection forKey:column];
    }
}

- (void)saveParam
{
    [self.device saveRemoteSignallingParams:self.paramArray];
}

@end
