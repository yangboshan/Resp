//
//  AccountListViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-17.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomTableViewController.h"
#import "XLModelDataInterface.h"

typedef NS_ENUM(NSUInteger, AccountListType) {
    AccountListTypeEdit = 0,
    AccountListTypeSwitch = 1,
    AccountListTypeSelect = 2
};
@protocol AccountListViewControllerDelegate;


@interface AccountListViewController : CustomTableViewController

@property (nonatomic) XLViewDataLine *line;
@property (nonatomic) NSMutableArray *userArray;
@property (nonatomic,assign) id <AccountListViewControllerDelegate> selectDelegate;;

- (id)initWithType:(AccountListType)type;

@end


@protocol AccountListViewControllerDelegate

@required
- (void)accountListViewController:(AccountListViewController *)controller onSelectUsers:(NSArray *)users;

@end
