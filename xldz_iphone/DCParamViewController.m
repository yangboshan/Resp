//
//  DCParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-21.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DCParamViewController.h"

#import "JMWhenTapped.h"
#import "MySectionHeaderView.h"
#import "MyTextField.h"
#import "UIButton+Bootstrap.h"

@interface DCParamViewController () <UITextFieldDelegate>
{
    NSArray *paramNameArray;
    NSArray *paramPropArray;
}

@property (nonatomic) NSMutableDictionary *valueMap;

@end

@implementation DCParamViewController

@synthesize valueMap = _valueMap;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        paramNameArray = [NSArray arrayWithObjects:
                        @"量程起始值",
                        @"量程终止值",
                        @"上限",
                        @"下限",
                        @"冻结密度",
                        nil];
        paramPropArray = [NSArray arrayWithObjects:
                        @"antumStartValue",
                        @"antumEndValue",
                        @"maxValue",
                        @"minValue",
                        @"frozenDensity",
                        nil];
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
    
    [self.editBtn normalStyle];
    [self.editBtn setTitle:(self.isEditing ? @"完成" : @"编辑") forState:UIControlStateNormal];
    [self.saveBtn okStyle];
    [self.cancelBtn cancelStyle];
    [self.editBtn addTarget:self action:@selector(toggleEditing:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveBtn addTarget:self action:@selector(saveParam:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableDictionary *)valueMap
{
    if (!_valueMap) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:paramPropArray.count];
        for (NSString *prop in paramPropArray) {
            id value = [self.dcAnalog valueForKey:prop];
            if (value == nil) {
                value = [NSNull null];
            }
            [dic setObject:value forKey:prop];
        }
        
        _valueMap = dic;
    }
    return _valueMap;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 30)];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"直流模拟量 - %@", self.dcAnalog.name];
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.valueMap.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DCParamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UITextField *textField;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor listItemBgColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 130, 30)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        textField = [[MyTextField alloc] initWithFrame:CGRectMake(150, 7, 150, 30)];
        textField.delegate = self;
        
        nameLabel.tag = 551;
        textField.tag = 552;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:textField];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        textField = (UITextField *)[cell.contentView viewWithTag:552];
    }
    
    textField.enabled = self.editing;
    
    NSString *prop = [paramPropArray objectAtIndex:indexPath.row];
    NSString *name = [paramNameArray objectAtIndex:indexPath.row];
    id value = [self.valueMap valueForKey:prop];
    if (value == [NSNull null]) {
        value = nil;
    }
    nameLabel.text = name;
    textField.text = value;
    
    return cell;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
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
    
    CGRect rect = [textField convertRect:textField.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    CGRect frame = self.tableView.frame;
    frame.size.height = CGRectGetMinY(self.bottomView.frame);
    self.tableView.frame = frame;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect rect = [textField convertRect:textField.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSString *prop = [paramPropArray objectAtIndex:indexPath.row];
        
        [self.valueMap setObject:textField.text forKey:prop];
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

- (IBAction)toggleEditing:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    self.editing = !self.isEditing;
    [self.tableView reloadData];
    [self.editBtn setTitle:(self.isEditing ? @"完成" : @"编辑") forState:UIControlStateNormal];
}

- (IBAction)saveParam:(id)sender
{
    [self.valueMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *porperty = key;
        id value = obj;
        if (value == [NSNull null]) {
            value = nil;
        }
        
        [self.dcAnalog setValue:value forKey:porperty];
    }];
    
    [self.editDelegate dcParamViewController:self onSave:YES];
}

- (IBAction)onCancel:(id)sender
{
    [self.editDelegate dcParamViewController:self onSave:NO];
}

@end
