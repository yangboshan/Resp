//
//  DeviceCreateViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-25.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceCreateViewController.h"

#import "Navbar.h"
#import "JMWhenTapped.h"
#import "UIButton+Bootstrap.h"
#import "MyTextField.h"
#import "Toast+UIView.h"

@interface DeviceCreateViewController () <UITextFieldDelegate>
{
    XLViewDataDevice *tempDevice;
    
    NSArray *dropdownOptions;
    NSArray *dropdownTitles;
}

@end

@implementation DeviceCreateViewController

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
    
    [self.navigationItem setNewTitle:@"新建设备"];
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
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    [self.okBtn okStyle];
    [self.okBtn addTarget:self action:@selector(onOK:) forControlEvents:UIControlEventTouchUpInside];
    
    tempDevice = [[XLViewDataDevice alloc] init];
    tempDevice.deviceType = DeviceTypeFMR;
    
    dropdownOptions = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:DeviceTypeFMR], [NSNumber numberWithUnsignedInteger:DeviceTypeSwitch], nil];
    dropdownTitles = [NSArray arrayWithObjects:@"智能变压器", @"智能开关", nil];
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

- (void)hideKeyboard
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

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
    CCComboBox *dropDownView;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor listItemBgColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 120, 30)];
        nameLabel.textColor = [UIColor textWhiteColor];
        textField = [[MyTextField alloc] initWithFrame:CGRectMake(140, 7, 130, 30)];
        textField.delegate = self;
        dropDownView = [[CCComboBox alloc] initWithFrame:CGRectMake(140, 7, 130, 30)];
        dropDownView.delegate = self;
        
        nameLabel.tag = 551;
        textField.tag = 552;
        dropDownView.tag = 553;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:textField];
        [cell.contentView addSubview:dropDownView];

    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        textField = (UITextField *)[cell.contentView viewWithTag:552];
        dropDownView = (CCComboBox *)[cell.contentView viewWithTag:552];
    }
    
    if (indexPath.row == 0) {
        textField.hidden = NO;
        dropDownView.hidden = YES;
        
        nameLabel.text = @"名称";
        textField.text = tempDevice.deviceName;
    } else {
        textField.hidden = YES;
        dropDownView.hidden = NO;
        
        nameLabel.text = @"设备类型";
//        dropDownView.title = (tempDevice.deviceType == DeviceTypeUndefined ? @"未定义" : (tempDevice.deviceType == DeviceTypeFMR ? @"智能变压器" : @"智能开关"));
//        
//        [dropDownView setSelectionOptions:dropdownOptions withTitles:dropdownTitles];
        NSUInteger index = (tempDevice.deviceType == DeviceTypeUndefined ? NSNotFound : (tempDevice.deviceType == DeviceTypeFMR ? 0 : 1));
        [dropDownView setDataArray:[dropdownTitles mutableCopy] selected:index];
    }
    
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
        tempDevice.deviceName = textField.text;
    }
}

- (void)selected:(CCComboBox *)comboBox atIndex:(NSUInteger)index
{
    CGRect rect = [comboBox convertRect:comboBox.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        tempDevice.deviceType = [[dropdownOptions objectAtIndex:index] unsignedIntegerValue];
    }
}

//#pragma mark - Drop Down Selector Delegate
//
//- (BOOL)dropDownControlViewWillBecomeActive:(LHDropDownControlView *)view  {
//    self.tableView.scrollEnabled = NO;
//    return YES;
//}
//
//- (void)dropDownControlView:(LHDropDownControlView *)view didFinishWithSelection:(id)selection {
//    self.tableView.scrollEnabled = YES;
//    
//    CGRect rect = [view convertRect:view.bounds toView:self.tableView];
//    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
//    if (indexPath && selection) {
//        NSInteger index = [dropdownOptions indexOfObject:selection];
//        view.title = [dropdownTitles objectAtIndex:index];
//        tempDevice.deviceType = [selection unsignedIntegerValue];
//    }
//}

- (IBAction)onOK:(id)sender
{
    if (!tempDevice.deviceName.length) {
        [self.view makeToast:@"设备名称不能为空"];
        return;
    }
    
    if (self.createDelegate) {
        [self.createDelegate deviceCreateViewController:self onCreateDevice:tempDevice];
    }
}

@end
