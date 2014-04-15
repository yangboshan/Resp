//
//  SwitchSOEEventsViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SwitchSOEEventsViewController.h"

#import "MySectionHeaderView.h"

@interface SwitchSOEEventsViewController ()

@end

@implementation SwitchSOEEventsViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.text = @"序号";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"名称";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 80, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"事件状态";
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(200, 0, 120, 30)];
    label4.textColor = [UIColor whiteColor];
    label4.backgroundColor = [UIColor clearColor];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = @"发生时间";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label3];
    [view addSubview:label4];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SOECell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *label1, *label2, *label3, *label4;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        
        label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        label1.textColor = [UIColor textWhiteColor];
        label1.backgroundColor = [UIColor clearColor];
        label1.textAlignment = NSTextAlignmentCenter;
        label1.adjustsFontSizeToFitWidth = YES;
        label2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 80, 44)];
        label2.textColor = [UIColor textWhiteColor];
        label2.backgroundColor = [UIColor clearColor];
        label2.textAlignment = NSTextAlignmentCenter;
        label2.adjustsFontSizeToFitWidth = YES;
        label3 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 80, 44)];
        label3.textColor = [UIColor textWhiteColor];
        label3.backgroundColor = [UIColor clearColor];
        label3.textAlignment = NSTextAlignmentCenter;
        label3.adjustsFontSizeToFitWidth = YES;
        label4 = [[UILabel alloc] initWithFrame:CGRectMake(205, 0, 110, 44)];
        label4.textColor = [UIColor textWhiteColor];
        label4.backgroundColor = [UIColor clearColor];
        label4.textAlignment = NSTextAlignmentCenter;
        label4.font = [UIFont systemFontOfSize:14];
        label4.numberOfLines = 2;
        label4.adjustsFontSizeToFitWidth = YES;
        
        label1.tag = 551;
        label2.tag = 552;
        label3.tag = 553;
        label4.tag = 554;
        
        [cell.contentView addSubview:label1];
        [cell.contentView addSubview:label2];
        [cell.contentView addSubview:label3];
        [cell.contentView addSubview:label4];
    } else {
        label1 = (UILabel *)[cell.contentView viewWithTag:551];
        label2 = (UILabel *)[cell.contentView viewWithTag:552];
        label3 = (UILabel *)[cell.contentView viewWithTag:553];
        label4 = (UILabel *)[cell.contentView viewWithTag:554];
    }
    
    NSDictionary *event = [events objectAtIndex:indexPath.row];
    label1.text = [event objectForKey:@"序号"];
    label2.text = [event objectForKey:@"名称"];
    label3.text = [event objectForKey:@"事件状态"];
    label4.text = [event objectForKey:@"发生时间"];
    
    return cell;
}

@end
