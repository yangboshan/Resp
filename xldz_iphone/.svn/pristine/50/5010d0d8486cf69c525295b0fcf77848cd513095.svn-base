//
//  FMREventsViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "FMREventsViewController.h"

#import "Navbar.h"
#import "MySectionHeaderView.h"
#import "SaftyTableViewCell.h"
#import "JMWhenTapped.h"

@interface FMREventsViewController ()
{
    NSString *notifKey;
    
    NSInteger curSelectIndex;
}
@property (nonatomic) NSDateFormatter *dateFormatter;
@end

static NSString *CellIdentifier = @"TableInfoCell";

@implementation FMREventsViewController
@synthesize dateFormatter = _dateFormatter;

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter  = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yy-MM-dd\nHH:mm:ss"];
    }
    return _dateFormatter;
};

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setNewTitle:@"事件数据"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.bottomView.hidden = YES;
    self.tableView.frame = CGRectUnion(self.tableView.frame, self.bottomView.frame);
    
    UINib *nib = [UINib nibWithNibName:@"safty_list_info_cell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    [self addHeader];

    curSelectIndex = NSNotFound;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"变压器%@-事件数据", self.device.deviceId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshHeader beginRefreshing];
    });
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryEvents:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader endRefreshing];
            
            events = result;
            [self.tableView reloadData];
        });
    }
}

- (void)dealloc
{
    [refreshHeader free];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return events.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 70, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:14];
    label1.text = @"事件名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(95, 0, 75, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:14];
    label2.text = @"发生时间";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(175, 0, 70, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.font = [UIFont systemFontOfSize:14];
    label3.text = @"发生/恢复";
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(250, 0, 70, 30)];
    label4.textColor = [UIColor whiteColor];
    label4.backgroundColor = [UIColor clearColor];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.font = [UIFont systemFontOfSize:14];
    label4.text = @"事件性质";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label3];
    [view addSubview:label4];
    
    [label2 whenTapped:^{
        static BOOL flag = YES;
        flag = !flag;
        [self sortByField:@"发生时间" ascending:flag];
    }];
    [label3 whenTapped:^{
        static BOOL flag = YES;
        flag = !flag;
        [self sortByField:@"发生/恢复" ascending:flag];
    }];
    [label4 whenTapped:^{
        static BOOL flag = YES;
        flag = !flag;
        [self sortByField:@"事件性质" ascending:flag];
    }];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SaftyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.clipsToBounds = YES;
    
    [cell.eventName setNumberOfLines:2];
    //cell.eventName.lineBreakMode = UILineBreakModeWordWrap;
    
    [cell.eventTime setNumberOfLines:2];
    //cell.eventTime.lineBreakMode = UILineBreakModeWordWrap;
    
    
    NSDictionary *event = [events objectAtIndex:indexPath.row];
    cell.eventName.text = [event objectForKey:@"事件名称"];
    NSDate *date = [event objectForKey:@"发生时间"];
    cell.eventTime.text = [self.dateFormatter stringFromDate:date];
    cell.eventHappen.text = [event objectForKey:@"发生/恢复"];
    cell.eventPrority.text = [event objectForKey:@"事件性质"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath      *)indexPath;
{
    /// Here you can set also height according to your section and row
    int height=40;
    return indexPath.row == curSelectIndex ? height+95 : height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (curSelectIndex == indexPath.row){
        curSelectIndex = NSNotFound;
    } else {
        curSelectIndex = indexPath.row;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView beginUpdates];
    [tableView endUpdates];
}


- (void)sortByField:(NSString *)field ascending:(BOOL)ascending
{
    events = [events sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDictionary *dic1 = obj1;
        NSDictionary *dic2 = obj2;
        id val1 = [dic1 objectForKey:field];
        id val2 = [dic2 objectForKey:field];
        
        if (!ascending) {
            id tmp = val2;
            val2 = val1;
            val1 = tmp;
        }
        
        if ([val1 isKindOfClass:[NSString class]] && [val2 isKindOfClass:[NSString class]]) {
            NSString *str1 = val1;
            NSString *str2 = val2;
            return [str1 compare:str2];
        } else if ([val1 isKindOfClass:[NSDate class]] && [val2 isKindOfClass:[NSDate class]]) {
            NSDate *date1 = val1;
            NSDate *date2 = val2;
            return [date1 compare:date2];
        } else {
            return NSOrderedSame;
        }
    }];
    
    [self.tableView reloadData];
}

@end
