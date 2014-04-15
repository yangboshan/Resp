//
//  CommonPowerPlotViewController.m
//  XLApp
//
//  Created by sureone on 2/26/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "CommonPowerPlotViewController.h"
#import "Navbar.h"
#import "CorePlot-CocoaTouch.h"
#import "NSNumberExtensions.h"
#import "LeveyPopListView.h"
#import "app-config.h"
#import "NSDictionary+NSDictionary_Data.h"

#import "EWMultiColumnTableView.h"

#import "MyTextField.h"
#import "MySectionHeaderView.h"

@interface CommonPowerPlotViewController ()  <LeveyPopListViewDelegate,EWMultiColumnTableViewDataSource>


@property (nonatomic, retain) IBOutlet EWMultiColumnTableView *ewTableView;


@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelLine1;
@property (weak, nonatomic) IBOutlet UILabel *labelLine2;
@property (weak, nonatomic) IBOutlet UIView *timeButtonsView;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *plotView;


//keep the plot data each as NSDictionay in the array.
@property (nonatomic) NSArray *currPlotData;
@property (nonatomic,retain) NSMutableArray *arrayLabels;
@end

@implementation CommonPowerPlotViewController{
    
    
    UIButton *realBtn,*dayBtn,*weekBtn,*yearBtn,*monthBtn;
    CPTGraph *graph;
    NSMutableArray *dataOptions;
    BOOL isLoadingData;

    int gForwardKeepFlag;
        NSTimer * timer;
    
    int minutesOptions[10];
    int otherTimeOptions[10];
    
    
    CGFloat     colWidth ;
    CGFloat     dateColWidth;
    CGFloat cellHeight;
    
    


}


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
    // Do any additional setup after loading the view from its nib.
    

    
    
    CGRect origRc = self.viewPlotArea.frame;
    self.viewPlotArea.frame=CGRectMake(0, 0, origRc.size.width,origRc.size.height);
    [_viewScrollContaner addSubview:self.viewPlotArea];
    
    
//    UILabel* value = [[UILabel alloc]initWithFrame:CGRectMake(0, 300, 100, 30)];
//    
//    value.text=@"test";
//    value.textColor=[UIColor greenColor];
//    value.font=[UIFont systemFontOfSize:12];
//    
//    value.lineBreakMode=NSLineBreakByWordWrapping;
//    value.textAlignment=NSTextAlignmentCenter;
//    value.numberOfLines=0;
//    
//    [self.viewScrollContaner addSubview:value];
//    
   
    
    _labelTitle.text=self.plotDataTitle;
    
    if(graph==nil){
        graph = [[CPTXYGraph alloc] initWithFrame:self.plotView.bounds];
        [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
        self.plotView.hostedGraph = graph;
    }
    
    [self commoneSetupPlot:graph];

    if(self.plotType!=PLOT_DETAIL){
        
        if(self.plotType==B_PLOT || (self.plotType==S_PLOT && self.dataMapKeys.count==1)){
                self.plotTags=[NSArray arrayWithObjects:@"数值",nil];
        }
        
        
        if(self.plotType==K_PLOT && self.dataMapKeys.count==4){
            self.plotTags=[NSArray arrayWithObjects:@"开始",@"结束",@"最大",@"最小",nil];
        }


        [self setupStatButtons];
    }else{
        
        if(self.plotDataType==XLViewPlotDataTPVolt
           || self.plotDataType==XLViewPlotDataTPCurr){
            
            self.plotNum=3;
            
            self.plotTags=[NSArray arrayWithObjects:@"A",@"B",@"C",nil];
            
            self.dataMapKeys=[NSArray arrayWithObjects:@"ax",@"bx",@"cx",nil];
            
        }else if(
                 self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter
                 || self.plotDataType==XLViewPlotDataSumAndTPPowerFactorScatter
                 || self.plotDataType==XLViewPlotDataSumAndTPRealPowerScatter){
            
            self.plotNum=4;
            
            self.plotTags=[NSArray arrayWithObjects:@"总",@"A",@"B",@"C",nil];
            
            self.dataMapKeys=[NSArray arrayWithObjects:@"pj",@"ax",@"bx",@"cx",nil];
            
        }
        
        CGSize size = self.viewPlotContainer.frame.size;
        self.viewPlotContainer.frame=CGRectMake(0,30,size.width,size.height);
    }
    
    
    origRc = self.viewPlotArea.frame;
    
    


    
    
    if(self.plotType!=PLOT_DETAIL){
        self.plotTimeType=XLViewPlotTimeDay;
    }
    
    self.title=self.plotDataTitle;
    
    
    _viewPlotLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0];
    
    
    //long press gesture detect for finger moving on plot
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPressPlotView:)];
    longPress.minimumPressDuration = .5;
    [self.plotView addGestureRecognizer:longPress];

    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    

    
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    
    if(self.plotType==PLOT_DETAIL){
        if(self.plotTimeType==XLViewPlotTime60Min){
            [self activeButton:realBtn];
            realBtn.titleLabel.text=@"60分钟▽";
        }
    }
    
    
    
    NSString *dateString = [formatter stringFromDate:self.refDate];
    
    self.labelLine2.text=dateString;
    
    [self addPlotLabels ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProgressPecentNotify:) name:XLViewProgressPercent object:nil];

    
    
    [self requestPlotData];
    
    [self renderDetailTableView];
}

-(void)renderDetailDataAt{
    

    int colNum = self.plotNum;
    NSMutableArray* colName = [[NSMutableArray alloc]init];
    
    for(int i=0;i<colNum;i++){
        [colName addObject:[self.plotTags objectAtIndex:i]];
    }
    
    
    
    int numRecords;
    int TimeDensity;
    
    [self calculatePlotForRecordsNum:&numRecords andTimeDensity:&TimeDensity];
    
    NSMutableArray* rowValues = [[NSMutableArray alloc]init];
    
    
    int seconds = [self getXSeconds];
    
     NSArray* datas = self.currPlotData;
    
    for(int i=0;i<numRecords;i++){
        NSDictionary *data = [datas objectAtIndex:i];
        for(int j=0;j<colNum;j++){
          
            if([data isEqual:[NSNull null]]){
                [rowValues addObject:[NSNull null]];
            }else{
                [rowValues addObject:[data objectForKey:[NSString stringWithFormat:@"v%d",(j+1)]]];
            }
            
        }
    }
    
    
    
    
    
    
    CGSize size = self.viewDetailArea.frame.size;
    
    
    float timeLabelWidth = 80;
    float timeLabelHeight = 29;
    
    float yOffset=4;
    float xOffset=4;
    
    float vWidth = (320-timeLabelWidth-xOffset)/colNum;
    float vHeight = 29;

    
    int x=0;
    int y=0;
    
    CGRect rcPlot = self.viewPlotContainer.frame;
    
    y=rcPlot.origin.y+10+rcPlot.size.height;
    
    NSDateFormatter *dateFormatter = [self getDateFormater];
    
    int idx_row_value=0;
    
    UILabel* line = [[UILabel alloc]initWithFrame:CGRectMake(2, y, 316, 0.5)];
    line.backgroundColor=[UIColor lightGrayColor];
    
    [self.viewScrollContaner addSubview:line];
    
    y+=yOffset;
    
    
    for(int i=0;i<1;i++){
        
        
        x=xOffset;
        
        
        NSString *dateString = @"时间";
        
        UILabel* uiLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, timeLabelWidth, timeLabelHeight)];
        uiLabel.text=dateString;
        uiLabel.textColor=[UIColor whiteColor];
        uiLabel.font=[UIFont systemFontOfSize:12];
        uiLabel.lineBreakMode=NSLineBreakByWordWrapping;
        uiLabel.textAlignment=NSTextAlignmentCenter;
        uiLabel.numberOfLines=0;
        [self.viewScrollContaner addSubview:uiLabel];
        
        [_arrayLabels addObject:uiLabel];
        x+=timeLabelWidth;
        
        
        for(int j=0;j<colNum;j++){
            
            
         
            
            NSString *textValue = [colName objectAtIndex:j];
            
            
            UILabel* value = [[UILabel alloc]initWithFrame:CGRectMake(x, y, vWidth, vHeight)];
            
            value.text=textValue;
            value.textColor=[UIColor whiteColor];
            value.font=[UIFont systemFontOfSize:12];
            
            value.lineBreakMode=NSLineBreakByWordWrapping;
            value.textAlignment=NSTextAlignmentCenter;
            value.numberOfLines=0;
            
            [self.viewScrollContaner addSubview:value];
            
            [_arrayLabels addObject:value];
            x+=vWidth;
            
            
        }
        
        y+=vHeight+yOffset;
        
        UILabel* line = [[UILabel alloc]initWithFrame:CGRectMake(2, y, 316, 0.5)];
        line.backgroundColor=[UIColor lightGrayColor];
        
        [self.viewScrollContaner addSubview:line];
        
        y+=yOffset;
        
    }
    
    
    
    for(int i=0;i<numRecords;i++){
        
        
        x=xOffset;
        
        
        NSDate* newDate=[self.refDate dateByAddingTimeInterval:seconds*i];
        
        NSString *dateString = [dateFormatter stringFromDate:newDate];
        
        UILabel* uiLabel = [[UILabel alloc]initWithFrame:CGRectMake(x, y, timeLabelWidth, timeLabelHeight)];
        uiLabel.text=dateString;
        uiLabel.textColor=[UIColor whiteColor];
        uiLabel.font=[UIFont systemFontOfSize:12];
        uiLabel.lineBreakMode=NSLineBreakByWordWrapping;
        uiLabel.textAlignment=NSTextAlignmentCenter;
        uiLabel.numberOfLines=0;
        [self.viewScrollContaner addSubview:uiLabel];
        
        [_arrayLabels addObject:uiLabel];
        x+=timeLabelWidth;
        
        
        for(int j=0;j<colNum;j++){
            
            
            NSNumber *number = [rowValues objectAtIndex:idx_row_value];
            
            NSString *textValue;
          
            if([number isEqual:[NSNull null]]){
                textValue = @"-";
            }else{
                textValue = [number stringValue];
                
            }
            
            
            UILabel* value = [[UILabel alloc]initWithFrame:CGRectMake(x, y, vWidth, vHeight)];
            
            value.text=textValue;
            value.textColor=[UIColor greenColor];
            value.font=[UIFont systemFontOfSize:12];
            
            value.lineBreakMode=NSLineBreakByWordWrapping;
            value.textAlignment=NSTextAlignmentCenter;
            value.numberOfLines=0;
            
            [self.viewScrollContaner addSubview:value];
            
            [_arrayLabels addObject:value];
            x+=vWidth;
            
            idx_row_value++;
            
        }
        
        y+=vHeight+yOffset;
        
        UILabel* line = [[UILabel alloc]initWithFrame:CGRectMake(2, y, 316, 0.5)];
        line.backgroundColor=[UIColor lightGrayColor];
        
        [self.viewScrollContaner addSubview:line];
        
        y+=yOffset;

    }
    

    
    
//    self.viewDetailArea.frame=CGRectMake(0, rcPlot.origin.y+rcPlot.size.height+10, 320,y);
//    [self.viewScrollContaner addSubview:self.viewDetailArea];
    
    self.viewScrollContaner.contentSize = CGSizeMake(320, _viewDetailArea.frame.origin.y+y);

    
}

-(void)setupPlots{
    if(self.plotDataType==XLViewPlotDataTPVolt
       || self.plotDataType==XLViewPlotDataTPCurr
       || self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter
       || self.plotDataType==XLViewPlotDataSumAndTPPowerFactorScatter
       || self.plotDataType==XLViewPlotDataSumAndTPRealPowerScatter
       || self.plotType==S_PLOT){
        [self setupForScatterPlot];
    }
    if(self.plotDataType==XLViewPlotDataConsume ||
       self.plotType==B_PLOT
       ){
        [self setupForBarPlot];
    }
    if(self.plotDataType==XLViewPlotDataSumAndTPRealPower||
       self.plotType==K_PLOT){
        [self setupForTrendPlot];
    }
}

- (void)fingerMoveToRecordAtIndex:(int)idx{
    
}

- (void)processTheDataSelect:(CGPoint)point withOrigPoint:(CGPoint)origPt{
    
    if(self.currPlotData==nil) return;
    
//    float count = self.currPlotData.count+0.5;
    

    int idx = point.x+0.5;
    if(idx<0) idx=0;
    if(idx>=self.currPlotData.count) idx=self.currPlotData.count-1;
    

    
    
    
//    self.viewForCurrentSelectedData.hidden=NO;
//    
//    CGRect rect =self.viewForCurrentSelectedData.frame;
//    
//    if(origPt.x+rect.size.width+1>320) origPt.x=origPt.x-rect.size.width-1;
//    else
//        origPt.x+=1;
//    self.viewForCurrentSelectedData.frame= CGRectMake(origPt.x,42,rect.size.width,rect.size.height);
//    
//    
//    
    
    
    NSArray *datas = self.currPlotData;
    
    NSDictionary *data = [datas objectAtIndex:idx];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    int seconds = 60;
    [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
    

    if(PLOT_DETAIL==self.plotType){
        if(self.plotDataType==XLViewPlotDataTPVolt ||
           self.plotDataType==XLViewPlotDataTPCurr ||
           self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter ||
                      self.plotDataType==XLViewPlotDataSumAndTPPowerFactorScatter||
           self.plotDataType==XLViewPlotDataSumAndTPRealPowerScatter){
            
            //A 相电压
            NSNumber *nbrA = [data objectForKey:@"ax"];
            NSNumber *nbrB = [data objectForKey:@"bx"];
            NSNumber *nbrC = [data objectForKey:@"cx"];
            if(XLViewPlotDataSumAndTPRealPowerScatter==self.plotDataType||
                          self.plotDataType==XLViewPlotDataSumAndTPPowerFactorScatter||
               self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter){
                 NSNumber *nbrT = [data objectForKey:@"t"];
                
                self.labelLine1.text = [NSString stringWithFormat:@"A: %.1f B: %.1f C: %.1f 总: %.1f",
                                        [nbrA doubleValue],
                                        [nbrB doubleValue],
                                        [nbrC doubleValue],
                                        [nbrT doubleValue]];
                
            }else{
                self.labelLine1.text = [NSString stringWithFormat:@"A: %.1f B: %.1f C: %.1f",
                                        [nbrA doubleValue],
                                        [nbrB doubleValue],
                                        [nbrC doubleValue]];
            }
            
        }else if(self.plotDataType==XLViewPlotDataConsume){
            //电量
            NSNumber *nbr = [data objectForKey:@"consume"];
            self.labelLine1.text = [NSString stringWithFormat:@"%.2f",
                                    [nbr doubleValue]];
        }if(self.plotDataType==XLViewPlotDataSumAndTPRealPower){
            
            //power
            NSNumber *nbrA = [data objectForKey:@"low"];
            NSNumber *nbrB = [data objectForKey:@"high"];
            self.labelLine1.text = [NSString stringWithFormat:@"最大: %.2f 最小: %.2f",
                                    [nbrA doubleValue],
                                    [nbrB doubleValue]];
            
        }
        
        
        
        
        

            
        if(self.plotTimeType==XLViewPlotTime1Min ||
           self.plotTimeType==XLViewPlotTime5Min ||
           self.plotTimeType==XLViewPlotTime15Min ||
           self.plotTimeType==XLViewPlotTime30Min ||
           self.plotTimeType==XLViewPlotTime60Min ||
           self.plotTimeType==XLViewPlotTimeDay
           ){
            [formatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
            seconds = 60;
        }else if(self.plotTimeType==XLViewPlotTimeWeek || self.plotTimeType==XLViewPlotTimeMonth){
             [formatter setDateFormat:@"yyyy年MM月dd日"];
            seconds = 60*60*24;
        }else if(self.plotTimeType==XLViewPlotTimeYear){
            [formatter setDateFormat:@"yyyy年MM月"];
            seconds = 60*60*24*12;
        }
    }else{
        
        seconds = [self getXSeconds];
        
    }
    
    

    

    NSDate *date = [self.refDate dateByAddingTimeInterval:seconds*idx];
    NSString *dateString = [formatter stringFromDate:date];
    self.labelLine2.text=dateString;
    
    
}



- (void)handleLongPressPlotView:(UILongPressGestureRecognizer *)gesture {
    if(UIGestureRecognizerStateBegan == gesture.state) {
        // Called on start of gesture, do work here
//        NSLog(@"gesture start");
        
        
        
        NSUInteger *touchCount = [gesture numberOfTouches];
        for (NSUInteger t = 0; t < touchCount; t++) {
            CGPoint point = [gesture locationOfTouch:t inView:gesture.view];
            if(gesture.view==self.plotView){
                //                NSLog(@"long press move %f,%f",point.x,point.y);
                CGPoint pt = [graph convertTheSelectPoint:point];
                [self processTheDataSelect:pt withOrigPoint:point];
                
                [graph showMeasureLinesAtPoint:point];
            }
            
            
            
            
        }
        
    }
    
    if(UIGestureRecognizerStateChanged == gesture.state) {
        // Do repeated work here (repeats continuously) while finger is down
        
        NSUInteger *touchCount = [gesture numberOfTouches];
        for (NSUInteger t = 0; t < touchCount; t++) {
            CGPoint point = [gesture locationOfTouch:t inView:gesture.view];
            if(gesture.view==self.plotView){
                //                NSLog(@"long press move %f,%f",point.x,point.y);
                CGPoint pt = [graph convertTheSelectPoint:point];
                [self processTheDataSelect:pt withOrigPoint:point];
                [graph showMeasureLinesAtPoint:point];
            }
            
            
            
            
        }
        
        
    }
    
    if(UIGestureRecognizerStateEnded == gesture.state) {
        // Do end work here when finger is lifted
//        NSLog(@"gesture ends");
        if(gesture.view==self.plotView){
            [graph hideMeasureLines];
        }
        
//        self.viewForCurrentSelectedData.hidden=YES;
    }
}




-(void)setupStatButtons
{
    
    
    
    
    float width = self.view.frame.size.width;
    float height = self.timeButtonsView.frame.size.height;

    int mi,oi;
    mi=0;
    oi=0;
        
    for(int i=0;i<self.timeTypes.count;i++){
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"1"]){
            
            minutesOptions[mi]=XLViewPlotTime1Min;

            mi++;
        }
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"5"]){
            
            minutesOptions[mi]=XLViewPlotTime5Min;
            
            mi++;
        }
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"15"]){
            
            minutesOptions[mi]=XLViewPlotTime15Min;
            
            mi++;
        }
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"30"]){
            
            minutesOptions[mi]=XLViewPlotTime30Min;
            
            mi++;
        }
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"60"]){
            
            minutesOptions[mi]=XLViewPlotTime60Min;
            
            mi++;
        }
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"D"]){
            
            otherTimeOptions[oi]=XLViewPlotTimeDay;
            
            oi++;
        }
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"W"]){
            
            otherTimeOptions[oi]=XLViewPlotTimeWeek;
            
            oi++;
        }
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"M"]){
            
            otherTimeOptions[oi]=XLViewPlotTimeMonth;
            
            oi++;
        }
        if([[_timeTypes objectAtIndex:i] isEqualToString:@"Y"]){
            
            otherTimeOptions[oi]=XLViewPlotTimeYear;
            
            oi++;
        }
    }
    
    int btnNum=0;
    
    if(mi>0)btnNum++;
    if(oi>0)btnNum+=oi;
    
    float btnWidth = width/btnNum;
    
    float x=0;
    
    UIImage * backgroundImg = [UIImage imageNamed:@"plot_tab_buttons_middle_normal_bg.png"];
    
    if(mi>0){
        NSString* firstMinuteOption=@"1分钟▽";
        
        if(minutesOptions[0]==XLViewPlotTime5Min){
            firstMinuteOption=@"5分钟▽";
        }
        if(minutesOptions[0]==XLViewPlotTime15Min){
            firstMinuteOption=@"15分钟▽";
            
        }
        if(minutesOptions[0]==XLViewPlotTime30Min){
            firstMinuteOption=@"30分钟▽";
            
        }
        if(minutesOptions[0]==XLViewPlotTime60Min){
            firstMinuteOption=@"60分钟▽";
        }
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [button setTitle:firstMinuteOption forState:UIControlStateNormal];
        [button setFrame:CGRectMake(0,0,btnWidth,height)];
        [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0, 0.0, 0.0 )];
        
        [button addTarget:self action:@selector(plotSwitchBtnPressed:) forControlEvents:UIControlEventTouchDown];
        
        [_timeButtonsView addSubview:button];
        
        x+=btnWidth;
        
        realBtn = button;
        
        
        
        [realBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
        [realBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
    }
    
    
    for(int k=0;k<oi;k++){
        
        NSString *btnLabel;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        
        if(otherTimeOptions[k]==XLViewPlotTimeDay){
            btnLabel=@"日";
            dayBtn=button;
            
        }
        if(otherTimeOptions[k]==XLViewPlotTimeWeek){
            btnLabel=@"周";
            weekBtn=button;
            
        }
        if(otherTimeOptions[k]==XLViewPlotTimeMonth){
            btnLabel=@"月";
            monthBtn=button;
            
        }
        if(otherTimeOptions[k]==XLViewPlotTimeYear){
            btnLabel=@"年";
            yearBtn=button;
            
        }
        [button setTitle:btnLabel forState:UIControlStateNormal];
        [button setFrame:CGRectMake(x,0,btnWidth,height)];
        
        [button addTarget:self action:@selector(plotSwitchBtnPressed:) forControlEvents:UIControlEventTouchDown];
        
        [_timeButtonsView addSubview:button];
        x+=btnWidth;
        
        
            [button setBackgroundImage:backgroundImg forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        [dayBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    }
    


    
    
    
    
    
    
    
    //
    //    UIImage *image = [[UIImage imageNamed:@"tab_bar_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //	[button setBackgroundImage:image forState:UIControlStateNormal];
    //	[button setBackgroundImage:image forState:UIControlStateHighlighted];
    
}

-(void)addPlotLabels{
    [[_viewPlotLabel subviews]
     makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    
    CGSize viewSize = _viewPlotLabel.frame.size;
    
//    if(self.plotType==PLOT_DETAIL){
//        if(self.plotDataType==XLViewPlotDataSumAndTPRealPowerScatter ||
//                    self.plotDataType==XLViewPlotDataTPCurr ||
//                           self.plotDataType==XLViewPlotDataTPVolt ||
//                      self.plotDataType==XLViewPlotDataSumAndTPPowerFactorScatter||
//           self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter){
//            
//            float offset=10;
//            float width=40;
//            UILabel* label;
//            
//            float x = viewSize.width/2-(offset*3+width*4)/2;
//            float y=2;
//            
//            CGRect rect = CGRectMake(x,y, width, 12);
//            
//            
//            label = [[UILabel alloc]initWithFrame:rect];
//            label.text=@"总 ━ ";
//            label.textColor=[UIColor whiteColor];
//            label.font=[UIFont systemFontOfSize:12];
//            
//            [_viewPlotLabel addSubview:label];
//            
//            
//            x+=width+offset;
//            rect = CGRectMake(x,y, width, 12);
//            
//            label = [[UILabel alloc]initWithFrame:rect];
//            label.text=@"A相 ━ ";
//            label.textColor=[UIColor redColor];
//            label.font=[UIFont systemFontOfSize:12];
//            
//            [_viewPlotLabel addSubview:label];
//            
//            x+=width+offset;
//            
//            
//            rect = CGRectMake(x,y, width, 12);
//            
//            
//            label = [[UILabel alloc]initWithFrame:rect];
//            label.text=@"B相 ━ ";
//            label.textColor=[UIColor greenColor];
//            label.font=[UIFont systemFontOfSize:12];
//            
//            [_viewPlotLabel addSubview:label];
//            
//            x+=width+offset;
//            rect = CGRectMake(x,y, width, 12);
//            label = [[UILabel alloc]initWithFrame:rect];
//            label.text=@"C相 ━ ";
//            label.textColor=[UIColor yellowColor];
//            label.font=[UIFont systemFontOfSize:12];
//            
//            [_viewPlotLabel addSubview:label];
//        }
//    }else{
    
        if(self.plotTags!=nil && self.plotTags.count>0){
            
            float offset=5;
            float width=50;
            UILabel* label;
            
            float startX = viewSize.width/2-(offset*(self.plotTags.count-1)+width*(self.plotTags.count))/2;
            float y=2;
            float x=0;
            
            
            NSArray *colorsPlan = [NSArray arrayWithObjects:[UIColor whiteColor],
                                   [UIColor redColor],
                                   [UIColor greenColor],
                                   [UIColor yellowColor],
                                   [UIColor blueColor],
                                   [UIColor orangeColor], nil];
            
            if(self.plotNum==3){
                colorsPlan = [NSArray arrayWithObjects:
                              [UIColor redColor],
                              [UIColor greenColor],
                              [UIColor yellowColor],
                              [UIColor blueColor],
                              [UIColor orangeColor], nil];
                
            }
            
            for(int i =0;i<self.plotNum;i++){

                x=startX+(width+offset)*i;
                
                CGRect rect = CGRectMake(x,y, width, 10);
                
                
                label = [[UILabel alloc]initWithFrame:rect];
                label.text=[NSString stringWithFormat:@"%@ ━ ",[_plotTags objectAtIndex:i]];
                label.textColor=[colorsPlan objectAtIndex:i];
                label.font=[UIFont systemFontOfSize:10];
                
                [_viewPlotLabel addSubview:label];
                
                
            
            }
        }
        
//    }
    
    
}


-(void)setupForBarPlot{
    // 1 - Create the graph
    
    if(self.currPlotData==nil) return;
    
    NSTimeInterval seconds = 24 * 60 * 60;
    
    if(self.plotTimeType==XLViewPlotTime1Min){
        seconds=60;
    }
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    
    
    
    NSArray* datas = self.currPlotData;
    
    
    double minY=0xFFFFFFF;
    double maxY=-1;
    
    double value;
    
    
    for(int i=0;i<datas.count;i++){
        
        NSDictionary *data = [datas objectAtIndex:i];
        
        
        if(self.plotType!=PLOT_DETAIL){
            
            for(NSString *key in self.dataMapKeys){
                
                //the key begain with '_' not consider as XY calulate
                
                if([[key substringToIndex:1] isEqualToString:@"_"]==NO){
                    
                    value =   [data doubleValueForKey:key];
                    if(value<minY) minY=value;
                    if(value>maxY) maxY=value;
                }
                
            }
            
        }
        
    }
    
    
    // Axes
    
    
    [self setupAxis:graph withMinY:minY withMaxY:maxY];
    
    
    
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor grayColor];
    
    
    CPTBarPlot *barPlot = [(CPTBarPlot *)[CPTBarPlot alloc] initWithFrame : graph.bounds];
    
    barPlot.lineStyle         = nil;
    //    barPlot.barWidth          = CPTDecimalFromFloat(0.75f); // bar is 75% of the available space
    
    //使用视图空间坐标
    barPlot.identifier=@"BAR PLOT";
    barPlot.barWidthsAreInViewCoordinates=YES;
    barPlot.barWidth=CPTDecimalFromFloat(310/(self.currPlotData.count+2)-0.4);
    
    barPlot.barCornerRadius   = 0.0;
    barPlot.barsAreHorizontal = NO;
    barPlot.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
    
    
    barPlot.dataSource    = self;
    barPlot.delegate=self;
    
    [_viewPlotLabel setBackgroundColor:[UIColor blackColor]];
    
    
    
    
    
    
    [graph addPlot:barPlot];
    
}

-(void)setupForTrendPlot{
    
    if(self.currPlotData==nil) return;

    float PLOT_BAR_WIDTH=4.9f*(60.0/30);
    
    NSArray* datas = self.currPlotData;
    
    
    double minY=0xFFFFFFF;
    double maxY=-1;
    
    
    for(int i=0;i<datas.count;i++){
        
        
        NSDictionary *data = [datas objectAtIndex:i];
        
        
        if(self.plotDataType==XLViewPlotDataSumAndTPRealPower || self.plotType==K_PLOT){
          
            NSNumber *number = [data objectForKey:@"open"];
            double value = [number doubleValue];
            
            if(value<minY) minY=value;
            if(value>maxY) maxY=value;
            number = [data objectForKey:@"close"];
            value = [number doubleValue];
            
            if(value<minY) minY=value;
            if(value>maxY) maxY=value;
            
            number = [data objectForKey:@"high"];
            value = [number doubleValue];
            
            if(value<minY) minY=value;
            if(value>maxY) maxY=value;
            
            
            number = [data objectForKey:@"low"];
            value = [number doubleValue];
            
            if(value<minY) minY=value;
            if(value>maxY) maxY=value;
            
            
            
        }
        
    }
    
    
    // Axes
    
    
    [self setupAxis:graph withMinY:minY withMaxY:maxY];
    

    
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
    
    
    ohlcPlot.identifier = @"K_PLOT";
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
    
//    
//    ohlcPlot.increaseLineStyle=redLineStyle;
//    ohlcPlot.decreaseLineStyle=greenLineStyle;
//
    
//
    ohlcPlot.increaseLineStyle=redLineStyle;
    ohlcPlot.decreaseLineStyle=greenLineStyle;
    
    ohlcPlot.increaseFill = [CPTFill fillWithGradient:[CPTGradient increaseGradient]];
    ohlcPlot.decreaseFill = [CPTFill fillWithGradient:[CPTGradient decreaseGradient]];
    
    [graph addPlot:ohlcPlot];
}


-(NSDateFormatter*)getDateFormater{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if(self.plotType==PLOT_DETAIL){
        
        if(self.plotTimeType==XLViewPlotTime1Min ||
           self.plotTimeType==XLViewPlotTime5Min ||
           self.plotTimeType==XLViewPlotTime15Min ||
           self.plotTimeType==XLViewPlotTime30Min ||
           self.plotTimeType==XLViewPlotTime60Min ||
           self.plotTimeType==XLViewPlotTimeDay
           )
            [dateFormatter setDateFormat:@"dd日 HH时mm分"];
        else if(self.plotTimeType==XLViewPlotTimeWeek || self.plotTimeType==XLViewPlotTimeMonth)
            [dateFormatter setDateFormat:@"yyyy年mm月dd日"];
        else if(self.plotTimeType==XLViewPlotTimeYear){
            [dateFormatter setDateFormat:@"yyyy年mm月"];
            
        }
    }else{
        
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
        
    }
    return dateFormatter;
}

-(void)setupAxis:(CPTGraph*)graph withMinY:(double)minY withMaxY:(double)maxY
{

    NSTimeInterval seconds = 24 * 60 * 60;


    if(self.plotType==PLOT_DETAIL){
    
        if(self.plotTimeType==XLViewPlotTime1Min ||
           self.plotTimeType==XLViewPlotTime5Min ||
           self.plotTimeType==XLViewPlotTime15Min ||
           self.plotTimeType==XLViewPlotTime30Min ||
           self.plotTimeType==XLViewPlotTime60Min ||
           self.plotTimeType==XLViewPlotTimeDay
           )
            seconds = 60;
        else if(self.plotTimeType==XLViewPlotTimeWeek || self.plotTimeType==XLViewPlotTimeMonth)
            seconds = 60*60*24;
        else if(self.plotTimeType==XLViewPlotTimeYear){
            seconds = 60*60*24*12;
        }
    }else{
        seconds=[self getXSeconds];
    }
    

    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor darkGrayColor];
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor darkGrayColor];
    tickLineStyle.lineWidth = 1.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    
    gridLineStyle.dashPattern = @[@0.5,@1];
    gridLineStyle.lineColor=[CPTColor darkGrayColor];
    gridLineStyle.lineWidth = 0.8f;
    
    
    CPTXYAxisSet *xyAxisSet = (id)graph.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;
    
    xAxis.minorTicksPerInterval = 0;
    xAxis.axisLineStyle=axisLineStyle;
    xAxis.majorTickLineStyle=tickLineStyle;
    xAxis.minorTickLineStyle=nil;
    
    //    xAxis.majorGridLineStyle=gridLineStyle;
    //    xAxis.minorGridLineStyle=gridLineStyle;
    
    
    
    xAxis.tickDirection = CPTSignPositive;
    xAxis.tickLabelDirection=CPTSignNegative;
    xAxis.majorTickLength=3.0f;
    xAxis.minorTickLength=1.0f;
    xAxis.labelAlignment=CPTAlignmentLeft;
    
    //隐藏x刻度
    
    
    xAxis.labelTextStyle=nil;
    
    
    
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    yAxis.axisLineStyle=axisLineStyle;
    yAxis.majorTickLineStyle=tickLineStyle;
    yAxis.minorTickLineStyle=tickLineStyle;
    yAxis.majorGridLineStyle=gridLineStyle;
    yAxis.minorTicksPerInterval=0;
    yAxis.tickDirection = CPTSignPositive;
    yAxis.tickLabelDirection=CPTSignNegative;
    yAxis.majorTickLength=3.0f;
    yAxis.minorTickLength=1.0f;
    //刻度 密度
    
    CPTMutableTextStyle *yAxisTextStyle = [CPTMutableTextStyle textStyle];
    yAxisTextStyle.color    = [CPTColor orangeColor];
    yAxisTextStyle.fontSize = 8.0;
    yAxisTextStyle.textAlignment=CPTAlignmentRight;
    yAxis.labelTextStyle = yAxisTextStyle;


    CPTMutableLineStyle *rightAxisStyle = [CPTMutableLineStyle lineStyle];
    rightAxisStyle.lineColor = [CPTColor darkGrayColor];
    rightAxisStyle.lineWidth = AXIS_LINE_LENGTH;



    xAxis.majorIntervalLength   = CPTDecimalFromDouble(seconds);



    //    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    //刻度 密度
    //    xAxis.majorIntervalLength=CPTDecimalFromDouble(7*oneDay);


    NSDateFormatter *dateFormatter = [self getDateFormater];
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = self.refDate;
    xAxis.labelFormatter        = timeFormatter;




    CPTMutableTextStyle *axisTextStyle = [CPTMutableTextStyle textStyle];
    axisTextStyle.color    = [CPTColor orangeColor];
    axisTextStyle.fontSize = 8.0;

    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
    yAxis.labelTextStyle=axisTextStyle;


    double majorInterval = (maxY-minY)/8;

    double orthMinY=minY-2*majorInterval;
    

    double orthMaxY= maxY+2*majorInterval;



    //刻度 密度
    yAxis.majorIntervalLength=CPTDecimalFromDouble(majorInterval);
    //    yAxis.labelOnlyFirstAndLast = YES;

    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(orthMinY);

    
    
    double minX = seconds;
    
    double xLength = seconds * ([self numberOfRecordsForPlot:Nil]);


    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromDouble(xLength)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(orthMinY) length:CPTDecimalFromDouble(orthMaxY-orthMinY)];




    axisTextStyle = [CPTMutableTextStyle textStyle];
    axisTextStyle.color    = [CPTColor yellowColor];
    axisTextStyle.fontSize = 8.0;

    xAxis.labelTextStyle = axisTextStyle;

    xAxis.labelOnlyFirstAndLast = YES;

    CPTXYAxis *axisTop = [[CPTXYAxis alloc] init];
    axisTop.plotSpace                   = graph.defaultPlotSpace;
//    axisLeft.labelingPolicy              = CPTAxisLabelingPolicyEqualDivisions;
    axisTop.orthogonalCoordinateDecimal = CPTDecimalFromDouble(orthMaxY);
    axisTop.preferredNumberOfMajorTicks = 7;
    axisTop.minorTicksPerInterval       = 4;
    axisTop.tickDirection               = CPTSignNegative;
    axisTop.axisLineStyle               = axisLineStyle;
    axisTop.majorTickLength             = MAJOR_TICK_LENGTH;
    axisTop.majorTickLineStyle          = tickLineStyle;
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
    axisRight.orthogonalCoordinateDecimal = CPTDecimalFromDouble(xLength);
    axisRight.minorTicksPerInterval       = 1;
    axisRight.tickDirection               = CPTSignNegative;
    axisRight.axisLineStyle               = axisLineStyle;
    axisRight.majorTickLength             = 3.f;
    axisRight.majorTickLineStyle          = tickLineStyle;
    axisRight.minorTickLength             = 1;
    axisRight.minorTickLineStyle          = nil;
    axisRight.title                       = @"right axis";
    axisRight.titleTextStyle              = nil;
    axisRight.titleOffset                 = 0;
    axisRight.majorGridLineStyle=nil;
    axisRight.minorGridLineStyle=nil;
    axisRight.labelOnlyFirstAndLast=YES;

    axisRight.labelTextStyle = nil;


    axisRight.majorIntervalLength   = CPTDecimalFromDouble(majorInterval);

    axisRight.coordinate = CPTCoordinateY;




    graph.axisSet.axes = [NSArray arrayWithObjects:xAxis,yAxis, axisTop, axisRight, nil];
}

-(void)setupForScatterPlot{
    // 1 - Create the graph
    
    if(self.currPlotData==nil) return;
    

    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    
    
    
    NSArray* datas = self.currPlotData;
    
    
    double minY=0xFFFFFFF;
    double maxY=-1;
    
    
    for(int i=0;i<datas.count;i++){
        
        
        NSDictionary *data = [datas objectAtIndex:i];
        
        
        if([data isEqual:[NSNull null]]) continue;
        
        
        if(self.plotType!=PLOT_DETAIL){
            
            for(NSString *key in self.dataMapKeys){
                
                double value =   [data doubleValueForKey:key];
                if(value<minY) minY=value;
                if(value>maxY) maxY=value;
                
            }
            
        }else{
        
            
            if(self.plotDataType==XLViewPlotDataTPVolt || self.plotDataType==XLViewPlotDataTPCurr){
                
                //A 相电压
                NSNumber *number = [data objectForKey:@"ax"];
                double value = [number doubleValue];
                
                if(value<minY) minY=value;
                if(value>maxY) maxY=value;
                number = [data objectForKey:@"bx"];
                value = [number doubleValue];
                
                if(value<minY) minY=value;
                if(value>maxY) maxY=value;
                number = [data objectForKey:@"cx"];
                value = [number doubleValue];
                
                if(value<minY) minY=value;
                if(value>maxY) maxY=value;
                
                
            }else if(self.plotDataType==XLViewPlotDataSumAndTPRealPowerScatter||
                                self.plotDataType==XLViewPlotDataSumAndTPPowerFactorScatter||
                     self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter){
                
                //A相功率
                NSNumber *number = [data objectForKey:@"ax"];
                double value = [number doubleValue];
                
                if(value<minY) minY=value;
                if(value>maxY) maxY=value;
                number = [data objectForKey:@"bx"];
                value = [number doubleValue];
                
                if(value<minY) minY=value;
                if(value>maxY) maxY=value;
                number = [data objectForKey:@"cx"];
                value = [number doubleValue];
                
                if(value<minY) minY=value;
                if(value>maxY) maxY=value;
                
                
                number = [data objectForKey:@"pj"];
                value = [number doubleValue];
                
                if(value<minY) minY=value;
                if(value>maxY) maxY=value;
            }
        }
        
    }
    
    
    // Axes
    
    NSArray *colorsPlan = [NSArray arrayWithObjects:[CPTColor whiteColor],
                           [CPTColor redColor],
                           [CPTColor greenColor],
                           [CPTColor yellowColor],
                           [CPTColor blueColor],
                           [CPTColor orangeColor], nil];
    
    if(self.plotNum==3){
        colorsPlan = [NSArray arrayWithObjects:
                      [CPTColor redColor],
                      [CPTColor greenColor],
                      [CPTColor yellowColor],
                      [CPTColor blueColor],
                      [CPTColor orangeColor], nil];
        
    }
    

    [self setupAxis:graph withMinY:minY withMaxY:maxY];
    
    
    if(self.plotType==PLOT_DETAIL){
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        if(self.plotDataType==XLViewPlotDataTPVolt ||
           self.plotDataType==XLViewPlotDataTPCurr ||
           self.plotDataType==XLViewPlotDataSumAndTPRealPowerScatter||
                      self.plotDataType==XLViewPlotDataSumAndTPPowerFactorScatter||
           self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter){
            //Volt scatter plot for phase A
            
            CPTMutableLineStyle *lineStyleT = [CPTMutableLineStyle lineStyle];
            lineStyleT.lineWidth             = 1.0f;
            lineStyleT.lineColor             = [CPTColor redColor];
            
            CPTScatterPlot *dataSourceLinePlotT = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
            dataSourceLinePlotT.identifier    = @"SCATTER PLOT A";
            dataSourceLinePlotT.title         = @"Close Values";
            
            dataSourceLinePlotT.dataLineStyle = lineStyleT;
            dataSourceLinePlotT.dataSource    = self;
            
            plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    //        CPTColor *endColor = [CPTColor redColor];
    //        CPTColor *startColor = [endColor colorWithAlphaComponent:0.4f];
    //        CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:startColor endingColor:endColor];
    //        gradient.gradientType = CPTGradientTypeRadial;
    //        gradient.startAnchor = CGPointMake(0.35, 0.75);
            plotSymbol.fill = [CPTFill fillWithColor:[CPTColor redColor]];
            
            dataSourceLinePlotT.plotSymbol = plotSymbol;
            
            
            [graph addPlot:dataSourceLinePlotT];
            
            
            //Volt scatter plot for phase B
            lineStyleT = [CPTMutableLineStyle lineStyle];
            lineStyleT.lineWidth             = 1.0f;
            lineStyleT.lineColor             = [CPTColor greenColor];
            
            dataSourceLinePlotT = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
            dataSourceLinePlotT.identifier    = @"SCATTER PLOT B";
            dataSourceLinePlotT.title         = @"Close Values";
            
            dataSourceLinePlotT.dataLineStyle = lineStyleT;
            dataSourceLinePlotT.dataSource    = self;
            plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
            plotSymbol.fill = [CPTFill fillWithColor:[CPTColor blueColor]];
            dataSourceLinePlotT.plotSymbol = plotSymbol;
            
            
            [graph addPlot:dataSourceLinePlotT];
            
            
            lineStyleT = [CPTMutableLineStyle lineStyle];
            lineStyleT.lineWidth             = 1.0f;
            lineStyleT.lineColor             = [CPTColor yellowColor];
            
            dataSourceLinePlotT = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
            dataSourceLinePlotT.identifier    = @"SCATTER PLOT C";
            dataSourceLinePlotT.title         = @"Close Values";
            
            dataSourceLinePlotT.dataLineStyle = lineStyleT;
            dataSourceLinePlotT.dataSource    = self;
            
            plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
            plotSymbol.fill = [CPTFill fillWithColor:[CPTColor yellowColor]];
            dataSourceLinePlotT.plotSymbol = plotSymbol;
            
            
            [graph addPlot:dataSourceLinePlotT];
            
            if( self.plotDataType==XLViewPlotDataSumAndTPRealPowerScatter||
               self.plotDataType==XLViewPlotDataSumAndTPPowerFactorScatter||
               
               self.plotDataType==XLViewPlotDataSumAndTPReactivePowerScatter){
                lineStyleT = [CPTMutableLineStyle lineStyle];
                lineStyleT.lineWidth             = 1.0f;
                lineStyleT.lineColor             = [CPTColor whiteColor];
                
                dataSourceLinePlotT = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
                dataSourceLinePlotT.identifier    = @"SCATTER PLOT T";
                dataSourceLinePlotT.title         = @"Close Values";
                
                dataSourceLinePlotT.dataLineStyle = lineStyleT;
                dataSourceLinePlotT.dataSource    = self;
                
                plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
                plotSymbol.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
                dataSourceLinePlotT.plotSymbol = plotSymbol;
                
                [graph addPlot:dataSourceLinePlotT];
            }
        }
    }else{
        

        
        for(int i=0;i<self.plotNum;i++){
            CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
            CPTMutableLineStyle *lineStyleT = [CPTMutableLineStyle lineStyle];
            lineStyleT.lineWidth             = 1.0f;
            lineStyleT.lineColor             = [colorsPlan objectAtIndex:i];
            
            CPTScatterPlot *dataSourceLinePlotT = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
            dataSourceLinePlotT.identifier    = [ NSString stringWithFormat: @"S_PLOT %d",(i+1)];
            dataSourceLinePlotT.title         = @"Close Values";
            
            dataSourceLinePlotT.dataLineStyle = lineStyleT;
            dataSourceLinePlotT.dataSource    = self;
            
            plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
            //        CPTColor *endColor = [CPTColor redColor];
            //        CPTColor *startColor = [endColor colorWithAlphaComponent:0.4f];
            //        CPTGradient *gradient = [CPTGradient gradientWithBeginningColor:startColor endingColor:endColor];
            //        gradient.gradientType = CPTGradientTypeRadial;
            //        gradient.startAnchor = CGPointMake(0.35, 0.75);
            plotSymbol.fill = [CPTFill fillWithColor:[colorsPlan objectAtIndex:i]];
            
            dataSourceLinePlotT.plotSymbol = plotSymbol;
            
            
            [graph addPlot:dataSourceLinePlotT];

        }
        
    }

    
    
}



-(void) commoneSetupPlot:(CPTGraph*) graph
{
    
    
    
    if(self.currPlotData==nil) return;
    
    graph.paddingLeft=0;
    graph.paddingRight=0;
    graph.paddingTop=0;
    graph.paddingBottom=0;
    
    graph.plotAreaFrame.masksToBorder = NO;
    graph.plotAreaFrame.cornerRadius = 0.0f;
//    [self.plotView setAllowPinchScaling:YES];
    graph.defaultPlotSpace.allowsUserInteraction = YES;
    //        graph.defaultPlotSpace.allowsUserDragging = YES;
    
    
    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor           = [CPTColor whiteColor];
    borderLineStyle.lineWidth           = 1.0f;
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.paddingTop      = 1.0f;
    graph.plotAreaFrame.paddingRight    = 2.0f;
    graph.plotAreaFrame.paddingBottom   = 4.0f;
    graph.plotAreaFrame.paddingLeft     = 32.0f;
    graph.plotAreaFrame.masksToBorder   = NO;
    
    // Axes
    
    
    
}

-(void)activeButton:(id)button{
    for(UIButton* btn in _timeButtonsView.subviews){
        
        if(btn==button){
            btn.titleLabel.textColor = [UIColor whiteColor];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            
            
        }
        else{
            btn.titleLabel.textColor = [UIColor darkGrayColor];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        
    }
}


-(void)plotSwitchBtnPressed:(id)sender{

    [self activeButton:sender];
    
    if(sender == realBtn){
        [self showPlotTimeTypePopMenu];
        return;
    }
    if(sender == dayBtn){
        self.plotTimeType = XLViewPlotTimeDay;
    }
    if(sender == weekBtn){
        self.plotTimeType = XLViewPlotTimeWeek;
    }
    if(sender == monthBtn){
        self.plotTimeType = XLViewPlotTimeMonth;
    }
    if(sender == yearBtn){
        self.plotTimeType = XLViewPlotTimeYear;
    }
    
    [self requestPlotData];
    
}

#pragma mark - LeveyPopListView delegates
- (void)leveyPopListView:(LeveyPopListView *)popListView didSelectedIndex:(NSInteger)anIndex
{

        NSString *title = [NSString stringWithFormat:@"%@▽",[[dataOptions objectAtIndex:anIndex] objectForKey:@"text"]];

        [realBtn setTitle:title forState:UIControlStateNormal];

                self.plotTimeType = minutesOptions[anIndex];



        [self requestPlotData];
}
- (void)leveyPopListViewDidCancel
{

}

- (void)showPlotTimeTypePopMenu
{
    

    
    dataOptions=[[NSMutableArray alloc]init];
    
    for(int i=0;i<sizeof(minutesOptions)/sizeof(int);i++){
        if(minutesOptions[i]!=0){
            

            
            NSString* label=@"1分钟";
            
            if(minutesOptions[i]==XLViewPlotTime5Min){
                label=@"5分钟";
            }
            if(minutesOptions[i]==XLViewPlotTime15Min){
                label=@"15分钟";
                
            }
            if(minutesOptions[i]==XLViewPlotTime30Min){
                label=@"30分钟";
                
            }
            if(minutesOptions[i]==XLViewPlotTime60Min){
                label=@"60分钟";
            }
            
            
            [dataOptions addObject:[NSDictionary dictionaryWithObjectsAndKeys:label,@"text", nil]];
            
        }
    }
 
    
    UIWindow *frontWindow = [[[UIApplication sharedApplication] windows]
                             lastObject];
    
    
    LeveyPopListView *lplv = [[LeveyPopListView alloc] initWithTitle:@"选择时间类型" options:dataOptions];
    lplv.delegate = self;
    [lplv showInView:frontWindow animated:YES];

    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - plot data source
-(void)showPercentProgress:(float)percent{
    
    
    
    if(percent==1){
        
        self.progressBar.hidden=YES;
        [self.progressBar setProgress:0 animated:NO];
    }else{
        self.progressBar.hidden=NO;
        [self.progressBar setProgress:percent animated:YES];
    }
    
}

- (void)handleProgressPecentNotify:(NSNotification *)notification{
    NSDictionary *resp =(NSDictionary*) notification.userInfo;
    NSNumber* number = [resp objectForKey:@"percent"];
    dispatch_async(dispatch_get_main_queue(), ^{
        //todo update ui progress
        [self showPercentProgress:[number floatValue]];
    });
    
    
}
- (void)handleNotification:(NSNotification *)notification
{
    NSDictionary *resp =(NSDictionary*) notification.userInfo;
    
    NSDictionary* param = [resp objectForKey:@"parameter"];
    if (![[param objectForKey:@"xl-name"] isEqualToString:@"plotdata-detail"]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.currPlotData=(NSArray*)([resp objectForKey:@"array1"]);
        
        int idx=self.currPlotData.count-1;
        
        while(idx>=0){
            
            if([self.currPlotData objectAtIndex:idx] != [NSNull null]){
                break;
            }
            
            idx--;
        }
        
        if(idx<0) idx=0;
        
        [self handlePlotDateResponse:self.currPlotData];
        
        
        isLoadingData=NO;
    });
}

-(void)calculatePlotForRecordsNum:(int*)numRecords andTimeDensity:(int*)timeDensity{
    if(self.plotType==PLOT_DETAIL){
        
        if(self.plotTimeType==XLViewPlotTime5Min){
            *timeDensity=XLViewPlotTime1Min;
            *numRecords=5;
        }
        
        if(self.plotTimeType==XLViewPlotTime15Min){
            *timeDensity=XLViewPlotTime1Min;
            *numRecords=15;
        }
        if(self.plotTimeType==XLViewPlotTime30Min){
            *timeDensity=XLViewPlotTime1Min;
            *numRecords=30;
        }
        
        if(self.plotTimeType==XLViewPlotTime60Min){
            *timeDensity=XLViewPlotTime1Min;
            *numRecords=60;
        }
        
        if(self.plotTimeType==XLViewPlotTimeDay){
            *timeDensity=XLViewPlotTime1Min;
            *numRecords=24*60*60;
        }
        
        if(self.plotTimeType==XLViewPlotTimeWeek){
            *timeDensity=XLViewPlotTimeDay;
            *numRecords=7;
        }
        
        if(self.plotTimeType==XLViewPlotTimeMonth){
            *timeDensity=XLViewPlotTimeDay;
            
            NSCalendar *c = [NSCalendar currentCalendar];
            NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                                   inUnit:NSMonthCalendarUnit
                                  forDate:self.refDate];
            
            *numRecords=days.length;
        }
        
        if(self.plotTimeType==XLViewPlotTimeYear){
            *timeDensity=XLViewPlotTimeMonth;
            
            
            *numRecords=12;
        }
    }else{
        *timeDensity=XLViewPlotTimeDay;
        
        *numRecords=30;
    }
}


//请求数据
-(void)requestPlotData{
    
    int numRecords;
    int timeDensity;
    
    [self calculatePlotForRecordsNum:&numRecords andTimeDensity:&timeDensity];
    
    
    
    NSDictionary* param = [NSDictionary dictionaryWithObjectsAndKeys:@"plotdata-detail",@"xl-name",
                           self.refDate,@"start-date",
                           [NSNumber numberWithInt:self.plotDataType],@"plot-type",
                           //如果 plot-type 为 XLViewPlotDataByName 类型
                           //根据 plot-name 确定曲线数据类型
                           self.plotDataTitle,@"plot-name",
                           //返回的数据字典所包含的keys
                           self.dataMapKeys,@"data-map-keys",
                           [NSNumber numberWithInt:timeDensity],@"time-type",
                           [NSNumber numberWithInt:numRecords],@"num-records",
                           nil];
    
    [[XLModelDataInterface testData]requestPlotData:param];
    
    
}



//更新图表
-(void)handlePlotDateResponse:(NSArray*)aryResponse{
    
    self.currPlotData = aryResponse;
    
    [self commoneSetupPlot:graph];
    
    [graph removeAllPlots ];
    
    if(self.currPlotData==nil){
        graph.hidden=YES;
    }else{
        graph.hidden=NO;
        
    }
    
    [self setupPlots];
    
    [graph reloadData];
    
    
    
    //[self renderDetailDataAt];
    
    
    [self.ewTableView reloadData];
    

    
}

-(void)renderDetailTableView{
    

    
    dateColWidth = 100;
    cellHeight=25;
    
    
    colWidth=MAX((320-dateColWidth)/self.plotTags.count,(320-dateColWidth)/4);
    
    
 
    
    CGRect rcPlot = _viewPlotArea.frame;
    
    int height = 400;
    
    float yPos = rcPlot.origin.y+rcPlot.size.height+10;
    
    if(self.plotType==PLOT_DETAIL) yPos-=30;
    
    
    self.ewTableView = [[EWMultiColumnTableView alloc] initWithFrame:
                        CGRectMake(0, yPos, 320, height)
                        ];
    self.ewTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.ewTableView.sectionHeaderEnabled = NO;
    //    tblView.cellWidth = 100.0f;
    self.ewTableView.backgroundColor = [UIColor blackColor];
    self.ewTableView.leftHeaderBackgroundColor = [UIColor blackColor];
    self.ewTableView.boldSeperatorLineColor = [UIColor listDividerColor];
    self.ewTableView.normalSeperatorLineColor = [UIColor listDividerColor];
    self.ewTableView.boldSeperatorLineWidth = 1.0f;
    self.ewTableView.normalSeperatorLineWidth = 1.0f;
    self.ewTableView.dataSource = self;
    
    [self.viewScrollContaner addSubview:self.ewTableView];

}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSArray* datas = self.currPlotData;
    
    
    int numRecords;
    int timeDensity;
    
    [self calculatePlotForRecordsNum:&numRecords andTimeDensity:&timeDensity];

    if(numRecords>datas.count) numRecords=datas.count;
    
    return numRecords;
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

-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    NSArray *nums = nil;
    
    int seconds = 24*60*60;
    if(self.plotType==PLOT_DETAIL){
        if(self.plotTimeType==XLViewPlotTime1Min ||
           self.plotTimeType==XLViewPlotTime5Min ||
           self.plotTimeType==XLViewPlotTime15Min ||
           self.plotTimeType==XLViewPlotTime30Min ||
           self.plotTimeType==XLViewPlotTime60Min ||
                  self.plotTimeType==XLViewPlotTimeDay
           )
            seconds = 60;
        else if(self.plotTimeType==XLViewPlotTimeWeek || self.plotTimeType==XLViewPlotTimeMonth)
            seconds = 60*60*24;
        else if(self.plotTimeType==XLViewPlotTimeYear){
            seconds = 60*60*24*12;
        }
    }else{
        
        seconds=[self getXSeconds];
        
    }
    NSArray* datas = self.currPlotData;
    
    if ( [plot.identifier isEqual:@"BAR PLOT"] ) {
        
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    [(NSMutableArray *)nums addObject :[NSDecimalNumber numberWithUnsignedInteger:seconds*i] ];
                }
                break;
                
            case CPTBarPlotFieldBarTip:
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    if(self.plotDataType==XLViewPlotDataByName){
                        
                        NSDictionary *data = [datas objectAtIndex:i];
                        
                        if([data isEqual:[NSNull null]]){
                            [(NSMutableArray *)nums addObject :[NSNull null]];
                            continue;
                        }
                        
                        //电量
                        NSNumber* number = [data objectForKey:[self.dataMapKeys objectAtIndex:0]];
                        [(NSMutableArray *)nums addObject :number];
                    }
                    
                    
                }
        }
    }
    else if ( [(NSString*)plot.identifier hasPrefix:@"S_PLOT"] ) {
        
        
        NSString *idx = [(NSString*)plot.identifier substringFromIndex:[(NSString*)plot.identifier length]-1];
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    
                    [(NSMutableArray *)nums addObject :[NSDecimalNumber numberWithUnsignedInteger:seconds*i] ];
                }
                break;
                
            case CPTBarPlotFieldBarTip:
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    
                    NSDictionary *data = [datas objectAtIndex:i];
                    if([data isEqual:[NSNull null]]){
                        [(NSMutableArray *)nums addObject :[NSNull null]];
                        continue;
                    }
                    NSNumber* number = [data objectForKey:[NSString stringWithFormat:@"v%@",idx]];
                    [(NSMutableArray *)nums addObject :number];
                }
        }
    }
    else if ( [plot.identifier isEqual:@"K_PLOT"] ) {
        
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];

        for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
            
            NSDictionary *data = [datas objectAtIndex:i];
            
            
            if([data isEqual:[NSNull null]]){
                [(NSMutableArray *)nums addObject :[NSNull null]];
                continue;
            }
            
            NSTimeInterval x = seconds*i;
            
            double rOpen,rClose;
            rOpen= [data doubleValueForKey:@"open"];
            rClose=[data doubleValueForKey:@"close"];
            
            double rHigh=[data doubleValueForKey:@"high"];
            double rLow=[data doubleValueForKey:@"low"];
            
            
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

    }else if ( [plot.identifier isEqual:@"SCATTER PLOT A"] ) {
        
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    
                     [(NSMutableArray *)nums addObject :[NSDecimalNumber numberWithUnsignedInteger:seconds*i] ];
                }
                break;
                
            case CPTBarPlotFieldBarTip:
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    
                    NSDictionary *data = [datas objectAtIndex:i];
                    if([data isEqual:[NSNull null]]){
                        [(NSMutableArray *)nums addObject :[NSNull null]];
                        continue;
                    }
                    NSNumber* number = [data objectForKey:@"ax"];
                    [(NSMutableArray *)nums addObject :number];
                }
        }
    }else if ( [plot.identifier isEqual:@"SCATTER PLOT B"] ) {
        
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    
                     [(NSMutableArray *)nums addObject :[NSDecimalNumber numberWithUnsignedInteger:seconds*i] ];
                }
                break;
                
            case CPTBarPlotFieldBarTip:
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    NSDictionary *data = [datas objectAtIndex:i];
                    if([data isEqual:[NSNull null]]){
                        [(NSMutableArray *)nums addObject :[NSNull null]];
                        continue;
                    }
                    NSNumber* number = [data objectForKey:@"bx"];
                    [(NSMutableArray *)nums addObject :number];
                }
        }
    }else if ( [plot.identifier isEqual:@"SCATTER PLOT C"] ) {
        
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                     [(NSMutableArray *)nums addObject :[NSDecimalNumber numberWithUnsignedInteger:seconds*i] ];
                }
                break;
                
            case CPTBarPlotFieldBarTip:
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    NSDictionary *data = [datas objectAtIndex:i];
                    if([data isEqual:[NSNull null]]){
                        [(NSMutableArray *)nums addObject :[NSNull null]];
                        continue;
                    }
                    NSNumber* number = [data objectForKey:@"cx"];
                    [(NSMutableArray *)nums addObject :number];
                }
        }
    }else if ( [plot.identifier isEqual:@"SCATTER PLOT T"] ) {
        
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];
        switch ( fieldEnum ) {
            case CPTBarPlotFieldBarLocation:
                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                     [(NSMutableArray *)nums addObject :[NSDecimalNumber numberWithUnsignedInteger:seconds*i] ];
                }
                break;
                
            case CPTBarPlotFieldBarTip:
                
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                    
                    NSDictionary *data = [datas objectAtIndex:i];
                    if([data isEqual:[NSNull null]]){
                        [(NSMutableArray *)nums addObject :[NSNull null]];
                        continue;
                    }
                    NSNumber* number = [data objectForKey:@"pj"];
                    [(NSMutableArray *)nums addObject :number];
                }
        }
    }
    return nums;
}



-(IBAction)plotGowardTouchDown:(id)sender{
    
    
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
    
    
    [timer invalidate];
    timer=nil;
    
}
-(IBAction)plotGowardTouchUpOutside:(id)sender{
    
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
    
    [self requestPlotData];
}



#pragma mark - EWMultiColumnTableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(EWMultiColumnTableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(EWMultiColumnTableView *)tableView cellForIndexPath:(NSIndexPath *)indexPath column:(NSInteger)col
{
    
    float cellWidth;

        cellWidth=colWidth;

    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cellWidth, cellHeight)];
    view.backgroundColor = [UIColor listItemBgColor];
    view.tag = 500 + col;
    
    CGRect rect = CGRectMake(5, 2, cellWidth - 10, cellHeight-2);
    UILabel *uiLabel = [[UILabel alloc] initWithFrame:rect];
    
    uiLabel.textColor=[UIColor greenColor];
    uiLabel.font=[UIFont systemFontOfSize:12];
    uiLabel.lineBreakMode=NSLineBreakByWordWrapping;
    uiLabel.textAlignment=NSTextAlignmentCenter;
    uiLabel.numberOfLines=0;
    
    uiLabel.tag = 1;
  
    [view addSubview:uiLabel];

    return view;
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForCell:(UIView *)cell indexPath:(NSIndexPath *)indexPath column:(NSInteger)col {
    UILabel *uiLabel = (UILabel *)[cell viewWithTag:1];
  
    NSString* cellValue = [NSString stringWithFormat:@"%d-%d",indexPath.row,col];
    
    NSArray *datas= self.currPlotData;
    
    NSDictionary *data = [datas objectAtIndex:indexPath.row];
    
    if([data isEqual:[NSNull null]]){
        cellValue=@"-";
    }else{
        cellValue=[[data objectForKey:[self.dataMapKeys objectAtIndex:col] ] stringValue];
    }

    
    uiLabel.text = cellValue;
    //dropDownView.title = value;
    
 }

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView heightForCellAtIndexPath:(NSIndexPath *)indexPath column:(NSInteger)col
{
    return cellHeight;
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView widthForColumn:(NSInteger)column
{

    return colWidth;
}

- (NSInteger)tableView:(EWMultiColumnTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.currPlotData==nil) return 0;
    return self.currPlotData.count;
}

//table 中的section header
- (UIView *)tableView:(EWMultiColumnTableView *)tableView sectionHeaderCellForSection:(NSInteger)section column:(NSInteger)col
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectZero];
    l.backgroundColor = [UIColor yellowColor];
    return l;
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForSectionHeaderCell:(UIView *)cell section:(NSInteger)section column:(NSInteger)col
{
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView heightForSectionHeaderCellAtSection:(NSInteger)section column:(NSInteger)col
{
    return 0.0f;
}

- (NSInteger)numberOfColumnsInTableView:(EWMultiColumnTableView *)tableView
{
    int colNum = self.dataMapKeys.count;

    return colNum;
}

#pragma mark Header Cell
//行标题栏
- (UIView *)tableView:(EWMultiColumnTableView *)tableView headerCellForIndexPath:(NSIndexPath *)indexPath
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dateColWidth, cellHeight)];
    view.backgroundColor = [UIColor listItemBgColor];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(5.0f, 2.0f, dateColWidth-5.0f, cellHeight-2.0f)];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor textWhiteColor];
    l.adjustsFontSizeToFitWidth = YES;
    l.tag = 111;
    [view addSubview:l];
    
    return view;
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForHeaderCell:(UIView *)cell atIndexPath:(NSIndexPath *)indexPath
{
    UILabel *l = (UILabel *)[cell viewWithTag:111];
    
    int seconds = [self getXSeconds];
    
    NSDateFormatter *dateFormater = [self getDateFormater];
    
    
    NSDate* newDate=[self.refDate dateByAddingTimeInterval:seconds*indexPath.row];
    
    NSString *dateString = [dateFormater stringFromDate:newDate];
    
    l.text= dateString;
    
    l.textColor=[UIColor yellowColor];
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView heightForHeaderCellAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

//行标题栏中的section header
- (UIView *)tableView:(EWMultiColumnTableView *)tableView headerCellInSectionHeaderForSection:(NSInteger)section
{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectZero];
    return l;
}

- (void)tableView:(EWMultiColumnTableView *)tableView setContentForHeaderCellInSectionHeader:(UIView *)cell AtSection:(NSInteger)section
{
}

- (CGFloat)tableView:(EWMultiColumnTableView *)tableView heightForHeaderCellInSectionHeaderAtSection:(NSInteger)section
{
    return 0.0f;
}

//列标题
- (UIView *)tableView:(EWMultiColumnTableView *)tableView headerCellForColumn:(NSInteger)col
{
    
    float cellWidth=colWidth;

    
    MySectionHeaderView *view =  [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cellWidth, cellHeight)];

    
    UILabel *uiLabel = [[UILabel alloc] initWithFrame:view.bounds];
    
    uiLabel.textColor=[UIColor whiteColor];
    uiLabel.backgroundColor = [UIColor clearColor];
    uiLabel.font=[UIFont systemFontOfSize:12];
    uiLabel.lineBreakMode=NSLineBreakByWordWrapping;
    uiLabel.textAlignment=NSTextAlignmentCenter;
    uiLabel.numberOfLines=0;
    
    uiLabel.tag = 1;

    

    NSString *column = [self.plotTags objectAtIndex:col];
    uiLabel.text = column;
    [view addSubview:uiLabel];
    
    return view;
}

//左上角
- (UIView *)topleftHeaderCellOfTableView:(EWMultiColumnTableView *)tableView
{
    MySectionHeaderView *view =  [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, dateColWidth, [self heightForHeaderCellOfTableView:tableView])];
    CGRect rect = view.bounds;
    rect.origin.x = 5;
    rect.size.width -= 5;
    UILabel *l = [[UILabel alloc] initWithFrame:rect];
    l.backgroundColor = [UIColor clearColor];
    l.textColor = [UIColor whiteColor];
    l.font = [UIFont systemFontOfSize:12];
    l.text = @"时间";
    [view addSubview:l];
    
    return view;
}

- (CGFloat)heightForHeaderCellOfTableView:(EWMultiColumnTableView *)tableView
{
    return cellHeight;
}

- (CGFloat)widthForHeaderCellOfTableView:(EWMultiColumnTableView *)tableView
{
    return dateColWidth;
}


@end
