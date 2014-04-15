//
//  TestPointThresholdParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-21.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "TestPointThresholdParamViewController.h"

#import "JMWhenTapped.h"
#import "UIButton+Bootstrap.h"
#import "SSCheckBoxView.h"
#import "MJRefresh.h"
#import "MyTextField.h"

@interface TestPointThresholdParamViewController ()
{
    NSString *notifKey;
}

@property (nonatomic) NSArray *paramArray;
@property (nonatomic) NSMutableArray *selectedParams;

@end

@implementation TestPointThresholdParamViewController

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
    self.selectedParams = [NSMutableArray array];
    notifKey = [NSString stringWithFormat:@"测量点%@-越限参数", self.testPoint.pointId];
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.testPoint queryThresholdParams:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader endRefreshing];
            
            [self.selectedParams removeAllObjects];
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

- (NSMutableDictionary *)tableView:(UITableView *)tableView paramForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.paramArray objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UITextField *textField;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 120, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        textField = [[MyTextField alloc] initWithFrame:CGRectMake(140, 7, 120, 30)];
        textField.delegate = self;
        textField.adjustsFontSizeToFitWidth = YES;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        
        nameLabel.tag = 551;
        textField.tag = 552;
        checkBox.tag = 553;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:textField];
        [cell.contentView addSubview:checkBox];
        [checkBox whenTapped:^{
            checkBox.checked = !checkBox.checked;
            [self checkBoxViewChangedState:checkBox];
        }];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        textField = (UITextField *)[cell.contentView viewWithTag:552];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    }
    
    NSMutableDictionary *param = [self tableView:tableView paramForRowAtIndexPath:indexPath];
    BOOL editing = self.isEditing;
    if (editing && !param.editable) {
        editing = NO;
    }
    
    textField.enabled = editing;
    
    checkBox.checked = [self.selectedParams containsObject:param];
    
    nameLabel.text = param.paramName;
    switch (param.paramType) {
        case XLParamTypeString:
            textField.text = param.paramValue;
            textField.keyboardType = UIKeyboardTypeDefault;
            break;
        case XLParamTypeNumber:
            textField.text = param.paramValue;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        case XLParamTypeSpinner: {
            NSUInteger index = [param.listValues indexOfObject:param.paramValue];
            NSString *str = index == NSNotFound ? @"" : [param.listNames objectAtIndex:index];
            textField.text = str;
            break;
        }
        default:
            textField.text = @"未定义参数类型";
            textField.keyboardType = UIKeyboardTypeDefault;
            break;
    }
    
    return cell;
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSMutableDictionary *param = [self.paramArray objectAtIndex:indexPath.row];
        if (cbv.checked) {
            [self.selectedParams addObject:param];
        } else {
            [self.selectedParams removeObject:param];
        }
    }
}

- (IBAction)saveParam:(id)sender
{
    [super saveParam:sender];
    
    [self.testPoint saveThresholdParams:self.paramArray];
}

@end
