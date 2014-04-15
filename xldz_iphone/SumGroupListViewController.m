//
//  SumGroupListViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-25.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SumGroupListViewController.h"

#import "Navbar.h"
#import "UIButton+Bootstrap.h"
#import "MySectionHeaderView.h"
#import "SSCheckBoxView.h"
#import "AccountSumGroupViewController.h"

@interface SumGroupListViewController ()

@end

@implementation SumGroupListViewController

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
    
    [self.navigationItem setNewTitle:@"用户总加组"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    //[self.navigationItem setRightBarButtonItem:self.editButtonItem];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor listDividerColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //去除UITableView中多余的separator
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    [self.createGroupBtn normalStyle];
    [self.okBtn okStyle];
    [self.zhaoceBtn warningStyle];
    [self.createGroupBtn addTarget:self action:@selector(createSumGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.okBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 130, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 110, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"总加组号";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"关注";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label3];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userInfo.sumGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *idLabel;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 130, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        idLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 110, 44)];
        idLabel.textColor = [UIColor textWhiteColor];
        idLabel.backgroundColor = [UIColor clearColor];
        idLabel.textAlignment = NSTextAlignmentCenter;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];

        nameLabel.tag = 551;
        idLabel.tag = 552;
        checkBox.tag = 553;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:idLabel];
        [cell.contentView addSubview:checkBox];
        
        [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        idLabel = (UILabel *)[cell.contentView viewWithTag:552];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    }
    
    XLViewDataUserSumGroup *group = [self.userInfo.sumGroups objectAtIndex:indexPath.row];
    
    nameLabel.text = group.groupName;
    idLabel.text = group.groupId;
    checkBox.checked = group.attention;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XLViewDataUserSumGroup *group = [self.userInfo.sumGroups objectAtIndex:indexPath.row];
    
    AccountSumGroupViewController *controller = [[AccountSumGroupViewController alloc] init];
    controller.userInfo = self.userInfo;
    controller.sumGroup = group;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        XLViewDataUserSumGroup *group = [self.userInfo.sumGroups objectAtIndex:indexPath.row];
        
        group.attention = cbv.checked;
    }
}


- (IBAction)createSumGroup:(id)sender
{
    AccountSumGroupViewController *controller = [[AccountSumGroupViewController alloc] init];
    controller.userInfo = self.userInfo;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
