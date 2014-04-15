//
//  AccountAddTestPointViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "AccountAddTestPointViewController.h"

#import "Navbar.h"
#import "MySectionHeaderView.h"
#import "UIButton+Bootstrap.h"
#import "SSCheckBoxView.h"

#import "TestPointSettingViewController.h"
#import "TestPointCreateViewController.h"

@interface AccountAddTestPointViewController () <TestPointCreateViewControllerDelegate>

@property (nonatomic) NSMutableArray *testPoints;
@property (nonatomic) NSMutableArray *selectedTestPoints;

@end

@implementation AccountAddTestPointViewController

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationItem setNewTitle:@"用户测量点"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    [self.button1 setTitle:@"新建测量点" forState:UIControlStateNormal];
    [self.button2 setTitle:@"删除" forState:UIControlStateNormal];
    [self.button3 setTitle:@"确定" forState:UIControlStateNormal];
    [self.button4 setTitle:@"召测" forState:UIControlStateNormal];
    [self.button1 normalStyle];
    [self.button2 cancelStyle];
    [self.button3 okStyle];
    [self.button4 warningStyle];
    [self.button1 addTarget:self action:@selector(createTestPoint:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(deletePoint:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.button4 addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initData];
}

- (void)initData
{
    self.selectedTestPoints = [NSMutableArray array];
    
    NSArray *array = [[XLModelDataInterface testData] queryTestPointsForUser:self.userInfo];
    self.testPoints = [NSMutableArray arrayWithArray:array];
    for (XLViewDataTestPoint *point in self.testPoints) {
        point.online = point.device ? [[XLModelDataInterface testData] isDeviceOnline:point.device] : NO;
    }
    
    [self.tableView reloadData];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 70, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"状态";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 60, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"关注";
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
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UIImageView *statusImg;
    SSCheckBoxView *checkBox;
    SSCheckBoxView *checkBox2;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        statusImg = [[UIImageView alloc] initWithFrame:CGRectMake(130, 0, 70, 44)];
        statusImg.contentMode = UIViewContentModeCenter;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(200 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        checkBox2 = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                    style:kSSCheckBoxViewStyleCircle
                                                  checked:NO];
        
        nameLabel.tag = 551;
        statusImg.tag = 552;
        checkBox.tag = 553;
        checkBox2.tag = 554;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:statusImg];
        [cell.contentView addSubview:checkBox];
        [cell.contentView addSubview:checkBox2];
        
        [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
        [checkBox2 setStateChangedTarget:self selector:@selector(checkBoxViewChangedState2:)];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        statusImg = (UIImageView *)[cell.contentView viewWithTag:552];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
        checkBox2 = (SSCheckBoxView *)[cell.contentView viewWithTag:554];
    }
    
    XLViewDataTestPoint *point = [self.testPoints objectAtIndex:indexPath.row];
    
    nameLabel.text = point.pointName;
    statusImg.image = [UIImage imageNamed:(point.online ? @"wifi-icon" : @"wifi-off-icon")];
    checkBox.checked = point.attention;
    checkBox2.checked = [self.selectedTestPoints containsObject:point];
    
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
        point.attention = cbv.checked;
    }
}

- (void)checkBoxViewChangedState2:(SSCheckBoxView *)cbv
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

- (IBAction)refreshData:(id)sender
{
    [self initData];
}

- (IBAction)createTestPoint:(id)sender
{
    TestPointCreateViewController *controller = [[TestPointCreateViewController alloc] init];
    controller.createDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)deletePoint:(id)sender
{
    [[XLModelDataInterface testData] deleteTestPoints:self.selectedTestPoints];
    
    [self.testPoints removeObjectsInArray:self.selectedTestPoints];
    [self.selectedTestPoints removeAllObjects];
    [self.tableView reloadData];
}

- (void)testPointCreateViewController:(TestPointCreateViewController *)controller onCreatePoint:(XLViewDataTestPoint *)point
{
    [self.navigationController popViewControllerAnimated:YES];
    
    point.user = self.userInfo;
    [self.userInfo.defaultSumGroup.positiveTestPoints addObject:point];
    [[XLModelDataInterface testData] createTestPoint:point];
    
    [self.testPoints addObject:point];
    [self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"<#Nib name#>" bundle:nil];

    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
 
 */

@end