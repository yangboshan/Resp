//
//  DeviceBasicParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceBasicParamViewController.h"
#import <CoreLocation/CoreLocation.h>

#import "UIButton+Bootstrap.h"
#import "MJRefresh.h"

@interface DeviceBasicParamViewController () <CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocation *checkinLocation;
    
    NSString *notifKey;
}
@property (nonatomic) NSArray *paramArray;
@end

@implementation DeviceBasicParamViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.distanceFilter = 200;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"设备%@-基本参数", self.device.deviceId];
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryBasicParams:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.paramArray = result;
            [self.tableView reloadData];
            
            [refreshHeader endRefreshing];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSMutableDictionary *)locationParam
{
    for (NSMutableDictionary *param in self.paramArray) {
        if ([param.paramName isEqualToString:@"地理位置"]) {
            return param;
        }
    }
    return nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSMutableDictionary *param = [self locationParam];
    NSString *location = param.paramValue;
    if (param && location.length == 0) {
        if ([CLLocationManager locationServicesEnabled]) {
            NSLog( @"Starting CLLocationManager" );
            [locationManager startUpdatingLocation];
        } else {
            NSLog( @"Cannot Starting CLLocationManager" );
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    checkinLocation = newLocation;
    [locationManager stopUpdatingLocation];
    
    NSMutableDictionary *param = [self locationParam];
    NSString *location = param.paramValue;
    if (param && location.length == 0) {
        self.device.latitude = checkinLocation.coordinate.latitude;
        self.device.longitude = checkinLocation.coordinate.longitude;
        location = [NSString stringWithFormat:@"(%.5f, %.5f)", checkinLocation.coordinate.latitude, checkinLocation.coordinate.longitude];
        param.paramValue = location;
        NSUInteger row = [self.paramArray indexOfObject:param];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row  inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.paramArray.count;
}

- (NSMutableDictionary *)tableView:(UITableView *)tableView paramForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.paramArray objectAtIndex:indexPath.row];
}

- (IBAction)saveParam:(id)sender
{
    [super saveParam:sender];
    
    [self.device saveBasicParams:self.paramArray];
}

@end
