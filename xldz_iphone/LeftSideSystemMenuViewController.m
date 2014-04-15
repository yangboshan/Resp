//
// Created by sureone on 2/20/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LeftSideSystemMenuViewController.h"

#import "MFSideMenu.h"
#import "SystemViewController.h"
#import "SystemListViewController.h"
#import "Toast+UIView.h"
#import "LineListViewController.h"

@interface LeftSideSystemMenuViewController () <UIAlertViewDelegate>
@property (nonatomic) UIAlertView *deleteAlert;
@end

@implementation LeftSideSystemMenuViewController
@synthesize deleteAlert = _deleteAlert;

- (NSArray *)menuItems
{
    if (!_menuItems) {
        NSMutableArray *array = [NSMutableArray array];
//        [array addObject:[MenuItem itemWithTitle:@"切换系统" image:nil]];
//        [array addObject:[MenuItem itemWithTitle:@"创建新系统" image:nil]];
        [array addObject:[MenuItem itemWithTitle:@"编辑当前系统" image:nil]];
//        [array addObject:[MenuItem itemWithTitle:@"删除当前系统" image:nil]];
        [array addObject:[MenuItem itemWithTitle:@"编辑系统线路" image:nil]];
        
        _menuItems = array;
    }
    return _menuItems;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
//        case 0: {
//            SystemListViewController *controller = [[SystemListViewController alloc] init];
//            [self.navigationController pushViewController:controller animated:YES];
//            break;
//        }
//        case 1: {
//            SystemViewController *controller = [[SystemViewController alloc] init];
//            [self.navigationController pushViewController:controller animated:YES];
//            break;
//        }
        case 0: {
            XLViewDataSystem *system = [XLModelDataInterface testData].currentSystem;
            if (!system) {
                [self.view makeToast:@"请先选择当前系统"];
                return;
            }
            SystemViewController *controller = [[SystemViewController alloc] init];
            controller.systemInfo = system;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
//        case 3: {
//            XLViewDataSystem *system = [XLModelDataInterface testData].currentSystem;
//            if (!system) {
//                [self.view makeToast:@"请先选择当前系统"];
//                return;
//            }
//            [self.deleteAlert show];
//            break;
//        }
        case 1: {
            XLViewDataSystem *system = [XLModelDataInterface testData].currentSystem;
            if (!system) {
                [self.view makeToast:@"请先选择当前系统"];
                return;
            }
            LineListViewController *controller = [[LineListViewController alloc] initWithType:LineListTypeEdit];
            controller.system = system;
            controller.lineArray = [[[XLModelDataInterface testData] queryLinesForSystem:system] mutableCopy];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
    }


    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (UIAlertView *)deleteAlert
{
    if (!_deleteAlert) {
        _deleteAlert = [[UIAlertView alloc]initWithTitle:@"提示"
                                                 message:@"确认删除"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定", nil];
    }
    return _deleteAlert;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == self.deleteAlert) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            XLViewDataSystem *system = [XLModelDataInterface testData].currentSystem;
            NSArray *allSystems = [[XLModelDataInterface testData] queryAllSystems];
            XLViewDataSystem *next;
            BOOL found = NO;
            for (XLViewDataSystem *item in allSystems) {
                if ([item isEqual:system]) {
                    found = YES;
                } else if (!found) {
                    next = item;
                } else {
                    next = item;
                    break;
                }
            }
            [XLModelDataInterface testData].currentSystem = next;
            [[XLModelDataInterface testData] deleteSystem:system.systemId];
        }
    }
}

@end