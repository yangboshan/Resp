//
//  TestPointCreateViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-22.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "TestPointCreateViewController.h"

#import "JMWhenTapped.h"
#import "UIButton+Bootstrap.h"
#import "MySectionHeaderView.h"
#import "MyTextField.h"
#import "Toast+UIView.h"
#import "Navbar.h"

@interface TestPointCreateViewController () <UITextFieldDelegate>
{
    XLViewDataTestPoint *testPoint;
}

@end

@implementation TestPointCreateViewController

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
    
    [self.navigationItem setNewTitle:@"新建测量点"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorColor = [UIColor listDividerColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //去除UITableView中多余的separator
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    [self.tableView whenTapped:^{
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    }];
    
    [self.okBtn okStyle];
    [self.okBtn addTarget:self action:@selector(onOK:) forControlEvents:UIControlEventTouchUpInside];
    
    testPoint = [[XLViewDataTestPoint alloc] init];
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

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 30)];
//    label.font = [UIFont boldSystemFontOfSize:20];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"创建新测量点";
//    
//    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
//    view.backgroundColor = [UIColor blackColor];
//    [view addSubview:label];
//    
//    return view;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicParamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UITextField *textField;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor listItemBgColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 120, 30)];
        nameLabel.textColor = [UIColor textWhiteColor];
        textField = [[MyTextField alloc] initWithFrame:CGRectMake(140, 7, 130, 30)];
        textField.delegate = self;
        
        nameLabel.tag = 551;
        textField.tag = 552;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:textField];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        textField = (UITextField *)[cell.contentView viewWithTag:552];
    }
    
    NSString *name = indexPath.row == 0 ? @"测量点名称" : @"测量点号";
    NSString *prop = indexPath.row == 0 ? @"pointName" : @"pointNo";
    NSString *value = [testPoint valueForKey:prop];
    nameLabel.text = name;
    textField.text = value;
    
    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect rect = [textField convertRect:textField.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect rect = [textField convertRect:textField.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSString *prop = indexPath.row == 0 ? @"pointName" : @"pointNo";
        
        [testPoint setValue:textField.text forKey:prop];
    }
}

- (IBAction)onOK:(id)sender
{
    if (!testPoint.pointName.length) {
        [self.view makeToast:@"测量点名称不能为空"];
        return;
    }
    if (!testPoint.pointNo.length) {
        [self.view makeToast:@"测量点号不能为空"];
        return;
    }
    
    if (self.createDelegate) {
        [self.createDelegate testPointCreateViewController:self onCreatePoint:testPoint];
    }
}

@end
