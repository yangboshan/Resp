//
// Created by sureone on 2/13/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "HomeUserPlotViewController.h"

#import "TestDataSource.h"
#import "CorePlot-CocoaTouch.h"

#import "CPTGraphHostingView.h"
#import "CPTTheme.h"
#import "RKTabView.h"
#import "UIViewController+AKTabBarController.h"
#import "MBButtonMenuViewController.h"
#import "KxMenu.h"
#import "LeveyPopListView.h"
#import "XLModelDataInterface.h"
#import "NSString+FontAwesome.h"
#import "Toast+UIView.h"
#import "CommonPowerPlotViewController.h"
#import "SIAlertView.h"
#import "NSNumberExtensions.h"

#import "app-config.h"
#import "NSDictionary+NSDictionary_Data.h"

@interface HomeUserPlotViewController () <MBButtonMenuViewControllerDelegate,LeveyPopListViewDelegate,RKTabViewDelegate>

@property (nonatomic, strong) MBButtonMenuViewController *menu;

@end

@implementation HomeUserPlotViewController {

    UIButton* realBtn;
    UIButton* dayBtn;
    UIButton* weekBtn;
    UIButton* monthBtn;
    UIButton* yearBtn;
    NSMutableArray *dataOptions;

    NSString* currPopmenuType;
    
    
    BOOL isTopPlotAdded;
    BOOL isBottomPlotAdded;
    
    NSTimer * timer;
    NSTimer * longPressTimer;
    int gForwardKeepFlag;
    
    int curSelectRecord;
    int longPressCount;
    
    NSDate *curSelectedDate;
    
    MBProgressHUD *loadingView;
    
    BOOL isHideEd;
    
    BOOL isLoadingData;
  
//
//    UIPickerView *pickerView;
//    UIActionSheet *pickerViewPopup;

    
}




@synthesize plotButtonsViewHolder;

@synthesize plotDelegate;

- (void)processTheDataSelect:(CGPoint)point withOrigPoint:(CGPoint)origPt{
    
    if(self.currPlotData==nil) return;
    
    
    
    
    float count = self.currPlotData.count+0.5;
    
//    int idx=count*point.x;
//    
// //   -(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx
//    
//    if(idx<count-0.5)
    
//    NSLog(@"raw idx=%f",point.x);
    int idx = point.x+0.5;
    if(idx<0) idx=0;
    if(idx>=self.currPlotData.count) idx=self.currPlotData.count-1;
    
    [self barPlot:nil barWasSelectedAtRecordIndex:(idx)];
    
    
    self.viewForCurrentSelectedData.hidden=NO;
    
    CGRect rect =self.viewForCurrentSelectedData.frame;
    
    if(origPt.x+rect.size.width/2+3>320){
        origPt.x=320-rect.size.width-3;
    }
    else if(origPt.x-rect.size.width/2-1<2) origPt.x=3;
    else
        origPt.x-=rect.size.width/2;
    self.viewForCurrentSelectedData.frame= CGRectMake(origPt.x,38,rect.size.width,rect.size.height);
    
    
    
    
    self.viewForFlotY.hidden=NO;
    
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet*)graph.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;
    
    float maxY = CPTDecimalFloatValue(((CPTXYPlotSpace*)(graph.defaultPlotSpace)).yRange.maxLimit);
    float minY = CPTDecimalFloatValue(((CPTXYPlotSpace*)(graph.defaultPlotSpace)).yRange.minLimit);
    float curY = maxY-point.y+minY;
    if(curY<minY) curY=minY;
    
    if(curY>maxY) curY=maxY;
    
    self.labelForCurrYValue.text= [NSString stringWithFormat:@"%.1f",curY];
    
    
    rect =self.viewForFlotY.frame;
    
    self.viewForFlotY.frame= CGRectMake(0,40+ origPt.y-rect.size.height-2,rect.size.width,rect.size.height);
    if(curSelectRecord!=idx){
        longPressCount=0;
    }
    
    curSelectRecord=idx;
    


    

    
}

- (void)doTestLoad {
	// Do something usefull in here instead of sleeping ...
	sleep(1);
}

-(void)showLoadingProgress{
//    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
//	[self.view addSubview:loadingView];
//	
//	// Regiser for HUD callbacks so we can remove it from the window at the right time
//	loadingView.delegate = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
	
//
//	// Show the HUD while the provided method executes in a new thread
//	[loadingView showWhileExecuting:@selector(doTestLoad) onTarget:self withObject:nil animated:YES];
    

    
}

-(void)showPercentProgress:(float)percent{



        if(percent==1){
            
            self.progressBar.hidden=YES;
            [self.progressBar setProgress:0 animated:NO];
        }else{
            self.progressBar.hidden=NO;
            [self.progressBar setProgress:percent animated:YES];
        }

}


-(void)hideLoadingProgress{
    //    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    //	[self.view addSubview:loadingView];
    //
    //	// Regiser for HUD callbacks so we can remove it from the window at the right time
    //	loadingView.delegate = self;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
	
    //
    //	// Show the HUD while the provided method executes in a new thread
    //	[loadingView showWhileExecuting:@selector(doTestLoad) onTarget:self withObject:nil animated:YES];
}



-(void) handleLongPressTimer:(id)sender {
    
    if(curSelectRecord>=0){
        longPressCount++;
//        NSLog(@"go to detail...");
        //40*0.05 = hold the same record for 2 seconds
        if(longPressCount==MAX_DETAIL_DIALOG_SHOW_TIMER/0.05){
            
            longPressCount=0;
            [self confirmWhetherShowDetailView];
            [longPressTimer invalidate];
            longPressTimer=nil;
        
        }
    }
    
}



-(void)showRecordDetailView{
    
    CommonPowerPlotViewController *controller = [[CommonPowerPlotViewController alloc] init];
    
    
    if(self.plotTimeType==XLViewPlotTimeDay ||
       self.plotTimeType==XLViewPlotTimeWeek||
       self.plotTimeType==XLViewPlotTimeMonth){
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:curSelectedDate];
        
        NSInteger hour = [components hour];
        NSInteger minutes = [components minute];
        NSInteger seconds = [components second];
        
        
        seconds = [curSelectedDate timeIntervalSince1970]-hour*60*60-minutes*60-seconds;                
        controller.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    }
    
    if(self.plotTimeType==XLViewPlotTime5Min||
       self.plotTimeType==XLViewPlotTime15Min||
       self.plotTimeType==XLViewPlotTime30Min ||
              self.plotTimeType==XLViewPlotTime60Min){
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:curSelectedDate];

        NSInteger seconds = [components second];
        
        
        seconds = [curSelectedDate timeIntervalSince1970]-seconds;
        controller.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    }
        
    controller.plotDataType=self.plotDataType;
    
    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower){ //
        controller.plotDataType=XLViewPlotDataSumAndTPRealPowerScatter; //总及三相有功功率曲线图
        
    }
    
    if(self.plotDataType==XLViewPlotDataSumAndTPReactivePower){ //
        controller.plotDataType=XLViewPlotDataSumAndTPReactivePowerScatter; //总及三相有功功率曲线图
        
    }
    if(self.plotDataType==XLViewPlotDataSumAndTPPowerFactor){ //
        controller.plotDataType=XLViewPlotDataSumAndTPPowerFactorScatter; //总及三相有功功率曲线图
        
    }
    
    controller.plotType=PLOT_DETAIL;
    controller.plotDataTitle=_labelForCurrPlotType.text;
    controller.plotTimeType= self.plotTimeType;

    [self.navigationController pushViewController:controller animated:YES];
    
}


id observer1,observer2,observer3,observer4;



-(void)confirmWhetherShowDetailView
{
    
    int timeUnit = [self getXSeconds];
    
    
    
    NSDateFormatter *dateFormatter = [self getDateformater];
    
    NSDate *date = [self.refDate dateByAddingTimeInterval:curSelectRecord*timeUnit ];
    

    
    
    
    
    
    
    curSelectedDate=date;

    
    NSString *dateString = [dateFormatter stringFromDate:date];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:nil andMessage:
                              [NSString stringWithFormat:@"查看\"%@\" 的详细数据？",
                               dateString]];
    [alertView addButtonWithTitle:@"不"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"Cancel Clicked");
                          }];
    [alertView addButtonWithTitle:@"是"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              NSLog(@"OK Clicked");
                              [self showRecordDetailView];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    
    alertView.willShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willShowHandler3", alertView);
    };
    alertView.didShowHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didShowHandler3", alertView);
    };
    alertView.willDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, willDismissHandler3", alertView);
    };
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
        NSLog(@"%@, didDismissHandler3", alertView);
    };
    
    observer1 = [[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillShowNotification
                                                                  object:alertView
                                                                   queue:[NSOperationQueue mainQueue]
                                                              usingBlock:^(NSNotification *note) {
                                                                  NSLog(@"%@, -willShowHandler3", alertView);
                                                              }];
    observer2 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidShowNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 NSLog(@"%@, -didShowHandler3", alertView);
                                                             }];
    observer3 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewWillDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 NSLog(@"%@, -willDismissHandler3", alertView);
                                                             }];
    observer4 =[[NSNotificationCenter defaultCenter] addObserverForName:SIAlertViewDidDismissNotification
                                                                 object:alertView
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 NSLog(@"%@, -didDismissHandler3", alertView);
                                                                 
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer1];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer2];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer3];
                                                                 [[NSNotificationCenter defaultCenter] removeObserver:observer4];
                                                                 
                                                                 observer1 = observer2 = observer3 = observer4 = nil;
                                                             }];
    
    [alertView showWithDelay:5];
    

}





-(void)handlePinchGesture:(UIPinchGestureRecognizer *)gesture {
    
    
    CGPoint interactionPoint = [gesture locationInView:self.hostView];
    
    
    
    //interactionPoint.y = self.hostView.frame.size.height - interactionPoint.y;
    
//    if(interactionPoint.y<0) return;

    //interactionPoint.x = self.hostView.frame.size.width/2;
    interactionPoint.y = self.hostView.frame.size.height/2;
    
    CGFloat scale = [[gesture valueForKey:@"scale"] cgFloatValue];
    
    
    
    NSLog(@"pintch point(x,y)=(%f,%f)",interactionPoint.x,interactionPoint.y);
    NSLog(@"current pinch scale=%f",scale);
    
    [self.hostView commonProcessScaleAtPoint:interactionPoint withScale:scale];
    
    
    CPTXYPlotSpace *xySpace = graph.defaultPlotSpace;
    
    CPTPlotRange *newXRange = xySpace.xRange;
    
    
    CPTXYAxisSet *xyAxisSet = (CPTXYAxisSet*)graph.axisSet;
    
    CPTXYAxis *xAxis = xyAxisSet.xAxis;

//    _curRecordsRange= CPTDecimalIntegerValue( CPTDecimalDivide(newXRange.length, xAxis.majorIntervalLength));
    
    //                NSLog(@"records number = %f after scale",CPTDecimalDoubleValue(records));

    
    
    [gesture setScale:1.0f];
}


- (void)handleLongPressPlotView:(UILongPressGestureRecognizer *)gesture {
    if(UIGestureRecognizerStateBegan == gesture.state) {
        // Called on start of gesture, do work here
//        NSLog(@"gesture start");
        
        
        
        NSUInteger *touchCount = [gesture numberOfTouches];
        for (NSUInteger t = 0; t < touchCount; t++) {
            CGPoint point = [gesture locationOfTouch:t inView:gesture.view];
            if(gesture.view==self.hostView){
//                NSLog(@"long press move %f,%f",point.x,point.y);
                CGPoint pt = [graph convertTheSelectPoint:point];
                
                curSelectRecord=-2;
                longPressCount=0;
                [self processTheDataSelect:pt withOrigPoint:point];
                
                [graph showMeasureLinesAtPoint:point];
                [graph2 showRelativeMeasureLinesAtPoint:point];
                
                longPressTimer= [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(handleLongPressTimer:) userInfo:nil repeats:YES];
            }
            
            
            
            
        }
      
        [plotDelegate pleaseTurnThePanGestureOff:YES];
    }
    
    if(UIGestureRecognizerStateChanged == gesture.state) {
        // Do repeated work here (repeats continuously) while finger is down

        NSUInteger *touchCount = [gesture numberOfTouches];
        for (NSUInteger t = 0; t < touchCount; t++) {
            CGPoint point = [gesture locationOfTouch:t inView:gesture.view];
            if(gesture.view==self.hostView){
//                NSLog(@"long press move %f,%f",point.x,point.y);
                CGPoint pt = [graph convertTheSelectPoint:point];
                [self processTheDataSelect:pt withOrigPoint:point];
                [graph showMeasureLinesAtPoint:point];
                [graph2 showRelativeMeasureLinesAtPoint:point];
            }
            
            
        

        }
        
        
    }
    
    if(UIGestureRecognizerStateEnded == gesture.state) {
        // Do end work here when finger is lifted
       NSLog(@"gesture ends");
        [plotDelegate pleaseTurnThePanGestureOff:NO];
        if(gesture.view==self.hostView){
            [graph hideMeasureLines];
            [graph2 hideMeasureLines];
            curSelectRecord=-1;
            longPressCount=0;
            [longPressTimer invalidate];
            longPressTimer = nil;
        }
        
        self.viewForCurrentSelectedData.hidden=YES;
            self.viewForFlotY.hidden=YES;
        
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isLoadingData=NO;
    
    
    if([_viewType isEqualToString:@"user"]){
        
        if(IS_IPHONE && IS_IPHONE_5)
        {
            self.hostView.frame=CGRectMake(0, 36, 320, 204);
            
            self.progressBar.frame=CGRectMake(32,240,287,2);
            
            self.hostView2.frame=CGRectMake(0, 243, 320, 74);
            
            self.plotTabs.frame=CGRectMake(0, 331, 320, 23);
            
        }
        else if(IS_IPHONE)
        {
            
            self.hostView.frame=CGRectMake(0, 36, 320, 150);
            self.progressBar.frame=CGRectMake(32,185,287,2);
            
            self.hostView2.frame=CGRectMake(0, 188, 320, 48);
            
            
            self.plotTabs.frame=CGRectMake(0, 247, 320, 23);
            
            self.bottomPlotTitle.frame=CGRectMake(34, 185, 60, 23);
            
            
        }
        else
        {
            
        }
        
     
        
    }else if([_viewType isEqualToString:@"line"]){
                    self.plotTabs.hidden=YES;
        
        if(IS_IPHONE && IS_IPHONE_5)
        {
            self.hostView.frame=CGRectMake(0, 36, 320, 204);
            self.progressBar.frame=CGRectMake(32,240,287,2);
            
            self.hostView2.frame=CGRectMake(0, 243, 320, 74);
            

            
        }
        else if(IS_IPHONE)
        {
            
            self.hostView.frame=CGRectMake(0, 36, 320, 150);
            self.progressBar.frame=CGRectMake(32,185,287,2);
            
            self.hostView2.frame=CGRectMake(0, 188, 320, 48);
            
            
            
            
            
        }
        else
        {
            
        }
        
    }else if([_viewType isEqualToString:@"system"]){
        self.plotTabs.hidden=YES;
        
        if(IS_IPHONE && IS_IPHONE_5)
        {
            self.hostView.frame=CGRectMake(0, 36, 320, 204);
            self.progressBar.frame=CGRectMake(32,240,287,2);
            
            self.hostView2.frame=CGRectMake(0, 243, 320, 74);
            
            
            
        }
        else if(IS_IPHONE)
        {
            
            self.hostView.frame=CGRectMake(0, 36, 320, 150);
            self.progressBar.frame=CGRectMake(32,185,287,2);
            self.hostView2.frame=CGRectMake(0, 188, 320, 48);
            
            
            
            
        }
        else
        {
            
        }
    }
    
    isHideEd=YES;
    
    
    //add long press gesture
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPressPlotView:)];
    longPress.minimumPressDuration = .5;
    [_hostView addGestureRecognizer:longPress];
#ifdef SCALE_FROM_PARENT
    Class pinchClass = NSClassFromString(@"UIPinchGestureRecognizer");
    if ( pinchClass ) {
    
        UIPinchGestureRecognizer *pinchGestureRecognizer = [[pinchClass alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        [self.view addGestureRecognizer:pinchGestureRecognizer];
    }
#endif
    

    
    isTopPlotAdded=NO;
    isBottomPlotAdded=NO;

    [self setupStatButtons];
    [self initPlot];
    
    
    gForwardKeepFlag = NO;
    

    
    self.viewForCurrentSelectedData.hidden=YES;
    
        self.viewForFlotY.hidden=YES;
    
    
    self.plotTabs.titlesFontColor=[UIColor whiteColor];
    self.plotTabs.titlesFont=[UIFont boldSystemFontOfSize:12];
    self.plotTabs.horizontalInsets = HorizontalEdgeInsetsMake(2, 2, 3);
    self.plotTabs.drawSeparators = YES;
    self.plotTabs.currTab=0;
    self.plotTabs.delegate=self;
    
    curSelectRecord=-1;
    

    
    if(_curRecordsRange==0) self.curRecordsRange=DEFAULT_RECORDS_RANGE;
    
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProgressPecentNotify:) name:XLViewProgressPercent object:nil];
    
//    [self requestPlotData:self.refDate withRecords:_curRecordsRange withTPId:0];
    
}


- (void) firstLoadData{
    
    [self gotoToday];
    [self requestPlotData:self.refDate withRecords:_curRecordsRange withTPId:0];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if([self.viewType isEqualToString:@"user"]){
        [self loadPlotTabs];
    }
}


-(void)gotoToday{
    self.refDate = [NSDate dateWithTimeIntervalSinceNow:0];
    
    
    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSWeekdayCalendarUnit fromDate:self.refDate];
    
    NSInteger seconds = [components second];
    NSInteger minutes = [components minute];
    NSInteger hours = [components hour];

    
    
    
    
    
    if(self.plotTimeType==XLViewPlotTime1Min){
        
        seconds+=29*60;
        
        seconds = [self.refDate timeIntervalSince1970]-seconds;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
        
    }
    
    if(self.plotTimeType==XLViewPlotTime5Min){
        
        minutes=minutes % 5;
        
        seconds+=29*60*5;
        
        seconds = [self.refDate timeIntervalSince1970]-minutes*60-seconds;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
        
    }
    
    if(self.plotTimeType==XLViewPlotTime15Min){
        
        minutes=minutes % 15;
                seconds+=29*60*15;
        
        seconds = [self.refDate timeIntervalSince1970]-minutes*60-seconds;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
    }
    
    if(self.plotTimeType==XLViewPlotTime30Min){
        
        minutes=minutes % 30;
                seconds+=29*60*30;
        
        seconds = [self.refDate timeIntervalSince1970]-minutes*60-seconds;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
    }
    
    if(self.plotTimeType==XLViewPlotTime60Min){
        
                seconds+=29*60*60;
        
        seconds = [self.refDate timeIntervalSince1970]-minutes*60-seconds;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
    }
    
    if(self.plotTimeType==XLViewPlotTimeDay){
        
        double seconds = 24*60*60*29;
        seconds = [self.refDate timeIntervalSince1970]-seconds;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
    }
    
    if(self.plotTimeType==XLViewPlotTimeWeek){
        
        NSInteger dayWeek = [components weekday];
        
        double seconds = hours*60*60+minutes*60+seconds;
        
        if(dayWeek==1) //sunday
        {
            seconds+=6*24*60*60;
        }
        
        if(dayWeek>2){
            seconds+=(dayWeek-2)*24*60*60;
        }
        
        
        seconds+=7*24*60*60*29;
        
        
        seconds = [self.refDate timeIntervalSince1970]-seconds;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
    }
    
    if(self.plotTimeType==XLViewPlotTimeMonth){

        
        seconds+=30*24*60*60*29;
        seconds = [self.refDate timeIntervalSince1970]-seconds;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds];
        
        
        
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSWeekdayCalendarUnit fromDate:self.refDate];
        
        NSInteger seconds2 = [components second];
        NSInteger minutes2 = [components minute];
        NSInteger hours2 = [components hour];
        NSInteger day2 = [components day];
        
        seconds2+=minutes2*60+hours*60*60+(day2-1)*24*60*60;
        
        
        seconds2 = [self.refDate timeIntervalSince1970]-seconds2;
        self.refDate = [NSDate dateWithTimeIntervalSince1970:seconds2];
        
        

    }
    
    if(self.plotTimeType==XLViewPlotTimeYear){
        
        
        NSInteger year = [components year];
        year-=28;
        
        
        NSString *start = [NSString stringWithFormat:@"%d-01-01 00:00:00", year];
        
        NSDateFormatter *f = [[NSDateFormatter alloc] init];
        [f setDateFormat:@"yy-MM-dd hh:mm:ss"];
        self.refDate = [f dateFromString:start];
        
        
        
    }
}

- (void)plotSwitchBtnPressed:(id)sender {
    NSLog(@"Button %@ has been pressed in tabView", sender);

    
    XLViewPlotTimeType lastType = self.plotTimeType;

    if(sender==realBtn){
        
        
        [self showPlotTimeTypePopMenu];
        
        
    }
    
    if(sender==weekBtn){
        self.plotTimeType=XLViewPlotTimeWeek;
    }
    if(sender==yearBtn){
        self.plotTimeType=XLViewPlotTimeYear;
    }
    if(sender==monthBtn){
        self.plotTimeType=XLViewPlotTimeMonth;
    }
    if(sender==dayBtn){
        self.plotTimeType=XLViewPlotTimeDay;
    }
    for(UIButton* btn in plotButtonsViewHolder.subviews){

        if(btn==sender){
           btn.titleLabel.textColor = [UIColor whiteColor];
           [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];



        }
        else{
            btn.titleLabel.textColor = [UIColor darkGrayColor];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }

    }
    
    
    if(self.plotTimeType!=lastType){
        [self gotoToday];
    }
    
    self.textDataView.plotTimeType = self.plotTimeType;
    
    if(sender!=realBtn){
        [self requestPlotData:self.refDate withRecords:_curRecordsRange withTPId:0];
    }

}


-(void)setupStatButtons
{

    float width = self.view.frame.size.width;
    float height = self.plotButtonsViewHolder.frame.size.height;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [button setTitle:@"60分钟▽" forState:UIControlStateNormal];



    [button setFrame:CGRectMake(0,0,width/5,height)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0, 0.0, 0.0 )];

    [button addTarget:self action:@selector(plotSwitchBtnPressed:) forControlEvents:UIControlEventTouchDown];
    
    [plotButtonsViewHolder addSubview:button];
    
    realBtn = button;
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button setTitle:@"日" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0,0,width/5,height)];

    [button addTarget:self action:@selector(plotSwitchBtnPressed:) forControlEvents:UIControlEventTouchDown];
    
    [plotButtonsViewHolder addSubview:button];
    
    dayBtn = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button setTitle:@"周" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0,0,width/5,height)];
    
    [button addTarget:self action:@selector(plotSwitchBtnPressed:) forControlEvents:UIControlEventTouchDown];
    
    [plotButtonsViewHolder addSubview:button];
    
    weekBtn = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button setTitle:@"月" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0,0,width/5,height)];

    [button addTarget:self action:@selector(plotSwitchBtnPressed:) forControlEvents:UIControlEventTouchDown];
    
    [plotButtonsViewHolder addSubview:button];
    
    monthBtn = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [button setTitle:@"年" forState:UIControlStateNormal];

    [button setFrame:CGRectMake(0,0,width/5,height)];

    [button addTarget:self action:@selector(plotSwitchBtnPressed:) forControlEvents:UIControlEventTouchDown];
    
    [plotButtonsViewHolder addSubview:button];
    
    yearBtn = button;



    [dayBtn setFrame:CGRectMake(width/5,0,width/5,height)];
    
    [weekBtn setFrame:CGRectMake(width*2/5,0,width/5,height)];

    [monthBtn setFrame:CGRectMake(width*3/5,0,width/5,height)];
    [yearBtn setFrame:CGRectMake(width*4/5,0,width/5,height)];
    
    
    
    [weekBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [dayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [yearBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [realBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [monthBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    
    
    //默认曲线
    self.plotTimeType = XLViewPlotTimeDay;
    self.plotDataType = XLViewPlotDataSumAndTPRealPower;


    self.switchPlotTimeTypeButton.hidden=YES;
    
    UIImage * backgroundImg = [UIImage imageNamed:@"plot_tab_buttons_middle_normal_bg.png"];
    
//    backgroundImg = [backgroundImg resizableImageWithCapInsets:UIEdgeInsetsMake(2,2, 2, 2)];
    
    [dayBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    [weekBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    [monthBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    
    
    
    
    
//    backgroundImg = [UIImage imageNamed:@"plot_tab_buttons_left_normal_bg.png"];
    backgroundImg = [UIImage imageNamed:@"plot_tab_buttons_middle_normal_bg.png"];
    [realBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
//    backgroundImg = [UIImage imageNamed:@"plot_tab_buttons_right_normal_bg.png"];
    
    [yearBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    
    
    
    
    
    
    
    
//    
//    UIImage *image = [[UIImage imageNamed:@"tab_bar_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
//	[button setBackgroundImage:image forState:UIControlStateNormal];
//	[button setBackgroundImage:image forState:UIControlStateHighlighted];
    
}

- (void)loadPlotTabs
{
    self.user = [XLModelDataInterface testData].currentUser;
    if (!self.user) {
        [self.view.superview makeToast:@"请先选择当前用户"];
        self.userPlots = nil;
    } else {
        self.userPlots = [NSMutableArray array];
        for (XLViewDataUserSumGroup *group in self.user.sumGroups) {
            if (group.attention) {
                [self.userPlots addObject:group];
            }
        }
        [self.userPlots addObjectsFromArray:[[XLModelDataInterface testData] queryTestPointsWithAttentionForUser:self.user]];
    }

    NSMutableArray *tabItems = [NSMutableArray arrayWithCapacity:self.userPlots.count];
    [self.userPlots enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RKTabItem *item = [RKTabItem createButtonItemWithImage:[UIImage imageNamed:nil] target:self selector:@selector(buttonTabPressed:)];
        if ([obj isKindOfClass:[XLViewDataUserSumGroup class]]) {
            item.titleString = ((XLViewDataUserSumGroup *)obj).groupName;
        } else if ([obj isKindOfClass:[XLViewDataTestPoint class]]) {
            item.titleString = ((XLViewDataTestPoint *)obj).pointName;
        } else {
            NSAssert(NO, @"userPlots should contain sumGroup or testPoint");
        }
        [tabItems addObject:item];
    }];

    [self.plotTabs setTabItems:tabItems];
    
    NSInteger curTab = 0;
    if (self.user.currentTestPointOrGroup) {
        curTab = [self.userPlots indexOfObject:self.user.currentTestPointOrGroup];
        if (curTab == NSNotFound) {
            curTab = 0;
        }
    } else if (self.userPlots.count > 0) {
        self.user.currentTestPointOrGroup = [self.userPlots objectAtIndex:0];
    }
    NSLog(@"curTab = %d", curTab);
    self.plotTabs.currTab = curTab;
}

- (void)tabView:(RKTabView *)tabView tabSelectedAtIndex:(int)index{
    self.user.currentTestPointOrGroup = [self.userPlots objectAtIndex:index];
}

#pragma mark 切换统计项目

@synthesize switchPlotTypeButton;



- (void)plotGoward {
    
    if(isLoadingData) return;
    
    NSDate* newDate=nil;
    
    NSTimeInterval offset=0;
    
    int forwardSpeed=1;
    
    if(self.currPlotData!=nil){
        offset = forwardSpeed*([self getXSeconds]);
    }
    
    //move x asis forward
    if(gForwardKeepFlag==1){
        

            newDate=[self.refDate dateByAddingTimeInterval:offset];
    }else{

            newDate=[self.refDate dateByAddingTimeInterval:-offset];
        
    }
    
    
    
    
    [self requestPlotData:newDate withRecords:_curRecordsRange withTPId:0];
}

-(void)setRefDate:(NSDate *)refDate{
    _refDate=refDate;
    
    [self.textDataView updatePlotDate:refDate];


}



-(IBAction)plotGowardTouchDown:(id)sender{
    
    
    [plotDelegate pleaseTurnThePanGestureOff:YES];
    if(sender==self.forWordButton){
        
        gForwardKeepFlag=1;
        
    }else{
        gForwardKeepFlag=2;
    }
    

    [self plotGoward];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(keepForward:) userInfo:nil repeats:YES];
    
    
    
}
-(IBAction)plotGowardTouchUpInside:(id)sender{
    
    gForwardKeepFlag=0;
    
    
    [plotDelegate pleaseTurnThePanGestureOff:NO];
    
    [timer invalidate];
    timer=nil;
    
}
-(IBAction)plotGowardTouchUpOutside:(id)sender{
    
    [plotDelegate pleaseTurnThePanGestureOff:NO];
    gForwardKeepFlag=0;
    [timer invalidate];
    timer=nil;
    
}


-(void) keepForward:(id)sender {
    if (gForwardKeepFlag >0) {
        //This is for "Touch and Hold"
        
        
        [self plotGoward];
    }
    else {
        //This is for the person is off the button.
    }
}

- (IBAction) doSwitchPlotType{
    NSLog(@"switch plot type button clicked");
    [self showPlotTypePopMenu];
}

- (IBAction) doSwitchPlotTimeType{
    NSLog(@"switch plot type button clicked");
    [self showPlotTimeTypePopMenu];
}




- (void)showPlotTimeTypePopMenu
{

    dataOptions = [NSArray arrayWithObjects:
                [NSDictionary dictionaryWithObjectsAndKeys:@"1分钟",@"text", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:@"5分钟",@"text", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:@"15分钟",@"text", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:@"30分钟",@"text", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:@"60分钟",@"text", nil],
                nil];
    

    

    UIWindow *frontWindow = [[[UIApplication sharedApplication] windows]
            lastObject];


    LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"选择数据项目" options:dataOptions];
    lplv.delegate = self;
    [lplv showInView:frontWindow animated:YES];

    currPopmenuType=@"plotTimeType";

}


- (void)showPlotTypePopMenu
{
    
    
    
    NSString *edMenuStr=@"显示额定值";
    if(isHideEd==NO){
        edMenuStr=@"隐藏额定值";
    }

        dataOptions = [NSMutableArray arrayWithObjects:
                       [NSDictionary dictionaryWithObjectsAndKeys:@"总/三相有功功率",@"text", [NSNumber numberWithInt:XLViewPlotDataSumAndTPRealPower],@"value", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"总/三相无功功率",@"text", [NSNumber numberWithInt:XLViewPlotDataSumAndTPReactivePower],@"value", nil],
                       [NSDictionary dictionaryWithObjectsAndKeys:@"总/三相功率因数",@"text", [NSNumber numberWithInt:XLViewPlotDataSumAndTPPowerFactor],@"value", nil],

                       
                       
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"电压相位角",@"text", nil],
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"电流相位角",@"text", nil],
                       
                       nil];
    
    
    if(self.plotTimeType!=XLViewPlotTimeMonth &&
       self.plotTimeType!=XLViewPlotTimeWeek &&
       self.plotTimeType!=XLViewPlotTimeYear
       ){
        
        [dataOptions addObject:
         [NSDictionary dictionaryWithObjectsAndKeys:@"三相电压",@"text", [NSNumber numberWithInt:XLViewPlotDataTPVolt],@"value", nil]];
        [dataOptions addObject:
         [NSDictionary dictionaryWithObjectsAndKeys:@"三相电流",@"text", [NSNumber numberWithInt:XLViewPlotDataTPCurr],@"value", nil]];
        
    }
    
    if(self.plotDataType==XLViewPlotDataTPCurr ||
       self.plotDataType==XLViewPlotDataTPVolt ||
       self.plotDataType==XLViewPlotDataSumAndTPRealPower){
        [dataOptions addObject:
        [NSDictionary dictionaryWithObjectsAndKeys:edMenuStr,@"text", [NSNumber numberWithInt:XLViewPlotDataTypeNoneForEdMenu],@"value", nil]];
    }

    
    UIWindow *frontWindow = [[[UIApplication sharedApplication] windows]
                             lastObject];
    

    LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"选择数据项目" options:dataOptions];
    lplv.delegate = self;
    [lplv showInView:frontWindow animated:YES];


    currPopmenuType = @"plotType";
    
    
    
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{

    
    
    NSString *title = [NSString stringWithFormat:@"%@",[[dataOptions objectAtIndex:anIndex] objectForKey:@"text"]];


    if([currPopmenuType isEqualToString:@"plotType"]){
        
        
        NSNumber *value = [[dataOptions objectAtIndex:anIndex] objectForKey:@"value"];
        
        if([value intValue]!=XLViewPlotDataTypeNoneForEdMenu){
            self.labelForCurrPlotType.text=title;
        }else{
            isHideEd=!isHideEd;
        }
        
        
        



        switch ([value intValue]){
            case XLViewPlotDataSumAndTPRealPower:
                self.plotDataType=XLViewPlotDataSumAndTPRealPower;
                self.bottomPlotTitle.text=@"电量";
                weekBtn.enabled=YES;
                yearBtn.enabled=YES;
                monthBtn.enabled=YES;
                break;
            case XLViewPlotDataSumAndTPReactivePower:
                self.plotDataType=XLViewPlotDataSumAndTPReactivePower;
                self.bottomPlotTitle.text=@"电量";
                weekBtn.enabled=YES;
                yearBtn.enabled=YES;
                monthBtn.enabled=YES;
                break;
            case XLViewPlotDataSumAndTPPowerFactor:
                self.plotDataType=XLViewPlotDataSumAndTPPowerFactor;
                
                self.bottomPlotTitle.text=@"电量";
                weekBtn.enabled=YES;
                yearBtn.enabled=YES;
                monthBtn.enabled=YES;
                break;
            case XLViewPlotDataTPVolt:
                self.plotDataType=XLViewPlotDataTPVolt;
                self.bottomPlotTitle.text=@"三相电流";
                weekBtn.enabled=NO;
                yearBtn.enabled=NO;
                monthBtn.enabled=NO;
                
                
                break;

            case XLViewPlotDataTPCurr:
                self.plotDataType=XLViewPlotDataTPCurr;
                self.bottomPlotTitle.text=@"三相电压";
                weekBtn.enabled=NO;
                yearBtn.enabled=NO;
                monthBtn.enabled=NO;
                break;
        }
        
        if(self.plotDataType==XLViewPlotDataTPCurr ||
           self.plotDataType==XLViewPlotDataTPVolt){
            if(self.plotTimeType==XLViewPlotTimeWeek || self.plotTimeType==XLViewPlotTimeMonth || self.plotTimeType==XLViewPlotTimeYear){
                self.textDataView.plotDataType=self.plotDataType;
                [self plotSwitchBtnPressed:dayBtn];
                return;
                
            }
            
        }
    }if([currPopmenuType isEqualToString:@"plotTimeType"]){

        
        NSString *title = [NSString stringWithFormat:@"%@▽",[[dataOptions objectAtIndex:anIndex] objectForKey:@"text"]];
        
        [realBtn setTitle:title forState:UIControlStateNormal];
        
        XLViewPlotTimeType lastType = self.plotTimeType;

        switch (anIndex){
            case 0:
                self.plotTimeType =XLViewPlotTime1Min;
                break;
            case 1:
                self.plotTimeType=XLViewPlotTime5Min;
                break;
            case 2:
                self.plotTimeType=XLViewPlotTime15Min;
                break;
            case 3:
                self.plotTimeType=XLViewPlotTime30Min;
                break;
            case 4:
                self.plotTimeType=XLViewPlotTime60Min;
                break;
        }
        
        if(self.plotTimeType!=lastType){
            [self gotoToday];
        }

    }
    

    self.textDataView.plotDataType=self.plotDataType;
    self.textDataView.plotTimeType=self.plotTimeType;
    
    [self requestPlotData:self.refDate withRecords:_curRecordsRange withTPId:0];
}
- (void)leveyPopListViewDidCancel
{

}

#pragma mark - popup kxmenu demo

- (void)showKxMenu
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"选择项目"
                     image:nil
                    target:nil
                    action:NULL],
      
      [KxMenuItem menuItem:@"总/三相有功功率"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"总/三相无功功率"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"总/三相功率因数"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"三相电压"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"三相电流"
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
//      [KxMenuItem menuItem:@"电压相位角"
//                     image:nil
//                    target:self
//                    action:@selector(pushMenuItem:)],
//      [KxMenuItem menuItem:@"电流相位角"
//                     image:nil
//                    target:self
//                    action:@selector(pushMenuItem:)],
      ];
    
    KxMenuItem *first = menuItems[0];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    
    [KxMenu showMenuInView:self.view
                  fromRect:switchPlotTypeButton.frame
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
    
    KxMenuItem* item = sender;
    NSString *title = [NSString stringWithFormat:@"%@",item.title];
                
    [self.switchPlotTypeButton setTitle:title forState:UIControlStateNormal];
}

- (void) showButtonMenu {
    if (![self menu]) {

        NSArray *titles = @[@"总/三相有功功率",
                @"总/三相无功功率",
                @"总/三相功率因数",
                @"三相电压",
                @"三相电流",
//                @"电压相位角",
//                @"电流相位角",
                @"关闭"];
        _menu = [[MBButtonMenuViewController alloc] initWithButtonTitles:titles];
        [_menu setDelegate:self];
        [_menu setCancelButtonIndex:[[_menu buttonTitles]count]-1];
    }

    [[self menu] showInView:[self view]];
}




#pragma mark - MBButtonMenuViewControllerDelegate

- (void)buttonMenuViewController:(MBButtonMenuViewController *)buttonMenu buttonTappedAtIndex:(NSUInteger)index
{
    //
    //  Hide the menu
    //

    [buttonMenu hide];

    //
    //  Create a title
    //

    NSString *title = [NSString stringWithFormat:@"▲%@",
    [[self menu] buttonTitles][index]];




    [self.switchPlotTypeButton setTitle:title forState:UIControlStateNormal];

//    NSString *message = [NSString stringWithFormat:@"You chose %@", title];
//
//    //
//    //  Show an alert
//    //
//
//    UIAlertView *alert = [[UIAlertView alloc]
//            initWithTitle:nil
//                  message:message
//                 delegate:nil
//        cancelButtonTitle:@"OK"
//        otherButtonTitles: nil];
//    [alert show];
}

- (void)buttonMenuViewControllerDidCancel:(MBButtonMenuViewController *)buttonMenu
{
    [buttonMenu hide];
}




//BOOL pickerVisible = NO;
//NSMutableArray *dataArray = nil;
//
//- (void)showPickerView
//{
//    // Init the data array.
//     dataArray = [[NSMutableArray alloc] init];
//
//    // Add some data for demo purposes.
//    [dataArray addObject:@"One"];
//    [dataArray addObject:@"Two"];
//    [dataArray addObject:@"Three"];
//    [dataArray addObject:@"Four"];
//    [dataArray addObject:@"Five"];
//
//
//    pickerView=[[UIPickerView alloc] initWithFrame:CGRectMake(self.switchPlotTypeButton.frame.origin.x,self.switchPlotTypeButton.frame.origin.y-170,150,150)];
//
//    pickerView.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
//
//    pickerView.delegate = self;
//
//    pickerView.dataSource = self;
//
//    pickerView.showsSelectionIndicator = YES;
//
//    pickerView.backgroundColor = [UIColor clearColor];
//
//    [pickerView selectRow:1 inComponent:0 animated:YES];
//
//    pickerView.backgroundColor = [UIColor whiteColor];
//
//    [self.view addSubview:pickerView];
//
//
//}
//
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
//{
//
//    return 1;
//
//}
//
//- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
//{
//
//    return [dataArray count];
//}
//
//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//
//    return[dataArray objectAtIndex:row];
//
//}

#pragma mark 统计图

- (void)buttonTabPressed:(id)sender {
    NSLog(@"Button %@ has been pressed in tabView", sender);

}

#pragma mark plot setup

-(void) commoneSetupPlot:(CPTGraph*) graph
{
    
    if(self.currPlotData==nil) return;

    graph.paddingLeft=0;
    graph.paddingRight=0;
    graph.paddingTop=0;
    graph.paddingBottom=0;

    graph.plotAreaFrame.masksToBorder = NO;
    graph.plotAreaFrame.cornerRadius = 0.0f;
    #ifdef SCALE_FROM_PARENT
    [self.hostView setAllowPinchScaling:NO];
#else
    [self.hostView setAllowPinchScaling:YES];
#endif
    graph.defaultPlotSpace.allowsUserInteraction = YES;
    //        graph.defaultPlotSpace.allowsUserDragging = YES;


    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor           = [CPTColor whiteColor];
    borderLineStyle.lineWidth           = 1.0f;
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.paddingTop      = 2.0f;
    graph.plotAreaFrame.paddingRight    = 2.0f;
    graph.plotAreaFrame.paddingBottom   = 2.0f;
    graph.plotAreaFrame.paddingLeft     = 32.0f;
    graph.plotAreaFrame.masksToBorder   = NO;

    // Axes

    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = AXIS_LINE_LENGTH;
    axisLineStyle.lineColor = [CPTColor darkGrayColor];


    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];

    gridLineStyle.dashPattern = @[@0.5,@1];
    gridLineStyle.lineColor=[CPTColor grayColor];
    gridLineStyle.lineWidth = 0.8f;


    CPTXYAxisSet *xyAxisSet = (id)graph.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;

    xAxis.minorTicksPerInterval = 0;
    xAxis.axisLineStyle=axisLineStyle;
    xAxis.majorTickLineStyle=axisLineStyle;
    xAxis.minorTickLineStyle=nil;

//    xAxis.majorGridLineStyle=gridLineStyle;
//    xAxis.minorGridLineStyle=gridLineStyle;
    


    xAxis.tickDirection = CPTSignPositive;
    xAxis.tickLabelDirection=CPTSignNegative;
    xAxis.majorTickLength=MAJOR_TICK_LENGTH;
    xAxis.minorTickLength=1.0f;

    //隐藏x刻度
    

    xAxis.labelTextStyle=nil;



    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    yAxis.axisLineStyle=axisLineStyle;
    yAxis.majorTickLineStyle=axisLineStyle;
    yAxis.minorTickLineStyle=axisLineStyle;
    yAxis.majorGridLineStyle=gridLineStyle;
    yAxis.minorTicksPerInterval=0;
    yAxis.tickDirection = CPTSignPositive;
    yAxis.tickLabelDirection=CPTSignNegative;
    yAxis.majorTickLength=3.0f;
    yAxis.minorTickLength=1.0f;
    


    CPTMutableTextStyle *yAxisTextStyle = [CPTMutableTextStyle textStyle];
    yAxisTextStyle.color    = [CPTColor orangeColor];
    yAxisTextStyle.fontSize = 8.0;
    yAxisTextStyle.textAlignment=CPTAlignmentLeft;
    yAxis.labelTextStyle = yAxisTextStyle;
    
    
   

}
-(void)initPlot{
    

    if(graph==nil){
        graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
        [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
        self.hostView.hostedGraph = graph;
    }


    [self commoneSetupPlot:graph];


    if(graph2==nil){
        graph2 = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
        [graph2 applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
        self.hostView2.hostedGraph = graph2;
    }


    [self commoneSetupPlot:graph2];
    
    if(self.currPlotData==nil){
        graph.hidden=YES;
        graph2.hidden=YES;
    }else{
        graph.hidden=NO;
        graph2.hidden=NO;
        
    }

    [self setupForRealPowerPlot];
    //[self testBarPlot];

    graph2.relativeGraph = graph;
    graph.relativeGraph = graph2;
    
    
    
}

-(NSTimeInterval)getXSeconds{
    
    NSTimeInterval seconds = 24 * 60 * 60;
    
    if(self.plotTimeType == XLViewPlotTimeDay){
        
        seconds=24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTimeWeek){
        
        seconds=7*24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTimeMonth){
        
        seconds=30*24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTimeYear){
        
        seconds=365*24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTime1Min){
        
        seconds=1*60;
    }
    if(self.plotTimeType == XLViewPlotTime5Min){
        
        seconds=5*60;
    }
    if(self.plotTimeType == XLViewPlotTime15Min){
        
        seconds=15*60;
    }
    if(self.plotTimeType == XLViewPlotTime30Min){
        
        seconds=30*60;
    }
    if(self.plotTimeType == XLViewPlotTime60Min){
        
        seconds=60*60;
    }
    
    return seconds;

}


-(NSDateFormatter*)getDateformater{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    if(self.plotTimeType==XLViewPlotTimeDay)
        [dateFormatter setDateFormat:@"yy年MM月dd日"];
    else if(self.plotTimeType==XLViewPlotTime1Min ||
            self.plotTimeType==XLViewPlotTime5Min ||
            self.plotTimeType==XLViewPlotTime15Min ||
            self.plotTimeType==XLViewPlotTime30Min ||
            self.plotTimeType==XLViewPlotTime60Min
            )
        [dateFormatter setDateFormat:@"HH:mm"];
    else if(self.plotTimeType==XLViewPlotTimeMonth)
        [dateFormatter setDateFormat:@"yyyy年MM月"];
    else if(self.plotTimeType==XLViewPlotTimeYear){
        [dateFormatter setDateFormat:@"yyyy年"];
    }else if(self.plotTimeType==XLViewPlotTimeWeek){
        [dateFormatter setDateFormat:@"yy年MM月dd日"];
    }
    return dateFormatter;
}


-(void)setupForRealPowerPlot{
    // 1 - Create the graph
    
    
    
//    float PLOT_BAR_WIDTH=4.5f*(60/self.currPlotData.count);
    if(self.currPlotData==nil) return;
    
    float PLOT_BAR_WIDTH=4.9f*(60.0/_curRecordsRange);
    

    
    NSTimeInterval seconds = [self getXSeconds];
    
    
    
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    
    
    
    NSArray* datas = self.currPlotData;
    
    
    double minY=0xFFFFFFF;
    double maxY=-1;
    
    
    for(int i=0;i<datas.count;i++){
        
        NSDictionary *item = [datas objectAtIndex:i];
        
        if([item isEqual:[NSNull null]]) continue;
        
        NSMutableArray *keys;
        
        

        double value;
        if(self.plotDataType==XLViewPlotDataTPVolt){
            
            keys = [NSMutableArray arrayWithObjects:@"ax",@"bx",@"cx",
                    //todo 合格上下限
                    @"hgsx",@"hgxx", @"hgssx",@"hgxxx",
                    nil];
        }
        
        
        if(self.plotDataType==XLViewPlotDataTPCurr ){
            
            keys = [NSMutableArray arrayWithObjects:@"ax",@"bx",@"cx",
                    //todo 合格上下限
                    @"hgsx",@"hgssx",
                    nil];
        }
        
        //删除电压相位角，电流相位角
//        if(self.plotDataType==XLViewPlotDataTPVoltAngle||
//           self.plotDataType==XLViewPlotDataTPCurrAngle){
//            
//            keys = [NSMutableArray arrayWithObjects:@"ax",@"bx",@"cx", nil];
//        }


        if(self.plotDataType==XLViewPlotDataSumAndTPRealPower||
           self.plotDataType==XLViewPlotDataSumAndTPPowerFactor ||
           self.plotDataType==XLViewPlotDataSumAndTPReactivePower ||
           self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter){
            
            keys = [NSMutableArray arrayWithObjects:@"ax",@"bx",@"cx",@"close",
                    @"open", @"high",@"low",@"pj",nil];
            

        }
        
        if(
           self.plotDataType==XLViewPlotDataSumAndTPPowerFactor ){
            
            keys = [NSMutableArray arrayWithObjects:@"ax",@"bx",@"cx",@"close",
                    @"open", @"high",@"low",@"pj",nil];

        }
        
        if(isHideEd==NO && self.plotDataType!=XLViewPlotDataSumAndTPPowerFactor &&
           self.plotDataType!=XLViewPlotDataSumAndTPReactivePower)
            [keys addObject:@"ed"];
        
        
        
        for(NSString *key in keys){
            
            value =   [item doubleValueForKey:key];
            if(value<minY) minY=value;
            if(value>maxY) maxY=value;
            
        }
        
    }
    
    
    // Axes
    
    
    CPTXYAxisSet *xyAxisSet = (id)graph.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;
    xAxis.majorIntervalLength   = CPTDecimalFromDouble(seconds);
    
    //    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    //刻度 密度
    //    xAxis.majorIntervalLength=CPTDecimalFromDouble(7*oneDay);
    
    
    NSDateFormatter *dateFormatter = [self getDateformater];

    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = self.refDate;
    xAxis.labelFormatter        = timeFormatter;
    
    

    
    maxY=maxY*1.;
    minY=minY*1.;
    
    
    double majorInterval = (maxY-minY)/3.;
    
    double orthMinY=(minY)-majorInterval;
    double orthMaxY= maxY+2*majorInterval;
    
    

    
    
    double xLength = seconds * (_curRecordsRange);
    

    
    double minX = -0.5*seconds;
    

    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(minX) length:CPTDecimalFromDouble(xLength)];
    plotSpace.fixedXRange=plotSpace.xRange;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(orthMinY) length:CPTDecimalFromDouble(orthMaxY-orthMinY)];
    plotSpace.fixedYRange=plotSpace.yRange;
    
    
    CPTMutableLineStyle *rightAxisStyle = [CPTMutableLineStyle lineStyle];
    rightAxisStyle.lineColor = [CPTColor darkGrayColor];
    rightAxisStyle.lineWidth = AXIS_LINE_LENGTH;
    
    
    
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    
    //刻度 密度
    yAxis.majorIntervalLength=CPTDecimalFromDouble(majorInterval);
    yAxis.labelOnlyFirstAndLast = NO;
    
    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(orthMinY);
    

    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-seconds/2);
    
    
    
    CPTXYAxis *axisTop = [[CPTXYAxis alloc] init];
    axisTop.plotSpace                   = graph.defaultPlotSpace;
//    axisLeft.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    axisTop.orthogonalCoordinateDecimal = CPTDecimalFromDouble(orthMaxY);
    axisTop.preferredNumberOfMajorTicks = 7;
    axisTop.minorTicksPerInterval       = 4;
    axisTop.tickDirection               = CPTSignNegative;
    axisTop.axisLineStyle               = rightAxisStyle;
    axisTop.majorTickLength             = MAJOR_TICK_LENGTH;
    axisTop.majorTickLineStyle          = rightAxisStyle;
    axisTop.minorTickLength             = 1;
    axisTop.minorTickLineStyle          = nil;
    axisTop.title                       = @"right axis";
    axisTop.titleTextStyle              = nil;
    axisTop.titleOffset                 = 0;
    axisTop.majorGridLineStyle=nil;
    axisTop.minorGridLineStyle=nil;
    axisTop.majorIntervalLength   = CPTDecimalFromDouble(seconds);
    
    axisTop.labelTextStyle = nil;

    
    CPTXYAxis *axisRight = [[CPTXYAxis alloc] init];
    axisRight.plotSpace                   = graph.defaultPlotSpace;
    //    axisLeft.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    axisRight.orthogonalCoordinateDecimal = CPTDecimalFromDouble(xLength+minX);
    axisRight.minorTicksPerInterval       = 1;
    axisRight.tickDirection               = CPTSignNegative;
    axisRight.axisLineStyle               = rightAxisStyle;
    axisRight.majorTickLength             = 3.f;
    axisRight.majorTickLineStyle          = rightAxisStyle;
    axisRight.minorTickLength             = 1;
    axisRight.minorTickLineStyle          = nil;
    axisRight.title                       = @"right axis";
    axisRight.titleTextStyle              = nil;
    axisRight.titleOffset                 = 0;
    axisRight.majorGridLineStyle=nil;
    axisRight.minorGridLineStyle=nil;
    axisRight.labelOnlyFirstAndLast=YES;
    
    CPTMutableTextStyle *rightAxisTextStyle = [CPTMutableTextStyle textStyle];
    rightAxisTextStyle.color    = [CPTColor redColor];
    rightAxisTextStyle.fontSize = 8.0;
    rightAxisTextStyle.textAlignment=CPTAlignmentRight;
    axisRight.labelTextStyle = nil;
    
    
    axisRight.majorIntervalLength   = CPTDecimalFromDouble(majorInterval);
    
    axisRight.coordinate = CPTCoordinateY;
    
    
    
    
    graph.axisSet.axes = [NSArray arrayWithObjects:xAxis,yAxis, axisTop, axisRight, nil];
    
    
    
    
    
    
    
    // OHLC plot
    
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineColor = [CPTColor increaseColor];
    redLineStyle.lineWidth = 1.0;
    
    
    CPTMutableLineStyle *greenLineStyle = [CPTMutableLineStyle lineStyle];
    greenLineStyle.lineColor = [CPTColor decreaseColor];
    greenLineStyle.lineWidth = 1.0;
    
    
    
    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];
    whiteLineStyle.lineWidth = 2.0;
    CPTTradingRangePlot *ohlcPlot = [(CPTTradingRangePlot *)[CPTTradingRangePlot alloc] initWithFrame : graph.bounds];
    ohlcPlot.barWidth=PLOT_BAR_WIDTH;
    ohlcPlot.fixedBarWidth=ohlcPlot.barWidth;
    
    

    ohlcPlot.identifier = @"PLOT K";

    ohlcPlot.lineStyle  = whiteLineStyle;
    
    
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = 12.0;
    //标签
    //    ohlcPlot.labelTextStyle = whiteTextStyle;
    ohlcPlot.labelTextStyle = nil;
    
    ohlcPlot.labelOffset    = 5.0;
    ohlcPlot.stickLength    = 10.0;
    ohlcPlot.dataSource     = self;
    ohlcPlot.delegate       = self;
    ohlcPlot.plotStyle      = CPTTradingRangePlotStyleCandleStick;
    
    
    ohlcPlot.increaseLineStyle=redLineStyle;
    ohlcPlot.decreaseLineStyle=greenLineStyle;
    //    ohlcPlot.increaseLineStyle=nil;
    //    ohlcPlot.decreaseLineStyle=nil;
    
    
 
    
    ohlcPlot.increaseFill = [CPTFill fillWithGradient:[CPTGradient increaseGradient]];
    ohlcPlot.decreaseFill = [CPTFill fillWithGradient:[CPTGradient decreaseGradient]];
    
#if (0)
    //plot animation example
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [animation setDuration:1];
    CATransform3D transform = CATransform3DMakeScale(1, 0.0001, 1);
    // offsetY=[PlotDisplayAreaUnderXAxisHeight]-[PlotDisplayAreaHeight]/2
    transform = CATransform3DConcat(transform, CATransform3DMakeTranslation(0, 1, 0));
    animation.fromValue = [NSValue valueWithCATransform3D:transform];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    [ohlcPlot addAnimation:animation forKey:@"barGrowth"];
#endif
    
    BOOL k_mixed=NO;
    
    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower ||
       self.plotDataType==XLViewPlotDataSumAndTPReactivePower ||
       self.plotDataType==XLViewPlotDataSumAndTPPowerFactor){
        [graph addPlot:ohlcPlot];
        k_mixed=YES;
    }
    
    // Add legend
    //    graph.legend                    = [CPTLegend legendWithGraph:graph];
    //    graph.legend.textStyle          = xAxis.titleTextStyle;
    //    graph.legend.fill               = graph.plotAreaFrame.fill;
    //    graph.legend.borderLineStyle    = graph.plotAreaFrame.borderLineStyle;
    //    graph.legend.cornerRadius       = 2.0;
    //    graph.legend.swatchSize         = CGSizeMake(25.0, 25.0);
    //    graph.legend.swatchCornerRadius = 2.0;
    //    graph.legendAnchor              = CPTRectAnchorTopLeft;
    //    graph.legendDisplacement        = CGPointMake(0.0, 12.0);
    //
    // Set plot ranges
    
    // Line plot with gradient fill
    
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    
    
    CPTMutableLineStyle *lineStyleA = [CPTMutableLineStyle lineStyle];
    lineStyleA.lineWidth             = 1.0f;
    lineStyleA.lineColor             = [CPTColor redColor];
    
    CPTScatterPlot *dataSourceLinePlotA = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];

    dataSourceLinePlotA.identifier    = @"SCATTER A";

    
    
    plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor redColor]];
    if(!k_mixed) dataSourceLinePlotA.plotSymbol = plotSymbol;
    
    dataSourceLinePlotA.title         = @"Close Values";
    
    dataSourceLinePlotA.dataLineStyle = lineStyleA;
    dataSourceLinePlotA.dataSource    = self;
    [graph addPlot:dataSourceLinePlotA];
    
    
    // Line plot with gradient fill
    CPTMutableLineStyle *lineStyleB = [CPTMutableLineStyle lineStyle];
    lineStyleB.lineWidth             = 1.0f;
    lineStyleB.lineColor             = [CPTColor greenColor];
    
    CPTScatterPlot *dataSourceLinePlotB = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
    dataSourceLinePlotB.identifier    = @"SCATTER B";
    dataSourceLinePlotB.title         = @"Close Values";
    
    dataSourceLinePlotB.dataLineStyle = lineStyleB;
    dataSourceLinePlotB.dataSource    = self;
    plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
    if(!k_mixed) dataSourceLinePlotB.plotSymbol = plotSymbol;
    [graph addPlot:dataSourceLinePlotB];
    
    // Line plot with gradient fill
    CPTMutableLineStyle *lineStyleC = [CPTMutableLineStyle lineStyle];
    lineStyleC.lineWidth             = 1.0f;
    lineStyleC.lineColor             = [CPTColor yellowColor];
    
    CPTScatterPlot *dataSourceLinePlotC = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
    dataSourceLinePlotC.identifier    = @"SCATTER C";
    dataSourceLinePlotC.title         = @"Close Values";
    
    plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor yellowColor]];
    if(!k_mixed) dataSourceLinePlotC.plotSymbol = plotSymbol;
    dataSourceLinePlotC.dataLineStyle = lineStyleC;
    dataSourceLinePlotC.dataSource    = self;
    [graph addPlot:dataSourceLinePlotC];
    
    if(self.plotDataType==XLViewPlotDataTPCurr ||
       self.plotDataType==XLViewPlotDataTPVolt){
        
        // Line plot with gradient fill
        CPTMutableLineStyle *lineStyleSSX = [CPTMutableLineStyle lineStyle];
        lineStyleSSX.lineWidth             = 1.0f;
        lineStyleSSX.lineColor             = [CPTColor yellowColor];
                 lineStyleSSX.dashPattern = @[@1,@1];
        
        
        CPTScatterPlot *scatterSSX = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
        scatterSSX.identifier    = @"SCATTER SSX";
        scatterSSX.title         = @"Close Values";
        
        
        scatterSSX.dataLineStyle = lineStyleSSX;
        scatterSSX.dataSource    = self;
        [graph addPlot:scatterSSX];
        
        
        // Line plot with gradient fill
        CPTMutableLineStyle *lineStyleSX = [CPTMutableLineStyle lineStyle];
        lineStyleSX.lineWidth             = 1.0f;
        lineStyleSX.lineColor             = [CPTColor redColor];
        lineStyleSX.dashPattern = @[@1,@1];
        
        CPTScatterPlot *scatterSX = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
        scatterSX.identifier    = @"SCATTER SX";
        scatterSX.title         = @"Close Values";
        
        scatterSX.dataLineStyle = lineStyleSX;
        scatterSX.dataSource    = self;
        [graph addPlot:scatterSX];
        
        if(self.plotDataType==XLViewPlotDataTPVolt){
            // Line plot with gradient fill
            CPTMutableLineStyle *lineStyleXXX = [CPTMutableLineStyle lineStyle];
            lineStyleXXX.lineWidth             = 1.0f;
            lineStyleXXX.lineColor             = [CPTColor whiteColor];
            lineStyleXXX.dashPattern = @[@1,@1];
            
            CPTScatterPlot *scatterXXX = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
            scatterXXX.identifier    = @"SCATTER XXX";
            scatterXXX.title         = @"Close Values";
            
            scatterXXX.dataLineStyle = lineStyleXXX;
            scatterXXX.dataSource    = self;
            [graph addPlot:scatterXXX];
            
            // Line plot with gradient fill
            CPTMutableLineStyle *lineStyleXX = [CPTMutableLineStyle lineStyle];
            lineStyleXX.lineWidth             = 1.0f;
            lineStyleXX.lineColor             = [CPTColor greenColor];
             lineStyleXX.dashPattern = @[@1,@1];
            
            CPTScatterPlot *scatterXX = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
            
            
            scatterXX.identifier    = @"SCATTER XX";
            scatterXX.title         = @"Close Values";
            
            scatterXX.dataLineStyle = lineStyleXX;
            scatterXX.dataSource    = self;
            [graph addPlot:scatterXX];
        }
        
        
    }
    
    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower||
       self.plotDataType==XLViewPlotDataSumAndTPPowerFactor||
       self.plotDataType==XLViewPlotDataSumAndTPReactivePower){

        
        // Line plot with gradient fill
        CPTMutableLineStyle *lineStyleT = [CPTMutableLineStyle lineStyle];
        lineStyleT.lineWidth             = 1.0f;
        lineStyleT.lineColor             = [CPTColor whiteColor];
        
        CPTScatterPlot *dataSourceLinePlotT = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
        dataSourceLinePlotT.identifier    = @"SCATTER T";
        dataSourceLinePlotT.title         = @"Close Values";
        
        dataSourceLinePlotT.dataLineStyle = lineStyleT;
        dataSourceLinePlotT.dataSource    = self;
        
        
        [graph addPlot:dataSourceLinePlotT];
        
    }
    
    if(isHideEd==NO && self.plotDataType!=XLViewPlotDataSumAndTPPowerFactor
       && self.plotDataType!=XLViewPlotDataSumAndTPReactivePower){
        
        // Line plot with gradient fill
        CPTMutableLineStyle *lineStyleR = [CPTMutableLineStyle lineStyle];
        lineStyleR.lineWidth             = 1.0f;
        lineStyleR.lineColor             = [CPTColor yellowColor];
        CPTScatterPlot *dataSourceLinePlotR = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
        dataSourceLinePlotR.identifier    = @"SCATTER R";
        dataSourceLinePlotR.title         = @"Close Values";
        dataSourceLinePlotR.dataLineStyle = lineStyleR;
        dataSourceLinePlotR.dataSource    = self;
        [graph addPlot:dataSourceLinePlotR];
    }
    

    
    
    
    
    
    
    //bottom plot setup
    
    
    
    minY=0xFFFFFFFF;
    maxY=-1;
    
    NSArray* keys;
    

    if(self.plotDataType==XLViewPlotDataTPCurr || self.plotDataType==XLViewPlotDataTPVolt){
        
        datas = self.currPlotData2;
        
        keys = [NSMutableArray arrayWithObjects:@"ax",@"bx",@"cx",
                //todo 合格上下限
                //@"hgsx",@"hgxx",
                nil];
    }
    
    
    
    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower||
       self.plotDataType==XLViewPlotDataSumAndTPPowerFactor ||
              self.plotDataType==XLViewPlotDataSumAndTPReactivePower ||
       self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter){
        
        keys = [NSMutableArray arrayWithObjects:@"dl",nil];

    }
    
    for(int i=0;i<datas.count;i++){
        
        NSDictionary *item = [datas objectAtIndex:i];

         if([item isEqual:[NSNull null]]) continue;
        double value ;
        

        
        
        for(NSString *key in keys){
            
            value =   [item doubleValueForKey:key];

            if(value>maxY) maxY=value;
            if(value<minY) minY=value;
            
        }


        
    }
    
    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower||
       self.plotDataType==XLViewPlotDataSumAndTPPowerFactor ||
       self.plotDataType==XLViewPlotDataSumAndTPReactivePower ||
       self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter){

        minY=0;
        
    }
    
    if(self.plotDataType==XLViewPlotDataTPCurr || self.plotDataType==XLViewPlotDataTPVolt){
        
        if(minY>0)
            minY=0.9*minY;
        else
            minY=1.1*minY;
        
        
    }
    
    maxY=maxY*1.1;

    
    majorInterval = (maxY-minY)/3.;
    
    orthMinY=(minY);
    orthMaxY= maxY;
    
    
    plotSpace = (CPTXYPlotSpace *)graph2.defaultPlotSpace;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.5*seconds) length:CPTDecimalFromDouble(seconds * (_curRecordsRange))];
    plotSpace.fixedXRange=plotSpace.xRange;
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(orthMinY) length:CPTDecimalFromDouble(orthMaxY-orthMinY)];
    plotSpace.fixedYRange=plotSpace.yRange;
    
    
    
    // Axes
    
    
    xyAxisSet = (id)graph2.axisSet;
    xAxis        = xyAxisSet.xAxis;
    xAxis.majorIntervalLength   = CPTDecimalFromDouble(seconds);
    
    
    xAxis.labelFormatter        = timeFormatter;
    
    xAxis.labelAlignment = CPTAlignmentLeft;
    xAxis.labelOnlyFirstAndLast=YES;
    
    yAxis = xyAxisSet.yAxis;
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-seconds/2);

    
    
    
    //刻度 密度
    yAxis.majorIntervalLength=CPTDecimalFromDouble(majorInterval);
    
    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(orthMinY);
    
    
    CPTMutableTextStyle *axisTextStyle = [CPTMutableTextStyle textStyle];
    axisTextStyle.color    = [CPTColor yellowColor];
    axisTextStyle.fontSize = 8.0;
    
    xAxis.labelTextStyle = axisTextStyle;
    
    yAxis.labelOnlyFirstAndLast = NO;
    
    
    

    
    
    
    

    
    axisTop = [[CPTXYAxis alloc] init];
    axisTop.plotSpace                   = plotSpace;
    //    axisLeft.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    axisTop.orthogonalCoordinateDecimal = CPTDecimalFromDouble(orthMaxY);
    axisTop.preferredNumberOfMajorTicks = 7;
    axisTop.minorTicksPerInterval       = 4;
    axisTop.tickDirection               = CPTSignNegative;
    axisTop.axisLineStyle               = rightAxisStyle;
    axisTop.majorTickLength             = MAJOR_TICK_LENGTH;
    axisTop.majorTickLineStyle          = rightAxisStyle;
    axisTop.minorTickLength             = 1;
    axisTop.minorTickLineStyle          = nil;
    axisTop.title                       = @"right axis";
    axisTop.titleTextStyle              = nil;
    axisTop.titleOffset                 = 0;
    axisTop.majorGridLineStyle=nil;
    axisTop.minorGridLineStyle=nil;
    axisTop.majorIntervalLength   = CPTDecimalFromDouble(seconds);
    
    axisTop.labelTextStyle = nil;
    
    
     axisRight = [[CPTXYAxis alloc] init];
    axisRight.plotSpace                   = graph2.defaultPlotSpace;
    //    axisLeft.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    axisRight.orthogonalCoordinateDecimal = CPTDecimalFromDouble(xLength+minX);
    axisRight.minorTicksPerInterval       = 1;
    axisRight.tickDirection               = CPTSignNegative;
    axisRight.axisLineStyle               = rightAxisStyle;
    axisRight.majorTickLength             = 3.f;
    axisRight.majorTickLineStyle          = rightAxisStyle;
    axisRight.minorTickLength             = 1;
    axisRight.minorTickLineStyle          = nil;
    axisRight.title                       = @"right axis";
    axisRight.titleTextStyle              = nil;
    axisRight.titleOffset                 = 0;
    axisRight.majorGridLineStyle=nil;
    axisRight.minorGridLineStyle=nil;
    
    axisRight.labelOnlyFirstAndLast=NO;
    axisRight.labelTextStyle = nil;
    
    
    axisRight.majorIntervalLength   = CPTDecimalFromDouble(majorInterval);
    
    axisRight.coordinate = CPTCoordinateY;
    
    
    
    
    graph2.axisSet.axes = [NSArray arrayWithObjects:xAxis,yAxis, axisTop, axisRight, nil];
    
    
    

    
    
    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower||
       self.plotDataType==XLViewPlotDataSumAndTPPowerFactor ||
       self.plotDataType==XLViewPlotDataSumAndTPReactivePower ){

        
        CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
        barLineStyle.lineWidth = 1.0;
        barLineStyle.lineColor = [CPTColor grayColor];
        
        CPTBarPlot *barPlot = [(CPTBarPlot *)[CPTBarPlot alloc] initWithFrame : graph2.bounds];
        
        //    barPlot.lineStyle         = barLineStyle;
        //    barPlot.barWidth          = CPTDecimalFromFloat(0.75f); // bar is 75% of the available space
        
        //使用视图空间坐标
        barPlot.identifier=@"BAR";
        barPlot.barWidthsAreInViewCoordinates=YES;
        barPlot.barWidth=CPTDecimalFromFloat(PLOT_BAR_WIDTH);
        barPlot.fixedBarWidth=PLOT_BAR_WIDTH;
        barPlot.barCornerRadius   = 0.0;
        barPlot.barsAreHorizontal = NO;
        barPlot.dataSource    = self;
        barPlot.lineStyle=nil;
        
        barPlot.delegate=self;
        
        
        
        
        
        
        
        [graph2 addPlot:barPlot];
    }
    
    if(self.plotDataType==XLViewPlotDataTPCurr ||
       self.plotDataType==XLViewPlotDataTPVolt){
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        
        
        CPTMutableLineStyle *lineStyleA = [CPTMutableLineStyle lineStyle];
        lineStyleA.lineWidth             = 1.0f;
        lineStyleA.lineColor             = [CPTColor redColor];
        
        CPTScatterPlot *dataSourceLinePlotA = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
        
        dataSourceLinePlotA.identifier    = @"SCATTER A2";
        
        
        
        plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor redColor]];
        if(!k_mixed) dataSourceLinePlotA.plotSymbol = plotSymbol;
        
        dataSourceLinePlotA.title         = @"Close Values";
        
        dataSourceLinePlotA.dataLineStyle = lineStyleA;
        dataSourceLinePlotA.dataSource    = self;
        [graph2 addPlot:dataSourceLinePlotA];
        
        
        // Line plot with gradient fill
        CPTMutableLineStyle *lineStyleB = [CPTMutableLineStyle lineStyle];
        lineStyleB.lineWidth             = 1.0f;
        lineStyleB.lineColor             = [CPTColor greenColor];
        
        CPTScatterPlot *dataSourceLinePlotB = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
        dataSourceLinePlotB.identifier    = @"SCATTER B2";
        dataSourceLinePlotB.title         = @"Close Values";
        
        dataSourceLinePlotB.dataLineStyle = lineStyleB;
        dataSourceLinePlotB.dataSource    = self;
        plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor greenColor]];
        if(!k_mixed) dataSourceLinePlotB.plotSymbol = plotSymbol;
        [graph2 addPlot:dataSourceLinePlotB];
        
        // Line plot with gradient fill
        CPTMutableLineStyle *lineStyleC = [CPTMutableLineStyle lineStyle];
        lineStyleC.lineWidth             = 1.0f;
        lineStyleC.lineColor             = [CPTColor yellowColor];
        
        CPTScatterPlot *dataSourceLinePlotC = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
        dataSourceLinePlotC.identifier    = @"SCATTER C2";
        dataSourceLinePlotC.title         = @"Close Values";
        
        plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill = [CPTFill fillWithColor:[CPTColor yellowColor]];
        if(!k_mixed) dataSourceLinePlotC.plotSymbol = plotSymbol;
        dataSourceLinePlotC.dataLineStyle = lineStyleC;
        dataSourceLinePlotC.dataSource    = self;
        [graph2 addPlot:dataSourceLinePlotC];
    }
    
}






-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx
{
    [self notifyTheTextDataView:idx];
    
}

-(void)notifyTheTextDataView:(int)idx{
    
    NSArray* datas = self.currPlotData;
    
    NSDate *currDate=self.refDate;
    
     int seconds = 24*60*60;
    
    if(self.plotTimeType == XLViewPlotTimeDay){
        
        seconds=24*60*60;
    }
    
    if(self.plotTimeType == XLViewPlotTimeWeek){
        
        seconds=7*24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTimeMonth){
        
        seconds=30*24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTimeYear){
        
        seconds=365*24*60*60;
    }
    
    if(self.plotTimeType == XLViewPlotTime1Min){
        
        seconds=1*60;
    }
    if(self.plotTimeType == XLViewPlotTime5Min){
        
        seconds=5*60;
    }
    if(self.plotTimeType == XLViewPlotTime15Min){
        
        seconds=15*60;
    }
    if(self.plotTimeType == XLViewPlotTime30Min){
        
        seconds=30*60;
    }
    if(self.plotTimeType == XLViewPlotTime60Min){
        
        seconds=60*60;
    }
    currDate = [currDate dateByAddingTimeInterval:seconds*idx];
    id curSelectedData=nil;
    
    
    NSMutableDictionary *data = [datas objectAtIndex:idx];
    
    
    
    if([data isEqual:[NSNull null]]){
        data=[[NSMutableDictionary alloc]init];
    }else{
        NSMutableDictionary *data2 = [self.currPlotData2 objectAtIndex:idx];
        if(self.plotDataType==XLViewPlotDataTPCurr || self.plotDataType==XLViewPlotDataTPVolt){
            [data setObject:[data2 objectForKey:@"ax"] forKey:@"ax2"];
                        [data setObject:[data2 objectForKey:@"bx"] forKey:@"bx2"];
                        [data setObject:[data2 objectForKey:@"cx"] forKey:@"cx2"];
        }
        
    }
    curSelectedData=data;


    [data setObject:[NSNumber numberWithDouble:
    [currDate timeIntervalSince1970]] forKey:@"sj"];



    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    if(self.plotTimeType==XLViewPlotTimeDay ){
        [formatter setDateFormat:@"yy年MM月dd日"];
    }else if(self.plotTimeType==XLViewPlotTimeWeek){
        [formatter setDateFormat:@"yy年MM月dd日"];
    }else if(self.plotTimeType==XLViewPlotTimeYear){
        [formatter setDateFormat:@"YYYY年"];
    }else if(self.plotTimeType==XLViewPlotTimeMonth){
        [formatter setDateFormat:@"YYYY年MM月"];
    }
    else{
        [formatter setDateFormat:@"HH:mm"];
    }
    
    
    NSString *dateString = [formatter stringFromDate:currDate];
    
    
    
    self.labelForCurrSelectedTime.text=[NSString stringWithFormat:@"<font color='#FFFF00' size=10>%@</font>",dateString];
    
    
    [self.labelForCurrSelectedTime setBackgroundColor:[UIColor clearColor]];
    
    CGSize labelForCurrSelectedTime = [self.labelForCurrSelectedTime optimumSize];
    
    self.labelForCurrSelectedTime.frame=CGRectMake(0,0,184,labelForCurrSelectedTime.height);
    
    
   
    
    
    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower||
       self.plotDataType==XLViewPlotDataSumAndTPReactivePower||
       self.plotDataType==XLViewPlotDataSumAndTPPowerFactor){
         NSString *high,*low,*htime,*ltime,*open,*close;
        high=@"-";
        low=@"-";
        htime=@"-";
        ltime=@"-";
        open=@"-";
        close=@"-";
        
        if(
           self.plotTimeType==XLViewPlotTimeWeek ||
           self.plotTimeType==XLViewPlotTimeYear||
           self.plotTimeType==XLViewPlotTimeMonth
           ){
            [formatter setDateFormat:@"yy/MM/dd"];
        }else{
            [formatter setDateFormat:@"HH:mm"];
        }
        
        
        if(self.plotDataType==XLViewPlotDataSumAndTPRealPower||
           self.plotDataType==XLViewPlotDataSumAndTPReactivePower||
           self.plotDataType==XLViewPlotDataSumAndTPPowerFactor){
            if( ![data isEqual:[NSNull null]]){
                
                if([data objectForKey:@"high"]!=nil){
                    high=[NSString stringWithFormat:@"%.4f",[data doubleValueForKey:@"high"]];
                }
                if([data objectForKey:@"low"]!=nil){
                    low=[NSString stringWithFormat:@"%.4f",[data doubleValueForKey:@"low"]];
                }
                if([data objectForKey:@"open"]!=nil){
                    open=[NSString stringWithFormat:@"%.4f",[data doubleValueForKey:@"open"]];
                }
                if([data objectForKey:@"close"]!=nil){
                    close=[NSString stringWithFormat:@"%.4f",[data doubleValueForKey:@"close"]];
                }
                if([data objectForKey:@"zdfhfssj"]!=nil){
                    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[data doubleValueForKey:@"zdfhfssj"]];
                    
                    htime=[formatter stringFromDate:date];
                    
                }
                
                if([data objectForKey:@"zxfhfssj"]!=nil){
                    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[data doubleValueForKey:@"zxfhfssj"]];
                    
                    ltime=[formatter stringFromDate:date];
                    
                }
                
                [self.floatLabel1 setText:[NSString stringWithFormat:
                                           @"<font color='#FFFF00' size=10>最大:</font><font color='#00FF00' size=10>%@</font><font color='#FFFF00' size=10> 0点:</font><font color='#00FF00' size=10>%@</font>",high,open]];
                [self.floatLabel1 setBackgroundColor:[UIColor clearColor]];
                
                CGSize optimumSize = [self.floatLabel1 optimumSize];
                
                self.floatLabel1.frame=CGRectMake(0,labelForCurrSelectedTime.height-2,184,optimumSize.height);


                
                [self.floatLabel2 setText:[NSString stringWithFormat:
                                           @"<font color='#FFFF00' size=10>最小:</font><font color='#00FF00' size=10>%@</font><font color='#FFFF00' size=10> 24点:</font><font color='#00FF00' size=10>%@</font>",low,close]];
                [self.floatLabel2 setBackgroundColor:[UIColor clearColor]];

                CGSize optimumSize2 = [self.floatLabel1 optimumSize];
                self.floatLabel2.frame=CGRectMake(0,labelForCurrSelectedTime.height-2+optimumSize.height-2,184,optimumSize2.height);
                
            }
        }
    }
    
    
    if(self.plotDataType==XLViewPlotDataTPCurr || self.plotDataType==XLViewPlotDataTPVolt){
         NSString *va,*vb,*vc;
        va=@"-";
        vb=@"-";
        vc=@"-";

        
        if(self.plotDataType==XLViewPlotDataTPCurr){
            if( ![data isEqual:[NSNull null]]){
                
                if([data objectForKey:@"ax"]!=nil){
                    va=[NSString stringWithFormat:@"%.3f",[data doubleValueForKey:@"ax"]];
                }
                if([data objectForKey:@"bx"]!=nil){
                    vb=[NSString stringWithFormat:@"%.3f",[data doubleValueForKey:@"bx"]];
                }
                if([data objectForKey:@"cx"]!=nil){
                    vc=[NSString stringWithFormat:@"%.3f",[data doubleValueForKey:@"cx"]];
                }
                        
            }
            self.floatLabel1.text=[NSString stringWithFormat:@"<font color='#FFFF00' size=10>电流(A) A:</font><font color='#00FF00' size=10>%@ </font><font color='#FFFF00' size=10>B:</font><font color='#00FF00' size=10>%@</font> <font color='#FFFF00' size=10>C:</font><font color='#00FF00' size=10>%@</font>",va,vb,vc];
            

            [self.floatLabel1 setBackgroundColor:[UIColor clearColor]];
            
            CGSize optimumSize = [self.floatLabel1 optimumSize];
            
            self.floatLabel1.frame=CGRectMake(0,labelForCurrSelectedTime.height-2-5,184,optimumSize.height);
            
            if( ![data isEqual:[NSNull null]]){
                
                if([data objectForKey:@"ax2"]!=nil){
                    va=[NSString stringWithFormat:@"%.1f",[data doubleValueForKey:@"ax2"]];
                }
                if([data objectForKey:@"bx2"]!=nil){
                    vb=[NSString stringWithFormat:@"%.1f",[data doubleValueForKey:@"bx2"]];
                }
                if([data objectForKey:@"cx2"]!=nil){
                    vc=[NSString stringWithFormat:@"%.1f",[data doubleValueForKey:@"cx2"]];
                }
                
            }
            
            self.floatLabel2.text=[NSString stringWithFormat:@"<font color='#FFFF00' size=10>电压(V) A:</font><font color='#00FF00' size=10>%@ </font><font color='#FFFF00' size=10>B:</font><font color='#00FF00' size=10>%@</font> <font color='#FFFF00' size=10>C:</font><font color='#00FF00' size=10>%@</font>",va,vb,vc];
            
            
            [self.floatLabel2 setBackgroundColor:[UIColor clearColor]];
            
            CGSize optimumSize2 = [self.floatLabel2 optimumSize];
            
            self.floatLabel2.frame=CGRectMake(0,labelForCurrSelectedTime.height-2+optimumSize.height-12,184,optimumSize2.height);

        }
        if(self.plotDataType==XLViewPlotDataTPVolt){
            if( ![data isEqual:[NSNull null]]){
                
                if([data objectForKey:@"ax"]!=nil){
                    va=[NSString stringWithFormat:@"%.1f",[data doubleValueForKey:@"ax"]];
                }
                if([data objectForKey:@"bx"]!=nil){
                    vb=[NSString stringWithFormat:@"%.1f",[data doubleValueForKey:@"bx"]];
                }
                if([data objectForKey:@"cx"]!=nil){
                    vc=[NSString stringWithFormat:@"%.1f",[data doubleValueForKey:@"cx"]];
                }
                
            }

            
            self.floatLabel1.text=[NSString stringWithFormat:@"<font color='#FFFF00' size=10>电压(A) A:</font><font color='#00FF00' size=10>%@ </font><font color='#FFFF00' size=10>B:</font><font color='#00FF00' size=10>%@</font> <font color='#FFFF00' size=10>C:</font><font color='#00FF00' size=10>%@</font>",va,vb,vc];
            
            
            [self.floatLabel1 setBackgroundColor:[UIColor clearColor]];
            
            CGSize optimumSize = [self.floatLabel1 optimumSize];
            
            self.floatLabel1.frame=CGRectMake(0,labelForCurrSelectedTime.height-2-5,184,optimumSize.height);
            
            if( ![data isEqual:[NSNull null]]){
                
                if([data objectForKey:@"ax2"]!=nil){
                    va=[NSString stringWithFormat:@"%.3f",[data doubleValueForKey:@"ax2"]];
                }
                if([data objectForKey:@"bx2"]!=nil){
                    vb=[NSString stringWithFormat:@"%.3f",[data doubleValueForKey:@"bx2"]];
                }
                if([data objectForKey:@"cx2"]!=nil){
                    vc=[NSString stringWithFormat:@"%.3f",[data doubleValueForKey:@"cx2"]];
                }
                
            }

            self.floatLabel2.text=[NSString stringWithFormat:@"<font color='#FFFF00' size=10>电流(V) A:</font><font color='#00FF00' size=10>%@ </font><font color='#FFFF00' size=10>B:</font><font color='#00FF00' size=10>%@</font> <font color='#FFFF00' size=10>C:</font><font color='#00FF00' size=10>%@</font>",va,vb,vc];
            
            
            [self.floatLabel2 setBackgroundColor:[UIColor clearColor]];
            
            CGSize optimumSize2 = [self.floatLabel2 optimumSize];
            
            self.floatLabel2.frame=CGRectMake(0,labelForCurrSelectedTime.height-2+optimumSize.height-12,184,optimumSize2.height);

        }
    }
    
    
    self.textDataView.plotDataType=self.plotDataType;
    self.textDataView.plotTimeType=self.plotTimeType;
    
    [plotDelegate testPlotRecordSelectedWithIndex:idx withData:curSelectedData];
    
}

-(void)tradingRangePlot:(CPTTradingRangePlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx
{
    [self notifyTheTextDataView:idx];


    
}


#pragma mark - Bar Data source

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    CPTColor *color = nil;
    
    CPTGradient *gradient=nil;
    

    NSArray* datas = self.currPlotData;
    

    NSString *ksKey,*jsKey;
    
    

    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower ||
       self.plotDataType==XLViewPlotDataSumAndTPPowerFactor ||
       self.plotDataType==XLViewPlotDataSumAndTPReactivePower){
        
        ksKey=@"open";
        jsKey=@"close";

    }
    if(self.plotDataType==XLViewPlotDataTPVolt){
        
        ksKey=@"open";
        jsKey=@"close";
        
    }
    if(self.plotDataType==XLViewPlotDataTPCurr){
        
        ksKey=@"open";
        jsKey=@"close";
        
    }
    
    NSDictionary *data = [datas objectAtIndex:index];
    
    if([data isEqual:[NSNull null]]){
        gradient=[CPTGradient increaseGradient];
        
    }else{
    
        if([data doubleValueForKey:jsKey] >[data doubleValueForKey:ksKey]){
            gradient=[CPTGradient increaseGradient];
        }
        if([data doubleValueForKey:jsKey]<=[data doubleValueForKey:ksKey]){
            gradient=[CPTGradient decreaseGradient];
        }
    }
    
    //CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:color endingColor:[CPTColor blackColor]];
    
    //return [CPTFill fillWithGradient:fillGradient];
    return [CPTFill fillWithGradient:gradient];
}

-(NSString *)legendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    return [NSString stringWithFormat:@"Bar %lu", (unsigned long)(index + 1)];
}




//请求数据
-(void)requestPlotData:(NSDate*)startDate withRecords:(int)numRecords withTPId:(int)tpId{
    
    
    self.refDate = startDate;
    
    
    isLoadingData=YES;

    
    XLViewPlotDataType dType = self.plotDataType;
    XLViewPlotTimeType tType = self.plotTimeType;
    
    

    
    
    NSLog(@"request data form %@",self.refDate);
    
    
    NSMutableDictionary *notificationDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSString stringWithFormat:@"plotdata-%@",self.viewType], @"xl-name",
                                            [NSNumber numberWithInt:dType], @"plot-type",
                                            [NSNumber numberWithInt:tType], @"plot-time-type",
                                            self.refDate, @"start-date",
                                            nil];


    [[XLModelDataInterface testData] requestPlotData:notificationDic];

    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        __weak id<UIUpdateDelegate> delegate = self;
//        NSDictionary *dict = ;
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            
//            
//        });
//    });
    
    
    
    
    
    
}

- (void)handleProgressPecentNotify:(NSNotification *)notification{
    NSDictionary *resp =(NSDictionary*) notification.userInfo;
    NSNumber* number = [resp objectForKey:@"percent"];
    
    if (![[resp objectForKey:@"xl-name"] isEqualToString:[NSString stringWithFormat:@"plotdata-%@",self.viewType]]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showPercentProgress:[number floatValue]];

    });
    
    
}
- (void)handleNotification:(NSNotification *)notification
{
    
    
    
    NSDictionary *resp =(NSDictionary*) notification.userInfo;
    
    NSDictionary* param = [resp objectForKey:@"parameter"];
    if (![[param objectForKey:@"xl-name"] isEqualToString:[NSString stringWithFormat:@"plotdata-%@",self.viewType]]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
    
        self.currPlotData=(NSArray*)([resp objectForKey:@"array1"]);
        self.currPlotData2=(NSArray*)([resp objectForKey:@"array2"]);
        
        int idx=self.currPlotData.count-1;
        
        while(idx>=0){
            
            if([self.currPlotData objectAtIndex:idx] != [NSNull null]){
                break;
            }
            
            idx--;
        }
        
        if(idx<0) idx=0;
        
        [self handlePlotDateResponse:self.currPlotData];
        
        [self notifyTheTextDataView:idx];
        
        isLoadingData=NO;
     });
}



//更新图表
-(void)handlePlotDateResponse:(NSArray*)aryResponse{
    
    self.currPlotData = aryResponse;

    [self commoneSetupPlot:graph];
    [self commoneSetupPlot:graph2];
    
    [graph removeAllPlots ];
    [graph2 removeAllPlots ];
    
    if(self.currPlotData==nil){
        graph.hidden=YES;
        graph2.hidden=YES;
    }else{
        graph.hidden=NO;
        graph2.hidden=NO;
        
    }
    
//    [self resetForRealPowerPlot];
    
    [self setupForRealPowerPlot];
    
    
    [graph reloadData];
    [graph2 reloadData];
    
//    [self hideLoadingProgress];
    
//    [self showPercentProgress:1];
    
    
}


#pragma mark - CPTTradingRangePlotDataSource Methods



-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
//    NSArray* datas = self.currPlotData;
//    return datas.count;
    
    return _curRecordsRange;
}


-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    NSArray *nums = nil;
    
    int seconds = 24*60*60;
    
    if(self.plotTimeType == XLViewPlotTimeDay){
        
        seconds=24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTimeWeek){
        
        seconds=7*24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTimeMonth){
        
        seconds=30*24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTimeYear){
        
        seconds=365*24*60*60;
    }
    if(self.plotTimeType == XLViewPlotTime1Min){
        
        seconds=1*60;
    }
    if(self.plotTimeType == XLViewPlotTime5Min){
        
        seconds=5*60;
    }
    if(self.plotTimeType == XLViewPlotTime15Min){
        
        seconds=15*60;
    }
    if(self.plotTimeType == XLViewPlotTime30Min){
        
        seconds=30*60;
    }
    if(self.plotTimeType == XLViewPlotTime60Min){
        
        seconds=60*60;
    }


    NSArray* datas = self.currPlotData;
    
    if(
    [plot.identifier isEqual:@"SCATTER A2"] || //A相
    [plot.identifier isEqual:@"SCATTER B2"] ||  //B相
       [plot.identifier isEqual:@"SCATTER C2"]){
        datas = self.currPlotData2;
    }



    if ( [plot.identifier isEqual:@"PLOT K"] ) {
        
        NSString *openK,*closeK,*highK,*lowK;
        
        if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
           XLViewPlotDataSumAndTPPowerFactor==self.plotDataType ||
           XLViewPlotDataSumAndTPReactivePower==self.plotDataType){
            openK=@"open";
            closeK=@"close";
            highK=@"high";
            lowK=@"low";
        }
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];
        for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
            
            NSDictionary *data = [datas objectAtIndex:i];
            
            
            if([data isEqual:[NSNull null]]){
                [(NSMutableArray *)nums addObject :[NSNull null]];
                continue;
            }
            
            NSTimeInterval x = seconds*i;
            
            double rOpen,rClose;
            rOpen= [data doubleValueForKey:openK];
            rClose=[data doubleValueForKey:closeK];
            
            double rHigh=[data doubleValueForKey:highK];
            double rLow=[data doubleValueForKey:lowK];
            
            
            NSDictionary *dict= [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSDecimalNumber numberWithDouble:x], [NSNumber numberWithInt:CPTTradingRangePlotFieldX],
                                 [NSDecimalNumber numberWithDouble:rOpen], [NSNumber numberWithInt:CPTTradingRangePlotFieldOpen],
                                 [NSDecimalNumber numberWithDouble:rHigh], [NSNumber numberWithInt:CPTTradingRangePlotFieldHigh],
                                 [NSDecimalNumber numberWithDouble:rLow], [NSNumber numberWithInt:CPTTradingRangePlotFieldLow],
                                 [NSDecimalNumber numberWithDouble:rClose], [NSNumber numberWithInt:CPTTradingRangePlotFieldClose],
                                 nil];
            
            
            NSNumber *num = [dict objectForKey:[NSNumber numberWithUnsignedInteger:fieldEnum]];
            
            [(NSMutableArray *)nums addObject :num];
        }
        
        
        
    }else if ( [plot.identifier isEqual:@"SCATTER A"] || //A相
              [plot.identifier isEqual:@"SCATTER B"] ||  //B相
              [plot.identifier isEqual:@"SCATTER C"] || //C相
              [plot.identifier isEqual:@"SCATTER A2"] || //A相
              [plot.identifier isEqual:@"SCATTER B2"] ||  //B相
              [plot.identifier isEqual:@"SCATTER C2"] || //C相
              [plot.identifier isEqual:@"SCATTER SSX"] || //上上限
              [plot.identifier isEqual:@"SCATTER SX"] ||  //上限
              [plot.identifier isEqual:@"SCATTER XXX"] || //下下限
              [plot.identifier isEqual:@"SCATTER XX"] || //下限
              [plot.identifier isEqual:@"SCATTER T"] || //总
              [plot.identifier isEqual:@"SCATTER R"] || //额定
              [plot.identifier isEqual:@"BAR"]) {

        NSString *valueK;
        if([plot.identifier isEqual:@"SCATTER A"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType||
               XLViewPlotDataSumAndTPPowerFactor==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType||
               XLViewPlotDataTPVoltAngle==self.plotDataType||
               XLViewPlotDataTPCurrAngle==self.plotDataType){
                valueK=@"ax";//a相
                
            }
        }
        if([plot.identifier isEqual:@"SCATTER B"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType||
               XLViewPlotDataSumAndTPPowerFactor==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType||
               XLViewPlotDataTPVoltAngle==self.plotDataType||
               XLViewPlotDataTPCurrAngle==self.plotDataType){
                valueK=@"bx";//b相
                
            }
        }
        
        if([plot.identifier isEqual:@"SCATTER C"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType||
               XLViewPlotDataSumAndTPPowerFactor==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType||
               XLViewPlotDataTPVoltAngle==self.plotDataType||
               XLViewPlotDataTPCurrAngle==self.plotDataType){
                valueK=@"cx";//c相
                
            }
        }
        if([plot.identifier isEqual:@"SCATTER A2"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType||
               XLViewPlotDataSumAndTPPowerFactor==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType||
               XLViewPlotDataTPVoltAngle==self.plotDataType||
               XLViewPlotDataTPCurrAngle==self.plotDataType){
                valueK=@"ax";//a相2
                
            }
        }
        if([plot.identifier isEqual:@"SCATTER B2"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType||
               XLViewPlotDataSumAndTPPowerFactor==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType||
               XLViewPlotDataTPVoltAngle==self.plotDataType||
               XLViewPlotDataTPCurrAngle==self.plotDataType){
                valueK=@"bx";//b相2
                
            }
        }
        
        if([plot.identifier isEqual:@"SCATTER C2"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType||
               XLViewPlotDataSumAndTPPowerFactor==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType||
               XLViewPlotDataTPVoltAngle==self.plotDataType||
               XLViewPlotDataTPCurrAngle==self.plotDataType){
                valueK=@"cx";//c相2
                
            }
        }
        if([plot.identifier isEqual:@"SCATTER R"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType){
                valueK=@"ed";
            }

        }
        if([plot.identifier isEqual:@"SCATTER T"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType ||
               XLViewPlotDataSumAndTPPowerFactor==self.plotDataType ||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType){
                valueK=@"pj"; //总平均
            }
        }
        if([plot.identifier isEqual:@"SCATTER SSX"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType ||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType){
                valueK=@"hgssx"; //上上限
            }
        }
        if([plot.identifier isEqual:@"SCATTER XXX"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType ||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType){
                valueK=@"hgxxx"; //下下限
            }
        }
        if([plot.identifier isEqual:@"SCATTER SX"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType ||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType){
                valueK=@"hgsx"; //上限
            }
        }
        if([plot.identifier isEqual:@"SCATTER XX"]){
            if(XLViewPlotDataSumAndTPRealPower==self.plotDataType||
               XLViewPlotDataTPCurr==self.plotDataType||
               XLViewPlotDataTPVolt==self.plotDataType ||
               XLViewPlotDataSumAndTPReactivePower==self.plotDataType){
                valueK=@"hgxx"; //下限
            }
        }
        if([plot.identifier isEqual:@"BAR"]){
            valueK=@"dl"; //电量
        }
        
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {


                    [(NSMutableArray *)nums addObject :[NSDecimalNumber numberWithUnsignedInteger:seconds*i]];
                }
                break;

            case CPTBarPlotFieldBarTip:

                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {

                    NSDictionary *data = [datas objectAtIndex:i];
                    if([data isEqual:[NSNull null]]){
                        [(NSMutableArray *)nums addObject :[NSNull null]];
                        continue;
                    }
                    NSDecimalNumber* num = [NSDecimalNumber numberWithDouble:[data doubleValueForKey:valueK]];
                    [(NSMutableArray *)nums addObject :num];
                }

//            nums = [plotData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
                break;

            default:
                break;
        }

    }
    return nums;
}



/// @name Bar Fills
/// @{

/** @brief @optional Gets a range of fills used with a candlestick plot when close >= open for the given plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of fills.
 **/
-(NSArray *)increaseFillsForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange
{
    return nil;
}

/** @brief @optional Gets the fill used with a candlestick plot when close >= open for the given plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::increaseFillsForTradingRangePlot:recordIndexRange: -increaseFillsForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The bar fill for the bar with the given index. If the data source returns @nil, the default increase fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(CPTFill *)increaseFillForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx{
    return nil;
}

/** @brief @optional Gets a range of fills used with a candlestick plot when close < open for the given plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 **/
-(NSArray *)decreaseFillsForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange{
    return nil;
}

/** @brief @optional Gets the fill used with a candlestick plot when close < open for the given plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::decreaseFillsForTradingRangePlot:recordIndexRange: -decreaseFillsForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The bar fill for the bar with the given index. If the data source returns @nil, the default decrease fill is used.
 *  If the data source returns an NSNull object, no fill is drawn.
 **/
-(CPTFill *)decreaseFillForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx{
    return nil;
}

/// @}

/// @name Bar Line Styles
/// @{

/** @brief @optional Gets a range of line styles used to draw candlestick or OHLC symbols for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(NSArray *)lineStylesForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange{
    return nil;
}

/** @brief @optional Gets the line style used to draw candlestick or OHLC symbols for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::lineStylesForTradingRangePlot:recordIndexRange: -lineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line style for the symbol with the given index. If the data source returns @nil, the default line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)lineStyleForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx{
    return nil;
}

/** @brief @optional Gets a range of line styles used to outline candlestick symbols when close >= open for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(NSArray *)increaseLineStylesForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange{
    return nil;
}

/** @brief @optional Gets the line style used to outline candlestick symbols when close >= open for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::increaseLineStylesForTradingRangePlot:recordIndexRange: -increaseLineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line line style for the symbol with the given index. If the data source returns @nil, the default increase line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)increaseLineStyleForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx{
    return nil;
}

/** @brief @optional Gets a range of line styles used to outline candlestick symbols when close < open for the given trading range plot.
 *  @param plot The trading range plot.
 *  @param indexRange The range of the data indexes of interest.
 *  @return An array of line styles.
 **/
-(NSArray *)decreaseLineStylesForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndexRange:(NSRange)indexRange{
    return nil;
}

/** @brief @optional Gets the line style used to outline candlestick symbols when close < open for the given trading range plot.
 *  This method will not be called if
 *  @link CPTTradingRangePlotDataSource::decreaseLineStylesForTradingRangePlot:recordIndexRange: -decreaseLineStylesForTradingRangePlot:recordIndexRange: @endlink
 *  is also implemented in the datasource.
 *  @param plot The trading range plot.
 *  @param idx The data index of interest.
 *  @return The line line style for the symbol with the given index. If the data source returns @nil, the default decrease line style is used.
 *  If the data source returns an NSNull object, no line is drawn.
 **/
-(CPTLineStyle *)decreaseLineStyleForTradingRangePlot:(CPTTradingRangePlot *)plot recordIndex:(NSUInteger)idx{
    return nil;
}

/// @}





@end