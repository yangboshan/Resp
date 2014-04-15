//
//  CPTMeasureLine.h
//  CorePlot-CocoaTouch
//
//  Created by sureone on 2/9/14.
//
//

#import "CPTLayer.h"

@class CPTPlotArea;
@class CPTPlotSpace;


@interface CPTMeasureLine : CPTLayer{
    CGPoint measurePoint;
    BOOL isRelativeMeasure;
    CGPoint relativeMeasurePoint;
    CPTCoordinate coordinate;
    CPTPlotSpace *plotSpace;
    CPTPlotArea *plotArea;
    
    
}

@property (nonatomic, readwrite, assign) CPTCoordinate coordinate;

/// @name Plot Space
/// @{
@property (nonatomic, readwrite, retain) CPTPlotSpace *plotSpace;
@property (nonatomic, readwrite, retain) CPTPlotArea *plotArea;
/// @}


@property (nonatomic, readwrite, assign) CGPoint relativeMeasurePoint;
@property (nonatomic, readwrite, assign) CGPoint measurePoint;
@property (nonatomic, readwrite, assign) BOOL isRelativeMeasure;


@end
