//
//  SwitchEventsViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-13.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SwitchEventsViewController.h"

#import "Navbar.h"
#import "SwitchActionEventsViewController.h"
#import "SwitchSOEEventsViewController.h"

@interface SwitchEventsViewController ()
{
    NSArray *tabControllers;
}

@end

@implementation SwitchEventsViewController

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
	
    [self.navigationItem setNewTitle:@"事件数据"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.dataSource = self;
    self.delegate = self;
    
    SwitchActionEventsViewController *controller1 = [[SwitchActionEventsViewController alloc] init];
    SwitchActionEventsViewController *controller2 = [[SwitchActionEventsViewController alloc] init];
    SwitchActionEventsViewController *controller3 = [[SwitchActionEventsViewController alloc] init];
    SwitchSOEEventsViewController *controller4 = [[SwitchSOEEventsViewController alloc] init];
    
    controller1.title = @"动作事件";
    controller2.title = @"操作事件";
    controller3.title = @"告警事件";
    controller4.title = @"SOE事件";
    
    controller1.eventType = @"动作事件";
    controller2.eventType = @"操作事件";
    controller3.eventType = @"告警事件";
    controller4.eventType = @"SOE事件";
    
    controller1.device = self.device;
    controller2.device = self.device;
    controller3.device = self.device;
    controller4.device = self.device;
    
    tabControllers = [NSArray arrayWithObjects:controller1, controller2, controller3, controller4, nil];
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
            return 80.0;
        case ViewPagerOptionFixFormerTabsPositions:
            return 0.0;
        case ViewPagerOptionFixLatterTabsPositions:
            return 0.0;
        default:
            return value;
    }
}

@end
