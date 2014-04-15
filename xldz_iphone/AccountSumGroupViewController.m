//
//  AccountSumGroupViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "AccountSumGroupViewController.h"

#import "Navbar.h"
#import "SSCheckBoxView.h"
#import "MySectionHeaderView.h"
#import "JMWhenTapped.h"
#import "UIButton+Bootstrap.h"
#import "Toast+UIView.h"

#import "DeviceViewController.h"


@interface AccountSumGroupViewController () <UITextFieldDelegate>
{
    NSArray *testPoints;
    NSMutableArray *plusTestPoints;
    NSMutableArray *minusTestPoints;
}

@end

@implementation AccountSumGroupViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationItem setNewTitle:@"编辑总加组"];
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
        CGRect frame = self.tableView.frame;
        frame.size.height = CGRectGetMinY(self.bottomView.frame);
        self.tableView.frame = frame;
    }];
    
    [self.createGroupBtn normalStyle];
    [self.okBtn okStyle];
    [self.zhaoceBtn warningStyle];
    //[self.createGroupBtn addTarget:self action:@selector(createSumGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.okBtn addTarget:self action:@selector(onOK:) forControlEvents:UIControlEventTouchUpInside];
    
    self.groupNameField.delegate = self;
    self.groupIdField.delegate = self;
    if (self.sumGroup) {
        self.groupNameField.text = self.sumGroup.groupName;
        self.groupIdField.text = self.sumGroup.groupId;
    }
    
    self.createGroupBtn.hidden = YES;
    CGFloat delta = CGRectGetMinX(self.okBtn.frame) - CGRectGetMinX(self.createGroupBtn.frame);
    delta = delta / 2;
    CGRect frame = self.okBtn.frame;
    frame.origin.x -= delta;
    self.okBtn.frame = frame;
    frame = self.zhaoceBtn.frame;
    frame.origin.x -= delta;
    self.zhaoceBtn.frame = frame;
    
    [self initData];
}

- (void)initData
{
    testPoints = [[XLModelDataInterface testData] queryTestPointsForUser:self.userInfo];
    plusTestPoints = [self.sumGroup.positiveTestPoints mutableCopy];
    minusTestPoints = [self.sumGroup.negativeTestPoints mutableCopy];
    if (!plusTestPoints) {
        plusTestPoints = [NSMutableArray arrayWithArray:testPoints];
    }
    if (!minusTestPoints) {
        minusTestPoints = [NSMutableArray array];
    }
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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 90, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(110, 0, 50, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"运算";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 100, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"所属设备";
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label4.textColor = [UIColor whiteColor];
    label4.backgroundColor = [UIColor clearColor];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = @"选择";

    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label3];
    [view addSubview:label4];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return self.formView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return self.formView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return testPoints.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UIButton *actionBtn;
    UILabel *deviceBtn;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 90, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        actionBtn = [[UIButton alloc] initWithFrame:CGRectMake(110, 0, 50, 44)];
        deviceBtn = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 100, 44)];
        deviceBtn.textColor = [UIColor textWhiteColor];
        deviceBtn.backgroundColor = [UIColor clearColor];
        //[deviceBtn setTitle:@"查看" forState:UIControlStateNormal];
        //[deviceBtn setTitleColor:[UIColor textWhiteColor] forState:UIControlStateNormal];
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        
        nameLabel.tag = 551;
        actionBtn.tag = 552;
        deviceBtn.tag = 553;
        checkBox.tag = 554;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:actionBtn];
        [cell.contentView addSubview:deviceBtn];
        [cell.contentView addSubview:checkBox];
        
        [actionBtn addTarget:self action:@selector(toggleAction:) forControlEvents:UIControlEventTouchUpInside];
        //[deviceBtn addTarget:self action:@selector(viewDevice:) forControlEvents:UIControlEventTouchUpInside];
        //[checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
        [checkBox whenTapped:^{
            checkBox.checked = !checkBox.checked;
            [self checkBoxViewChangedState:checkBox];
        }];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        actionBtn = (UIButton *)[cell.contentView viewWithTag:552];
        deviceBtn = (UILabel *)[cell.contentView viewWithTag:553];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:554];
    }
    
    XLViewDataTestPoint *point = [testPoints objectAtIndex:indexPath.row];
    
    nameLabel.text = point.pointName;
    NSString *deviceName = point.device ? point.device.deviceName : @"无";
//    [deviceBtn setTitle:deviceName forState:UIControlStateNormal];
    deviceBtn.text = deviceName;
    
    if ([plusTestPoints containsObject:point]) {
        [actionBtn setImage:[UIImage imageNamed:@"plus-vector"] forState:UIControlStateNormal];
        checkBox.checked = YES;
    } else if ([minusTestPoints containsObject:point]) {
        [actionBtn setImage:[UIImage imageNamed:@"minus-vector"] forState:UIControlStateNormal];
        checkBox.checked = YES;
    } else {
        [actionBtn setImage:nil forState:UIControlStateNormal];
        checkBox.checked = NO;
    }
    
    
    return cell;
}

- (IBAction)toggleAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGRect rect = [btn convertRect:btn.bounds toView:self.tableView];

    XLViewDataTestPoint *point;
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        point = [testPoints objectAtIndex:indexPath.row];
        
        if ([plusTestPoints containsObject:point]) {
            [plusTestPoints removeObject:point];
            [minusTestPoints addObject:point];
        } else if ([minusTestPoints containsObject:point]) {
            [minusTestPoints removeObject:point];
        } else {
            [plusTestPoints addObject:point];
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (IBAction)viewDevice:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    CGRect rect = [btn convertRect:btn.bounds toView:self.tableView];
    
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
       XLViewDataTestPoint *point = [testPoints objectAtIndex:indexPath.row];
        if (point.device) {
            DeviceViewController *controller = [[DeviceViewController alloc] init];
            controller.device = point.device;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        XLViewDataTestPoint *point = [testPoints objectAtIndex:indexPath.row];
        
        [plusTestPoints removeObject:point];
        [minusTestPoints removeObject:point];
        if (cbv.checked) {
            [plusTestPoints addObject:point];
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = self.tableView.frame;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect cf = [self.tableView convertRect:self.tableView.bounds toView:keyWindow];
    CGFloat delta = 216 - CGRectGetHeight(keyWindow.frame) + CGRectGetMaxY(cf);//键盘高度216
    if (delta > 0) {
        frame.size.height = CGRectGetMinY(self.bottomView.frame) - delta;
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.tableView.frame = frame;
        [UIView commitAnimations];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.groupNameField) {
        [self.groupIdField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        CGRect frame = self.tableView.frame;
        frame.size.height = self.bottomView.frame.origin.y;
        self.tableView.frame = frame;
    }
    return YES;
}

- (IBAction)onOK:(id)sender
{
    if (!self.sumGroup && !self.groupNameField.text.length) {
        [self.view makeToast:@"总加组名称不能为空"];
        return;
    }
    if (!self.sumGroup && !self.groupIdField.text.length) {
        [self.view makeToast:@"总加组号不能为空"];
        return;
    }
    
    if (!self.sumGroup) {
        self.sumGroup = [[XLViewDataUserSumGroup alloc] init];
        [self.userInfo addSumGroup:self.sumGroup];
    }
    
    self.sumGroup.groupName = self.groupNameField.text;
    self.sumGroup.groupId = self.groupIdField.text;
    self.sumGroup.positiveTestPoints = [NSMutableArray arrayWithArray:plusTestPoints];
    self.sumGroup.negativeTestPoints = [NSMutableArray arrayWithArray:minusTestPoints];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
