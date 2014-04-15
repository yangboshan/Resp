//
//  TestPointViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-21.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "TestPointViewController.h"

#import "Navbar.h"
#import "TestPointSettingViewController.h"
//#import "TestPointBasicParamViewController.h"
//#import "TestPointTransParamViewController.h"
//#import "TestPointThresholdParamViewController.h"
#import "DataCatalogViewController.h"


@interface TestPointViewController ()

@end

@implementation TestPointViewController

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
    
    [self.navigationItem setNewTitle:self.testPoint.pointName];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    [self.settingBtn addTarget:self action:@selector(gotoPointSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBtn addTarget:self action:@selector(gotoPointControl:) forControlEvents:UIControlEventTouchUpInside];
    [self.helpBtn addTarget:self action:@selector(gotoPointHelp:) forControlEvents:UIControlEventTouchUpInside];
    [self.realtimeDataBtn addTarget:self action:@selector(gotoPointRealtimeData:) forControlEvents:UIControlEventTouchUpInside];
    [self.historyDataBtn addTarget:self action:@selector(gotoPointHistoryData:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoPointSetting:(id)sender
{
    TestPointSettingViewController *controller = [[TestPointSettingViewController alloc] init];
    controller.testPoint = self.testPoint;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)gotoPointControl:(id)sender
{
    //TODO
}
- (IBAction)gotoPointHelp:(id)sender
{
    //TODO
}
- (IBAction)gotoPointRealtimeData:(id)sender
{
    DataCatalogViewController *controller = [[DataCatalogViewController alloc] init];
    controller.device = self.testPoint.device;
    controller.currentPoint = self.testPoint;
    controller.realtime = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)gotoPointHistoryData:(id)sender
{
    DataCatalogViewController *controller = [[DataCatalogViewController alloc] init];
    controller.device = self.testPoint.device;
    controller.currentPoint = self.testPoint;
    controller.realtime = NO;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
