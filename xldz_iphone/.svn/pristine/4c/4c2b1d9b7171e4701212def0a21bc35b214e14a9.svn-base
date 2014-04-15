//
//  DataCatalogViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-26.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DataCatalogViewController.h"

#include "Navbar.h"
#import "EAIntroView.h"
#import "JMWhenTapped.h"
#import "DeviceOrPointDataCatalogViewController.h"
#import "DeviceViewController.h"

@interface DataCatalogViewController () <EAIntroDelegate, DatePickerActionSheetDelegate>
{
    NSArray *allPoints;
    NSArray *controllers;
    DeviceOrPointDataCatalogViewController *currentController;
    
    NSDate *deviceDate;
    NSDateFormatter *dateFormatter;
}

@property (strong, nonatomic) EAIntroView *introView;
@property (nonatomic) DatePickerActionSheet *timeActionSheet;
@end

@implementation DataCatalogViewController
@synthesize timeActionSheet = _timeActionSheet;

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
    
    [self.navigationItem setNewTitle:@""];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd\nHH:mm:ss"];
    self.realtimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.realtimeLabel.font=[UIFont systemFontOfSize:10];
    self.realtimeLabel.textColor = [UIColor whiteColor];
    self.realtimeLabel.backgroundColor = [UIColor clearColor];
    self.realtimeLabel.textAlignment=UITextAlignmentCenter;
    self.realtimeLabel.numberOfLines = 2;
    self.realtimeLabel.text = @"2012-03-01\n99:99:99";
    [self.realtimeLabel sizeToFit];
    UIBarButtonItem *myButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.realtimeLabel];
    [self.navigationItem setRightBarButtonItem:myButtonItem];
    [self.realtimeLabel whenTapped:^{
        if (self.realtime) {
            [self.timeActionSheet.datePicker setDate:deviceDate animated:YES];
        } else {
            if (currentController.refreshDate) {
                [self.timeActionSheet.datePicker setDate:currentController.refreshDate animated:YES];
            }
        }
        [self.timeActionSheet show];
    }];
    if (self.realtime) {
        deviceDate =  [self.device queryDeviceTime];
        self.realtimeLabel.text = deviceDate != nil ? [dateFormatter stringFromDate:deviceDate] : @"----";
    }

    NSMutableArray *array = [NSMutableArray array];
    if (self.device) {
        DeviceOrPointDataCatalogViewController *deviceController = [[DeviceOrPointDataCatalogViewController alloc] initWithDeviceOrPoint:self.device];
        [array addObject:deviceController];
        
        allPoints = [[XLModelDataInterface testData] queryTestPointsForDevice:self.device];
        for (XLViewDataTestPoint *point in allPoints) {
            DeviceOrPointDataCatalogViewController *pointController = [[DeviceOrPointDataCatalogViewController alloc] initWithDeviceOrPoint:point];
            [array addObject:pointController];
        }
    } else if (self.currentPoint) {
        DeviceOrPointDataCatalogViewController *pointController = [[DeviceOrPointDataCatalogViewController alloc] initWithDeviceOrPoint:self.currentPoint];
        [array addObject:pointController];
    }
    controllers = array;
    
    NSMutableArray *pages = [NSMutableArray array];
    for (DeviceOrPointDataCatalogViewController *controller in controllers) {
        controller.realtime = self.realtime;
        [self addChildViewController:controller];
        [controller didMoveToParentViewController:self];
        
        controller.view.frame = self.view.bounds;
        controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        EAIntroPage *page = [EAIntroPage pageWithCustomView:controller.view];
        [pages addObject:page];
    }
    
    self.introView = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:pages];
    self.introView.swipeToExit = NO;
    //self.introView.easeOutCrossDisolves = NO;
    //self.introView.hideOffscreenPages = NO;
    self.introView.skipButton.hidden = YES;
    self.introView.delegate = self;
    self.introView.pageControl.userInteractionEnabled = NO;
    self.introView.pageControlY = 60;
    
    NSUInteger index = 0;
    if (self.currentPoint && allPoints.count > 0) {
        index = [allPoints indexOfObject:self.currentPoint];
        if (index == NSNotFound) {
            index = 0;
        } else {
            index += 1;
        }
    }
    self.introView.scrollView.contentOffset = CGPointMake(index * 320, 0);
    [self intro:self.introView pageDidScrollToVisibleIndex:index];
    
    [self.introView showInView:self.view animateDuration:0.0f];
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

- (DatePickerActionSheet *)timeActionSheet
{
    if (!_timeActionSheet) {
        _timeActionSheet = [[DatePickerActionSheet alloc] init];
        _timeActionSheet.pickerDelegate = self;
    }
    return _timeActionSheet;
}

- (void)datePickerActionSheet:(UIActionSheet *)actionSheet didPickDate:(NSDate *)date
{
    if (self.realtime) {
        [self.device setDeviceTime:date];
    } else {
        [currentController queryDataForDate:date];
    }
    
}

#pragma mark - EAIntroDelegate
- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex
{
    [self intro:introView pageDidScrollToVisibleIndex:pageIndex];
}

- (void)intro:(EAIntroView *)introView pageDidScrollToVisibleIndex:(NSInteger)pageIndex
{
    NSString *title;
    DeviceOrPointDataCatalogViewController *controller = [controllers objectAtIndex:pageIndex];
    id data = controller.deviceOrPoint;
    if ([data isKindOfClass:[XLViewDataDevice class]]) {
        title = ((XLViewDataDevice *)data).deviceName;
    } else if ([data isKindOfClass:[XLViewDataUserSumGroup class]]) {
        title = ((XLViewDataUserSumGroup *)data).groupName;
    } else if ([data isKindOfClass:[XLViewDataTestPoint class]]) {
        title = ((XLViewDataTestPoint *)data).pointName;
    }
    
    title = [title stringByAppendingString:(self.realtime ? @"-实时数据" : @"-历史数据")];
    [self.navigationItem setNewTitle:title];
    
    
    if (!self.realtime) {
        NSDate *date = controller.refreshDate;
        self.realtimeLabel.text = date != nil ? [dateFormatter stringFromDate:date] : @"----";
        if (currentController) {
            [currentController removeObserver:self forKeyPath:@"refreshDate"];
        }
        currentController = controller;
        [currentController addObserver:self forKeyPath:@"refreshDate" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)dealloc
{
    [currentController removeObserver:self forKeyPath:@"refreshDate"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"refreshDate"]) {
        NSDate *date = currentController.refreshDate;
        self.realtimeLabel.text = date != nil ? [dateFormatter stringFromDate:date] : @"----";
    }
}

@end
