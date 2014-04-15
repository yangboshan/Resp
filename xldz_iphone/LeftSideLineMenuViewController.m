//
// Created by sureone on 2/20/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LeftSideLineMenuViewController.h"

#import "MFSideMenu.h"
#import "Toast+UIView.h"
#import "LineViewController.h"
#import "LineListViewController.h"
#import "AccountListViewController.h"

@interface LeftSideLineMenuViewController () <LineViewControllerDelegate, UIAlertViewDelegate>
@property (nonatomic) UIAlertView *deleteAlert;
@end

@implementation LeftSideLineMenuViewController
@synthesize deleteAlert = _deleteAlert;

- (NSArray *)menuItems
{
    if (!_menuItems) {
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[MenuItem itemWithTitle:@"搜索线路" image:nil]];
        [array addObject:[MenuItem itemWithTitle:@"创建新线路" image:nil]];
        [array addObject:[MenuItem itemWithTitle:@"编辑当前线路" image:nil]];
        [array addObject:[MenuItem itemWithTitle:@"删除当前线路" image:nil]];
        [array addObject:[MenuItem itemWithTitle:@"我的关注" image:nil]];
        [array addObject:[MenuItem itemWithTitle:@"编辑用户" image:nil]];
        
        _menuItems = array;
    }
    return _menuItems;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.row) {
        case 0: {
            LineListViewController *controller = [[LineListViewController alloc] init];
            controller.lineArray = [[[XLModelDataInterface testData] queryAllLines] mutableCopy];
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 1: {
            LineViewController *controller = [[LineViewController alloc] init];
            controller.createDelegate = self;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 2: {
            XLViewDataLine *line = [XLModelDataInterface testData].currentLine;
            if (!line) {
                [self.view makeToast:@"请先选择当前线路"];
                return;
            }
            LineViewController *controller = [[LineViewController alloc] init];
            controller.lineInfo = line;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 3: {
            XLViewDataLine *line = [XLModelDataInterface testData].currentLine;
            if (!line) {
                [self.view makeToast:@"请先选择当前线路"];
                return;
            }
            [self.deleteAlert show];
            break;
        }
        case 4: {
            LineListViewController *controller = [[LineListViewController alloc] initWithType:LineListTypeeSwitch];
            NSArray *all = [[XLModelDataInterface testData] queryAllLines];
            NSMutableArray * array = [NSMutableArray array];
            for (XLViewDataLine *line in all) {
                if (line.attention) {
                    [array addObject:line];
                }
            }
            controller.lineArray = array;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        case 5: {
            XLViewDataLine *line = [XLModelDataInterface testData].currentLine;
            if (!line) {
                [self.view makeToast:@"请先选择当前线路"];
                return;
            }
            AccountListViewController *controller = [[AccountListViewController alloc] initWithType:AccountListTypeEdit];
            controller.line = line;
            [self.navigationController pushViewController:controller animated:YES];
            break;
        }
        default:
            break;
    }

    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}

- (void)lineViewController:(LineViewController *)controller onCreateLine:(XLViewDataLine *)line
{
    [[XLModelDataInterface testData] createLine:line];
    
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
            XLViewDataLine *line = [XLModelDataInterface testData].currentLine;
            NSArray *allLines = [[XLModelDataInterface testData] queryAllLines];
            XLViewDataLine *next;
            BOOL found = NO;
            for (XLViewDataLine *item in allLines) {
                if (line.attention) {
                    if ([item isEqual:line]) {
                        found = YES;
                    } else if (!found) {
                        next = item;
                    } else {
                        next = item;
                        break;
                    }
                    
                }
            }
            [XLModelDataInterface testData].currentLine = next;
            [[XLModelDataInterface testData] deleteLine:line.lineId];
        }
    }
}

@end