//
//  DCParamViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-21.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"



@protocol DCParamViewControllerDelegate;


@interface DCParamViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) XLViewDataDCAnalog *dcAnalog;

@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain) IBOutlet UIView *bottomView;
@property (nonatomic, retain) IBOutlet UIButton  *editBtn;
@property (nonatomic, retain) IBOutlet UIButton  *saveBtn;
@property (nonatomic, retain) IBOutlet UIButton  *cancelBtn;

@property (nonatomic,assign) id <DCParamViewControllerDelegate> editDelegate;

@end

@protocol DCParamViewControllerDelegate

@required
- (void)dcParamViewController:(DCParamViewController *)controller onSave:(BOOL)save;

@end
