//
//  PSViewController.h
//  PieChart
//
//  Created by Pavan Podila on 2/26/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "PieView.h"
#import "Model/TestDataSource.h"

@interface PSViewController : UIViewController<CPTBarPlotDataSource, CPTBarPlotDelegate,CPTPlotSpaceDelegate>
{
    @private
    CPTGraph* graph;
    CPTGraph* graph2;
    TestDataSource* dataSource;
    
}


@property (weak, nonatomic) IBOutlet PieView *pieView;

@property (nonatomic, retain) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, retain) IBOutlet CPTGraphHostingView *hostView2;
@property (nonatomic, strong) CPTTheme *selectedTheme;
@end
