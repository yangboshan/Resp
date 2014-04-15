//
// Created by sureone on 2/12/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ContentViewController.h"
#import "CPTPlotSpace.h"
#import "CPTBarPlot.h"
#import "HomeUserPlotViewController.h"

@class CPTGraph;
@class TestDataSource;
@class CPTGraphHostingView;
@class CPTTheme;
@class RKTabView;



@interface HomeUserViewController : ContentViewController <HomeUserPlotViewDelegate>
{
@private
    UIView* textDataView;
    UIView* plotView;
    
}


@property (nonatomic, retain) IBOutlet UIView *textDataView;
@property (nonatomic, retain) IBOutlet UIView *plotView;
@property (nonatomic, retain) UIScrollView *bottomButtonsView;

@property (nonatomic,copy) NSString *viewType;
@property (nonatomic) NSString *userId;

@property (nonatomic) id parentViewHavePanGesture;

-(void)loadData;


@end