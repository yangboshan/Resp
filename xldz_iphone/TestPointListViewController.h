//
//  TestPointListViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-22.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CustomTableViewController.h"
#import "XLModelDataInterface.h"

@protocol TestPointListViewControllerDelegate;

@interface TestPointListViewController : CustomTableViewController

@property (nonatomic) XLViewDataUserBaiscInfo *userInfo;
@property (nonatomic) XLViewDataDevice *device;

@property (nonatomic,assign) id <TestPointListViewControllerDelegate> selectDelegate;

@end


@protocol TestPointListViewControllerDelegate

@required
- (void)testPointListViewController:(TestPointListViewController *)controller didSelectedPoints:(NSArray *)points;

@end