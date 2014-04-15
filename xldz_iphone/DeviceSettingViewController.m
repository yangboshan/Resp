//
//  DeviceSettingViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceSettingViewController.h"

#import "Navbar.h"

#import "DeviceBasicParamViewController.h"
#import "DeviceTransParamViewController.h"
#import "DeviceDCParamViewController.h"
#import "DevicePointsViewController.h"
#import "DeviceEventParamViewController.h"
#import "DeviceLoopsViewController.h"
#import "DeviceProtectionParamViewController.h"
#import "DeviceSystemParamViewController.h"
#import "DeviceTelemetryParamViewController.h"
#import "DeviceRemoteSignallingParamViewController.h"
#import "DeviceRemoteControlParamViewController.h"


@interface DeviceSettingViewController ()
{
    NSArray *tabControllers;
}
@end

@implementation DeviceSettingViewController

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
    
    NSString *title = [NSString stringWithFormat:@"%@ - 参数设置", self.device.deviceName];
    [self.navigationItem setNewTitle:title];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.dataSource = self;
    self.delegate = self;
    
    if (self.device.deviceType == DeviceTypeFMR) {
        DeviceBasicParamViewController *controller1 = [[DeviceBasicParamViewController alloc] init];
        DeviceTransParamViewController *controller2 = [[DeviceTransParamViewController alloc] init];
        DeviceDCParamViewController *controller3 = [[DeviceDCParamViewController alloc] init];
        DevicePointsViewController *controller4 = [[DevicePointsViewController alloc] init];
        DeviceEventParamViewController *controller5 = [[DeviceEventParamViewController alloc] init];
        
        controller1.title = @"基本参数";
        controller2.title = @"通信参数";
        controller3.title = @"直流模拟量";
        controller4.title = @"管理测量点";
        controller5.title = @"事件参数";
        
        controller1.device = self.device;
        controller2.device = self.device;
        controller3.device = self.device;
        controller4.device = self.device;
        controller5.device = self.device;
        
        tabControllers = [NSArray arrayWithObjects:controller1, controller2, controller3, controller4, controller5, nil];
    } else if (self.device.deviceType == DeviceTypeSwitch) {
        DeviceBasicParamViewController *controller1 = [[DeviceBasicParamViewController alloc] init];
        DeviceProtectionParamViewController *controller2 = [[DeviceProtectionParamViewController alloc] init];
        DeviceTransParamViewController *controller3 = [[DeviceTransParamViewController alloc] init];
        DeviceLoopsViewController *controller4 = [[DeviceLoopsViewController alloc] init];
        DeviceSystemParamViewController *controller5 = [[DeviceSystemParamViewController alloc] init];
        DeviceTelemetryParamViewController *controller6 = [[DeviceTelemetryParamViewController alloc] init];
        DeviceRemoteSignallingParamViewController *controller7 = [[DeviceRemoteSignallingParamViewController alloc] init];
        DeviceRemoteControlParamViewController *controller8 = [[DeviceRemoteControlParamViewController alloc] init];

        
        controller1.title = @"基本参数";
        controller2.title = @"保护参数";
        controller3.title = @"通信参数";
        controller4.title = @"回路参数";
        controller5.title = @"系统参数";
        controller6.title = @"遥测参数";
        controller7.title = @"遥信参数";
        controller8.title = @"遥控参数";
        
        controller1.device = self.device;
        controller2.device = self.device;
        controller3.device = self.device;
        controller4.device = self.device;
        controller5.device = self.device;
        controller6.device = self.device;
        controller7.device = self.device;
        controller8.device = self.device;
        
        tabControllers = [NSArray arrayWithObjects:controller1, controller2, controller3, controller4, controller5, controller6, controller7, controller8, nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
