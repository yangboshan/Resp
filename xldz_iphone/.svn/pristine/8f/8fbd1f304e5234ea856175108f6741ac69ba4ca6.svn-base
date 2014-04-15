//
//  AccountViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-17.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "AccountViewController.h"

#import "Navbar.h"
#import "JMWhenTapped.h"
#import "UIButton+Bootstrap.h"
#import "SSCheckBoxView.h"
#import "LeveyPopListView.h"
#import "AccountAddDeviceViewController.h"
#import "AccountSumGroupViewController.h"
#import "AccountAddTestPointViewController.h"
#import "Toast+UIView.h"

@interface AccountViewController () <UITextFieldDelegate, UITextViewDelegate, LeveyPopListViewDelegate>
{
    BOOL create;
    
    NSArray *allLines;
}

@end

@implementation AccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setNewTitle:(self.userInfo ? @"用户详情" : @"新建用户")];
    [self.navigationItem setBackItemWithTarget:self action:@selector(onCancel:)];
    
    CGFloat y = 0;
    //CGFloat centerX = self.view.bounds.size.width / 2;
    
    CGRect frame = self.container1.frame;
    frame.origin.y = y;
    self.container1.frame = frame;
    [self.scrollView addSubview:self.container1];
    
    y = CGRectGetMaxY(frame);
    frame = self.container2.frame;
    frame.origin.y = y;
    self.container2.frame = frame;
    [self.scrollView addSubview:self.container2];
    
    y = CGRectGetMaxY(frame);
    frame = self.container3.frame;
    frame.origin.y = y;
    self.container3.frame = frame;
    [self.scrollView addSubview:self.container3];
    
    y = CGRectGetMaxY(frame);
    self.scrollView.contentSize = CGSizeMake(320, y);
    
    self.userNameLabel.delegate = self;
    self.userLineLabel.delegate = self;
    self.userProfessionLabel.delegate = self;
    self.infoTextView.delegate = self;
    
    [self.addDeviceBtn blueBorderStyle];
    [self.addMeasurePointBtn blueBorderStyle];
    [self.editGroupBtn blueBorderStyle];
    [self.okBtn okStyle];
    [self.cancelBtn cancelStyle];
    
    SSCheckBoxView *checkbox = [[SSCheckBoxView alloc] initWithFrame:self.attentionCheckBox.frame
                                                             style:kSSCheckBoxViewStyleGlossy
                                                           checked:NO];
    [checkbox setText:@"添加到我的关注"];
    [self.attentionCheckBox.superview addSubview:checkbox];
    [self.attentionCheckBox removeFromSuperview];
    self.attentionCheckBox = checkbox;
    
    [self.scrollView whenTapped:^{
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        
        self.scrollView.frame = self.view.bounds;
    }];
    [self.attentionCheckBox whenTapped:^{
        self.attentionCheckBox.checked = !self.attentionCheckBox.checked;
    }];
    [self.addDeviceBtn addTarget:self action:@selector(addDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.addMeasurePointBtn addTarget:self action:@selector(addTestPoint:) forControlEvents:UIControlEventTouchUpInside];
    [self.editGroupBtn addTarget:self action:@selector(editSumGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.okBtn addTarget:self action:@selector(onOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    create = self.userInfo == nil;
    if (create) {
        XLViewDataUserBaiscInfo *tempUserInfo = [[XLViewDataUserBaiscInfo alloc] init];
        tempUserInfo.line = [XLModelDataInterface testData].currentLine;
        
        if (self.createDelegate) {
            [self.createDelegate accountViewController:self onCreateUser:tempUserInfo];
        }
        self.userInfo = tempUserInfo;
    }
    
    XLViewDataUserBaiscInfo *user = self.userInfo;
    self.userNameLabel.text = user.userName;
    self.userLineLabel.text = user.line.lineName;
    self.userProfessionLabel.text = user.businessType;
    self.userNoLabel.text = user.userNo;
    self.infoTextView.text = user.userInfo;
    
    self.attentionCheckBox.checked = user.attention;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.userLineLabel) {
        allLines = [[XLModelDataInterface testData] queryAllLines];
        NSMutableArray *dataOptions = [NSMutableArray arrayWithCapacity:allLines.count];
        for (XLViewDataLine *line in allLines) {
            [dataOptions addObject:[NSDictionary dictionaryWithObjectsAndKeys:line.lineName, @"text", nil]];
        }
        
        UIWindow *frontWindow = [[[UIApplication sharedApplication] windows] lastObject];
        LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"选择所属线路" options:dataOptions];
        lplv.delegate = self;
        [lplv showInView:frontWindow animated:YES];
        
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = self.scrollView.frame;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect cf = [self.scrollView convertRect:self.scrollView.bounds toView:keyWindow];
    CGFloat delta = 216 - CGRectGetHeight(keyWindow.frame) + CGRectGetMaxY(cf);//键盘高度216
    if (delta > 0) {
        frame.size.height = CGRectGetHeight(self.view.frame) - delta;
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.scrollView.frame = frame;
        [UIView commitAnimations];
    }
}

#pragma mark - UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self textFieldDidBeginEditing:nil];
    [self.scrollView scrollRectToVisible:textView.frame animated:YES];
}


- (IBAction)addDevice:(id)sender
{
    AccountAddDeviceViewController *controller = [[AccountAddDeviceViewController alloc] init];
    controller.userInfo = self.userInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)addTestPoint:(id)sender
{
    AccountAddTestPointViewController *controller = [[AccountAddTestPointViewController alloc] init];
    controller.userInfo = self.userInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)editSumGroup:(id)sender
{
    AccountSumGroupViewController *controller = [[AccountSumGroupViewController alloc] init];
    controller.userInfo = self.userInfo;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onOK:(id)sender
{
    if (!self.userNameLabel.text.length) {
        [self.view makeToast:@"用户名不能为空"];
        return;
    }
    
    self.userInfo.userName = self.userNameLabel.text;
    //        self.userInfo.lineName = self.userLineLabel.text;
    self.userInfo.businessType = self.userProfessionLabel.text;
    self.userInfo.userInfo = self.infoTextView.text;
    self.userInfo.userNo = self.userNoLabel.text;
    
    self.userInfo.attention = self.attentionCheckBox.checked;
    
    [self.navigationController popViewControllerAnimated:YES];
    
//    if (self.userInfo) {
//        
//    } else {
//        tempUserInfo.userName = self.userNameLabel.text;
////        tempUserInfo.lineName = self.userLineLabel.text;
//        tempUserInfo.businessType = self.userProfessionLabel.text;
//        tempUserInfo.userInfo = self.infoTextView.text;
//        
//        tempUserInfo.attention = self.attentionCheckBox.checked;
//        
//        
////        [[XLModelDataInterface testData] createUserBasicInfo:tempUserInfo];
////        tempUserInfo = nil;
//    }
}

- (IBAction)onCancel:(id)sender
{
    if (create) {
        [[XLModelDataInterface testData] deleteUserBasicInfo:self.userInfo.userId];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //TODO
    // 这里应该将tempUserInfo里的设备和测量点都删除
    // back:中也应该这样操作，但不能保证解决问题，还有程序强退的可能
    
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{
//    if (self.userInfo) {
    self.userInfo.line = [allLines objectAtIndex:anIndex];
//    } else {
//        tempUserInfo = [allLines objectAtIndex:anIndex];
//    }
}

- (void)leveyPopListViewDidCancel
{
}

@end
