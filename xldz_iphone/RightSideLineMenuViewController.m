//
// Created by sureone on 2/20/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "RightSideLineMenuViewController.h"

#import "MFSideMenu.h"
@implementation RightSideLineMenuViewController

- (NSArray *)menuItems
{
    if (!_menuItems) {
        NSMutableArray *array = [NSMutableArray array];
        [array addObject:[MenuItem itemWithTitle:@"基本情况" image:nil]];
        
        _menuItems = array;
    }
    return _menuItems;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
}
@end