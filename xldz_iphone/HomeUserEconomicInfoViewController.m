//
//  HomeUserEconomicInfoViewController.m
//  XLApp
//
//  Created by sureone on 2/20/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "HomeUserEconomicInfoViewController.h"
#import "Navbar.h"
#import "EconomicTableViewCell.h"
#import "XLModelDataInterface.h"
#import "TestPointEconomicDetialViewController.h"
#import "MBProgressHUD.h"

@interface HomeUserEconomicInfoViewController ()
{
    BOOL navbarHidden;
    NSArray* tpList;
}
@end

@implementation HomeUserEconomicInfoViewController



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
    // Do any additional setup after loading the view from its nib.
    self.title = @"经济性";
//    [self.navigationItem setNewTitle:@"经济性"];
//    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
//    
//    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
//    returnButtonItem.title = @"返回";
//    self.navigationItem.backBarButtonItem = returnButtonItem;
//    
//    if (IOS_VERSION_7) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTheNotify:) name:XLViewDataNotification object:nil];
    
    [self requestDataFromDevice:nil withDate:nil withUlsNo:nil];
}

- (void)requestDataFromDevice:(NSString*)testPointId withDate:(NSDate*)theDate withUlsNo:(NSString*)ulsNo
{
    
    NSMutableDictionary *notificationDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSString stringWithFormat:@"economic-tp-list"], @"xl-name",
                                            theDate, @"time",
                                            ulsNo,@"ulsNo",
                                            nil];
    
    [self showLoadingProgress];
    
    [[XLModelDataInterface testData] requestTestPointListForEconomic:notificationDic];
    
    
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
    
    NSArray* result = [resp objectForKey:@"result"];
    NSDictionary* param = [resp objectForKey:@"parameter"];
    
    if (![[param objectForKey:@"xl-name"] isEqualToString:@"economic-tp-list"]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        tpList = result;
        [self.tableView reloadData];
        [self hideLoadingProgress];
        
    });
    
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    navbarHidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = navbarHidden;
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    if (section == 0)
    //        return 1.0f;
    //    return 32.0f;
    
    return 1.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    if(tpList==nil) return 0;
    return [tpList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"EconomicInfoCell"];
    if (cell2 == nil) {
        // Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"economic_list_info_cell" bundle:nil];
        // Grab a pointer to the custom cell.
        cell2 = (EconomicTableViewCell *)temporaryController.view;
        // Release the temporary UIViewController.
        
    }

    EconomicTableViewCell* cell = (EconomicTableViewCell*)cell2;
    cell.selectionStyle=UITableViewCellSelectionStyleDefault;
    
    
    //    cell.fieldLabel.font = [UIFont boldSystemFontOfSize:12];
    //    cell.valueLabel.font = [UIFont boldSystemFontOfSize:12];
    //    cell.valueLabel.textColor = [UIColor whiteColor];
    //    cell.fieldLabel.textColor = [UIColor lightGrayColor];
    
    // Configure the cell...
    
    //    [cell setBackgroundColor:[UIColor colorWithHue:27 saturation:27 brightness:27 alpha:0]];
    

    
    NSDictionary* dict = [tpList objectAtIndex:indexPath.row];

    cell.tpName.text = [dict objectForKey:@"tpName"];
    cell.tpNo.text = [dict objectForKey:@"tpNo"];

    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath      *)indexPath;
{
    /// Here you can set also height according to your section and row
    
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TestPointEconomicDetialViewController *controller = [[TestPointEconomicDetialViewController alloc] init];

    
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    
    NSDictionary* dict = [tpList objectAtIndex:indexPath.row];
    
    controller.tpName =  [dict objectForKey:@"tpName"];
    controller.tpNo = [dict objectForKey:@"tpNo"];
    
    
    
    

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

@end
