//
//  DeviceLoopsViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-10.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceLoopsViewController.h"

#import "LeveyPopListView.h"
#import "MyTextField.h"

@interface DeviceLoopsViewController () <LeveyPopListViewDelegate>
{
    UITextField *choserTextField;
    
    NSString *notifKey;
}

@property (nonatomic) NSArray *paramArray;
@property (nonatomic) UIView *loopChoser;

@end

@implementation DeviceLoopsViewController

@synthesize currentLoop = _currentLoop;

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
	
    self.loopChoser = [self choseLoopContainer];
    choserTextField.text = self.currentLoop.loopName;
    [self.view addSubview:self.loopChoser];
    
    CGFloat delta = self.loopChoser.bounds.size.height;
    CGRect frame = self.tableView.frame;
    frame.origin.y += delta;
    frame.size.height -= delta;
    self.tableView.frame = frame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"开关%@-回路参数", self.device.deviceId];
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryLoopParams:dic];
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
    
    self.paramArray = [currentLoop.loopParams paramsCopy];
    [self.tableView reloadData];
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

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    UILabel *nameLabel;
//    UITextField *textField;
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.backgroundColor = [UIColor listItemBgColor];
//        
//        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 110, 30)];
//        nameLabel.textColor = [UIColor textWhiteColor];
//        nameLabel.backgroundColor = [UIColor clearColor];
//        nameLabel.adjustsFontSizeToFitWidth = YES;
//        textField = [[UITextField alloc] initWithFrame:CGRectMake(150, 7, 150, 30)];
//        textField.delegate = self;
//        textField.adjustsFontSizeToFitWidth = YES;
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
//    NSString *prop = [paramPropArray objectAtIndex:indexPath.row];
//    NSString *name = [paramNameArray objectAtIndex:indexPath.row];
//    id value = [self.valueMap valueForKey:prop];
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
//        NSString *prop = [paramPropArray objectAtIndex:indexPath.row];
//        
//        [self.valueMap setObject:textField.text forKey:prop];
//    }
//}

- (IBAction)saveParam:(id)sender
{
    [super saveParam:sender];
    
    if (self.currentLoop) {
        [self.device saveLoopParams:self.paramArray forLoop:self.currentLoop];
    }
    
//    [self.valueMap enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
//        NSString *porperty = key;
//        id value = obj;
//        if (value == [NSNull null]) {
//            value = nil;
//        }
//        
//        [self.currentLoop setValue:value forKey:porperty];
//    }];
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
