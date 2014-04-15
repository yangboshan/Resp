//
//  CommonPowerPlotViewController.h
//  XLApp
//
//  Created by sureone on 2/26/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"
#import "CorePlot-CocoaTouch.h"


@interface CommonPowerPlotViewController : UIViewController<CPTPlotDataSource, CPTPlotSpaceDelegate,CPTTradingRangePlotDataSource,CPTTradingRangePlotDelegate>


@property (nonatomic) XLViewPlotDataType plotDataType;
@property (nonatomic) XLViewPlotTimeType plotTimeType;
@property (nonatomic) XLViewPlotType plotType;
@property (nonatomic) NSString* plotDataTitle;
@property (nonatomic) NSString* plotCatalog;
@property (nonatomic) NSArray* dataMapKeys;
//曲线数目
@property (nonatomic) int plotNum;
//当有多条曲线时，曲线标签
@property (nonatomic) NSArray* plotTags;
@property (nonatomic) NSArray* timeTypes;

@property (nonatomic) NSDate* refDate;

@property (nonatomic) NSString *testPointId;

@property (weak, nonatomic) IBOutlet UIView *viewPlotLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

@property (nonatomic, retain) IBOutlet UIButton *backWordButton;
@property (nonatomic, retain) IBOutlet UIButton *forWordButton;

@property (weak, nonatomic) IBOutlet UIView *viewPlotContainer;
@property (weak, nonatomic) IBOutlet UIView *viewPlotArea;
@property (weak, nonatomic) IBOutlet UIView *viewDetailArea;

@property (weak, nonatomic) IBOutlet UIScrollView *viewScrollContaner;

-(IBAction)plotGowardTouchDown:(id)sender;
-(IBAction)plotGowardTouchUpInside:(id)sender;
-(IBAction)plotGowardTouchUpOutside:(id)sender;
@end
