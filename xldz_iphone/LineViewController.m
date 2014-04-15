//
//  LineViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-26.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "LineViewController.h"

#import "Navbar.h"
#import "JMWhenTapped.h"
#import "UIButton+Bootstrap.h"
#import "Toast+UIView.h"
#import "LeveyPopListView.h"
#import "XLModelDataInterface.h"
#import "AccountViewController.h"
#import "AccountListViewController.h"

@interface LineViewController () <UITextFieldDelegate, UITextViewDelegate, LeveyPopListViewDelegate, AccountViewControllerDelegate, AccountListViewControllerDelegate>
{
    //XLViewDataLine *templineInfo;
    BOOL create;
    
    NSArray *allSystems;
}

@end

@implementation LineViewController

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
    
    [self.navigationItem setNewTitle:(self.lineInfo ? @"线路详情" : @"新建线路")];
    [self.navigationItem setBackItemWithTarget:self action:@selector(onCancel:)];
    
    CGFloat y = 0;
    
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
    
    self.lineNameLabel.delegate = self;
    self.systemLabel.delegate = self;
    self.lineNoLabel.delegate = self;
    self.lineInfoTextView.delegate = self;
    
    [self.addUserBtn blueBorderStyle];
    [self.createUserBtn blueBorderStyle];
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
    [self.addUserBtn addTarget:self action:@selector(addUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.createUserBtn addTarget:self action:@selector(createUser:) forControlEvents:UIControlEventTouchUpInside];
    [self.okBtn addTarget:self action:@selector(onOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    
    create = self.lineInfo == nil;
    if (create) {
        XLViewDataLine *templineInfo = [[XLViewDataLine alloc] init];
        templineInfo.system = [XLModelDataInterface testData].currentSystem;
        
        if (self.createDelegate) {
            [self.createDelegate lineViewController:self onCreateLine:templineInfo];
        }
        self.lineInfo = templineInfo;
    }
    
    XLViewDataLine *line = self.lineInfo;
    self.lineNameLabel.text = line.lineName;
    self.systemLabel.text = line.system.systemName;
    self.lineNoLabel.text = line.lineNo;
    self.lineInfoTextView.text = line.lineInfo;
    self.attentionCheckBox.checked = line.attention;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.systemLabel) {
        allSystems = [[XLModelDataInterface testData] queryAllSystems];
        NSMutableArray *dataOptions = [NSMutableArray arrayWithCapacity:allSystems.count];
        for (XLViewDataSystem *system in allSystems) {
            [dataOptions addObject:[NSDictionary dictionaryWithObjectsAndKeys:system.systemName, @"text", nil]];
        }
        
        UIWindow *frontWindow = [[[UIApplication sharedApplication] windows] lastObject];
        LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"选择所属系统" options:dataOptions];
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


- (IBAction)onOK:(id)sender
{
    if (!self.lineNameLabel.text.length) {
        [self.view makeToast:@"线路名称不能为空"];
        return;
    }
    
    self.lineInfo.lineName = self.lineNameLabel.text;
    self.lineInfo.lineNo = self.lineNoLabel.text;
    self.lineInfo.lineInfo = self.lineInfoTextView.text;
    self.lineInfo.attention = self.attentionCheckBox.checked;
    
    [self.navigationController popViewControllerAnimated:YES];
    
//    if (self.lineInfo) {
//        
//    } else {
//        templineInfo.lineName = self.lineNameLabel.text;
//        templineInfo.lineNo = self.lineNoLabel.text;
//        templineInfo.lineInfo = self.lineInfoTextView.text;
//        templineInfo.attention = self.attentionCheckBox.checked;
//        
//        
////        [[XLModelDataInterface testData] createLine:templineInfo];
////        templineInfo = nil;
//    }
    
}

- (IBAction)onCancel:(id)sender
{
    if (create) {
        [[XLModelDataInterface testData] deleteLine:self.lineInfo.lineId];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createUser:(id)sender
{
    AccountViewController *controller = [[AccountViewController alloc] init];
    controller.createDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)addUser:(id)sender
{
    AccountListViewController *controller = [[AccountListViewController alloc] initWithType:AccountListTypeSelect];
    controller.line = self.lineInfo;
    controller.selectDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - AccountListViewControllerDelegate
- (void)accountListViewController:(AccountListViewController *)controller onSelectUsers:(NSArray *)users
{
    [users enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XLViewDataUserBaiscInfo *user = obj;
        user.line = self.lineInfo;
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AccountViewControllerDelegate
- (void)accountViewController:(AccountViewController *)controller onCreateUser:(XLViewDataUserBaiscInfo *)user
{
    user.line = self.lineInfo;
    //[[XLModelDataInterface testData] createUserBasicInfo:user];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{
//    if (self.lineInfo) {
    self.lineInfo.system = [allSystems objectAtIndex:anIndex];
//    } else {
//        templineInfo.system = [allSystems objectAtIndex:anIndex];
//    }
}

- (void)leveyPopListViewDidCancel
{
}

@end
