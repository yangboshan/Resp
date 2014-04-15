#import "CPTXYAxisSet.h"

#import "CPTLineStyle.h"
#import "CPTPathExtensions.h"
#import "CPTUtilities.h"
#import "CPTXYAxis.h"

/**
 *  @brief A set of cartesian (X-Y) axes.
 **/
@implementation CPTXYAxisSet

/** @property CPTXYAxis *xAxis
 *  @brief The x-axis.
 **/
@dynamic xAxis;

/** @property CPTXYAxis *yAxis
 *  @brief The y-axis.
 **/
@dynamic yAxis;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTXYAxisSet object with the provided frame rectangle.
 *
 *  This is the designated initializer. The @ref axes array
 *  will contain two new axes with the following properties:
 *
 *  <table>
 *  <tr><td>@bold{Axis}</td><td>@link CPTAxis::coordinate coordinate @endlink</td><td>@link CPTAxis::tickDirection tickDirection @endlink</td></tr>
 *  <tr><td>@ref xAxis</td><td>#CPTCoordinateX</td><td>#CPTSignNegative</td></tr>
 *  <tr><td>@ref yAxis</td><td>#CPTCoordinateY</td><td>#CPTSignNegative</td></tr>
 *  </table>
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTXYAxisSet object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        CPTXYAxis *xAxis = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame : newFrame];
        xAxis.coordinate    = CPTCoordinateX;
        xAxis.tickDirection = CPTSignNegative;

        CPTXYAxis *yAxis = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame : newFrame];
        yAxis.coordinate    = CPTCoordinateY;
        yAxis.tickDirection = CPTSignNegative;
        
        
        CPTXYAxis *xAxis2 = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame : newFrame];
        xAxis.coordinate    = CPTCoordinateX;
        xAxis.tickDirection = CPTSignNegative;
        
        CPTXYAxis *yAxis2 = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame : newFrame];
        yAxis.coordinate    = CPTCoordinateY;
        yAxis.tickDirection = CPTSignNegative;
        
//        
//        CPTXYAxis *xAxisTop = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame : newFrame];
//        xAxisTop.coordinate    = CPTCoordinateX;
//        xAxisTop.tickDirection = CPTSignNegative;
//        
//        CPTXYAxis *yAxisRight = [(CPTXYAxis *)[CPTXYAxis alloc] initWithFrame : newFrame];
//        yAxisRight.coordinate    = CPTCoordinateY;
//        yAxisRight.tickDirection = CPTSignNegative;
        

        self.axes = [NSArray arrayWithObjects:xAxis, yAxis,xAxis2,yAxis2, nil];
        
        [xAxis release];
        [yAxis release];
        
    }
    return self;
}

/// @}

#pragma mark -
#pragma mark Drawing

/// @cond

-(void)renderAsVectorInContext:(CGContextRef)context
{
    if ( self.hidden ) {
        return;
    }

    CPTLineStyle *theLineStyle = self.borderLineStyle;
    if ( theLineStyle ) {
        [super renderAsVectorInContext:context];

        CALayer *superlayer = self.superlayer;
        CGRect borderRect   = CPTAlignRectToUserSpace(context, [self convertRect:superlayer.bounds fromLayer:superlayer]);

        [theLineStyle setLineStyleInContext:context];

        CGFloat radius = superlayer.cornerRadius;

        if ( radius > CPTFloat(0.0) ) {
            CGContextBeginPath(context);
            AddRoundedRectPath(context, borderRect, radius);

            [theLineStyle strokePathInContext:context];
        }
        else {
            [theLineStyle strokeRect:borderRect inContext:context];
        }
    }
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(CPTXYAxis *)xAxis
{
    return (CPTXYAxis *)[self axisForCoordinate:CPTCoordinateX atIndex:0];
}

-(CPTXYAxis *)yAxis
{
    return (CPTXYAxis *)[self axisForCoordinate:CPTCoordinateY atIndex:0];
}


-(CPTXYAxis *)xAxis2
{
    return (CPTXYAxis *)[self axisForCoordinate:CPTCoordinateX atIndex:1];
}

-(CPTXYAxis *)yAxis2
{
    return (CPTXYAxis *)[self axisForCoordinate:CPTCoordinateY atIndex:1];
}



/// @endcond

@end