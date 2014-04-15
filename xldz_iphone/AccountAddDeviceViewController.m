//
//  AccountAddDeviceViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-18.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "AccountAddDeviceViewController.h"

#import "Navbar.h"
#import "UIButton+Bootstrap.h"
#import "SSCheckBoxView.h"
#import "MySectionHeaderView.h"
#import "DeviceViewController.h"
#import "DeviceCreateViewController.h"


@interface AccountAddDeviceViewController () <DeviceCreateViewControllerDelegate>
{
    NSMutableArray *deviceList;
    NSMutableArray *selectedDeviceList;
}

@end

@implementation AccountAddDeviceViewController

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
    
    [self.navigationItem setNewTitle:@"用户下属设备"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    [self.button1 setTitle:@"新建设备" forState:UIControlStateNormal];
    [self.button2 setTitle:@"删除" forState:UIControlStateNormal];
    [self.button3 setTitle:@"确定" forState:UIControlStateNormal];
    [self.button4 setTitle:@"召测" forState:UIControlStateNormal];
    [self.button1 normalStyle];
    [self.button2 cancelStyle];
    [self.button3 okStyle];
    [self.button4 warningStyle];
    [self.button1 addTarget:self action:@selector(addNewDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(deleteDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3 addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [self.button4 addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self initData];
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

- (void)initData
{
    selectedDeviceList = [NSMutableArray array];
    
    NSArray *array = [[XLModelDataInterface testData] queryDevicesForUser:self.userInfo];
    deviceList = [NSMutableArray arrayWithArray:array];
    for (XLViewDataDevice *device in deviceList) {
        device.online = [[XLModelDataInterface testData] isDeviceOnline:device];
    }
    
    [self.tableView reloadData];
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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 170, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(190, 0, 70, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"状态";
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label4.textColor = [UIColor whiteColor];
    label4.backgroundColor = [UIColor clearColor];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = @"选择";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label4];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return deviceList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UIImageView *statusImg;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 170, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        statusImg = [[UIImageView alloc] initWithFrame:CGRectMake(190, 0, 70, 44)];
        statusImg.contentMode = UIViewContentModeCenter;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        
        nameLabel.tag = 551;
        statusImg.tag = 552;
        checkBox.tag = 553;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:statusImg];
        [cell.contentView addSubview:checkBox];
        
        [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        statusImg = (UIImageView *)[cell.contentView viewWithTag:552];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    }
    
    XLViewDataDevice *device = [deviceList objectAtIndex:indexPath.row];
    
    nameLabel.text = device.deviceName;
    statusImg.image = [UIImage imageNamed:(device.online ? @"wifi-icon" : @"wifi-off-icon")];
    checkBox.checked = [selectedDeviceList containsObject:device];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XLViewDataDevice *device = [deviceList objectAtIndex:indexPath.row];
    
    DeviceViewController *controller = [[DeviceViewController alloc] init];
    controller.device = device;
    
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        XLViewDataDevice *device = [deviceList objectAtIndex:indexPath.row];
        
        if (cbv.checked) {
            [selectedDeviceList addObject:device];
        } else {
            [selectedDeviceList removeObject:device];
        }
    }
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
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (IBAction)refreshData:(id)sender
{
    [self initData];
}

- (IBAction)addNewDevice:(id)sender
{
    DeviceCreateViewController *controller = [[DeviceCreateViewController alloc] init];
    controller.createDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)deleteDevice:(id)sender
{
    [[XLModelDataInterface testData] deleteDevices:selectedDeviceList];

    [deviceList removeObjectsInArray:selectedDeviceList];
    [selectedDeviceList removeAllObjects];
    [self.tableView reloadData];
}

- (void)deviceCreateViewController:(DeviceCreateViewController *)controller onCreateDevice:(XLViewDataDevice *)device
{
    [self.navigationController popViewControllerAnimated:YES];
    
    [[XLModelDataInterface testData] createDevice:device];
    device.user = self.userInfo;
    
    [deviceList addObject:device];
    [self.tableView reloadData];
}

@end
