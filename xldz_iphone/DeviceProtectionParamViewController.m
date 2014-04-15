//
//  DeviceProtectionParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-10.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceProtectionParamViewController.h"

#import "MySectionHeaderView.h"
#import "LeveyPopListView.h"
#import "MyTextField.h"

@interface DeviceProtectionParamViewController () <LeveyPopListViewDelegate>
{
    NSMutableArray *section1Params;
    NSMutableArray *section2Params;
    
    UIView *sectionHeaderView;
    UITextField *choserTextField;
    
    NSString *notifKey;
}

@property (nonatomic) NSArray *paramArray;
@property (nonatomic) UIView *loopChoser;

@end

@implementation DeviceProtectionParamViewController
@synthesize currentLoop = _currentLoop;

- (id)init
{
    self = [super init];
    if (self) {
        section1Params = [NSMutableArray array];
        section2Params = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loopChoser = [self choseLoopContainer];
    choserTextField.text = self.currentLoop.loopName;
    [self.view addSubview:self.loopChoser];
    
    CGFloat delta = self.loopChoser.bounds.size.height;
    CGRect frame = self.tableView.frame;
    frame.origin.y += delta;
    frame.size.height -= delta;
    self.tableView.frame = frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"开关%@-保护参数", self.device.deviceId];
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryProtectionParams:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader endRefreshing];
            
            self.loopArray = result;
            self.currentLoop = [self.loopArray firstObject];
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
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentLoop:(XLViewDataSwitchLoop *)currentLoop
{
    _currentLoop = currentLoop;
    choserTextField.text = currentLoop.loopName;
    if (currentLoop) {
        self.paramArray = [currentLoop.protectionParams paramsCopy];
    } else {
        self.paramArray = nil;
    }
    
    [section1Params removeAllObjects];
    [section2Params removeAllObjects];
    for (NSMutableDictionary *param in self.paramArray) {
        if (param.paramType == XLParamTypeSpinner) {
            [section1Params addObject:param];
        } else if (param.paramType == XLParamTypeMulitValue) {
            [section2Params addObject:param];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.paramArray == nil ? 0 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? section1Params.count : section2Params.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? 0 : 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [[MySectionHeaderView alloc] initWithFrame:CGRectZero];
    } else {
        if (!sectionHeaderView) {
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 30)];
            label1.textColor = [UIColor whiteColor];
            label1.backgroundColor = [UIColor clearColor];
            //label1.textAlignment = NSTextAlignmentCenter;
            label1.text = @"名称";
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 60, 30)];
            label2.textColor = [UIColor whiteColor];
            label2.backgroundColor = [UIColor clearColor];
            label2.textAlignment = NSTextAlignmentCenter;
            label2.text = @"定值";
            UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 60, 30)];
            label3.textColor = [UIColor whiteColor];
            label3.backgroundColor = [UIColor clearColor];
            label3.textAlignment = NSTextAlignmentCenter;
            label3.text = @"最大值";
            UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
            label4.textColor = [UIColor whiteColor];
            label4.backgroundColor = [UIColor clearColor];
            label4.textAlignment = NSTextAlignmentCenter;
            label4.text = @"最小值";
            
            MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
            view.backgroundColor = [UIColor blackColor];
            [view addSubview:label1];
            [view addSubview:label2];
            [view addSubview:label3];
            [view addSubview:label4];
            
            sectionHeaderView = view;
        }
        
        return sectionHeaderView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = @"MultiValueCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        UILabel *nameLabel;
        UITextField *textField1, *textField2, *textField3;
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.backgroundColor=[UIColor clearColor];
            UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
            bgview.opaque = YES;
            bgview.backgroundColor = [UIColor listItemBgColor];
            cell.backgroundView = bgview;
            
            nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 100, 30)];
            nameLabel.textColor = [UIColor textWhiteColor];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.adjustsFontSizeToFitWidth = YES;
            textField1 = [[MyTextField alloc] initWithFrame:CGRectMake(145, 7, 50, 30)];
            textField1.delegate = self;
            textField2 = [[MyTextField alloc] initWithFrame:CGRectMake(205, 7, 50, 30)];
            textField2.delegate = self;
            textField3 = [[MyTextField alloc] initWithFrame:CGRectMake(265, 7, 50, 30)];
            textField3.delegate = self;
            
            
            nameLabel.tag = 551;
            textField1.tag = 552;
            textField2.tag = 553;
            textField3.tag = 554;
            [cell.contentView addSubview:nameLabel];
            [cell.contentView addSubview:textField1];
            [cell.contentView addSubview:textField2];
            [cell.contentView addSubview:textField3];
        } else {
            nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
            textField1 = (UITextField *)[cell.contentView viewWithTag:552];
            textField2 = (UITextField *)[cell.contentView viewWithTag:553];
            textField3 = (UITextField *)[cell.contentView viewWithTag:554];
        }
        
        NSMutableDictionary *param = [self tableView:tableView paramForRowAtIndexPath:indexPath];
        BOOL editing = self.isEditing;
        if (editing && !param.editable) {
            editing = NO;
        }
        
        [[NSArray arrayWithObjects:textField1, textField2, textField3, nil] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UITextField *textField = obj;
            textField.enabled = editing;
            
            textField.textAlignment = NSTextAlignmentCenter;
            textField.keyboardType = UIKeyboardTypeDecimalPad;
        }];
        
        nameLabel.text = param.paramName;
        textField1.text = [param objectForKey:@"定值"];
        textField2.text = [param objectForKey:@"最大值"];
        textField3.text = [param objectForKey:@"最小值"];

        return  cell;
    }
}

-(NSMutableDictionary *)tableView:(UITableView *)tableView paramForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *section = indexPath.section == 0 ? section1Params : section2Params;
    return [section objectAtIndex:indexPath.row];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect rect = [textField convertRect:textField.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSMutableDictionary *param = [self tableView:self.tableView paramForRowAtIndexPath:indexPath];
        if (textField.tag == 552) {
            [param setObject:textField.text forKey:@"定值"];
        } else if (textField.tag == 553) {
            [param setObject:textField.text forKey:@"最大值"];
        } else if (textField.tag == 554) {
            [param setObject:textField.text forKey:@"最小值"];
        }
    }
}

- (void)saveParam:(id)sender
{
    [super saveParam:sender];
    
    if (self.currentLoop) {
        [self.device saveProtectionParams:self.paramArray forLoop:self.currentLoop];
    }
}

- (UIView *)choseLoopContainer
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 110, 30)];
    label.textColor = [UIColor textGreenColor];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"选择回线";
    
    UITextField *textField = [[MyTextField alloc] initWithFrame:CGRectMake(150, 10, 150, 30)];
    textField.textColor = [UIColor textGreenColor];
    textField.delegate = self;
    choserTextField = textField;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [view addSubview:label];
    [view addSubview:textField];
    
    return view;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == choserTextField) {
        NSMutableArray *dataOptions = [NSMutableArray arrayWithCapacity:self.loopArray.count];
        for (XLViewDataSwitchLoop *loop in self.loopArray) {
            [dataOptions addObject:[NSDictionary dictionaryWithObjectsAndKeys:loop.loopName, @"text", nil]];
        }
        
        UIWindow *frontWindow = [[[UIApplication sharedApplication] windows] lastObject];
        LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"选择数据项目" options:dataOptions];
        lplv.delegate = self;
        [lplv showInView:frontWindow animated:YES];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{
    self.currentLoop = [self.loopArray objectAtIndex:anIndex];
}

- (void)leveyPopListViewDidCancel
{
}

@end
