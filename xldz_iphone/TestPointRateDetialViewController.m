//
//  TestPointRateDetialViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-4.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "TestPointRateDetialViewController.h"

#import "Navbar.h"
#import "JMWhenTapped.h"


@interface TestPointRateDetialViewController ()
{
    NSString *notifKey;
    
    CGFloat columnWidth;
    CGFloat hdrColumnWidth;
    
    NSArray *columnTitles;
    NSArray *tableData;
    NSString *rowTitle;
    
    NSDateFormatter *dateFormatter;
}

@end

@implementation TestPointRateDetialViewController
@synthesize timeType = _timeType;
@synthesize refreshDate = _refreshDate;
@synthesize timeActionSheet = _timeActionSheet;

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setNewTitle:self.testPoint.pointName];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.bottomView.hidden = YES;
    self.tableView.frame = CGRectUnion(self.tableView.frame, self.bottomView.frame);
    self.tableView.allowsSelection = NO;
    
    if (!self.realtime) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
        [self.view addSubview:view];
        
        UIImage * backgroundImg = [UIImage imageNamed:@"plot_tab_buttons_middle_normal_bg.png"];
        self.dayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dayBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.dayBtn setTitle:@"日" forState:UIControlStateNormal];
        [self.dayBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
        self.dayBtn.frame = CGRectMake(0, 0, 160, 30);
        [self.dayBtn addTarget:self action:@selector(timeBtnPressed:) forControlEvents:UIControlEventTouchDown];
        
        self.monthBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.monthBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.monthBtn setTitle:@"月" forState:UIControlStateNormal];
        [self.monthBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
        self.monthBtn.frame = CGRectMake(160, 0, 160, 30);
        [self.monthBtn addTarget:self action:@selector(timeBtnPressed:) forControlEvents:UIControlEventTouchDown];
        
        [view addSubview:self.dayBtn];
        [view addSubview:self.monthBtn];
        
        self.timeType = XLViewPlotTimeDay;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 160, 30)];
        self.timeLabel.font = [UIFont systemFontOfSize:15];
        self.timeLabel.textColor = [UIColor yellowColor];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.timeLabel];
        if (self.refreshDate) {
            self.timeLabel.text = [dateFormatter stringFromDate:self.refreshDate];
        }
        [self.timeLabel whenTapped:^{
            [self.timeActionSheet show];
        }];
        
        CGRect frame = self.tableView.frame;
        frame.origin.y += 60;
        frame.size.height -= 60;
        self.tableView.frame = frame;
    }
    
    hdrColumnWidth = 50.0;
    NSString *category = self.category;
    if ([category isEqualToString:@"A、B、C三相电压、电流2～19次谐波有效值"]) {
        rowTitle = @"%d次谐波有效值";
        hdrColumnWidth = 50.0;
    } else if ([category isEqualToString:@"A、B、C三相电压、电流2～19次谐波含有率"]) {
        rowTitle = @"%d次谐波含有率";
        hdrColumnWidth = 50.0;
    } else if ([category isEqualToString:@"A/B/C相2～19次谐波电流最大值及发生时间"]) {
        rowTitle = @"%d次谐波电流最大值\n及发生时间";
        hdrColumnWidth = 110.0;
    } else if ([category isEqualToString:@"A/B/C相2～19次谐波电压含有率及总畸变率最大值及发生时间"]) {
        rowTitle = @"%d次谐波电压含有率\n及总畸变率最大值\n及发生时间";
        hdrColumnWidth = 110.0;
    }
    columnWidth = (320.0 - hdrColumnWidth) / 5.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"设备%@-%@", self.testPoint.pointId, self.category];
    [self initData];
}

- (void)initData
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                notifKey, @"xl-name",
                                self.category, @"category",
                                [NSNumber numberWithBool:self.realtime], @"realtime",
                                nil];
    if (!self.realtime) {
        [dic setObject:[NSNumber numberWithInt:self.timeType] forKey:@"plotTimeType"];
        [dic setObject:self.refreshDate forKey:@"time"];
    }
    [self.testPoint query2_19ListData:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        NSArray *columns = [dic objectForKey:@"column"];
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [refreshHeader endRefreshing];
            
            columnTitles = columns;
            tableData = result;
            columnWidth = (320.0 - hdrColumnWidth) / columnTitles.count;
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

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setTimeType:(XLViewPlotTimeType)timeType
{
    _timeType = timeType;
    
    [self.dayBtn setTitleColor:(timeType == XLViewPlotTimeDay ? [UIColor whiteColor] : [UIColor darkGrayColor]) forState:UIControlStateNormal];
    [self.monthBtn setTitleColor:(timeType == XLViewPlotTimeMonth ? [UIColor whiteColor] : [UIColor darkGrayColor]) forState:UIControlStateNormal];
}

- (void)setRefreshDate:(NSDate *)refreshDate
{
    _refreshDate = refreshDate;
    self.timeLabel.text = [dateFormatter stringFromDate:self.refreshDate];
}

- (DatePickerActionSheet *)timeActionSheet
{
    if (!_timeActionSheet) {
        _timeActionSheet = [[DatePickerActionSheet alloc] init];
        _timeActionSheet.datePicker.datePickerMode = UIDatePickerModeDate;
        _timeActionSheet.pickerDelegate = self;
    }
    return _timeActionSheet;
}

- (void)datePickerActionSheet:(UIActionSheet *)actionSheet didPickDate:(NSDate *)date
{
    self.refreshDate = date;
    [self initData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return tableData.count;//19 - 2 + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self tableView:tableView viewForHeaderInSection:section].frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor listItemBgColor];
    
    CGFloat x = hdrColumnWidth;
    CGFloat height = 0;
    for (NSString *column in columnTitles) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, columnWidth, 0)];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.text = column;
        
        CGSize size = [column sizeWithFont:label.font constrainedToSize:CGSizeMake(columnWidth, MAXFLOAT) lineBreakMode:label.lineBreakMode];
        height = MAX(height, size.height + 10);
        
        [view addSubview:label];
        x += columnWidth;
    }
    
    for (UIView *label in view.subviews) {
        CGRect rect = label.frame;
        rect.size.height = height;
        label.frame = rect;
    }
    view.frame = CGRectMake(0, 0, 320, height + 1);
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, height, 320, 1)];
    divider.backgroundColor = [UIColor listDividerColor];
    [view addSubview:divider];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell-%d", columnTitles.count];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        UILabel* name = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, hdrColumnWidth, 0)];
        name.textColor=[UIColor whiteColor];
        name.backgroundColor = [UIColor clearColor];
        name.font = [UIFont systemFontOfSize:12];
        name.lineBreakMode = NSLineBreakByWordWrapping;
        name.textAlignment = NSTextAlignmentCenter;
        name.numberOfLines = 0;
        name.tag = 500;
        [cell.contentView addSubview:name];
        
        CGFloat begin = hdrColumnWidth;
        for (NSUInteger i = 1; i <= columnTitles.count; i++, begin += columnWidth) {
            UILabel* value = [[UILabel alloc]initWithFrame:CGRectMake(begin, 0, columnWidth, 0)];
            value.textColor=[UIColor greenColor];
            value.backgroundColor = [UIColor clearColor];
            value.font = [UIFont systemFontOfSize:12];
            value.lineBreakMode = NSLineBreakByWordWrapping;
            value.textAlignment = NSTextAlignmentCenter;
            value.numberOfLines = 0;
            
            value.tag = 500 + i;
            [cell.contentView addSubview:value];
        }
    }
    
    NSDictionary *data = [tableData objectAtIndex:indexPath.row];
    
    CGFloat rowHeight = 0;
    UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:500];
    nameLabel.text = [[NSString alloc]initWithFormat:rowTitle, indexPath.row + 2];
    CGSize size = [nameLabel.text sizeWithFont:nameLabel.font constrainedToSize:CGSizeMake(hdrColumnWidth, MAXFLOAT) lineBreakMode:nameLabel.lineBreakMode];
//    CGRect rect = nameLabel.frame;
//    rect.size.height = size.height + 10;
//    nameLabel.frame = rect;
    rowHeight = MAX(rowHeight, size.height + 10);
    
    for (NSUInteger i = 1; i <= columnTitles.count; i++) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:500 + i];
        label.text = [data objectForKey:[columnTitles objectAtIndex:i - 1]];
        
        size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(columnWidth, MAXFLOAT) lineBreakMode:label.lineBreakMode];
//        rect = label.frame;
//        rect.size.height = size.height + 10;
//        label.frame = rect;
        rowHeight = MAX(rowHeight, size.height + 10);
    }
    
    cell.frame = CGRectMake(0, 0, 320, rowHeight + 1);
    for (NSUInteger i = 0; i <= columnTitles.count; i++) {
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:500 + i];
        CGRect rect = label.frame;
        rect.size.width = label == nameLabel ? hdrColumnWidth :columnWidth;
        rect.size.height = rowHeight;
        label.frame = rect;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height;
}

- (IBAction)timeBtnPressed:(id)sender
{
    UIButton *btn = sender;
    if (btn == self.dayBtn) {
        self.timeType = XLViewPlotTimeDay;
    } else if (btn == self.monthBtn){
        self.timeType = XLViewPlotTimeMonth;
    }
}

@end
