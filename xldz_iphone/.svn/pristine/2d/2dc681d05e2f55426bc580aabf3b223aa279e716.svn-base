//
//  CustomInputTableViewViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-2.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "CustomInputTableViewController.h"

#import "JMWhenTapped.h"

@interface CustomInputTableViewController ()

@end

@implementation CustomInputTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
//    [self.tableView whenTapped:^{
//        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
//        CGRect frame = self.tableView.frame;
//        frame.size.height = CGRectGetMinY(self.bottomView.frame) - CGRectGetMinY(self.tableView.frame);
//        self.tableView.frame = frame;
//    }];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];

}

- (void)hideKeyboard {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    CGRect frame = self.tableView.frame;
    frame.size.height = CGRectGetMinY(self.bottomView.frame) - CGRectGetMinY(self.tableView.frame);
    self.tableView.frame = frame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = self.tableView.frame;
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect cf = [self.tableView convertRect:self.tableView.bounds toView:keyWindow];
    CGFloat delta = 216 - CGRectGetHeight(keyWindow.frame) + CGRectGetMaxY(cf);//键盘高度216
    if (delta > 0) {
        frame.size.height -= delta;
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.tableView.frame = frame;
        [UIView commitAnimations];
    }
    
    CGRect rect = [textField convertRect:textField.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    return YES;
}


@end
