//
//  AccountAttentionListViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-25.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "AccountAttentionListViewController.h"

#import "Navbar.h"
#import "MySectionHeaderView.h"
#import "SSCheckBoxView.h"

@interface AccountAttentionListViewController ()
{
    CGFloat colWidth;
    NSArray *tableColumns;
    
    NSString *notifKey;
    NSMutableDictionary *userStaticDic;
}
@end

@implementation AccountAttentionListViewController

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
    
    colWidth = 80;
    self.ewTableView = [[EWMultiColumnTableView alloc] initWithFrame:self.tableView.bounds];
    self.ewTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.ewTableView.sectionHeaderEnabled = NO;
    self.ewTableView.backgroundColor = [UIColor blackColor];
    self.ewTableView.leftHeaderBackgroundColor = [UIColor blackColor];
    self.ewTableView.boldSeperatorLineColor = [UIColor listDividerColor];
    self.ewTableView.normalSeperatorLineColor = [UIColor listDividerColor];
    self.ewTableView.boldSeperatorLineWidth = 1.0f;
    self.ewTableView.normalSeperatorLineWidth = 1.0f;
    self.ewTableView.dataSource = self;
    
    [self.view addSubview:self.ewTableView];
    [self.tableView removeFromSuperview];
    
    tableColumns = [NSArray arrayWithObjects:@"经济性", @"安全性", @"电能质量",
                    @"额定容量", @"最大负荷", @"最小负荷", @"最大需量", @"安全运行", @"电量", @"有功损耗", @"功率因素",
                    nil];
    
    [self.ewTableView reloadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = @"我关注的用户";
    userStaticDic = [NSMutableDictionary dictionary];
    for (XLViewDataUserBaiscInfo *user in self.userArray) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             notifKey, @"xl-name",
                             user.userId, @"userId",
                             nil];
        [user queryStatistics:dic];
    }
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSDictionary *result = NotificationResult(dic);
        NSString *userId = [[dic objectForKey:@"parameter"] objectForKey:@"userId"];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [userStaticDic setObject:result forKey:userId];
            [self.ewTableView reloadData];
        });
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    
    CGRect rect = CGRectMake((colWidth - 30) / 2, 5, 30, 30);
    UILabel *block = [[UILabel alloc] initWithFrame:rect];
    block.textColor = [UIColor greenColor];
    block.font = [UIFont systemFontOfSize:14];
    block.textAlignment = NSTextAlignmentCenter;
    block.tag = 1;
    [view addSubview:block];
    
    return view;
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForCell:(UIView *)cell indexPath:(NSIndexPath *)indexPath column:(NSInteger)col {
    UILabel *block = (UILabel *)[cell viewWithTag:1];
    
    XLViewDataUserBaiscInfo *user = [self.userArray objectAtIndex:indexPath.row];
    NSDictionary *bundle = [userStaticDic objectForKey:user.userId];
    NSString *column = [tableColumns objectAtIndex:col];

    block.hidden = bundle == nil;
    if (!bundle) {
        return;
    }
    if (col >= 0 && col < 3) {//经济性
        BOOL b = [[bundle objectForKey:column] boolValue];
        block.frame = CGRectMake((colWidth - 30) / 2, 5, 30, 30);
        block.text = @"";
        block.backgroundColor = b ? [UIColor greenColor] : [UIColor redColor];
        block.layer.cornerRadius = 15;
    } else {
        NSString *val = [bundle objectForKey:column];
        block.frame = CGRectMake(0, 0, colWidth, 40);
        block.text = val;
        block.backgroundColor = [UIColor clearColor];
        block.layer.cornerRadius = 0;
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
    return self.userArray.count;
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
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 40.0f)];
    view.backgroundColor = [UIColor listItemBgColor];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(20.0f, 5.0f, 80.0f, 30.0f)];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor textWhiteColor];
    l.adjustsFontSizeToFitWidth = YES;
    UIImageView *statusImg = [[UIImageView alloc] initWithFrame:CGRectMake(100, 0, 40, 40)];
    statusImg.contentMode = UIViewContentModeCenter;
    SSCheckBoxView *checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(140 + 13, 0, 47, 40)
                                               style:kSSCheckBoxViewStyleCircle
                                             checked:NO];
    
    l.tag = 111;
    statusImg.tag = 112;
    checkBox.tag = 113;
    [view addSubview:l];
    [view addSubview:statusImg];
    [view addSubview:checkBox];
    
    [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
    
    return view;
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    UITableView *tableView = self.ewTableView.headerTblView;
    CGRect rect = [cbv convertRect:cbv.bounds toView:tableView];
    NSIndexPath *indexPath = [[tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        XLViewDataUserBaiscInfo *user = [self.userArray objectAtIndex:indexPath.row];
        
        user.attention = cbv.checked;
    }
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForHeaderCell:(UIView *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *l = (UILabel *)[cell viewWithTag:111];
    UIImageView *statusImg = (UIImageView *)[cell viewWithTag:112];
    SSCheckBoxView *checkBox = (SSCheckBoxView *)[cell viewWithTag:113];
    
    XLViewDataUserBaiscInfo *user = [self.userArray objectAtIndex:indexPath.row];
    l.text = user.userName;
    statusImg.image = [UIImage imageNamed:(user.online ? @"wifi-icon" : @"wifi-off-icon")];
    checkBox.checked = user.attention;
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
    MySectionHeaderView *view =  [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, [self heightForHeaderCellOfTableView:tableView])];
    CGRect rect = view.bounds;
    rect.origin.x = 20;
    rect.size.width = 80;
    UILabel *l = [[UILabel alloc] initWithFrame:rect];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont systemFontOfSize:14];
    l.text = @"用户名";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 40, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"状态";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(140, 0, 60, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"关注";
    [view addSubview:l];
    [view addSubview:label2];
    [view addSubview:label3];
    
    return view;
}

- (CGFloat)heightForHeaderCellOfTableView:(EWMultiColumnTableView *)tableView
{
    return 30.0f;
}

- (CGFloat)widthForHeaderCellOfTableView:(EWMultiColumnTableView *)tableView
{
    return 200.0;
}


@end
