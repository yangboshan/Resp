//
//  SwitchDataCatalog2ViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-18.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SwitchDataCatalog2ViewController.h"

#import "Navbar.h"
#import "UIButton+Bootstrap.h"
#import "MJRefresh.h"
#import "JMWhenTapped.h"
#import "MySectionHeaderView.h"
#import "DeviceViewController.h"

@interface ExpandCell : UITableViewCell

@property (nonatomic) NSDictionary *catalogItem;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *valueLabel;
@property (nonatomic) UIView *detailView;

@end

@implementation ExpandCell
@synthesize catalogItem = _catalogItem;
@synthesize titleLabel = _titleLabel;
@synthesize valueLabel = _valueLabel;
@synthesize detailView = _detailView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        self.backgroundView = bgview;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor textWhiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)valueLabel
{
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textColor = [UIColor whiteColor];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.numberOfLines = 0;
        _valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.detailView addSubview:_valueLabel];
    }
    return _valueLabel;
}

- (UIView *)detailView
{
    if (!_detailView) {
        _detailView = [[UIView alloc] initWithFrame:CGRectZero];
        _detailView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:_detailView];
    }
    return _detailView;
}

- (void)setCatalogItem:(NSDictionary *)catalogItem
{
    _catalogItem = catalogItem;
    
    self.titleLabel.text = [catalogItem objectForKey:@"title"];
    self.valueLabel.text = [catalogItem objectForKey:@"value"];
   
    CGRect titleFrame = CGRectMake(20, 10, 280, 0);
    CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(titleFrame.size.width, MAXFLOAT) lineBreakMode:self.titleLabel.lineBreakMode];
    titleFrame.size.height = size.height + 5;
    self.titleLabel.frame = titleFrame;
    
    CGRect valueFrame = CGRectMake(10, 5, 300, 0);
    size = [self.valueLabel.text sizeWithFont:self.valueLabel.font constrainedToSize:CGSizeMake(valueFrame.size.width, MAXFLOAT) lineBreakMode:self.valueLabel.lineBreakMode];
    valueFrame.size.height = size.height + 5;
    self.valueLabel.frame = valueFrame;
    self.detailView.frame = CGRectMake(0, titleFrame.size.height + 20, 320, valueFrame.size.height + 10);
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = CGRectGetMaxY(self.detailView.frame);
    self.frame = selfFrame;
}

@end

@interface SwitchDataCatalog2ViewController () <DatePickerActionSheetDelegate>
{
    NSDateFormatter *dateFormatter;
    NSString *notifKey;
    
    MJRefreshHeaderView *refreshHeader;
    MJRefreshFooterView *refreshFooter;
    
    NSArray *columnTitles;
    NSArray *columnWidths;
    
    NSTimer *timer;
}

@property (nonatomic) UILabel *realtimeLabel;
@property (nonatomic) NSDate *refreshDate;
@property (nonatomic) DatePickerActionSheet *timeActionSheet;
@property (nonatomic) NSMutableArray *catalogItems;

@end

@implementation SwitchDataCatalog2ViewController
@synthesize timeActionSheet = _timeActionSheet;
@synthesize refreshDate = _refreshDate;

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
	
    //NSString *title = [NSString stringWithFormat:@"%@-%@", self.device.deviceName, self.category];
    [self.navigationItem setNewTitle:self.category];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.catalogItems = [NSMutableArray array];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd\nHH:mm:ss"];
    self.realtimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.realtimeLabel.font=[UIFont systemFontOfSize:10];
    self.realtimeLabel.textColor = [UIColor whiteColor];
    self.realtimeLabel.backgroundColor = [UIColor clearColor];
    self.realtimeLabel.textAlignment=UITextAlignmentCenter;
    self.realtimeLabel.numberOfLines = 2;
    self.realtimeLabel.text = @"2012-03-01\n99:99:99";
    [self.realtimeLabel sizeToFit];
    UIBarButtonItem *myButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.realtimeLabel];
    [self.navigationItem setRightBarButtonItem:myButtonItem];
    [self.realtimeLabel whenTapped:^{
        if (self.refreshDate) {
            [self.timeActionSheet.datePicker setDate:self.refreshDate animated:YES];
        }
        [self.timeActionSheet show];
    }];

    
    self.button1.frame = CGRectMake(117.5, 10, 85, 30);
    [self.button1 setTitle:@"召测" forState:UIControlStateNormal];
    [self.button1 normalStyle];
    [self.button1 addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
    self.button2.hidden = YES;
    self.button3.hidden = YES;
    self.button4.hidden = YES;
    
    self.tableView.allowsSelection = NO;
    [self addHeader];
    
    if ([self.category rangeOfString:@"遥测"].location != NSNotFound) {
        [self addFooter];
        columnTitles = [NSArray arrayWithObjects:@"名称", @"实际值", @"品质描述", nil];
        columnWidths = [NSArray arrayWithObjects:[NSNumber numberWithDouble:100.0], [NSNumber numberWithDouble:60.0], [NSNumber numberWithDouble:140.0], nil];
    } else if ([self.category rangeOfString:@"遥信"].location != NSNotFound) {
        [self addFooter];
        columnTitles = [NSArray arrayWithObjects:@"名称", @"实际值", @"品质描述", nil];
        columnWidths = [NSArray arrayWithObjects:[NSNumber numberWithDouble:100], [NSNumber numberWithDouble:60], [NSNumber numberWithDouble:140], nil];
    } else if ([self.category rangeOfString:@"遥控"].location != NSNotFound) {
        [self addFooter];
        columnTitles = [NSArray arrayWithObjects:@"名称", @"遥控号", @"压板", nil];
        columnWidths = [NSArray arrayWithObjects:[NSNumber numberWithDouble:100], [NSNumber numberWithDouble:60], [NSNumber numberWithDouble:140], nil];
    } else if ([self.category rangeOfString:@"运行状态"].location != NSNotFound) {
        columnTitles = [NSArray arrayWithObjects:@"名称", @"数据展示", nil];
        columnWidths = [NSArray arrayWithObjects:[NSNumber numberWithDouble:150], [NSNumber numberWithDouble:150], nil];
    } else if ([self.category rangeOfString:@"回线"].location != NSNotFound) {
        columnTitles = [NSArray arrayWithObjects:@"名称", @"数据", nil];
        columnWidths = [NSArray arrayWithObjects:[NSNumber numberWithDouble:100], [NSNumber numberWithDouble:200], nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"开关%@-%@-%@", self.device.deviceId, (self.realtime ? @"实时数据" : @"历史数据"), self.category];
    self.refreshDate = [NSDate date];
    [refreshHeader beginRefreshing];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.realtime) {
        timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(refreshData:) userInfo:nil repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    NSLog(@"SwitchDataCatalog2ViewController initData");
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         notifKey, @"xl-name",
                         self.category, @"category",
                         [NSNumber numberWithBool:self.realtime], @"realtime",
                         self.refreshDate, @"time",
                         nil];
    [self.device queryCatalog2DataForCategroy:dic];
}

- (void)loadMoreData
{
    NSLog(@"SwitchDataCatalog2ViewController initData");
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         notifKey, @"xl-name",
                         self.category, @"category",
                         [NSNumber numberWithBool:self.realtime], @"realtime",
                         self.refreshDate, @"time",
                         @YES, @"load-more",
                         nil];
    [self.device queryCatalog2DataForCategroy:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        BOOL loadMore = [[[dic objectForKey:@"parameter"] objectForKey:@"load-more"] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!loadMore) {
                [self.catalogItems removeAllObjects];
            }
            [self.catalogItems addObjectsFromArray:result];
            [self.tableView reloadData];
            
            if (loadMore) {
                [refreshFooter endRefreshing];
            } else {
                [refreshHeader endRefreshing];
            }
        });
    }
}

- (void)addHeader
{
    __unsafe_unretained UIViewController *vc = self;
    refreshHeader = [MJRefreshHeaderView header];
    refreshHeader.scrollView = self.tableView;
    refreshHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc performSelector:@selector(initData) withObject:nil];
    };
}

- (void)addFooter
{
    __unsafe_unretained UIViewController *vc = self;
    refreshFooter = [MJRefreshFooterView footer];
    refreshFooter.scrollView = self.tableView;
    refreshFooter.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc performSelector:@selector(loadMoreData) withObject:nil];
    };
}


- (void)dealloc
{
    [refreshHeader free];
    [refreshFooter free];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (DatePickerActionSheet *)timeActionSheet
{
    if (!_timeActionSheet) {
        _timeActionSheet = [[DatePickerActionSheet alloc] init];
        _timeActionSheet.pickerDelegate = self;
    }
    return _timeActionSheet;
}

- (void)datePickerActionSheet:(UIActionSheet *)actionSheet didPickDate:(NSDate *)date
{
    self.refreshDate = date;
    [self initData];
}

- (void)setRefreshDate:(NSDate *)refreshDate
{
    _refreshDate = refreshDate;
    self.realtimeLabel.text = refreshDate != nil ? [dateFormatter stringFromDate:refreshDate] : @"----";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.catalogItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];

    NSInteger len = columnTitles.count;
    CGFloat x = 20;
    for (NSInteger i = 0; i < len; i++) {
        CGFloat width = [[columnWidths objectAtIndex:i] doubleValue];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(x, 0, width, 30)];
        label1.textColor = [UIColor whiteColor];
        label1.backgroundColor = [UIColor clearColor];
        label1.text = [columnTitles objectAtIndex:i];
        if (i > 0) {
            label1.textAlignment = NSTextAlignmentCenter;
        }
        [view addSubview:label1];
        x += width;
    }
    
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ExpandCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *item = [self.catalogItems objectAtIndex:indexPath.row];
    
    NSInteger len = columnTitles.count;
    CGFloat x = 20;
    for (NSInteger i = 0; i < len; i++) {
        NSInteger tag = 500 + i;
        CGFloat width = [[columnWidths objectAtIndex:i] doubleValue];
        UILabel *label1 = (UILabel *)[cell viewWithTag:tag];
        if (!label1) {
            label1 = [[UILabel alloc] initWithFrame:CGRectZero];
            label1.tag = tag;
            [cell addSubview:label1];
        }
        label1.frame = CGRectMake(x, 0, width, 44);
        label1.textColor = [UIColor textWhiteColor];
        label1.backgroundColor = [UIColor clearColor];
        label1.adjustsFontSizeToFitWidth = YES;
        NSString *column = [columnTitles objectAtIndex:i];
        label1.text = [item objectForKey:column];
        if (i > 0) {
            label1.textAlignment = NSTextAlignmentCenter;
        }
        label1.layer.cornerRadius = 0;
        
        if ([self.category rangeOfString:@"运行状态"].location != NSNotFound && [column isEqualToString:@"数据展示"]) {
            if ([label1.text isEqualToString:@"正常"]) {
                label1.backgroundColor = [UIColor greenColor];
            } else {
                label1.backgroundColor = [UIColor redColor];
            }
            label1.text = @"";
            CGRect frame = label1.frame;
            frame.origin.x += (frame.size.width - 30) / 2;
            frame.origin.y = (44 - 30) / 2;
            frame.size.height = 30;
            frame.size.width = 30;
            label1.frame = frame;
            label1.layer.cornerRadius = 15;
        }
        x += width;
    }

    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    ExpandCell *cell = (ExpandCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
//    return indexPath.row == curSelectIndex ? cell.frame.size.height : cell.detailView.frame.origin.y;
//}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (curSelectIndex == indexPath.row){
//        curSelectIndex = NSNotFound;
//    } else {
//        curSelectIndex = indexPath.row;
//    }
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [tableView beginUpdates];
//    [tableView endUpdates];
//}

- (IBAction)refreshData:(id)sender
{
    [self initData];
    //[self.tableView reloadData];
}

@end
