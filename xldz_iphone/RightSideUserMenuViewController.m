//
//  RightSideUserMenuViewController.m
//  XLApp
//
//  Created by sureone on 2/17/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "RightSideUserMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "HomeUserBasicInfoViewController.h"
#import "MFSideMenu.h"
#import "Toast+UIView.h"
#import "HomeUserAnalysisReportViewController.h"
#import "HomeUserIndustryCompareViewController.h"
#import "AccountAddDeviceViewController.h"
#import "DataCatalogViewController.h"
#import "StartSyncAlertView.h"

#import "XLModelDataInterface.h"

#import "WebSVGViewController.h"

@interface RightSideUserMenuViewController ()
{
    float percent;
}

@end

@implementation RightSideUserMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    percent = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewUpdatePercent object:nil];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    NSNumber *num = [dic objectForKey:@"percent"];
    percent = [num floatValue];
    
    MenuItem *item = [self.menuItems objectAtIndex:6];
    NSString *str = [NSString stringWithFormat:@"更新用户数据%d％", (int)(percent * 100)];
    if (percent == 1) {
        str = @"更新用户数据";
    }
    item.title = str;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)menuItems
{
    if (!_menuItems) {
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[MenuItem itemWithTitle:@"基本情况" image:@"icon_basic_info"]];
        [array addObject:[MenuItem itemWithTitle:@"分析报告" image:@"icon_analysis_report"]];
        [array addObject:[MenuItem itemWithTitle:@"行业对标" image:@"icon_industry_compare"]];
        [array addObject:[MenuItem itemWithTitle:@"相关设备" image:@"icon_related_device"]];
        [array addObject:[MenuItem itemWithTitle:@"当前测量点" image:@"icon_analysis_report"]];
        [array addObject:[MenuItem itemWithTitle:@"接线图" image:@"icon_analysis_report"]];
        
        
        [array addObject:[MenuItem itemWithTitle:@"更新用户数据" image:@"icon_analysis_report"]];
        
        _menuItems = array;
    }
    return _menuItems;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            [[self navigationController] setNavigationBarHidden:YES animated:YES];
            HomeUserBasicInfoViewController *controller = [[HomeUserBasicInfoViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 1: {
            HomeUserAnalysisReportViewController *controller = [[HomeUserAnalysisReportViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 2: {
            HomeUserIndustryCompareViewController *controller = [[HomeUserIndustryCompareViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 3: {
            XLViewDataUserBaiscInfo *user = [XLModelDataInterface testData].currentUser;
            if (!user) {
                [self.view makeToast:@"请先选择当前用户"];
                return;
            }
            AccountAddDeviceViewController *controller = [[AccountAddDeviceViewController alloc] init];
            controller.userInfo = user;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 4: {
            id obj = [XLModelDataInterface testData].currentUser.currentTestPointOrGroup;
            if (!obj || ![obj isKindOfClass:[XLViewDataTestPoint class]]) {
                [self.view makeToast:@"请先选择测量点"];
                return;
            }
            XLViewDataTestPoint *point = obj;
            DataCatalogViewController *controller = [[DataCatalogViewController alloc] init];
            controller.device = point.device;
            controller.currentPoint = point;
            controller.realtime = [[XLModelDataInterface testData] isDeviceOnline:point.device];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 5: {
            WebSVGViewController *controller = [[WebSVGViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];

            //            CircuitDiagramViewController *controller = [[CircuitDiagramViewController alloc] init];
            //            [self.navigationController pushViewController:controller animated:YES];
            //
            //            controller.detailItem = @"strokes";
            
            break;
        }
        case 6: {
            StartSyncAlertView *alertView = [[StartSyncAlertView alloc] init];
            [alertView show];
            break;
        }
        default:
            break;
    }

    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}



@end
