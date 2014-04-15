//
//  LineListViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "CustomTableViewController.h"

#import "XLModelDataInterface.h"

typedef NS_ENUM(NSUInteger, LineListType) {
    LineListTypeEdit = 0,
    LineListTypeeSwitch = 1,
    LineListTypeSelect = 2
};
@protocol LineListViewControllerDelegate;


@interface LineListViewController : CustomTableViewController

@property (nonatomic) NSMutableArray *lineArray;
@property (nonatomic) XLViewDataSystem *system;

@property (nonatomic,assign) id <LineListViewControllerDelegate> selectDelegate;

- (id)initWithType:(LineListType)type;

@end


@protocol LineListViewControllerDelegate

@required
- (void)lineListViewController:(LineListViewController *)controller onSelectLines:(NSArray *)lines;

@end