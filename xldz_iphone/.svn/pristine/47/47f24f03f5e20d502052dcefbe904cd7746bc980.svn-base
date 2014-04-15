//
//  TabMessageViewController.m
//  XLApp
//
//  Created by sureone on 2/16/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "TabMessageViewController.h"

#import "Navbar.h"

@implementation XLSystemMessage
@end

@interface TabMessageViewController ()

@property (nonatomic, readonly) NSDateFormatter *dateFormatter;

@end

static NSString *CellIdentifier = @"Cell";

@implementation TabMessageViewController
@synthesize dateFormatter = _dateFormatter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"消息";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setNewTitle:@"系统消息"];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor listDividerColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //去除UITableView中多余的separator
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    [self.view addSubview:self.tableView];
    
    UINib *nib = [UINib nibWithNibName:@"MessageTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tabImageName
{
	return @"message_icon";
}

- (void)initData
{
    XLSystemMessage *msg1 = [[XLSystemMessage alloc] init];
    msg1.content = @"用户“新联电子”数据已同步";
    msg1.date = [NSDate date];
    XLSystemMessage *msg2 = [[XLSystemMessage alloc] init];
    msg2.content = @"用户“小网科技”数据未上传";
    msg2.date = [NSDate date];
    XLSystemMessage *msg3 = [[XLSystemMessage alloc] init];
    msg3.content = @"主站档案有更改，请下载";
    msg3.date = [NSDate date];
    XLSystemMessage *msg4 = [[XLSystemMessage alloc] init];
    msg4.content = @"本次安装设备列表";
    msg4.date = [NSDate date];
    XLSystemMessage *msg5 = [[XLSystemMessage alloc] init];
    msg5.content = @"请更新APP软件到最新版本";
    msg5.date = [NSDate date];
    
    self.messages = [NSArray arrayWithObjects:msg1, msg2, msg3, msg4, msg5, nil];
    
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.backgroundColor = [UIColor listItemBgColor];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:551];
    UILabel *timeLabel = (UILabel *)[cell.contentView viewWithTag:552];
    titleLabel.textColor = [UIColor textWhiteColor];
    
    XLSystemMessage *msg = [self.messages objectAtIndex:indexPath.row];
    titleLabel.text = msg.content;
    timeLabel.text = [self.dateFormatter stringFromDate:msg.date];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
