//
//  CPTMeasureLine.m
//  CorePlot-CocoaTouch
//
//  Created by sureone on 2/9/14.
//
//

#import "CPTMeasureLine.h"
#import "CPTMutableLineStyle.h"
#import "CPTColor.h"
#import "CPTPlotArea.h"


@implementation CPTMeasureLine

//http://stackoverflow.com/questions/10663746/redrawing-custom-calayer-subclass-on-custom-property-change
@synthesize relativeMeasurePoint;

@synthesize measurePoint;
@synthesize isRelativeMeasure;

// Plot space

/** @property CPTPlotSpace *plotSpace
 *  @brief The plot space for the axis.
 **/
@synthesize plotSpace;


/** @property CPTCoordinate coordinate
 *  @brief The axis coordinate.
 **/
@synthesize coordinate;

@synthesize plotArea;




-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        self.needsDisplayOnBoundsChange = YES;
        self.isRelativeMeasure=NO;
    }
    return self;
}

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
//        CPTMeasureLine *theLayer = (CPTMeasureLine *)layer;
        

    }
    return self;
}

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }
    
    
    
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    
    lineStyle.dashPattern = @[@4,@2];
    lineStyle.lineColor=[CPTColor yellowColor];
    lineStyle.lineWidth = 1.0f;
    
    
    if(isRelativeMeasure==YES  && relativeMeasurePoint.x!=-1){
        //绘制被测量线
        
        CGContextMoveToPoint(context, relativeMeasurePoint.x-self.plotArea.origXOffset, self.bounds.size.height);
        CGContextAddLineToPoint(context, relativeMeasurePoint.x-self.plotArea.origXOffset, self.bounds.origin.y);
        
        
        [lineStyle setLineStyleInContext:context];
        [lineStyle strokePathInContext:context];
        
    }else if(measurePoint.x!=-1){
    
//        NSLog(@"%f,%f",measurePoint.x,measurePoint.y);
        //绘制测量线
        CGContextMoveToPoint(context, self.bounds.origin.x, self.bounds.size.height-measurePoint.y+self.plotArea.origYOffset);
        CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height-measurePoint.y+self.plotArea.origYOffset);
        
        CGContextMoveToPoint(context, measurePoint.x-self.plotArea.origXOffset, self.bounds.size.height);
        CGContextAddLineToPoint(context, measurePoint.x-self.plotArea.origXOffset, self.bounds.origin.y-self.plotArea.origYOffset);

        
        [lineStyle setLineStyleInContext:context];
        [lineStyle strokePathInContext:context];
    }
    
    
    
#if (0)
    
    if ( lineStyle ) {
        [super renderAsVectorInContext:context];
        
        CPTPlotSpace *thePlotSpace           = self.plotSpace;
        NSSet *locations                     = (major ? self.majorTickLocations : self.minorTickLocations);
        CPTCoordinate selfCoordinate         = self.coordinate;
        CPTCoordinate orthogonalCoordinate   = CPTOrthogonalCoordinate(selfCoordinate);
        CPTMutablePlotRange *orthogonalRange = [[thePlotSpace plotRangeForCoordinate:orthogonalCoordinate] mutableCopy];
        CPTPlotRange *theGridLineRange       = self.gridLinesRange;
        CPTMutablePlotRange *labeledRange    = nil;
        
        switch ( self.labelingPolicy ) {
            case CPTAxisLabelingPolicyNone:
            case CPTAxisLabelingPolicyLocationsProvided:
            {
                labeledRange = [[self.plotSpace plotRangeForCoordinate:self.coordinate] mutableCopy];
                CPTPlotRange *theVisibleRange = self.visibleRange;
                if ( theVisibleRange ) {
                    [labeledRange intersectionPlotRange:theVisibleRange];
                }
            }
                break;
                
            default:
                break;
        }
        
        if ( theGridLineRange ) {
            [orthogonalRange intersectionPlotRange:theGridLineRange];
        }
        
        CPTPlotArea *thePlotArea = self.plotArea;
        NSDecimal startPlotPoint[2];
        NSDecimal endPlotPoint[2];
        startPlotPoint[orthogonalCoordinate] = orthogonalRange.location;
        endPlotPoint[orthogonalCoordinate]   = orthogonalRange.end;
        CGPoint originTransformed = [self convertPoint:self.bounds.origin fromLayer:thePlotArea];
        
        CGFloat lineWidth = lineStyle.lineWidth;
        
        CPTAlignPointFunction alignmentFunction = NULL;
        if ( ( self.contentsScale > CPTFloat(1.0) ) && (round(lineWidth) == lineWidth) ) {
            alignmentFunction = CPTAlignIntegralPointToUserSpace;
        }
        else {
            alignmentFunction = CPTAlignPointToUserSpace;
        }
        
        CGContextBeginPath(context);
        
        for ( NSDecimalNumber *location in locations ) {
            NSDecimal locationDecimal = location.decimalValue;
            
            if ( labeledRange && ![labeledRange contains:locationDecimal] ) {
                continue;
            }
            
            startPlotPoint[selfCoordinate] = locationDecimal;
            endPlotPoint[selfCoordinate]   = locationDecimal;
            
            // Start point
            CGPoint startViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:startPlotPoint numberOfCoordinates:2];
            startViewPoint.x += originTransformed.x;
            startViewPoint.y += originTransformed.y;
            
            // End point
            CGPoint endViewPoint = [thePlotSpace plotAreaViewPointForPlotPoint:endPlotPoint numberOfCoordinates:2];
            endViewPoint.x += originTransformed.x;
            endViewPoint.y += originTransformed.y;
            
            // Align to pixels
            startViewPoint = alignmentFunction(context, startViewPoint);
            endViewPoint   = alignmentFunction(context, endViewPoint);
            
            // Add grid line
            CGContextMoveToPoint(context, startViewPoint.x, startViewPoint.y);
            CGContextAddLineToPoint(context, endViewPoint.x, endViewPoint.y);
        }
        
        // Stroke grid lines
        [lineStyle setLineStyleInContext:context];
        [lineStyle strokePathInContext:context];
        
        [orthogonalRange release];
        [labeledRange release];
    }
    
#endif

    
}

/// @endcond


#pragma mark -
#pragma mark Responder Chain and User interaction

/// @name User Interaction
/// @{

-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    
//    self.isRelativeMeasure=NO;
//    self.measurePoint=interactionPoint;

//    [self setNeedsDisplay];
    return YES;
}

-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
//    self.measurePoint=interactionPoint;
//        [self setNeedsDisplay];
    return YES;
}

-(BOOL)pointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
//    self.measurePoint=interactionPoint;
//        [self setNeedsDisplay];
    return YES;
}

-(BOOL)pointingDeviceCancelledEvent:(CPTNativeEvent *)event
{
    return NO;
}

/// @}

@end
