//
//  PSViewController.m
//  PieChart
//
//  Created by Pavan Podila on 2/26/12.
//  Copyright (c) 2012 Pixel-in-Gene. All rights reserved.
//

#import "PSViewController.h"
#import "CPDStockPriceStore.h"
#import "CPDConstants.h"
#import "Model/TestDataSource.h"

@implementation PSViewController
@synthesize pieView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
- (IBAction)animatePieSlices:(id)sender {
	NSMutableArray *randomNumbers = [NSMutableArray array];
	int count = 1 + rand() % 10;
	for (int i = 0; i < count; i++) {
		[randomNumbers addObject:[NSNumber numberWithInt:rand() % 100]];
	}
	
	pieView.sliceValues = randomNumbers;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initPlot];
	// Do any additional setup after loading the view, typically from a nib.
}



- (void)viewDidUnload
{
	[self setPieView:nil];
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



#pragma mark - Chart behavior
-(void)initPlot {
//    [self configureHost];
//    [self configureGraph];
//    [self configureChart];
//    [self configureLegend];
//    [self configureAxes];
    
//    [self testRangePlot];
    [self testTrendRangePlot];
    [self testBarPlot];
    
    graph2.relativeGraph = graph;
    graph.relativeGraph = graph2;
}

-(void)configureHost {

    
}

-(void)configureGraph {
    
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	[graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
	self.hostView.hostedGraph = graph;
    graph.paddingTop=0;
    graph.paddingBottom=0;
    graph.paddingLeft=0;
        graph.paddingRight=0;
	// 2 - Set graph title
	NSString *title = @"Portfolio Prices: April 2012";
	graph.title = title;
	// 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
	// 4 - Set padding for plot area
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:30.0f];
    [graph.plotAreaFrame setPaddingTop:30.0f];
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;

}

-(void)configureChart {
    
	// 1 - Get graph and plot space
	CPTGraph *graph = self.hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
    
    
	
    // 2 - Create the three plots
	CPTScatterPlot *aaplPlot = [[CPTScatterPlot alloc] init];
	aaplPlot.dataSource = self;
	aaplPlot.identifier = CPDTickerSymbolAAPL;
	CPTColor *aaplColor = [CPTColor redColor];
	[graph addPlot:aaplPlot toPlotSpace:plotSpace];
	
//    CPTScatterPlot *googPlot = [[CPTScatterPlot alloc] init];
//	googPlot.dataSource = self;
//	googPlot.identifier = CPDTickerSymbolGOOG;
//	CPTColor *googColor = [CPTColor greenColor];
//	[graph addPlot:googPlot toPlotSpace:plotSpace];
	
    CPTScatterPlot *msftPlot = [[CPTScatterPlot alloc] init];
	msftPlot.dataSource = self;
	msftPlot.identifier = CPDTickerSymbolMSFT;
	CPTColor *msftColor = [CPTColor blueColor];
    [graph addPlot:msftPlot toPlotSpace:plotSpace];
    
    
    
    

    
	// 3 - Set up plot space
	[plotSpace scaleToFitPlots:[NSArray arrayWithObjects:
                                aaplPlot,
//                                googPlot,
                                msftPlot,
                                nil]];
    
    
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
	plotSpace.xRange = xRange;
    
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
	// 4 - Create styles and symbols
    
	CPTMutableLineStyle *aaplLineStyle = [aaplPlot.dataLineStyle mutableCopy];
	aaplLineStyle.lineWidth = 1.0;
	aaplLineStyle.lineColor = aaplColor;
	aaplPlot.dataLineStyle = aaplLineStyle;
    
	CPTMutableLineStyle *aaplSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	aaplSymbolLineStyle.lineColor = aaplColor;
	CPTPlotSymbol *aaplSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	aaplSymbol.fill = [CPTFill fillWithColor:aaplColor];
	aaplSymbol.lineStyle = aaplSymbolLineStyle;
	aaplSymbol.size = CGSizeMake(2.0f, 2.0f);
	aaplPlot.plotSymbol = aaplSymbol;
	
//    CPTMutableLineStyle *googLineStyle = [googPlot.dataLineStyle mutableCopy];
//	googLineStyle.lineWidth = 1.0;
//	googLineStyle.lineColor = googColor;
//	googPlot.dataLineStyle = googLineStyle;
//	CPTMutableLineStyle *googSymbolLineStyle = [CPTMutableLineStyle lineStyle];
//	googSymbolLineStyle.lineColor = googColor;
//	CPTPlotSymbol *googSymbol = [CPTPlotSymbol starPlotSymbol];
//	googSymbol.fill = [CPTFill fillWithColor:googColor];
//	googSymbol.lineStyle = googSymbolLineStyle;
//	googSymbol.size = CGSizeMake(6.0f, 6.0f);
//	googPlot.plotSymbol = googSymbol;
    
    
	CPTMutableLineStyle *msftLineStyle = [msftPlot.dataLineStyle mutableCopy];
	msftLineStyle.lineWidth = 1.0;
	msftLineStyle.lineColor = msftColor;
	msftPlot.dataLineStyle = msftLineStyle;
	
    CPTMutableLineStyle *msftSymbolLineStyle = [CPTMutableLineStyle lineStyle];
	msftSymbolLineStyle.lineColor = msftColor;
    
	CPTPlotSymbol *msftSymbol = [CPTPlotSymbol diamondPlotSymbol];
	msftSymbol.fill = [CPTFill fillWithColor:msftColor];
	msftSymbol.lineStyle = msftSymbolLineStyle;
	msftSymbol.size = CGSizeMake(2.0f, 2.0f);
	msftPlot.plotSymbol = msftSymbol;



//    CPTXYPlotSpace *plotSpace2 = [[CPTXYPlotSpace alloc] init];
//    plotSpace2.xRange = plotSpace.xRange;
//    plotSpace2.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(20)
//                                                     length:CPTDecimalFromFloat(100 - 20)];
//    [graph addPlotSpace:plotSpace2];
////    y2.plotSpace = plotSpace2;
    
    
    
    
    
}

-(void)configureLegend {
}

-(void)configureAxes {
    
    // 1 - Create styles
    CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
    axisTitleStyle.color = [CPTColor whiteColor];
    axisTitleStyle.fontName = @"Helvetica-Bold";
    axisTitleStyle.fontSize = 8.0f;
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 8.0f;
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 1.0f;
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];

    gridLineStyle.dashPattern = @[@0.5,@1];
    gridLineStyle.lineColor=[CPTColor grayColor];
    gridLineStyle.lineWidth = 1.0f;

    // 2 - Get axis set
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
    // 3 - Configure x-axis
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Day of Month";
    x.titleTextStyle = axisTitleStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = axisLineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLineStyle = axisLineStyle;
    x.majorTickLength = 1.0f;
    x.tickDirection = CPTSignNegative;
    CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
    NSInteger i = 0;
    
    for (NSString *date in [[CPDStockPriceStore sharedInstance] datesInMonth]) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
        CGFloat location = i++;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    // 4 - Configure y-axis
    CPTAxis *y = axisSet.yAxis;
//    y.title = @"Price";
    y.titleTextStyle = axisTitleStyle;
    y.titleOffset = -10.0f;
    y.axisLineStyle = axisLineStyle;
    y.majorGridLineStyle = gridLineStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = axisLineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    NSInteger majorIncrement = 100;
    NSInteger minorIncrement = 50;
    CGFloat yMax = 700.0f;  // should determine dynamically based on max price
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
        NSUInteger mod = j % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(j);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
        }
    }
    y.axisLabels = yLabels;    
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
    
    

    
    
    
}

-(void)testRangePlot{
    
    NSDate* refDate = [NSDate date];
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    // 1 - Create the graph
    if(graph==nil){
        graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
        [graph applyTheme:[CPTTheme themeNamed:kCPTStocksTheme]];
        self.hostView.hostedGraph = graph;
        graph.paddingLeft=0;
        graph.paddingRight=0;
    }
    
    // Title
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color         = [CPTColor whiteColor];
    textStyle.fontSize      = 18.0f;
    textStyle.fontName      = @"Helvetica";
    graph.title             = @"Click to Toggle Range Plot Style";
    graph.titleTextStyle    = textStyle;
    graph.titleDisplacement = CGPointMake(0.0f, -20.0f);
    
    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    NSTimeInterval xLow       = oneDay * 0.5f;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xLow) length:CPTDecimalFromFloat(oneDay * 5.0f)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(1.0) length:CPTDecimalFromFloat(5.0)];
    
    // Axes
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromFloat(oneDay);
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"2");
    x.minorTicksPerInterval       = 0;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;
    
    CPTXYAxis *y = axisSet.yAxis;
    y.majorIntervalLength         = CPTDecimalFromString(@"0.5");
    y.minorTicksPerInterval       = 5;
    y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(oneDay);
    
    // Create a plot that uses the data source method
    CPTRangePlot *dataSourceLinePlot = [[CPTRangePlot alloc] init] ;
    dataSourceLinePlot.identifier = @"Date Plot";
    
    // Add line style
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth             = 1.0f;
    lineStyle.lineColor             = [CPTColor greenColor];
    CPTLineStyle *barLineStyle;
    barLineStyle                    = lineStyle;
    dataSourceLinePlot.barLineStyle = barLineStyle;
    
    // Bar properties
    dataSourceLinePlot.barWidth   = 10.0f;
    dataSourceLinePlot.gapWidth   = 20.0f;
    dataSourceLinePlot.gapHeight  = 20.0f;
    
    dataSource = [[TestDataSource alloc]initWithTestData];
    dataSourceLinePlot.dataSource = dataSource;
    
    // Add plot
    [graph addPlot:dataSourceLinePlot];
    graph.defaultPlotSpace.delegate = dataSource;
    
    // Store area fill for use later
    CPTColor *transparentGreen = [[CPTColor greenColor] colorWithAlphaComponent:0.2];
//    areaFill = [[CPTFill alloc] initWithColor:(id)transparentGreen];
}

-(void)testTrendRangePlot{
    // 1 - Create the graph
    
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:oneDay / 2.0];
    
    
    if(graph==nil){
        graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
        [graph applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
        self.hostView.hostedGraph = graph;
        graph.paddingLeft=0;
        graph.paddingRight=0;
        graph.paddingTop=0;
        graph.paddingBottom=0;
        
        graph.plotAreaFrame.masksToBorder = NO;
        graph.plotAreaFrame.cornerRadius = 0.0f;
        [self.hostView setAllowPinchScaling:YES];
        graph.defaultPlotSpace.allowsUserInteraction = YES;
//        graph.defaultPlotSpace.allowsUserDragging = YES;
    }
    
    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor           = [CPTColor whiteColor];
    borderLineStyle.lineWidth           = 1.0f;
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.paddingTop      = 20.0f;
    graph.plotAreaFrame.paddingRight    = 20.0f;
    graph.plotAreaFrame.paddingBottom   = 30.0f;
    graph.plotAreaFrame.paddingLeft     = 30.0f;
    graph.plotAreaFrame.masksToBorder   = NO;
    
    // Axes
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 1.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    
    gridLineStyle.dashPattern = @[@0.5,@1];
    gridLineStyle.lineColor=[CPTColor grayColor];
    gridLineStyle.lineWidth = 1.0f;
    
    
    CPTXYAxisSet *xyAxisSet = (id)graph.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;
    xAxis.majorIntervalLength   = CPTDecimalFromDouble(oneDay);
    
    xAxis.minorTicksPerInterval = 1;
    xAxis.axisLineStyle=axisLineStyle;
    xAxis.majorTickLineStyle=tickLineStyle;
    
    xAxis.majorGridLineStyle=gridLineStyle;
    xAxis.minorGridLineStyle=gridLineStyle;
    xAxis.minorTickLineStyle=tickLineStyle;
    
    xAxis.tickDirection = CPTSignPositive;
    xAxis.tickLabelDirection=CPTSignNegative;
    xAxis.majorTickLength=3.0f;
    xAxis.minorTickLength=1.0f;
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    xAxis.labelFormatter        = timeFormatter;
    
    
    //x 轴箭头
    if(0){
        CPTLineCap *lineCap = [[CPTLineCap alloc] init];
        lineCap.lineStyle    = xAxis.axisLineStyle;
        lineCap.lineCapType  = CPTLineCapTypeOpenArrow;
        lineCap.size         = CGSizeMake(12.0, 12.0);
        xAxis.axisLineCapMax = lineCap;
    }
    
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-0.5*oneDay);
    yAxis.axisLineStyle=axisLineStyle;
    yAxis.majorTickLineStyle=tickLineStyle;
    yAxis.minorTickLineStyle=tickLineStyle;
    yAxis.majorGridLineStyle=gridLineStyle;
    yAxis.minorTicksPerInterval=1;
    yAxis.tickDirection = CPTSignPositive;
    yAxis.tickLabelDirection=CPTSignNegative;
    yAxis.majorTickLength=3.0f;
    yAxis.minorTickLength=1.0f;
    
    
    
    
    
    
    
    dataSource = [[TestDataSource alloc]initWithTestData];
    
    
    
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    //CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    //dataSourceLinePlot.areaFill      = areaGradientFill;
    //dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(0.0);
    
    areaColor                         = [CPTColor colorWithComponentRed:0.0 green:1.0 blue:0.0 alpha:0.6];
    areaGradient                      = [CPTGradient gradientWithBeginningColor:[CPTColor clearColor] endingColor:areaColor];
    areaGradient.angle                = -90.0f;
    //areaGradientFill                  = [CPTFill fillWithGradient:areaGradient];
    //dataSourceLinePlot.areaFill2      = areaGradientFill;
    //dataSourceLinePlot.areaBaseValue2 = CPTDecimalFromDouble(5.0);
    
    // OHLC plot
    
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineColor = [CPTColor redColor];
    redLineStyle.lineWidth = 1.0;
    
    
    CPTMutableLineStyle *greenLineStyle = [CPTMutableLineStyle lineStyle];
    greenLineStyle.lineColor = [CPTColor greenColor];
    greenLineStyle.lineWidth = 1.0;
    
    
    
    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];
    whiteLineStyle.lineWidth = 2.0;
    CPTTradingRangePlot *ohlcPlot = [(CPTTradingRangePlot *)[CPTTradingRangePlot alloc] initWithFrame : graph.bounds];
    ohlcPlot.identifier = @"OHLC";
    ohlcPlot.lineStyle  = whiteLineStyle;
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = 12.0;
    //标签
    //    ohlcPlot.labelTextStyle = whiteTextStyle;
    ohlcPlot.labelTextStyle = nil;
    
    ohlcPlot.labelOffset    = 5.0;
    ohlcPlot.stickLength    = 10.0;
    ohlcPlot.dataSource     = dataSource;
    ohlcPlot.delegate       = self;
    ohlcPlot.plotStyle      = CPTTradingRangePlotStyleCandleStick;
    
    
    ohlcPlot.increaseLineStyle=redLineStyle;
    ohlcPlot.decreaseLineStyle=greenLineStyle;
    [graph addPlot:ohlcPlot];
    
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
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.5*oneDay) length:CPTDecimalFromDouble(oneDay * 8)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(4)];
    
    
    // Line plot with gradient fill
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth             = 1.0f;
    lineStyle.lineColor             = [CPTColor whiteColor];
    
    CPTScatterPlot *dataSourceLinePlot = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
    dataSourceLinePlot.identifier    = @"Data Source Plot";
    dataSourceLinePlot.title         = @"Close Values";
    
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource    = dataSource;
    [graph addPlot:dataSourceLinePlot];
    
}


-(void)testBarPlot{
    // 1 - Create the graph
    
    

    
    NSTimeInterval oneDay = 24 * 60 * 60;
    
    // If you make sure your dates are calculated at noon, you shouldn't have to
    // worry about daylight savings. If you use midnight, you will have to adjust
    // for daylight savings time.
    NSDate *refDate = [NSDate dateWithTimeIntervalSinceReferenceDate:oneDay / 2.0];
    
    
    if(graph2==nil){
        graph2 = [[CPTXYGraph alloc] initWithFrame:self.hostView2.bounds];
        [graph2 applyTheme:[CPTTheme themeNamed:kCPTPlainBlackTheme]];
        self.hostView2.hostedGraph = graph2;
        graph2.paddingLeft=0;
        graph2.paddingRight=0;
        graph2.paddingBottom=0;
        graph2.paddingTop=0;
        
        graph2.plotAreaFrame.masksToBorder = NO;
        graph2.plotAreaFrame.cornerRadius = 0.0f;
        [self.hostView2 setAllowPinchScaling:YES];
    }
    
    CPTGraph* graph = graph2;
    

    
    CPTMutableLineStyle *borderLineStyle = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor           = [CPTColor whiteColor];
    borderLineStyle.lineWidth           = 1.0f;
    graph.plotAreaFrame.borderLineStyle = nil;
    graph.plotAreaFrame.paddingTop      = 20.0f;
    graph.plotAreaFrame.paddingRight    = 20.0f;
    graph.plotAreaFrame.paddingBottom   = 30.0f;
    graph.plotAreaFrame.paddingLeft     = 30.0f;
    graph.plotAreaFrame.masksToBorder   = NO;
    
    // Axes
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0f;
    axisLineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
    tickLineStyle.lineColor = [CPTColor whiteColor];
    tickLineStyle.lineWidth = 1.0f;
    
    CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
    
    gridLineStyle.dashPattern = @[@0.5,@1];
    gridLineStyle.lineColor=[CPTColor grayColor];
    gridLineStyle.lineWidth = 1.0f;
    
    
    CPTXYAxisSet *xyAxisSet = (id)graph.axisSet;
    CPTXYAxis *xAxis        = xyAxisSet.xAxis;
    xAxis.majorIntervalLength   = CPTDecimalFromDouble(oneDay);

    xAxis.minorTicksPerInterval = 1;
    xAxis.axisLineStyle=axisLineStyle;
    xAxis.majorTickLineStyle=tickLineStyle;
    
    xAxis.majorGridLineStyle=gridLineStyle;
    xAxis.minorGridLineStyle=gridLineStyle;
    xAxis.minorTickLineStyle=tickLineStyle;
    
    xAxis.tickDirection = CPTSignPositive;
    xAxis.tickLabelDirection=CPTSignNegative;
    xAxis.majorTickLength=3.0f;
    xAxis.minorTickLength=1.0f;
    

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    xAxis.labelFormatter        = timeFormatter;
    
    
    //x 轴箭头
    if(0){
        CPTLineCap *lineCap = [[CPTLineCap alloc] init];
        lineCap.lineStyle    = xAxis.axisLineStyle;
        lineCap.lineCapType  = CPTLineCapTypeOpenArrow;
        lineCap.size         = CGSizeMake(12.0, 12.0);
        xAxis.axisLineCapMax = lineCap;
    }
    
    CPTXYAxis *yAxis = xyAxisSet.yAxis;
    yAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(-0.5*oneDay);
    yAxis.axisLineStyle=axisLineStyle;
    yAxis.majorTickLineStyle=tickLineStyle;
    yAxis.minorTickLineStyle=tickLineStyle;
    yAxis.majorGridLineStyle=gridLineStyle;
    yAxis.minorTicksPerInterval=1;
    yAxis.tickDirection = CPTSignPositive;
    yAxis.tickLabelDirection=CPTSignNegative;
    yAxis.majorTickLength=3.0f;
    yAxis.minorTickLength=1.0f;

    
    
    
    
    
    if(dataSource==nil)
        dataSource = [[TestDataSource alloc]initWithTestData];


    
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    //CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    //dataSourceLinePlot.areaFill      = areaGradientFill;
    //dataSourceLinePlot.areaBaseValue = CPTDecimalFromDouble(0.0);
    
    areaColor                         = [CPTColor colorWithComponentRed:0.0 green:1.0 blue:0.0 alpha:0.6];
    areaGradient                      = [CPTGradient gradientWithBeginningColor:[CPTColor clearColor] endingColor:areaColor];
    areaGradient.angle                = -90.0f;
    //areaGradientFill                  = [CPTFill fillWithGradient:areaGradient];
    //dataSourceLinePlot.areaFill2      = areaGradientFill;
    //dataSourceLinePlot.areaBaseValue2 = CPTDecimalFromDouble(5.0);
    
    // OHLC plot
    
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineColor = [CPTColor redColor];
    redLineStyle.lineWidth = 1.0;
    
    
    CPTMutableLineStyle *greenLineStyle = [CPTMutableLineStyle lineStyle];
    greenLineStyle.lineColor = [CPTColor greenColor];
    greenLineStyle.lineWidth = 1.0;
    
    
    
    CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle];
    whiteLineStyle.lineColor = [CPTColor whiteColor];
    whiteLineStyle.lineWidth = 2.0;
    CPTTradingRangePlot *ohlcPlot = [(CPTTradingRangePlot *)[CPTTradingRangePlot alloc] initWithFrame : graph.bounds];
    ohlcPlot.identifier = @"OHLC";
    ohlcPlot.lineStyle  = whiteLineStyle;
    CPTMutableTextStyle *whiteTextStyle = [CPTMutableTextStyle textStyle];
    whiteTextStyle.color    = [CPTColor whiteColor];
    whiteTextStyle.fontSize = 12.0;
    //标签
//    ohlcPlot.labelTextStyle = whiteTextStyle;
    ohlcPlot.labelTextStyle = nil;
    
    ohlcPlot.labelOffset    = 5.0;
    ohlcPlot.stickLength    = 10.0;
    ohlcPlot.dataSource     = dataSource;
    ohlcPlot.delegate       = self;
    ohlcPlot.plotStyle      = CPTTradingRangePlotStyleCandleStick;
    
    
    ohlcPlot.increaseLineStyle=redLineStyle;
    ohlcPlot.decreaseLineStyle=greenLineStyle;
//    [graph addPlot:ohlcPlot];
    
    // Add legend  图形说明
//    graph.legend                    = [CPTLegend legendWithGraph:graph];
//    graph.legend.textStyle          = xAxis.titleTextStyle;
//    graph.legend.fill               = graph.plotAreaFrame.fill;
//    graph.legend.borderLineStyle    = graph.plotAreaFrame.borderLineStyle;
//    graph.legend.cornerRadius       = 2.0;
//    graph.legend.swatchSize         = CGSizeMake(25.0, 25.0);
//    graph.legend.swatchCornerRadius = 2.0;
//    graph.legendAnchor              = CPTRectAnchorTopLeft;
//    graph.legendDisplacement        = CGPointMake(0.0, 12.0);
    
    // Set plot ranges
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(-0.5*oneDay) length:CPTDecimalFromDouble(oneDay * 8)];


    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(4)];
    
    
    // Line plot with gradient fill
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth             = 1.0f;
    lineStyle.lineColor             = [CPTColor whiteColor];
    
    CPTScatterPlot *dataSourceLinePlot = [(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame : graph.bounds];
    dataSourceLinePlot.identifier    = @"Data Source Plot";
    dataSourceLinePlot.title         = @"Close Values";
    
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource    = dataSource;
    [graph addPlot:dataSourceLinePlot];
    
    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor orangeColor];
    
    CPTBarPlot *barPlot = [(CPTBarPlot *)[CPTBarPlot alloc] initWithFrame : graph.bounds];
    
    barPlot.lineStyle         = barLineStyle;
//    barPlot.barWidth          = CPTDecimalFromFloat(0.75f); // bar is 75% of the available space

    //使用视图空间坐标
    barPlot.barWidthsAreInViewCoordinates=YES;
    barPlot.barWidth=CPTDecimalFromFloat(4.f);

    barPlot.barCornerRadius   = 2.0;
    barPlot.barsAreHorizontal = NO;


    barPlot.dataSource    = dataSource;
    barPlot.delegate=self;
    barPlot.barCornerRadius = 2.0f;



    [graph addPlot:barPlot];
    
    

    
    
}

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)idx
{
    NSLog(@"recored %d selected",idx);
    
}

@end
