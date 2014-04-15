//
// Created by sureone on 2/13/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ContentViewController.h"
#import "CPTPlotSpace.h"
#import "CPTBarPlot.h"
#import "CorePlot-CocoaTouch.h"
#import "XLModelDataInterface.h"
#import "HomeUserTextDataViewController.h"
#import "MBProgressHUD.h"
#import "KOAProgressBar.h"
#import "RTLabel.h"

@class CPTGraph;
@class TestDataSource;
@class CPTGraphHostingView;
@class CPTTheme;
@class RKTabView;




@protocol HomeUserPlotViewDelegate

@optional

-(void)testPlotRecordSelectedWithIndex:(int)idx withData:(id)data;
-(void)pleaseTurnThePanGestureOff:(BOOL)yes;

@end

@interface HomeUserPlotViewController : UIViewController <CPTPlotDataSource, CPTPlotSpaceDelegate,CPTTradingRangePlotDataSource,CPTTradingRangePlotDelegate,MBProgressHUDDelegate,UIUpdateDelegate>
/*<UIPickerViewDelegate,UIPickerViewDataSource>*/
{
    CPTGraph* graph;
    CPTGraph* graph2;
    RKTabView* plotTabs;    
    TestDataSource* dataSource;
    
    UIView* plotButtonsViewHolder;
    UIButton *switchPlotTypeButton;
    id plotDelegate;


}
@property (nonatomic,assign) NSInteger curRecordsRange;
@property (nonatomic, retain) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, retain) IBOutlet CPTGraphHostingView *hostView2;
@property (nonatomic, retain) XLViewDataUserBaiscInfo *user;
@property (nonatomic, retain) NSMutableArray *userPlots;
@property (nonatomic, retain) IBOutlet RKTabView *plotTabs;
@property (nonatomic, retain) IBOutlet UIView *plotButtonsViewHolder;
@property (nonatomic, retain) IBOutlet UIButton *switchPlotTypeButton;

@property (weak, nonatomic) IBOutlet UIButton *switchPlotTimeTypeButton;
@property (nonatomic,weak) HomeUserTextDataViewController* textDataView;

@property (nonatomic, retain) id plotDelegate;


@property (nonatomic) NSString *viewType;



@property (nonatomic, strong) NSArray *currPlotData;
@property (nonatomic, strong) NSArray *currPlotData2;

@property (nonatomic, strong) CPTTheme *selectedTheme;

@property (nonatomic) NSString *userId;
@property (nonatomic) enum _XLViewPlotDataType plotDataType;
@property (nonatomic) NSDate *refDate;
@property (nonatomic, retain) IBOutlet UIButton *backWordButton;
@property (nonatomic, retain) IBOutlet UIButton *forWordButton;

@property (nonatomic) XLViewPlotTimeType plotTimeType;
@property (weak, nonatomic) IBOutlet UILabel *labelForCurrPlotType;


-(IBAction)plotGowardTouchDown:(id)sender;
-(IBAction)plotGowardTouchUpInside:(id)sender;
-(IBAction)plotGowardTouchUpOutside:(id)sender;

//Give the timer properties.
@property (nonatomic, retain) NSTimer * timer;
@property (weak, nonatomic) IBOutlet UIView *viewForCurrentSelectedData;
@property (weak, nonatomic) IBOutlet RTLabel *labelForCurrSelectedTime;

@property (weak, nonatomic) IBOutlet UILabel *labelForCurSelectedMax;
@property (weak, nonatomic) IBOutlet UILabel *labelForCurrSelectedMin;
@property (weak, nonatomic) IBOutlet UILabel *labelForCurrSelected0;
@property (weak, nonatomic) IBOutlet UILabel *labelForCurrSelected24;
@property (weak, nonatomic) IBOutlet UIView *viewForFlotY;
@property (weak, nonatomic) IBOutlet UILabel *labelForCurrYValue;
@property (weak, nonatomic) IBOutlet UILabel *bottomPlotTitle;
@property (weak, nonatomic) IBOutlet RTLabel *floatLabel1;
@property (weak, nonatomic) IBOutlet RTLabel *floatLabel2;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;

- (IBAction)doSwitchPlotType;

- (void) firstLoadData;
@end