//
//  TestDataSource.m
//  PieChart
//
//  Created by sureone on 1/28/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "TestDataSource.h"

@implementation TestDataSource{
    
}

static double values[22][11]={
    /*open,close,high,low,*/
    {2.5,3.0,3.2,2.1,500,400,1000,100,90,1000,0.9},
    {2.1,1.6,2.5,1.2,500,500,1100,200,92,1100,0.81},
    {2.5,3.2,2.7,2.1,500,600,1200,300,93,1200,0.92},
    {2.8,3.6,2.7,2.1,500,700,1300,400,94,1300,0.78},
    {3.4,2.6,2.7,2.1,500,800,1400,500,95,1400,0.95},
    {2.5,3.1,2.7,2.1,500,900,1600,600,96,1500,0.93},
    {2.5,1.6,2.7,2.1,500,1000,1700,700,97,1600,0.76},
    {2.5,3.0,3.2,2.1,500,1100,1800,800,98,1700,0.69},
    {2.1,1.6,2.5,1.2,500,1200,1900,900,99,1800,0.92},
    {2.5,3.2,2.7,2.1,500,1300,2000,1000,90,1900,0.99},
    {2.5,3.0,3.2,2.1,500,400,1000,100,90,1000,0.9},
    {2.1,1.6,2.5,1.2,500,500,1100,200,92,1100,0.81},
    {2.5,3.2,2.7,2.1,500,600,1200,300,93,1200,0.92},
    {2.8,3.6,2.7,2.1,500,700,1300,400,94,1300,0.78},
    {3.4,2.6,2.7,2.1,500,800,1400,500,95,1400,0.95},
    {2.5,3.1,2.7,2.1,500,900,1600,600,96,1500,0.93},
    {2.5,1.6,2.7,2.1,500,1000,1700,700,97,1600,0.76},
    {2.5,3.0,3.2,2.1,500,1100,1800,800,98,1700,0.69},
    {2.1,1.6,2.5,1.2,500,1200,1900,900,99,1800,0.92},
    {2.5,3.2,2.7,2.1,500,1300,2000,1000,90,1900,0.99},
    {2.1,1.6,2.5,1.2,500,1200,1900,900,99,1800,0.92},
    {2.5,3.2,2.7,2.1,500,1300,2000,1000,90,1900,0.99},

};

-(double*)detailPlotValueAtIndex:(int)index
{
    double* p = values[index];
    return p;
}

-(id)initWithTestData{
    
    self = [super init];
    
    // Add some data
    int oneDay = 24*60*60;

    if ( plotData==nil ) {
        NSMutableArray *newData = [NSMutableArray array];
        int i=0;
        while(i<22){
            
            NSTimeInterval x = oneDay * i*0.25;
            
            double rOpen,rClose;
            rOpen=values[i][0];
            rClose=values[i][1];
            double rHigh=values[i][2];
            double rLow=values[i][3];
            
            [newData addObject:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [NSDecimalNumber numberWithDouble:x], [NSNumber numberWithInt:CPTTradingRangePlotFieldX],
              [NSDecimalNumber numberWithDouble:rOpen], [NSNumber numberWithInt:CPTTradingRangePlotFieldOpen],
              [NSDecimalNumber numberWithDouble:rHigh], [NSNumber numberWithInt:CPTTradingRangePlotFieldHigh],
              [NSDecimalNumber numberWithDouble:rLow], [NSNumber numberWithInt:CPTTradingRangePlotFieldLow],
              [NSDecimalNumber numberWithDouble:rClose], [NSNumber numberWithInt:CPTTradingRangePlotFieldClose],
              nil]];

            
            i++;
            
        }
        
        
        plotData = newData;
    }
    
    return self;
}

#pragma mark - Bar Data source

-(CPTFill *)barFillForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    CPTColor *color = nil;
    
    switch ( index ) {
        case 0:
            color = [CPTColor redColor];
            break;
            
        case 1:
            color = [CPTColor greenColor];
            break;
            
        case 2:
            color = [CPTColor blueColor];
            break;
            
        case 3:
            color = [CPTColor yellowColor];
            break;
            
        case 4:
            color = [CPTColor purpleColor];
            break;
            
        case 5:
            color = [CPTColor cyanColor];
            break;
            
        case 6:
            color = [CPTColor orangeColor];
            break;
            
        case 7:
            color = [CPTColor magentaColor];
            break;
            
        default:
            color = [CPTColor orangeColor];
            break;
    }
    
    CPTGradient *fillGradient = [CPTGradient gradientWithBeginningColor:color endingColor:[CPTColor blackColor]];
    
    return [CPTFill fillWithGradient:fillGradient];
}

-(NSString *)legendTitleForBarPlot:(CPTBarPlot *)barPlot recordIndex:(NSUInteger)index
{
    return [NSString stringWithFormat:@"Bar %lu", (unsigned long)(index + 1)];
}


#pragma mark - CPTTradingRangePlotDataSource Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return plotData.count;
}


-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
    NSArray *nums = nil;
    
    int oneDay = 24*60*60;
    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
    switch ( fieldEnum ) {
        case CPTBarPlotFieldBarLocation:
            nums = [NSMutableArray arrayWithCapacity:indexRange.length];
            for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                [(NSMutableArray *)nums addObject :[NSDecimalNumber numberWithUnsignedInteger:i*oneDay]];
            }
            break;
            
        case CPTBarPlotFieldBarTip:
            
            nums = [NSMutableArray arrayWithCapacity:indexRange.length];
            for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
                NSDecimalNumber* num = [[plotData objectAtIndex:i] objectForKey:[NSNumber numberWithUnsignedInt:CPTTradingRangePlotFieldOpen]];
                
                [(NSMutableArray *)nums addObject :num];
            }
            
//            nums = [plotData objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:indexRange]];
            break;
            
        default:
            break;
    }
        
    
    }else{
        
        nums = [NSMutableArray arrayWithCapacity:indexRange.length];
        for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ ) {
            
            NSNumber *num = [[plotData objectAtIndex:i] objectForKey:[NSNumber numberWithUnsignedInteger:fieldEnum]];
            
            [(NSMutableArray *)nums addObject :num];
        }

        
        
    }
    
    return nums;
}


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSDecimalNumber *num = [NSDecimalNumber zero];
    NSDecimalNumber *num1 = [NSDecimalNumber zero];
    
    
    
    if ( [plot.identifier isEqual:@"Data Source Plot"] ) {
        switch ( fieldEnum ) {
            case CPTScatterPlotFieldX:
                num = [[plotData objectAtIndex:index] objectForKey:[NSNumber numberWithUnsignedInt:CPTTradingRangePlotFieldX]];
                break;
                
            case CPTScatterPlotFieldY:
            
                num = [[plotData objectAtIndex:index] objectForKey:[NSNumber numberWithUnsignedInt:CPTTradingRangePlotFieldOpen]];
                num1=[[plotData objectAtIndex:index] objectForKey:[NSNumber numberWithUnsignedInt:CPTTradingRangePlotFieldClose]];
                

                
                
                break;
                
            default:
                break;
        }
    }
    else {
        num = [[plotData objectAtIndex:index] objectForKey:[NSNumber numberWithUnsignedInteger:fieldEnum]];
    }
    return num;
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
