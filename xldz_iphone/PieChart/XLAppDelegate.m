//
// Created by sureone on 2/11/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "XLAppDelegate.h"
#import "AKTabBarController.h"
#import "XLMainTabViewController.h"
#import "PSViewController.h"
#import "MHTabBarController.h"
#import "TabHomeViewController.h"
#import "TabMoreViewController.h"
#import "TabMessageViewController.h"
#import "TabMapViewController.h"
#import "TabDiscuzViewController.h"
#import "LeftSideUserMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "Navbar.h"
#import "StartSyncAlertView.h"
#import "XLModelDataInterface.h"
#import "XLSyncDeviceBussiness.h"
#import "XLCoreData.h"
#import "XLSettingManager.h"


@implementation XLAppDelegate {

}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[XLSettingManager sharedXLSettingManager] beginSyncData];

    
    
    // 要使用百度地图，请先启动BaiduMapManager
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"rusPLvtiHfMRoACRWO9WBsi2"  generalDelegate:self];
    if (!ret) {
        NSLog(@"map manager start failed!");
    }

    
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // If the device is an iPad, we make it taller.
    _tabBarController = [[AKTabBarController alloc] initWithTabBarHeight:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? 60 : 40];
    [_tabBarController setMinimumHeightToDisplayTitle:40.0];

    UITableViewController *tableViewController = [[XLMainTabViewController alloc] initWithStyle:UITableViewStylePlain];

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    navigationController.navigationBar.tintColor = [UIColor darkGrayColor];


    TabHomeViewController *homeController = [[TabHomeViewController alloc] init];
    TabMessageViewController *messageController = [[TabMessageViewController alloc] init];
    TabMapViewController *mapController = [[TabMapViewController alloc] init];
    TabDiscuzViewController *discuzController = [[TabDiscuzViewController alloc] init];
    TabMoreViewController *moreController = [[TabMoreViewController alloc]init];
    
    UINavigationController *nav1 = [[UINavigationController alloc] initWithNavigationBarClass:[Navbar class] toolbarClass:nil];
    nav1.viewControllers = @[homeController];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithNavigationBarClass:[Navbar class] toolbarClass:nil];
    nav2.viewControllers = @[messageController];
    UINavigationController *nav3 = [[UINavigationController alloc] initWithNavigationBarClass:[Navbar class] toolbarClass:nil];
    nav3.viewControllers = @[mapController];
    UINavigationController *nav4 = [[UINavigationController alloc] initWithNavigationBarClass:[Navbar class] toolbarClass:nil];
    nav4.viewControllers = @[discuzController];
    UINavigationController *nav5 = [[UINavigationController alloc] initWithNavigationBarClass:[Navbar class] toolbarClass:nil];
    nav5.viewControllers = @[moreController];
    

    [_tabBarController setViewControllers:[NSMutableArray arrayWithObjects: nav1, nav2, nav3, nav4,nav5,nil]];


    // Below you will find an example of possible customization, just uncomment the lines

    /*
    // Tab background Image
    [_tabBarController setBackgroundImageName:@"noise-dark-gray.png"];
    [_tabBarController setSelectedBackgroundImageName:@"noise-dark-blue.png"];

    // Tabs top embos Color
    [_tabBarController setTabEdgeColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.8]];

    // Tabs Colors settings
    [_tabBarController setTabColors:@[[UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.0],
                                          [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1.0]]]; // MAX 2 Colors

    [_tabBarController setSelectedTabColors:@[[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0],
                                                  [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0]]]; // MAX 2 Colors

    // Tab Stroke Color
    [_tabBarController setTabStrokeColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];

    // Icons Color settings
    [_tabBarController setIconColors:@[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1],
                                           [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]]]; // MAX 2 Colors

    [_tabBarController setSelectedIconColors:@[[UIColor colorWithRed:174.0/255.0 green:174.0/255.0 blue:174.0/255.0 alpha:1],
                                                   [UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1]]]; // MAX 2 Colors

    // Text Color
    [_tabBarController setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
    [_tabBarController setSelectedTextColor:[UIColor colorWithRed:228.0/255.0 green:228.0/255.0 blue:228.0/255.0 alpha:1.0]];

    // Hide / Show glossy on tab icons
    [_tabBarController setIconGlossyIsHidden:YES];
    */
    
    
//    LeftSideUserMenuViewController *leftMenuViewController = [[LeftSideUserMenuViewController alloc] init];
//    LeftSideUserMenuViewController *rightMenuViewController = [[LeftSideUserMenuViewController alloc] init];
//    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
//                                                    containerWithCenterViewController:_tabBarController
//                                                    leftMenuViewController:leftMenuViewController
//                                                    rightMenuViewController:rightMenuViewController];

    
    [_window setRootViewController:_tabBarController];
    [_window makeKeyAndVisible];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        BOOL b = [[XLModelDataInterface testData] connectToDevice];
//        if (b) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                StartSyncAlertView *alertView = [[StartSyncAlertView alloc] init];
//                [alertView show];
//            });
//        }
//    });
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"wifi", @"xl-name", nil];
    [[XLModelDataInterface testData] checkWifiConnect:dic];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewWifiConnected object:nil];
    
    return YES;
}

- (void)handleNotification:(NSNotification *)aNotification
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"auto_update_off"]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        StartSyncAlertView *alertView = [[StartSyncAlertView alloc] init];
        [alertView show];
    });
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}
@end