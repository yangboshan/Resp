//
// Created by sureone on 2/11/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TabHomeViewController.h"
#import "TopBarViewController.h"
#import "HomeUserViewController.h"
#import "LeftSideUserMenuViewController.h"
#import "MFSideMenuContainerViewController.h"
#import "RightSideUserMenuViewController.h"
#import "RightSideSystemMenuViewController.h"
#import "LeftSideSystemMenuViewController.h"
#import "LeftSideLineMenuViewController.h"
#import "RightSideLineMenuViewController.h"
#import "SwitchMainViewController.h"

@interface TabHomeViewController() <MHTabBarControllerDelegate>
{
    MFSideMenuContainerViewController* _homeUserViewContainer;
    MFSideMenuContainerViewController* _homeSysViewContainer;
    MFSideMenuContainerViewController* _homeLineViewContainer;
    MFSideMenuContainerViewController *_switchViewViewContainer;
    
    HomeUserViewController* _homeUserViewController;
    HomeUserViewController* _homeSystemViewController;
    HomeUserViewController* _homeLineViewController;
    SwitchMainViewController *_switchViewViewController;
}

@property (nonatomic) MFSideMenuContainerViewController* homeUserViewContainer;
@property (nonatomic) MFSideMenuContainerViewController* homeSysViewContainer;
@property (nonatomic) MFSideMenuContainerViewController* homeLineViewContainer;
@property (nonatomic) MFSideMenuContainerViewController* switchViewViewContainer;

@property (nonatomic) HomeUserViewController* homeUserViewController;
@property (nonatomic) HomeUserViewController* homeSystemViewController;
@property (nonatomic) HomeUserViewController* homeLineViewController;
@property (nonatomic) SwitchMainViewController *switchViewViewController;
@end

@implementation TabHomeViewController {
    NSArray *viewControllers;
//    UIView *fixedTopBarView;
    UIView *tabContentView;
    MHTabBarController *tabBarController;
    TopBarViewController* topBarViewController;
    
    BOOL firstDeviceIsSwitch;
}

@synthesize homeUserViewContainer = _homeUserViewContainer;
@synthesize homeSysViewContainer = _homeSysViewContainer;
@synthesize homeLineViewContainer = _homeLineViewContainer;
@synthesize switchViewViewContainer = _switchViewViewContainer;
@synthesize homeUserViewController = _homeUserViewController;
@synthesize homeSystemViewController = _homeSystemViewController;
@synthesize homeLineViewController = _homeLineViewController;
@synthesize switchViewViewController = _switchViewViewController;



- (void)mh_tabBarController:(MHTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index{
     if(index==0){
         if (firstDeviceIsSwitch) {
             self.currView= @"switch";
             [self.switchViewViewController loadData];
         } else {
             self.currView= @"user";
             [self.homeUserViewController loadData];
         }
     }if(index==1){
        self.currView=@"line";
         [self.homeLineViewController loadData];
    }if(index==2){
        self.currView=@"sys";
        [self.homeSystemViewController loadData];
    }

}

- (void)setupLeftMenuItems {

}
- (void)setupRightMenuItems {

}

- (void)mh_tabBarControllerLeftFixButtonPressed:(MHTabBarController *)tabBarController atSide:(int)side
{
    if([_currView isEqualToString:@"user"]){
        if(side==0)
            [self.homeUserViewContainer toggleLeftSideMenuCompletion:^{
                [self setupLeftMenuItems];
            }];
        else
            [self.homeUserViewContainer toggleRightSideMenuCompletion:^{
                [self setupRightMenuItems];
            }];
    }else if([_currView isEqualToString:@"line"]){

        if(side==0)
            [self.homeLineViewContainer toggleLeftSideMenuCompletion:^{
                [self setupLeftMenuItems];
            }];
        else
            [self.homeLineViewContainer toggleRightSideMenuCompletion:^{
                [self setupRightMenuItems];
            }];

    }else if([_currView isEqualToString:@"sys"]){
        if(side==0)
            [self.homeSysViewContainer toggleLeftSideMenuCompletion:^{
                [self setupLeftMenuItems];
            }];
        else
            [self.homeSysViewContainer toggleRightSideMenuCompletion:^{
                [self setupRightMenuItems];
            }];
    } else if([_currView isEqualToString:@"switch"]){
        if(side==0)
            [self.switchViewViewContainer toggleLeftSideMenuCompletion:^{
                [self setupLeftMenuItems];
            }];
        else
            [self.switchViewViewContainer toggleRightSideMenuCompletion:^{
                [self setupRightMenuItems];
            }];
    }

}




- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"首页";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"home_icon";
}

- (CGFloat)topBarHeight
{
    return 40.0f;
}

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

//    fixedTopBarView = [[UIView alloc] initWithFrame:rect];
//    fixedTopBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    [self.view addSubview:fixedTopBarView];
//
//
//    float height = [[UIScreen mainScreen] bounds].size.height;
//
//    if(IS_IPHONE && height == 568.0f)
//    {
//        topBarViewController = [[TopBarViewController alloc] initWithNibName:@"fixed_top_view" bundle:nil];
//    }
//    else if(IS_IPHONE)
//    {
//        topBarViewController = [[TopBarViewController alloc] initWithNibName:@"fixed_top_view" bundle:nil];
//    }

//
//    [self addChildViewController:topBarViewController];
//    [topBarViewController didMoveToParentViewController:self];
//
//
//    [fixedTopBarView addSubview:topBarViewController.view];

//    rect.origin.y = self.topBarHeight;
    
//    rect.size.height = self.view.bounds.size.height - self.topBarHeight;
    CGRect rect = self.view.bounds;
    if (IOS_VERSION_7) {
        rect.origin.y = 20.f;
        rect.size.height -= 20.f;
    }
    tabContentView = [[UIView alloc] initWithFrame:rect];
    tabContentView.backgroundColor = [UIColor blackColor];
    tabContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self.view addSubview:tabContentView];


    tabBarController = [[MHTabBarController alloc] init];
    tabBarController.showMenuBtns = YES;

    [self addChildViewController:tabBarController];
    [tabBarController didMoveToParentViewController:self];


    tabBarController.delegate = self;
    [self loadTabs];
    
    tabBarController.view.frame = self.view.bounds;
    [tabContentView addSubview:tabBarController.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    NSLog(@"TabHomeViewController viewWillAppear");
    [self loadTabs];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (MFSideMenuContainerViewController *)homeUserViewContainer
{
    if (!_homeUserViewContainer) {
        _homeUserViewController = [[HomeUserViewController alloc] init];
        _homeUserViewController.viewType=@"user";
        
        RightSideUserMenuViewController *rightSideUserMenuViewController = [[RightSideUserMenuViewController alloc] init];
        LeftSideUserMenuViewController *leftSideUserMenuController = [[LeftSideUserMenuViewController alloc] init];
        _homeUserViewContainer = [MFSideMenuContainerViewController
                                  containerWithCenterViewController:_homeUserViewController
                                  leftMenuViewController:leftSideUserMenuController
                                  rightMenuViewController:rightSideUserMenuViewController];
        
        _homeUserViewContainer.title=@"用户";
        
        //todo 模拟数据
        _homeUserViewController.userId=@"user1";
        
        _homeUserViewContainer.menuWidth=self.view.frame.size.width*3/5;
        _homeUserViewContainer.panMode=MFSideMenuPanModeDefault;
        
        _homeUserViewController.parentViewHavePanGesture = _homeUserViewContainer;
    }
    return _homeUserViewContainer;
}

- (MFSideMenuContainerViewController *)homeSysViewContainer
{
    if (!_homeSysViewContainer) {
        _homeSystemViewController = [[HomeUserViewController alloc] init];
        _homeSystemViewController.viewType=@"system";
        
        RightSideSystemMenuViewController *rightSideSystemMenuViewController = [[RightSideSystemMenuViewController alloc] init];
        LeftSideSystemMenuViewController *leftSideSystemMenuViewController = [[LeftSideSystemMenuViewController alloc] init];
        _homeSysViewContainer = [MFSideMenuContainerViewController
                                containerWithCenterViewController:_homeSystemViewController
                                leftMenuViewController:leftSideSystemMenuViewController
                                rightMenuViewController:rightSideSystemMenuViewController];
        
        _homeSysViewContainer.title=@"系统";
        
        _homeSysViewContainer.menuWidth=self.view.frame.size.width*3/5;
        _homeSysViewContainer.panMode=MFSideMenuPanModeDefault;

        _homeSystemViewController.parentViewHavePanGesture = _homeSysViewContainer;
    }
    return _homeSysViewContainer;
}

- (MFSideMenuContainerViewController *)homeLineViewContainer
{
    if (!_homeLineViewContainer) {
        _homeLineViewController = [[HomeUserViewController alloc] init];
        _homeLineViewController.viewType=@"line";
        
        RightSideLineMenuViewController *rightSideLineMenuViewController = [[RightSideLineMenuViewController alloc] init];
        LeftSideLineMenuViewController *leftSideLineMenuViewController = [[LeftSideLineMenuViewController alloc] init];
        _homeLineViewContainer = [MFSideMenuContainerViewController
                                 containerWithCenterViewController:_homeLineViewController
                                 leftMenuViewController:leftSideLineMenuViewController
                                 rightMenuViewController:rightSideLineMenuViewController];
        
        _homeLineViewContainer.title=@"线路";
        
        _homeLineViewContainer.menuWidth=self.view.frame.size.width*3/5;
        _homeLineViewContainer.panMode=MFSideMenuPanModeDefault;
 
        _homeLineViewController.parentViewHavePanGesture = _homeLineViewContainer;
    }
    return _homeLineViewContainer;
}

- (MFSideMenuContainerViewController *)switchViewViewContainer
{
    if (!_switchViewViewContainer) {
        RightSideUserMenuViewController *rightSideSwitchMenuViewController = [[RightSideUserMenuViewController alloc] init];
        LeftSideUserMenuViewController *leftSideSwitchMenuController = [[LeftSideUserMenuViewController alloc] init];
        
        _switchViewViewController = [[SwitchMainViewController alloc] init];
        _switchViewViewContainer = [MFSideMenuContainerViewController
                                   containerWithCenterViewController:_switchViewViewController
                                   leftMenuViewController:leftSideSwitchMenuController
                                   rightMenuViewController:rightSideSwitchMenuViewController];
        _switchViewViewContainer.title=@"XXXX";
        _switchViewViewContainer.menuWidth=self.view.frame.size.width*3/5;
        _switchViewViewContainer.panMode=MFSideMenuPanModeDefault;
    }
    return _switchViewViewContainer;
}

-(void)loadTabs {
    XLViewDataDevice *firstDevice = nil;
    XLViewDataUserBaiscInfo *user = [XLModelDataInterface testData].currentUser;
    if (user) {
        firstDevice = [[XLModelDataInterface testData] queryDevicesForUser:user].firstObject;
    }
    

//    listViewController1.title = @"Tab 1";
//    listViewController2.title = @"Tab 2";
//    listViewController3.title = @"Tab 3";
//
//    listViewController2.tabBarItem.image = [UIImage imageNamed:@"Taijitu"];
//    listViewController2.tabBarItem.imageInsets = UIEdgeInsetsMake(0.0f, -4.0f, 0.0f, 0.0f);
//    listViewController2.tabBarItem.titlePositionAdjustment = UIOffsetMake(4.0f, 0.0f);

    firstDeviceIsSwitch = firstDevice != nil && firstDevice.deviceType == DeviceTypeSwitch;
    if (firstDeviceIsSwitch) {
        self.switchViewViewContainer.title = firstDevice.deviceName;
        self.switchViewViewController.device = firstDevice;
        viewControllers = @[self.switchViewViewContainer];
    } else {
        viewControllers = @[self.homeUserViewContainer, self.homeLineViewContainer, self.homeSysViewContainer];
    }

    tabBarController.viewControllers = viewControllers;
}
@end