//
//  TestPointCreateViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-22.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"

@protocol TestPointCreateViewControllerDelegate;

@interface TestPointCreateViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UIButton  *okBtn;

@property (nonatomic,assign) id <TestPointCreateViewControllerDelegate> createDelegate;

@end


@protocol TestPointCreateViewControllerDelegate

@required
- (void)testPointCreateViewController:(TestPointCreateViewController *)controller onCreatePoint:(XLViewDataTestPoint *)point;

@end