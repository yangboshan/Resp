//
//  DeviceTransParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceTransParamViewController.h"

#import "JMWhenTapped.h"
#import "SSCheckBoxView.h"
#import "UIButton+Bootstrap.h"
#import "MySectionHeaderView.h"
#import "MJRefresh.h"

@interface DeviceTransParamViewController ()
{
    NSString *notifKey;
}

@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic) NSDictionary *params;
@property (nonatomic) NSArray *sectionTitles;

@end

@implementation DeviceTransParamViewController

//- (id)init
//{
//    self = [super init];
//    if (self) {
//    
//    }
//    return self;
//}
//
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"设备%@-通讯参数", self.device.deviceId];
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryTransParams:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSDictionary *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader endRefreshing];
            
            NSString *selected = [result objectForKey:@"SELECTED_GROUP"];
            self.sectionTitles = [result objectForKey:@"GROUPS"];
            self.selectedIndex = [self.sectionTitles indexOfObject:selected];
            self.params = result;
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
    return self.sectionTitles.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 40)];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = [self.sectionTitles objectAtIndex:section];
    
    SSCheckBoxView *checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(270, 0, 50, 40)
                                                               style:kSSCheckBoxViewStyleCircle
                                                             checked:NO];
    checkBox.userInteractionEnabled = NO;
    checkBox.checked = section == self.selectedIndex;
    
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label];
    [view addSubview:checkBox];
    
    [view whenTapped:^{
        checkBox.checked = !checkBox.checked;
        
        if (checkBox.checked) {
            self.selectedIndex = section;
            [self.tableView reloadData];
        } else if (self.selectedIndex == section) {
            self.selectedIndex = NSNotFound;
        }
    }];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *title = [self.sectionTitles objectAtIndex:section];
    NSArray *pList = [self.params objectForKey:title];
    return pList.count;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"TransParamCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    UILabel *nameLabel;
//    UITextField *textField;
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//        bgview.opaque = YES;
//        bgview.backgroundColor = [UIColor listItemBgColor];
//        cell.backgroundView = bgview;
//
//        
//        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 130, 30)];
//        nameLabel.textColor = [UIColor textWhiteColor];
//        nameLabel.backgroundColor = [UIColor clearColor];
//        nameLabel.adjustsFontSizeToFitWidth = YES;
//        textField = [[UITextField alloc] initWithFrame:CGRectMake(150, 7, 150, 30)];
//        textField.delegate = self;
//        
//        nameLabel.tag = 551;
//        textField.tag = 552;
//        [cell.contentView addSubview:nameLabel];
//        [cell.contentView addSubview:textField];
//    } else {
//        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
//        textField = (UITextField *)[cell.contentView viewWithTag:552];
//    }
//    
//    textField.userInteractionEnabled = self.editing;
//    textField.borderStyle = self.editing ? UITextBorderStyleRoundedRect : UITextBorderStyleNone;
//    textField.textColor = self.editing ? [UIColor blackColor] : [UIColor textWhiteColor];
//    textField.backgroundColor = self.editing ? [UIColor textFieldBgColor] : [UIColor clearColor];
//    
//    NSString *title = [self.sectionTitles objectAtIndex:indexPath.section];
//    NSArray *pList = [self.params objectForKey:title];
//    
//    id value = [map valueForKey:prop];
//    if (value == [NSNull null]) {
//        value = nil;
//    }
//    nameLabel.text = name;
//    textField.text = value;
//    
//    return cell;
//}
//
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    CGRect rect = [textField convertRect:textField.bounds toView:self.tableView];
//    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
//    if (indexPath) {
//        NSMutableDictionary *map = [self getValueMapForSection:indexPath.section];
//        NSString *prop = [self getParamPropForIndexPath:indexPath];
//        
//        [map setObject:textField.text forKey:prop];
//    }
//}
//
//- (IBAction)toggleEditing:(id)sender
//{
//    UIButton *btn = sender;
//    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
//    
//    self.editing = !self.isEditing;
//    [self.tableView reloadData];
//    [btn setTitle:(self.isEditing ? @"完成" : @"编辑") forState:UIControlStateNormal];
//}

- (NSMutableDictionary *)tableView:(UITableView *)tableView paramForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = [self.sectionTitles objectAtIndex:indexPath.section];
    NSArray *pList = [self.params objectForKey:title];
    return [pList objectAtIndex:indexPath.row];
}

- (IBAction)saveParam:(id)sender
{
    [super saveParam:sender];
    
    NSString *title = self.selectedIndex == NSNotFound ? nil : [self.sectionTitles objectAtIndex:self.selectedIndex];
    [self.device saveTransportParams:self.params selectedType:title];
}

//- (IBAction)refreshData:(id)sender
//{
//    self.selectedType = self.device.transportType;
//    self.wifiValueMap = nil;
//    self.lanValueMap = nil;
//    self.gprsValueMap = nil;
//    [self.tableView reloadData];
//}

@end
