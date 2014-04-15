//
//  DeviceTelemetryParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-12.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceTelemetryParamViewController.h"

#import "MySectionHeaderView.h"
#import "MyTextField.h"

@interface DeviceTelemetryParamViewController ()
{
    NSString *notifKey;
    BOOL inited;
}
@end

@implementation DeviceTelemetryParamViewController

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
    
    colWidth = 100.0f;
	
    self.ewTableView = [[EWMultiColumnTableView alloc] initWithFrame:self.tableView.bounds];
    self.ewTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.ewTableView.sectionHeaderEnabled = NO;
    //    tblView.cellWidth = 100.0f;
    self.ewTableView.backgroundColor = [UIColor blackColor];
    self.ewTableView.leftHeaderBackgroundColor = [UIColor blackColor];
    self.ewTableView.boldSeperatorLineColor = [UIColor listDividerColor];
    self.ewTableView.normalSeperatorLineColor = [UIColor listDividerColor];
    self.ewTableView.boldSeperatorLineWidth = 1.0f;
    self.ewTableView.normalSeperatorLineWidth = 1.0f;
    self.ewTableView.dataSource = self;
    
    [self.view addSubview:self.ewTableView];
    [self.tableView removeFromSuperview];
    
    //self.ewTableView.scrollEnabled = NO;
//    self.ewTableView.tblView.clipsToBounds = NO;
//    self.ewTableView.scrlView.clipsToBounds = NO;
    self.ewTableView.headerTblView.clipsToBounds = NO;
    [self.ewTableView reloadData];
    [self addCustomHeader];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.ewTableView addGestureRecognizer:gestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"开关%@-遥测参数", self.device.deviceId];
    
    [refreshHeader free];
    refreshHeader = nil;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!inited) {
        inited = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [ewRefreshHeader beginRefreshing];
        });
    }
}

- (void)initData {
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    tableColumns = [NSArray arrayWithObjects:@"发送标志", @"主动发送标志", @"系数", @"满度值", @"修正值", @"生成曲线类型", nil];
    [self.device queryTelemetryParams:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.paramArray = result;
            [self.ewTableView reloadData];
            
            [ewRefreshHeader endRefreshing];
        });
    }
}

- (void)dealloc
{
    [ewRefreshHeader free];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addCustomHeader
{
    __unsafe_unretained DeviceTelemetryParamViewController *vc = self;
    ewRefreshHeader = [MJRefreshHeaderView header];
    ewRefreshHeader.multiColumnView = self.ewTableView;
    ewRefreshHeader.scrollView = self.ewTableView.headerTblView;
    CGRect frame = ewRefreshHeader.frame;
    //frame.origin.x = -self.ewTableView.headerTblView.frame.size.width;
    frame.size.width = 320;
    ewRefreshHeader.frame = frame;
    ewRefreshHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc refreshData:nil];
    };
}

#pragma mark - EWMultiColumnTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(EWMultiColumnTableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(EWMultiColumnTableView *)tableView cellForIndexPath:(NSIndexPath *)indexPath column:(NSInteger)col
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, colWidth, 40.0f)];
    view.backgroundColor = [UIColor listItemBgColor];
    view.tag = 500 + col;
    
    CGRect rect = CGRectMake(5, 5, colWidth - 10, 30);
    UITextField *textField = [[MyTextField alloc] initWithFrame:rect];
    textField.adjustsFontSizeToFitWidth = YES;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    textField.tag = 1;
    [view addSubview:textField];
    
    CCComboBox *dropDownView = [[CCComboBox alloc] initWithFrame:rect];
    dropDownView.titleLabel.textAlignment = NSTextAlignmentCenter;
    dropDownView.delegate = self;
    dropDownView.tag = 2;
    [view addSubview:dropDownView];
    
    return view;
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
    textField.keyboardType = UIKeyboardTypeDecimalPad;
    
    if (!editing || col == 2 || col == 3 || col == 4) {
        textField.hidden = NO;
        dropDownView.hidden = YES;
    } else {
        textField.hidden = YES;
        dropDownView.hidden = NO;
        
        if (col == 0 || col == 1) {
            NSArray *options = [NSArray arrayWithObjects:@"发送", @"不发送", nil];
            //[dropDownView setSelectionOptions:options withTitles:options];
            [dropDownView setDataArray:[options mutableCopy] selected:[options indexOfObject:value]];
        } else if (col == 5) {
            NSArray *options = [NSArray arrayWithObjects:@"是", @"否", nil];
            //[dropDownView setSelectionOptions:options withTitles:options];
            [dropDownView setDataArray:[options mutableCopy] selected:[options indexOfObject:value]];
        }
    }
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView heightForCellAtIndexPath:(NSIndexPath *)indexPath column:(NSInteger)col
{
    return 40.0f;
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView widthForColumn:(NSInteger)column
{
    return colWidth;
}

- (NSInteger)tableView:(EWMultiColumnTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.paramArray.count;
}

//table 中的section header
- (UIView *)tableView:(EWMultiColumnTableView *)tableView sectionHeaderCellForSection:(NSInteger)section column:(NSInteger)col
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectZero];
    l.backgroundColor = [UIColor yellowColor];
    return l;
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForSectionHeaderCell:(UIView *)cell section:(NSInteger)section column:(NSInteger)col
{
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView heightForSectionHeaderCellAtSection:(NSInteger)section column:(NSInteger)col
{
    return 0.0f;
}

- (NSInteger)numberOfColumnsInTableView:(EWMultiColumnTableView *)tableView
{
    return tableColumns.count;
}

#pragma mark Header Cell
//行标题栏
- (UIView *)tableView:(EWMultiColumnTableView *)tableView headerCellForIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 40.0f)];
    view.backgroundColor = [UIColor listItemBgColor];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 5.0f, 55.0f, 30.0f)];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor textWhiteColor];
    l.adjustsFontSizeToFitWidth = YES;
    l.tag = 111;
    [view addSubview:l];
    
    return view;
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForHeaderCell:(UIView *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *l = (UILabel *)[cell viewWithTag:111];
    
    NSMutableDictionary *param = [self.paramArray objectAtIndex:indexPath.row];
    l.text = param.paramName;
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView heightForHeaderCellAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

//行标题栏中的section header
- (UIView *)tableView:(EWMultiColumnTableView *)tableView headerCellInSectionHeaderForSection:(NSInteger)section
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectZero];
    return l;
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForHeaderCellInSectionHeader:(UIView *)cell AtSection:(NSInteger)section
{
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView heightForHeaderCellInSectionHeaderAtSection:(NSInteger)section
{
    return 0.0f;
}

//列标题
- (UIView *)tableView:(EWMultiColumnTableView *)tableView headerCellForColumn:(NSInteger)col
{
    MySectionHeaderView *view =  [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, colWidth, 30.0f)];
    UILabel *l = [[UILabel alloc] initWithFrame:view.bounds];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont systemFontOfSize:14];
    l.textAlignment = NSTextAlignmentCenter;
    NSString *column = [tableColumns objectAtIndex:col];
    l.text = column;
    [view addSubview:l];
    
    return view;
}

//左上角
- (UIView *)topleftHeaderCellOfTableView:(EWMultiColumnTableView *)tableView
{
    MySectionHeaderView *view =  [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, [self heightForHeaderCellOfTableView:tableView])];
    CGRect rect = view.bounds;
    rect.origin.x = 5;
    rect.size.width -= 5;
    UILabel *l = [[UILabel alloc] initWithFrame:rect];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont systemFontOfSize:14];
    l.text = @"名称";
    [view addSubview:l];
    
    return view;
}

- (CGFloat)heightForHeaderCellOfTableView:(EWMultiColumnTableView *)tableView
{
    return 30.0f;
}

- (CGFloat)widthForHeaderCellOfTableView:(EWMultiColumnTableView *)tableView
{
    return 60.0;
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
        if (col == 0 || col == 1) {
            NSArray *options = [NSArray arrayWithObjects:@"发送", @"不发送", nil];
            selection = [options objectAtIndex:index];
        } else if (col == 5) {
            NSArray *options = [NSArray arrayWithObjects:@"是", @"否", nil];
            selection = [options objectAtIndex:index];
        }
        [param setObject:selection forKey:column];
    }
}

//#pragma mark - Drop Down Selector Delegate
//
//- (BOOL)dropDownControlViewWillBecomeActive:(LHDropDownControlView *)view  {
//    if (refreshHeader.isRefreshing) {
//        return NO;
//    }
//    self.ewTableView.scrollEnabled = NO;
//    return YES;
//    //view.layer.zPosition = CGFLOAT_MAX;
////    [view.superview bringSubviewToFront:view];
////    [self.ewTableView sendSubviewToBack:self.ewTableView.headerTblView];
////    
////    UITableView *tableView = self.ewTableView.tblView;
////    CGRect rect = [view convertRect:view.bounds toView:tableView];
////    NSIndexPath *indexPath = [[tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
////    if (indexPath) {
////        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
////        [cell.superview bringSubviewToFront:cell];
////    }
//}
//
//- (void)dropDownControlView:(LHDropDownControlView *)view didFinishWithSelection:(id)selection {
//    self.ewTableView.scrollEnabled = YES;
////    [self.ewTableView bringSubviewToFront:self.ewTableView.headerTblView];
//    
//    UITableView *tableView = self.ewTableView.tblView;
//    CGRect rect = [view convertRect:view.bounds toView:tableView];
//    NSIndexPath *indexPath = [[tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
//    if (indexPath && selection) {
//        NSMutableDictionary *param = [self.paramArray objectAtIndex:indexPath.row];
//        NSString *column = [tableColumns objectAtIndex:(view.superview.tag - 500)];
//        [param setObject:selection forKey:column];
//        view.title = selection;
//    }
//}

#pragma mark - UITextField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = self.ewTableView.frame;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect cf = [self.ewTableView convertRect:self.ewTableView.bounds toView:keyWindow];
    CGFloat delta = 216 - CGRectGetHeight(keyWindow.frame) + CGRectGetMaxY(cf);//键盘高度216
    if (delta > 0) {
        frame.size.height -= delta;
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.ewTableView.frame = frame;
        [UIView commitAnimations];
    }
    
    UITableView *tableView = self.ewTableView.tblView;
    CGRect rect = [textField convertRect:textField.bounds toView:tableView];
    NSIndexPath *indexPath = [[tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    return YES;
}

- (void)hideKeyboard {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    CGRect frame = self.ewTableView.frame;
    frame.size.height = CGRectGetMinY(self.bottomView.frame) - CGRectGetMinY(self.ewTableView.frame);
    self.ewTableView.frame = frame;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableView *tableView = self.ewTableView.tblView;
    CGRect rect = [textField convertRect:textField.bounds toView:tableView];
    NSIndexPath *indexPath = [[tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSMutableDictionary *param = [self.paramArray objectAtIndex:indexPath.row];
        NSString *column = [tableColumns objectAtIndex:(textField.superview.tag - 500)];
        [param setObject:textField.text forKey:column];
    }
}

- (IBAction)toggleEditing:(id)sender
{
    [super toggleEditing:sender];
    [self.ewTableView reloadData];
}

- (IBAction)saveParam:(id)sender
{
    [super saveParam:sender];
    [self.ewTableView reloadData];
    
    [self saveParam];
}

- (void)saveParam
{
    [self.device saveTelemetryParams:self.paramArray];
}

//- (IBAction)refreshData:(id)sender
//{
//    [super refreshData:sender];
//    [self.ewTableView reloadData];
//}

@end