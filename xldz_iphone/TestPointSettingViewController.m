//
//  TestPointSettingViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-21.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "TestPointSettingViewController.h"

#include "Navbar.h"

#import "TestPointBasicParamViewController.h"
#import "TestPointTransParamViewController.h"
#import "TestPointThresholdParamViewController.h"

@interface TestPointSettingViewController ()
{
    NSArray *tabControllers;
}
@end

@implementation TestPointSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *title = [NSString stringWithFormat:@"%@ - 参数设置", self.testPoint.pointName];
    [self.navigationItem setNewTitle:title];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.dataSource = self;
    self.delegate = self;
    
    TestPointBasicParamViewController *controller1 = [[TestPointBasicParamViewController alloc] init];
	TestPointTransParamViewController *controller2 = [[TestPointTransParamViewController alloc] init];
	TestPointThresholdParamViewController *controller3 = [[TestPointThresholdParamViewController alloc] init];
	
	controller1.title = @"基本参数";
	controller2.title = @"通信参数";
	controller3.title = @"越限参数";
    
    controller1.testPoint = self.testPoint;
    controller2.testPoint = self.testPoint;
    controller3.testPoint = self.testPoint;
    
	tabControllers = [NSArray arrayWithObjects:controller1, controller2, controller3, nil];
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

#pragma mark - ViewPagerDataSource
- (NSUInteger)numberOfTabsForViewPager:(ViewPagerController *)viewPager {
    return tabControllers.count;
}
- (UIView *)viewPager:(ViewPagerController *)viewPager viewForTabAtIndex:(NSUInteger)index {
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = [[tabControllers objectAtIndex:index] title];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    
    return label;
}

- (UIViewController *)viewPager:(ViewPagerController *)viewPager contentViewControllerForTabAtIndex:(NSUInteger)index {
    return [tabControllers objectAtIndex:index];
}

#pragma mark - ViewPagerDelegate
- (CGFloat)viewPager:(ViewPagerController *)viewPager valueForOption:(ViewPagerOption)option withDefault:(CGFloat)value {
    
    switch (option) {
        case ViewPagerOptionStartFromSecondTab:
            return 0.0;
        case ViewPagerOptionCenterCurrentTab:
            return 1.0;
        case ViewPagerOptionTabLocation:
            return 1.0;
        case ViewPagerOptionTabHeight:
            return 35.0;
        case ViewPagerOptionTabOffset:
            return 0.0;
        case ViewPagerOptionTabWidth:
            return 107.0;
        case ViewPagerOptionFixFormerTabsPositions:
            return 0.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0.0;
        default:
            return value;
    }
}

@end
