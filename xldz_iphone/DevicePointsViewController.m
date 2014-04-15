//
//  DevicePointsViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DevicePointsViewController.h"

#import "SSCheckBoxView.h"
#import "UIButton+Bootstrap.h"
#import "MySectionHeaderView.h"
#import "MJRefresh.h"

#import "TestPointSettingViewController.h"
#import "TestPointCreateViewController.h"
#import "TestPointListViewController.h"


@interface DevicePointsViewController () <TestPointListViewControllerDelegate>
{
    MJRefreshHeaderView *refreshHeader;
}

@property (nonatomic) NSMutableArray *testPoints;
@property (nonatomic) NSMutableArray *selectedTestPoints;

@end

@implementation DevicePointsViewController

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
    
    [self addHeader];
    
    self.button1.frame = CGRectMake(8, 10, 70, 30);
    self.button2.frame = CGRectMake(86, 10, 70, 30);
    self.button3.frame = CGRectMake(164, 10, 70, 30);
    self.button4.frame = CGRectMake(242, 10, 70, 30);
    [self.button1 setTitle:@"添加" forState:UIControlStateNormal];
    [self.button2 setTitle:@"删除" forState:UIControlStateNormal];
    [self.button3 setTitle:@"下发" forState:UIControlStateNormal];
    [self.button4 setTitle:@"召测" forState:UIControlStateNormal];
    [self.button1 okStyle];
    [self.button2 cancelStyle];
    [self.button3 warningStyle];
    [self.button4 normalStyle];
    [self.button1 addTarget:self action:@selector(addPoints:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(deletePoints:) forControlEvents:UIControlEventTouchUpInside];
    [self.button4 addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
    
    self.selectedTestPoints = [NSMutableArray array];
    dispatch_async(dispatch_get_main_queue(), ^{
        [refreshHeader beginRefreshing];
    });
}

- (void)initData {
    NSArray *array = [[XLModelDataInterface testData] queryTestPointsForDevice:self.device];
    BOOL online = [[XLModelDataInterface testData] isDeviceOnline:self.device];
    for (XLViewDataTestPoint *point in array) {
        point.online = online;
    }
    
    [self.selectedTestPoints removeAllObjects];
    self.testPoints = [NSMutableArray arrayWithArray:array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addHeader
{
    __unsafe_unretained DevicePointsViewController *vc = self;
    refreshHeader = [MJRefreshHeaderView header];
    refreshHeader.scrollView = self.tableView;
    refreshHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc refreshData:nil];
        [vc performSelector:@selector(doneWithView:) withObject:refreshView];
    };
}

- (void)doneWithView:(MJRefreshBaseView *)refreshView
{
    [refreshHeader endRefreshing];
}

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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    //label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 70, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"测量点号";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(190, 0, 70, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"状态";
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label4.textColor = [UIColor whiteColor];
    label4.backgroundColor = [UIColor clearColor];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = @"选择";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label3];
    [view addSubview:label4];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.testPoints.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TestPointCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *idLabel;
    UIImageView *statusImg;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor listItemBgColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        idLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 70, 44)];
        idLabel.textColor = [UIColor textWhiteColor];
        idLabel.backgroundColor = [UIColor clearColor];
        idLabel.textAlignment = NSTextAlignmentCenter;
        statusImg = [[UIImageView alloc] initWithFrame:CGRectMake(190, 0, 70, 44)];
        statusImg.contentMode = UIViewContentModeCenter;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        
        nameLabel.tag = 551;
        idLabel.tag = 552;
        statusImg.tag = 553;
        checkBox.tag = 554;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:idLabel];
        [cell.contentView addSubview:statusImg];
        [cell.contentView addSubview:checkBox];

        [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        idLabel = (UILabel *)[cell.contentView viewWithTag:552];
        statusImg = (UIImageView *)[cell.contentView viewWithTag:553];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:554];
    }
    
    XLViewDataTestPoint *point = [self.testPoints objectAtIndex:indexPath.row];
    
    nameLabel.text = point.pointName;
    idLabel.text = [NSString stringWithFormat:@"%@号", point.pointNo];
    statusImg.image = [UIImage imageNamed:(point.online ? @"wifi-icon" : @"wifi-off-icon")];
    checkBox.checked = [self.selectedTestPoints containsObject:point];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XLViewDataTestPoint *point = [self.testPoints objectAtIndex:indexPath.row];
    
    TestPointSettingViewController *controller = [[TestPointSettingViewController alloc] init];
    controller.testPoint = point;
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        XLViewDataTestPoint *point = [self.testPoints objectAtIndex:indexPath.row];
        
        if (cbv.checked) {
            [self.selectedTestPoints addObject:point];
        } else {
            [self.selectedTestPoints removeObject:point];
        }
    }
}


//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    SSCheckBoxView *checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:554];
//    checkBox.checked = YES;
//}
//
//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    SSCheckBoxView *checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:554];
//    checkBox.checked = NO;
//}

- (IBAction)addPoints:(id)sender
{
    TestPointListViewController *controller = [[TestPointListViewController alloc] init];
    controller.userInfo = self.device.user;
    controller.device = self.device;
    controller.selectDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)testPointListViewController:(TestPointListViewController *)controller didSelectedPoints:(NSArray *)points
{
    [self.navigationController popViewControllerAnimated:YES];
    
    for (XLViewDataTestPoint *point in points) {
        point.device = self.device;
        
        if (![self.testPoints containsObject:point]) {
            [self.testPoints addObject:point];
        }
    }
    [self.tableView reloadData];
}

- (IBAction)deletePoints:(id)sender
{
    [[XLModelDataInterface testData] deleteTestPoints:self.selectedTestPoints];
    
    [self.testPoints removeObjectsInArray:self.selectedTestPoints];
    [self.selectedTestPoints removeAllObjects];
    [self.tableView reloadData];
}

- (IBAction)refreshData:(id)sender
{
    [self initData];
    [self.tableView reloadData];
}

@end
