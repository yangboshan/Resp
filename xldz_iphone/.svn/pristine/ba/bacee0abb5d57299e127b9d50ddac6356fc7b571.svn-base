//
//  AccountViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-17.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"
@class SSCheckBoxView;

@protocol AccountViewControllerDelegate;

@interface AccountViewController : UIViewController

@property (nonatomic) XLViewDataUserBaiscInfo *userInfo;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView       *container1;
@property (nonatomic, retain) IBOutlet UIView       *container2;
@property (nonatomic, retain) IBOutlet UIView       *container3;

@property (nonatomic, retain) IBOutlet UITextField *userNameLabel;
@property (nonatomic, retain) IBOutlet UITextField *userLineLabel;
@property (nonatomic, retain) IBOutlet UITextField *userProfessionLabel;
@property (nonatomic, retain) IBOutlet UITextField *userNoLabel;
@property (nonatomic, retain) IBOutlet UITextView  *infoTextView;

@property (nonatomic, retain) IBOutlet UIButton  *addDeviceBtn;
@property (nonatomic, retain) IBOutlet UIButton  *addMeasurePointBtn;
@property (nonatomic, retain) IBOutlet UIButton  *editGroupBtn;
@property (nonatomic, retain) IBOutlet SSCheckBoxView  *attentionCheckBox;

@property (nonatomic, retain) IBOutlet UIButton  *okBtn;
@property (nonatomic, retain) IBOutlet UIButton  *cancelBtn;

@property (nonatomic,assign) id <AccountViewControllerDelegate> createDelegate;

@end


@protocol AccountViewControllerDelegate

@required
- (void)accountViewController:(AccountViewController *)controller onCreateUser:(XLViewDataUserBaiscInfo *)user;

@end