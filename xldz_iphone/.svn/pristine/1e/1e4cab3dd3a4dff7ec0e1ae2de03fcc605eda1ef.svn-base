//
//  SystemViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-26.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SystemViewController.h"

#import "Navbar.h"
#import "JMWhenTapped.h"
#import "UIButton+Bootstrap.h"
#import "Toast+UIView.h"

#import "LineViewController.h"
#import "LineListViewController.h"

@interface SystemViewController () <UITextFieldDelegate, UITextViewDelegate, LineViewControllerDelegate, LineListViewControllerDelegate>
{
    XLViewDataSystem *tempSystemInfo;
}

@end

@implementation SystemViewController

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
	
    [self.navigationItem setNewTitle:(self.systemInfo ? @"系统详情" : @"新建系统")];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
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
    
    self.systemNameLabel.delegate = self;
    self.systemInfoTextView.delegate = self;
    
    [self.addLineBtn blueBorderStyle];
    [self.createLineBtn blueBorderStyle];
    [self.okBtn okStyle];
    [self.cancelBtn cancelStyle];
    
    [self.scrollView whenTapped:^{
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        
        self.scrollView.frame = self.view.bounds;
    }];
    [self.addLineBtn addTarget:self action:@selector(addLine:) forControlEvents:UIControlEventTouchUpInside];
    [self.createLineBtn addTarget:self action:@selector(createLine:) forControlEvents:UIControlEventTouchUpInside];
    [self.okBtn addTarget:self action:@selector(onOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.systemInfo) {
        self.systemNameLabel.text = self.systemInfo.systemName;
        self.systemInfoTextView.text = self.systemInfo.systemInfo;
    } else {
        tempSystemInfo = [[XLViewDataSystem alloc] init];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
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
    if (!self.systemNameLabel.text.length) {
        [self.view makeToast:@"系统名称不能为空"];
        return;
    }
    
    if (self.systemInfo) {
        self.systemInfo.systemName = self.systemNameLabel.text;
        self.systemInfo.systemInfo = self.systemInfoTextView.text;
        
    } else {
        tempSystemInfo.systemName = self.systemNameLabel.text;
        tempSystemInfo.systemInfo = self.systemInfoTextView.text;

        [[XLModelDataInterface testData] createSystem:tempSystemInfo];
        tempSystemInfo = nil;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addLine:(id)sender
{
    LineListViewController *controller = [[LineListViewController alloc] initWithType:LineListTypeSelect];
    NSArray *all = [[XLModelDataInterface testData] queryAllLines];
    NSArray *except = [[XLModelDataInterface testData] queryLinesForSystem:self.systemInfo];
    NSMutableArray *array = [NSMutableArray arrayWithArray:all];
    [array removeObjectsInArray:except];
    controller.system = self.systemInfo == nil ? tempSystemInfo : self.systemInfo;
    controller.lineArray = array;
    controller.selectDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)lineListViewController:(LineListViewController *)controller onSelectLines:(NSArray *)lines
{
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XLViewDataLine *line = obj;
        line.system = self.systemInfo == nil ? tempSystemInfo : self.systemInfo;
    }];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createLine:(id)sender
{
    LineViewController *controller = [[LineViewController alloc] init];
    controller.createDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)lineViewController:(LineViewController *)controller onCreateLine:(XLViewDataLine *)line
{
    line.system = self.systemInfo == nil ? tempSystemInfo : self.systemInfo;
    [[XLModelDataInterface testData] createLine:line];
    
    //[self.navigationController popViewControllerAnimated:YES];
}

@end
