//
//  MenuTableViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "MenuTableViewController.h"


@implementation MenuItem

+ (MenuItem *)itemWithTitle:(NSString *)title image:(NSString *)image
{
    MenuItem *item = [[MenuItem alloc] init];
    item.title = title;
    item.iconName = image;
    return item;
}

@end



@interface MenuTableViewController ()

@end

@implementation MenuTableViewController
@synthesize menuItems = _menuItems;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor colorWithRed:51/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSArray *)menuItems
{
    return _menuItems;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setBackgroundColor:[UIColor colorWithRed:33 green:33 blue:0 alpha:0]];
        cell.textLabel.textColor=[UIColor lightGrayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:15];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        
        
        UIImageView *ivsep = [[UIImageView alloc]initWithFrame:CGRectMake(0, cell.frame.size.height-2, cell.frame.size.width, 2)];
        ivsep.image=[UIImage imageNamed:@"menu-sep"];
        
        [cell.contentView addSubview:ivsep];
    }
    
    MenuItem *item = [self.menuItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    [cell.imageView setImage:[UIImage imageNamed:item.iconName]];

    
    return cell;
}

@end
