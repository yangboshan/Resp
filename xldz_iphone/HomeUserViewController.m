//
// Created by sureone on 2/12/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "HomeUserViewController.h"

#import "TestDataSource.h"
#import "CorePlot-CocoaTouch.h"

#import "CPTGraphHostingView.h"
#import "CPTTheme.h"
#import "RKTabView.h"
#import "HomeUserTextDataViewController.h"
#import "HomeUserPlotViewController.h"
#import "HomeUserBottomDetailViewController.h"
#import "MFSideMenuContainerViewController.h"

#import "app-config.h"
@implementation HomeUserViewController {

    HomeUserTextDataViewController *homeUserTextDataViewController;
    HomeUserPlotViewController *homeUserPlotViewController;
    
    

}


@synthesize plotView,textDataView;

- (NSString *)tabImageName
{
    return @"image-2";
    
    


}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];



    CGRect rect = CGRectMake(0.0f,0.0f,self.view.bounds.size.width,0.0f);
    homeUserTextDataViewController = [[HomeUserTextDataViewController alloc] initWithNibName:@"home_user_text_data_view" bundle:nil];
    homeUserTextDataViewController.viewType = self.viewType;
    
    [self addChildViewController:homeUserTextDataViewController];


//    rect.size.height=homeUserTextDataViewController.view.frame.size.height;
//
//    homeUserTextDataViewController.view.frame=rect;
//    
    
    [self.view addSubview:homeUserTextDataViewController.view];
    [homeUserTextDataViewController didMoveToParentViewController:self];

//    self.textDataView.frame=rect;
    
//    [homeUserTextDataViewController.view setBackgroundColor:[UIColor colorWithRed:27 green:(27) blue:27 alpha:255]];
    
//    if(IS_IPHONE && IS_IPHONE_5)
//    {
//     homeUserPlotViewController = [[HomeUserPlotViewController alloc] initWithNibName:@"home_user_plot_view_4inch" bundle:nil];
//    }
//    else if(IS_IPHONE)
//    {
        homeUserPlotViewController = [[HomeUserPlotViewController alloc] initWithNibName:@"home_user_plot_view_4inch" bundle:nil];
//    }
//    else
//    {
//
//    }
    
//    
//    homeUserPlotViewController = [[HomeUserPlotViewController alloc] initWithNibName:@"home_user_plot_view" bundle:nil];

    homeUserPlotViewController.viewType=_viewType;
    homeUserTextDataViewController.viewType=_viewType;
    [self addChildViewController:homeUserPlotViewController];
    [homeUserPlotViewController didMoveToParentViewController:self];
    
    homeUserPlotViewController.plotDelegate=self;

    homeUserPlotViewController.userId=self.userId;

    rect.size.height=homeUserPlotViewController.view.bounds.size.height;
    rect.origin.y=homeUserTextDataViewController.view.bounds.size.height;
    homeUserPlotViewController.view.frame=rect;

    homeUserPlotViewController.textDataView=homeUserTextDataViewController;

    [self.view addSubview:homeUserPlotViewController.view];


    self.view.backgroundColor=[UIColor blackColor];
    
    
}


-(void)loadData{
    [homeUserPlotViewController firstLoadData];    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



-(void)testPlotRecordSelectedWithIndex:(int)idx withData:(id)data
{
    [homeUserTextDataViewController testUpdateTheDetailFromPlotWithDoubleArray:data];
}

-(void)pleaseTurnThePanGestureOff:(BOOL)yes{
    
    MFSideMenuContainerViewController* controller = (MFSideMenuContainerViewController*)(self.parentViewHavePanGesture);
    
    if(yes)
        [controller turnOffPanGesture];
    else
        [controller turnOnPanGesture];
    
    
    
    
}


@end