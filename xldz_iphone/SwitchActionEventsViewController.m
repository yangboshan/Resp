//
//  SwitchActionEventsViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SwitchActionEventsViewController.h"

#import "Toast+UIView.h"
#import "UIButton+Bootstrap.h"
#import "ActionEventTableViewCell.h"
#import "SwitchEventChartViewController.h"

@interface SwitchActionEventsViewController ()
{
    MJRefreshHeaderView *refreshHeader;
    MJRefreshFooterView *refreshFooter;
    
    NSString *notifKey;
}

@end

static NSString *CellIdentifier = @"EventCell";

@implementation SwitchActionEventsViewController

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
    
    events = [NSMutableArray array];
	
    self.button1.frame = CGRectMake(20, 10, 80, 30);
    self.button2.frame = CGRectMake(120, 10, 80, 30);
    self.button3.frame = CGRectMake(220, 10, 80, 30);
    self.button4.hidden = YES;
    [self.button1 setTitle:@"保存" forState:UIControlStateNormal];
    [self.button2 setTitle:@"下发" forState:UIControlStateNormal];
    [self.button3 setTitle:@"召测" forState:UIControlStateNormal];
    [self.button1 okStyle];
    [self.button2 warningStyle];
    [self.button3 normalStyle];
    [self.button1 addTarget:self action:@selector(saveEvents:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3 addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.allowsSelection = NO;
    UINib *nib = [UINib nibWithNibName:@"ActionEventTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    [self addHeader];
    [self addFooter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"开关%@-%@", self.device.deviceId, self.eventType];    
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshHeader beginRefreshing];
    });
}


- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         notifKey, @"xl-name",
                         self.eventType, @"event-type",
                         nil];
    [self.device queryEvents:dic];
}

- (void)loadMoreData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         notifKey, @"xl-name",
                         self.eventType, @"event-type",
                         @YES, @"load-more",
                         nil];
    [self.device queryEvents:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        BOOL loadMore = [[[dic objectForKey:@"parameter"] objectForKey:@"load-more"] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!loadMore) {
                [events removeAllObjects];
            }
            [events addObjectsFromArray:result];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [refreshHeader free];
    [refreshFooter free];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return events.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ActionEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.eventNoLabel.textColor = [UIColor textWhiteColor];
    cell.eventTimeLabel.textColor = [UIColor textWhiteColor];
    cell.eventTimeLabel.adjustsFontSizeToFitWidth = YES;
    cell.eventContentLabel.textColor = [UIColor textWhiteColor];
    cell.eventContentLabel.numberOfLines = 0;
    cell.eventContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [cell.chartBtn blueBorderStyle];

    NSDictionary *event = [events objectAtIndex:indexPath.row];
    cell.eventNoLabel.text = [event objectForKey:@"序号"];
    cell.eventTimeLabel.text = [event objectForKey:@"发生时间"];
    cell.eventContentLabel.text = [event objectForKey:@"事件内容"];
    
    CGRect frame = cell.eventContentLabel.frame;
    CGSize size = [cell.eventContentLabel.text sizeWithFont:cell.eventContentLabel.font constrainedToSize:CGSizeMake(frame.size.width, MAXFLOAT) lineBreakMode:cell.eventContentLabel.lineBreakMode];
    frame.size.height = size.height + 5;
    cell.eventContentLabel.frame = frame;
    
    cell.chartBtn.hidden = YES;
    if ([self.eventType isEqualToString:@"动作事件"]) {
        cell.chartBtn.hidden = NO;
        [cell.chartBtn removeTarget:self action:@selector(viewEventChart:) forControlEvents:UIControlEventTouchUpInside];
        [cell.chartBtn addTarget:self action:@selector(viewEventChart:) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect rect = cell.chartBtn.frame;
        rect.origin.y = CGRectGetMaxY(frame) + 5;
        cell.chartBtn.frame = rect;
        
        frame = rect;
    }
    
    CGRect f = cell.frame;
    f.size.height = CGRectGetMaxY(frame) + 10;
    cell.frame = f;

    return cell;
}

- (IBAction)viewEventChart:(id)sender
{
    UIButton *btn = sender;
    CGRect rect = [btn convertRect:btn.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSDictionary *event = [events objectAtIndex:indexPath.row];
        
        SwitchEventChartViewController *controller = [[SwitchEventChartViewController alloc] init];
        controller.device = self.device;
        controller.event = event;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)saveEvents:(id)sender
{
    [self.view makeToast:@"TODO"];
}

- (IBAction)refreshData:(id)sender
{
    [self initData];
    [self.tableView reloadData];
}

@end