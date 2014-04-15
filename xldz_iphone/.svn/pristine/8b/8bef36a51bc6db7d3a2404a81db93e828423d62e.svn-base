//
//  LeftSideUserMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "LeftSideUserMenuViewController.h"

#import "AccountViewController.h"
#import "AccountListViewController.h"
#import "AccountAttentionListViewController.h"
#import "AccountAddDeviceViewController.h"
#import "AccountAddTestPointViewController.h"
#import "SumGroupListViewController.h"
#import "AccountSumGroupViewController.h"

#import "Toast+UIView.h"
#import "MFSideMenu.h"

#import "XLModelDataInterface.h"

@interface LeftSideUserMenuViewController () <AccountViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic) UIAlertView *deleteAlert;
@end

@implementation LeftSideUserMenuViewController
@synthesize deleteAlert = _deleteAlert;

- (NSArray *)menuItems
{
    if (!_menuItems) {
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[MenuItem itemWithTitle:@"搜索用户" image:@"icon_analysis_report"]];
        [array addObject:[MenuItem itemWithTitle:@"创建新用户" image:@"icon_new_user"]];
        [array addObject:[MenuItem itemWithTitle:@"删除当前用户" image:@"icon_remove_user"]];
        [array addObject:[MenuItem itemWithTitle:@"编辑当前用户" image:@"icon_edit_user"]];
        [array addObject:[MenuItem itemWithTitle:@"我的关注" image:@"icon_switch_user"]];
        [array addObject:[MenuItem itemWithTitle:@"编辑用户设备" image:@"icon_analysis_report"]];
        [array addObject:[MenuItem itemWithTitle:@"编辑用户测量点" image:@"icon_analysis_report"]];
        [array addObject:[MenuItem itemWithTitle:@"编辑用户总加组" image:@"icon_analysis_report"]];
        
        _menuItems = array;
    }
    return _menuItems;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            AccountListViewController *controller = [[AccountListViewController alloc] initWithType:AccountListTypeEdit];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 1: {
            AccountViewController *controller = [[AccountViewController alloc] init];
            controller.createDelegate = self;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 2: {
            XLViewDataUserBaiscInfo *user = [XLModelDataInterface testData].currentUser;
            if (!user) {
                [self.view makeToast:@"请先选择当前用户"];
                return;
            }
            [self.deleteAlert show];
            break;
        }
        case 3: {
            XLViewDataUserBaiscInfo *user = [XLModelDataInterface testData].currentUser;
            if (!user) {
                [self.view makeToast:@"请先选择当前用户"];
                return;
            }
            AccountViewController *controller = [[AccountViewController alloc] init];
            controller.userInfo = user;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 4: {
            AccountAttentionListViewController *controller = [[AccountAttentionListViewController alloc] initWithType:AccountListTypeSwitch];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 5: {
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
        case 6: {
            XLViewDataUserBaiscInfo *user = [XLModelDataInterface testData].currentUser;
            if (!user) {
                [self.view makeToast:@"请先选择当前用户"];
                return;
            }
            AccountAddTestPointViewController *controller = [[AccountAddTestPointViewController alloc] init];
            controller.userInfo = user;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 7: {
            XLViewDataUserBaiscInfo *user = [XLModelDataInterface testData].currentUser;
            if (!user) {
                [self.view makeToast:@"请先选择当前用户"];
                return;
            }
            SumGroupListViewController *controller = [[SumGroupListViewController alloc] init];
            controller.userInfo = user;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
    }
    
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void)accountViewController:(AccountViewController *)controller onCreateUser:(XLViewDataUserBaiscInfo *)user
{
    [[XLModelDataInterface testData] createUserBasicInfo:user];

    //[self.navigationController popViewControllerAnimated:YES];
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
            XLViewDataUserBaiscInfo *user = [XLModelDataInterface testData].currentUser;
            NSArray *allUsers = [[XLModelDataInterface testData] getAllUserBasicInfo];
            XLViewDataUserBaiscInfo *next;
            BOOL found = NO;
            for (XLViewDataUserBaiscInfo *item in allUsers) {
                if (item.attention) {
                    if ([item isEqual:user]) {
                        found = YES;
                    } else if (!found) {
                        next = item;
                    } else {
                        next = item;
                        break;
                    }
                }
            }
            [XLModelDataInterface testData].currentUser = next;
            [[XLModelDataInterface testData] deleteUserBasicInfo:user.userId];
        }
    }
}

@end
