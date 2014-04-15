//
//  TabMoreViewController.m
//  XLApp
//
//  Created by sureone on 2/16/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "TabMoreViewController.h"

#import "AccountManageViewController.h"
#import "AppSettingViewController.h"
#import "DocumentSyncViewController.h"
#import "Navbar.h"

@interface TabMoreViewController ()

@end

@implementation TabMoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"更多";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"more_icon";
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setNewTitle:@"更多"];
    
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] ;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell setBackgroundColor:[UIColor blackColor]];
    [cell.textLabel setTextColor:[UIColor lightGrayColor]];
    
    if(indexPath.row==0)
    {
        cell.textLabel.text = @"应用设置";
        cell.imageView.image = [UIImage imageNamed:@"gear.png"];
    }
    
    
    if(indexPath.row==1)
    {
        cell.textLabel.text = @"权限管理";
        cell.imageView.image = [UIImage imageNamed:@"account-man.png"];
    }
    
    
    
    if(indexPath.row==2)
    {
        cell.textLabel.text = @"档案同步";
        cell.imageView.image = [UIImage imageNamed:@"sync3.png"];
    }

    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath      *)indexPath;
{
    /// Here you can set also height according to your section and row
    
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row==1){
    
        AccountManageViewController *controller = [[AccountManageViewController alloc] init];
        
        [self.navigationController pushViewController:controller animated:YES];
    }else if(indexPath.row==0){
        
        AppSettingViewController *controller = [[AppSettingViewController alloc] init];
        
        [self.navigationController pushViewController:controller animated:YES];
    }else if(indexPath.row==2){
        
        DocumentSyncViewController *controller = [[DocumentSyncViewController alloc] init];
        
        [self.navigationController pushViewController:controller animated:YES];
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


@end
