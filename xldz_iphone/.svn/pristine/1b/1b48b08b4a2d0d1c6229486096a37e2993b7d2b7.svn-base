//
//  SystemListViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SystemListViewController.h"

#import "XLModelDataInterface.h"
#import "Navbar.h"
#import "MySectionHeaderView.h"


@interface SystemListViewController ()

@end

@implementation SystemListViewController

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

	[self.navigationItem setNewTitle:@"用户列表"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.bottomView.hidden = YES;
    self.tableView.frame = CGRectUnion(self.tableView.frame, self.bottomView.frame);

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
    [self.tableView reloadData];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData
{
    NSArray *array = [[XLModelDataInterface testData] queryAllSystems];
    self.systemArray = [NSMutableArray arrayWithArray:array];
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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.text = @"名称";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.systemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor listItemBgColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 280, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.tag = 551;
        [cell.contentView addSubview:nameLabel];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
    }
    
    XLViewDataSystem *system = [self.systemArray objectAtIndex:indexPath.row];
    
    nameLabel.text = system.systemName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XLViewDataSystem *system = [self.systemArray objectAtIndex:indexPath.row];
    [XLModelDataInterface testData].currentSystem = system;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
