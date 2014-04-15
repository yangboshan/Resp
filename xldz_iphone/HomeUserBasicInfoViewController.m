//
//  HomeUserBasicInfoViewController.m
//  XLApp
//
//  Created by sureone on 2/18/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "HomeUserBasicInfoViewController.h"
#import "Navbar.h"
#import "XLApp-Prefix.pch"
#import "XLModelDataInterface.h"
#import "SimpleInfoTableCell.h"

@interface HomeUserBasicInfoViewController ()
{
    BOOL navbarHidden;
}
@end

@implementation HomeUserBasicInfoViewController

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
    
    
    self.title = @"基本情况";
    [self.navigationItem setNewTitle:@"基本情况"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
    returnButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = returnButtonItem;
    
    if (IOS_VERSION_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }


    //todo 测试代码
    self.userId=@"1";

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"BasicInfoCell"];
    if (cell2 == nil) {
        // Create a temporary UIViewController to instantiate the custom cell.
        UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:@"basic_list_info_cell" bundle:nil];
        // Grab a pointer to the custom cell.
        cell2 = (SimpleInfoTableCell *)temporaryController.view;
        // Release the temporary UIViewController.

    }
    
    SimpleInfoTableCell* cell = (SimpleInfoTableCell*)cell2;
    
    
//    cell.fieldLabel.font = [UIFont boldSystemFontOfSize:12];
//    cell.valueLabel.font = [UIFont boldSystemFontOfSize:12];
//    cell.valueLabel.textColor = [UIColor whiteColor];
//    cell.fieldLabel.textColor = [UIColor lightGrayColor];
    
    // Configure the cell...
    
//    [cell setBackgroundColor:[UIColor colorWithHue:27 saturation:27 brightness:27 alpha:0]];

    XLViewDataUserBaiscInfo *xlViewDataUserBaiscInfo = [[XLModelDataInterface testData] getUserBasicInfo:self.userId];



    if(xlViewDataUserBaiscInfo!=nil){
        if(indexPath.row==0){
            cell.fieldLabel.text = @"用户名称";
            cell.valueLabel.text = xlViewDataUserBaiscInfo.userName;

        }
        if(indexPath.row==1){
            cell.fieldLabel.text = @"所属线路";
            cell.valueLabel.text = xlViewDataUserBaiscInfo.line.lineName;

        }
        if(indexPath.row==2){
            cell.fieldLabel.text = @"合同容量";
            cell.valueLabel.text = xlViewDataUserBaiscInfo.capacity;

        }
        if(indexPath.row==3){
            cell.fieldLabel.text = @"地址";
            cell.valueLabel.text = xlViewDataUserBaiscInfo.address;

        }
    }
    







    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath      *)indexPath;
{
    /// Here you can set also height according to your section and row

    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    DemoViewController *demoController = [[DemoViewController alloc] initWithNibName:@"DemoViewController" bundle:nil];
    //    demoController.title = [NSString stringWithFormat:@"Demo #%d-%d", indexPath.section, indexPath.row];
    //
    //    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
    //
    //    NSArray *controllers = [NSArray arrayWithObject:demoController];
    //    navigationController.viewControllers = controllers;
    
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
