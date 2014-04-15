//
//  LineViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-26.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"
#import "SSCheckBoxView.h"


@protocol LineViewControllerDelegate;

@interface LineViewController : UIViewController

@property (nonatomic) XLViewDataLine *lineInfo;

@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property (nonatomic, retain) IBOutlet UIView       *container1;
@property (nonatomic, retain) IBOutlet UIView       *container2;
@property (nonatomic, retain) IBOutlet UIView       *container3;

@property (nonatomic, retain) IBOutlet UITextField *lineNameLabel;
@property (nonatomic, retain) IBOutlet UITextField *systemLabel;
@property (nonatomic, retain) IBOutlet UITextField *lineNoLabel;
@property (nonatomic, retain) IBOutlet UITextView  *lineInfoTextView;

@property (nonatomic, retain) IBOutlet UIButton  *addUserBtn;
@property (nonatomic, retain) IBOutlet UIButton  *createUserBtn;
@property (nonatomic, retain) IBOutlet SSCheckBoxView  *attentionCheckBox;

@property (nonatomic, retain) IBOutlet UIButton  *okBtn;
@property (nonatomic, retain) IBOutlet UIButton  *cancelBtn;


@property (nonatomic,assign) id <LineViewControllerDelegate> createDelegate;

@end


@protocol LineViewControllerDelegate

@required
- (void)lineViewController:(LineViewController *)controller onCreateLine:(XLViewDataLine *)line;

@end
