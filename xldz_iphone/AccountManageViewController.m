//
//  AccountManageViewController.m
//  XLApp
//
//  Created by sureone on 4/1/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "AccountManageViewController.h"
#import "Navbar.h"
#import "UIButton+Bootstrap.h"
#import "MySectionHeaderView.h"
#import "DeviceViewController.h"
#import "DeviceCreateViewController.h"
#import "MBProgressHUD.h"

#import "DeviceAccountDetailViewController.h"


@interface AccountManageViewController (){
    NSMutableArray *curUserList;
}
@end

@implementation AccountManageViewController



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
    
    [self.navigationItem setNewTitle:@"权限管理"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor listDividerColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //去除UITableView中多余的separator
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    [self.addBtn successStyle];
       [self.addBtn addTarget:self action:@selector(addAccount:) forControlEvents:UIControlEventTouchUpInside];

    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTheNotify:) name:XLViewDataNotification object:nil];
    
    [self requestDataFromDevice:nil];
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

- (void)requestDataFromDevice:(NSString*)devId
{
    
    NSMutableDictionary *notificationDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSString stringWithFormat:@"device-account-list"], @"xl-name",
                                            devId, @"device-id",
                                            nil];
    
    [self showLoadingProgress];
    
    [[XLModelDataInterface testData] requestDeviceAccountList:notificationDic];
    
    
}

-(void)showLoadingProgress{
    //    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    //	[self.view addSubview:loadingView];
    //
    //	// Regiser for HUD callbacks so we can remove it from the window at the right time
    //	loadingView.delegate = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
	
    //
    //	// Show the HUD while the provided method executes in a new thread
    //	[loadingView showWhileExecuting:@selector(doTestLoad) onTarget:self withObject:nil animated:YES];
    
    
    
}

-(void)hideLoadingProgress{
    //    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    //	[self.view addSubview:loadingView];
    //
    //	// Regiser for HUD callbacks so we can remove it from the window at the right time
    //	loadingView.delegate = self;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
	
    //
    //	// Show the HUD while the provided method executes in a new thread
    //	[loadingView showWhileExecuting:@selector(doTestLoad) onTarget:self withObject:nil animated:YES];
}



- (void)handleTheNotify:(NSNotification *)notification{
    NSDictionary *resp =(NSDictionary*) notification.userInfo;
    
    NSDictionary* result = [resp objectForKey:@"result"];
    NSDictionary* param = [resp objectForKey:@"parameter"];
    
    if (![[param objectForKey:@"xl-name"] isEqualToString:@"device-account-list"]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        curUserList = [NSMutableArray arrayWithArray:[result objectForKey:@"account-list"]];
        [self hideLoadingProgress];
        [self.tableView reloadData];
        
    });
    
    
}

- (void)initData
{
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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 230, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"账号";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(280, 0, 40, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font=[UIFont systemFontOfSize:12];
//    label2.textColor=[UIColor yellowColor];
    label2.text = @"控制";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(240, 0, 40, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.font=[UIFont systemFontOfSize:12];
//        label3.textColor=[UIColor yellowColor];
    label3.text = @"设置";
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 40, 30)];
    label4.textColor = [UIColor whiteColor];
    label4.backgroundColor = [UIColor clearColor];
    label4.font=[UIFont systemFontOfSize:12];
//    label4.textColor=[UIColor yellowColor];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = @"查询";
    
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
    return curUserList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *queryLabel;
    UILabel *setupLabel;
    UILabel *operationLabel;
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 230, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.tag = 551;
        [cell.contentView addSubview:nameLabel];
        
        
        operationLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 0, 40, 44)];
        operationLabel.textColor = [UIColor textWhiteColor];
        operationLabel.backgroundColor = [UIColor clearColor];
        operationLabel.textAlignment = NSTextAlignmentCenter;
        operationLabel.font=[UIFont systemFontOfSize:12];
        operationLabel.tag = 552;
        [cell.contentView addSubview:operationLabel];
        
        
        setupLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 0, 40, 44)];
        setupLabel.textColor = [UIColor textWhiteColor];
        setupLabel.backgroundColor = [UIColor clearColor];
        setupLabel.textAlignment = NSTextAlignmentCenter;
        setupLabel.font=[UIFont systemFontOfSize:12];
        setupLabel.tag = 553;
        [cell.contentView addSubview:setupLabel];
        
        

        
        queryLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 40, 44)];
        queryLabel.textColor = [UIColor textWhiteColor];
        queryLabel.backgroundColor = [UIColor clearColor];
        queryLabel.textAlignment = NSTextAlignmentCenter;
        queryLabel.font=[UIFont systemFontOfSize:12];
        queryLabel.tag = 554;
        [cell.contentView addSubview:queryLabel];
        

    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        operationLabel = (UILabel *)[cell.contentView viewWithTag:552];
        setupLabel = (UILabel *)[cell.contentView viewWithTag:553];
        queryLabel = (UILabel *)[cell.contentView viewWithTag:554];

    }
    
    
    NSDictionary* dict = [curUserList objectAtIndex:indexPath.row];

    nameLabel.text = [dict objectForKey:@"name"];
    
    if([[dict objectForKey:@"query"] isEqualToString:@"YES"]){
            queryLabel.text=@"√";
        queryLabel.textColor=[UIColor greenColor];
    }else{
             queryLabel.text=@"×";
                queryLabel.textColor=[UIColor redColor];
    }
    if([[dict objectForKey:@"setup"] isEqualToString:@"YES"]){
        setupLabel.text=@"√";
        setupLabel.textColor=[UIColor greenColor];
    }else{
        setupLabel.text=@"×";
         setupLabel.textColor=[UIColor redColor];
    }
    if([[dict objectForKey:@"operation"] isEqualToString:@"YES"]){
        operationLabel.text=@"√";
        operationLabel.textColor=[UIColor greenColor];
    }else{
        operationLabel.text=@"×";
         operationLabel.textColor=[UIColor redColor];
    }
//    statusImg.image = [UIImage imageNamed:(device.online ? @"wifi-icon" : @"wifi-off-icon")];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    DeviceAccountDetailViewController *controller = [[DeviceAccountDetailViewController alloc] init];
    
    
    NSDictionary* dict = [curUserList objectAtIndex:indexPath.row];
    
    
    controller.theTitle=[dict objectForKey:@"name"];
    controller.editMode=@"edit";
    controller.accountDict=dict;
    
    [self.navigationController pushViewController:controller animated:YES];
    
    
    

    
    
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

- (IBAction)addAccount:(id)sender
{
    
    
    DeviceAccountDetailViewController *controller = [[DeviceAccountDetailViewController alloc] init];
    
    controller.theTitle=@"新建账号";
    controller.editMode=@"new";
    
    
    [self.navigationController pushViewController:controller animated:YES];
    

}





@end
