//
//  DeviceDCParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceDCParamViewController.h"

#import "SSCheckBoxView.h"
#import "UIButton+Bootstrap.h"
#import "MySectionHeaderView.h"
#import "MJRefresh.h"

#import "DCParamViewController.h"

@interface DeviceDCParamViewController () <DCParamViewControllerDelegate>
{
    MJRefreshHeaderView *refreshHeader;
    NSString *notifKey;
}

@property (nonatomic) NSArray *dcParams;
@property (nonatomic) NSMutableArray *selectedParams;

@end

@implementation DeviceDCParamViewController

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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor listDividerColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //去除UITableView中多余的separator
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    [self addHeader];
    
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
    //[self.button1 addTarget:self action:@selector(presetRemoteControls:) forControlEvents:UIControlEventTouchUpInside];
    //[self.button2 addTarget:self action:@selector(executeRemoteControls:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3 addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    self.selectedParams = [NSMutableArray array];
    notifKey = [NSString stringWithFormat:@"设备%@-直流模拟量", self.device.deviceId];
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshHeader beginRefreshing];
    });
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryDCAnalogs:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader endRefreshing];
            
            [self.selectedParams removeAllObjects];
            self.dcParams = result;
            [self.tableView reloadData];
        });
    }
}

- (void)dealloc
{
    [refreshHeader free];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addHeader
{
    __unsafe_unretained DeviceDCParamViewController *vc = self;
    refreshHeader = [MJRefreshHeaderView header];
    refreshHeader.scrollView = self.tableView;
    refreshHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc performSelector:@selector(initData) withObject:nil];
    };
}
//
//- (void)doneWithView:(MJRefreshBaseView *)refreshView
//{
//    [self refreshData:nil];
//    [refreshView endRefreshing];
//}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 240, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"路数";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"选择";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label3];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dcParams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DCAnalogCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor listItemBgColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 260, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        
        nameLabel.tag = 551;
        checkBox.tag = 553;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:checkBox];
        
        [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    }
    
    XLViewDataDCAnalog *dc = [self.dcParams objectAtIndex:indexPath.row];
    nameLabel.text = dc.name;
    checkBox.checked = [self.selectedParams containsObject:dc];
    
    return cell;
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        XLViewDataDCAnalog *dc = [self.dcParams objectAtIndex:indexPath.row];
        
        if (cbv.checked) {
            [self.selectedParams addObject:dc];
        } else {
            [self.selectedParams removeObject:dc];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XLViewDataDCAnalog *dc = [self.dcParams objectAtIndex:indexPath.row];
    
    DCParamViewController *controller = [[DCParamViewController alloc] init];
    controller.dcAnalog = dc;
    controller.editDelegate = self;
    
    [self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    controller.view.frame = self.view.bounds;
    
    
    [UIView beginAnimations:@"animationID"context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    [self.view addSubview:controller.view];
    [UIView commitAnimations];
}

- (void)dcParamViewController:(DCParamViewController *)controller onSave:(BOOL)save
{
    [controller willMoveToParentViewController:nil];
    [controller removeFromParentViewController];
    
    [UIView beginAnimations:@"animationID"context:nil];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.view cache:YES];
    [controller.view removeFromSuperview];
    [UIView commitAnimations];
    
}

- (IBAction)refreshData:(id)sender
{
    [self initData];
    //[self.tableView reloadData];
}
@end