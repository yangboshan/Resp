#import "CPTPlotAreaFrame.h"

#import "CPTAxisSet.h"
#import "CPTPlotArea.h"
#import "CPTPlotGroup.h"

/// @cond
@interface CPTPlotAreaFrame()

@property (nonatomic, readwrite, retain) CPTPlotArea *plotArea;

@end

/// @endcond

#pragma mark -

/**
 *  @brief A layer drawn on top of the graph layer and behind all plot elements.
 *
 *  All graph elements, except for titles, legends, and other annotations
 *  attached directly to the graph itself are clipped to the plot area frame.
 **/
@implementation CPTPlotAreaFrame

/** @property CPTPlotArea *plotArea
 *  @brief The plot area.
 **/
@synthesize plotArea;

/** @property CPTAxisSet *axisSet
 *  @brief The axis set.
 **/
@dynamic axisSet;

/** @property CPTPlotGroup *plotGroup
 *  @brief The plot group.
 **/
@dynamic plotGroup;

#pragma mark -
#pragma mark Init/Dealloc

/// @name Initialization
/// @{

/** @brief Initializes a newly allocated CPTPlotAreaFrame object with the provided frame rectangle.
 *
 *  This is the designated initializer. The initialized layer will have the following properties:
 *  - @ref plotArea = a new CPTPlotArea with the same frame rectangle
 *  - @ref masksToBorder = @YES
 *  - @ref needsDisplayOnBoundsChange = @YES
 *
 *  @param newFrame The frame rectangle.
 *  @return The initialized CPTPlotAreaFrame object.
 **/
-(id)initWithFrame:(CGRect)newFrame
{
    if ( (self = [super initWithFrame:newFrame]) ) {
        plotArea = nil;

        CPTPlotArea *newPlotArea = [(CPTPlotArea *)[CPTPlotArea alloc] initWithFrame : newFrame];
        self.plotArea = newPlotArea;
        [newPlotArea release];

        self.masksToBorder              = YES;
        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

/// @}

/// @cond

-(id)initWithLayer:(id)layer
{
    if ( (self = [super initWithLayer:layer]) ) {
        CPTPlotAreaFrame *theLayer = (CPTPlotAreaFrame *)layer;

        plotArea = [theLayer->plotArea retain];
    }
    return self;
}

-(void)dealloc
{
    [plotArea release];
    [super dealloc];
}

/// @endcond

#pragma mark -
#pragma mark NSCoding Methods

/// @cond

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.plotArea forKey:@"CPTPlotAreaFrame.plotArea"];
}

-(id)initWithCoder:(NSCoder *)coder
{
    if ( (self = [super initWithCoder:coder]) ) {
        plotArea = [[coder decodeObjectForKey:@"CPTPlotAreaFrame.plotArea"] retain];
    }
    return self;
}

/// @endcond

#pragma mark -
#pragma mark Accessors

/// @cond

-(void)setPlotArea:(CPTPlotArea *)newPlotArea
{
    if ( newPlotArea != plotArea ) {
        [plotArea removeFromSuperlayer];
        [plotArea release];
        plotArea = [newPlotArea retain];
        if ( plotArea ) {
            [self insertSublayer:plotArea atIndex:0];
            plotArea.graph = self.graph;
        }
        [self setNeedsLayout];
    }
}

-(CPTAxisSet *)axisSet
{
    return self.plotArea.axisSet;
}

-(void)setAxisSet:(CPTAxisSet *)newAxisSet
{
    self.plotArea.axisSet = newAxisSet;
}

-(CPTPlotGroup *)plotGroup
{
    return self.plotArea.plotGroup;
}

-(void)setPlotGroup:(CPTPlotGroup *)newPlotGroup
{
    self.plotArea.plotGroup = newPlotGroup;
}

-(void)setGraph:(CPTGraph *)newGraph
{
    if ( newGraph != self.graph ) {
        [super setGraph:newGraph];

        self.plotArea.graph = newGraph;
    }
}


-(void)setPaddingLeft:(CGFloat)newPadding
{
    self.plotArea.origXOffset=newPadding;
    
    [super setPaddingLeft:newPadding];

}



-(void)setPaddingBottom:(CGFloat)newPadding
{
    self.plotArea.origYOffset=newPadding;
    [super setPaddingBottom:newPadding];

}

/// @endcond

#pragma mark -
#pragma mark Responder Chain and User interaction

/// @name User Interaction
/// @{

-(BOOL)pointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    
    if ( [self.plotArea pointingDeviceDownEvent:event atPoint:interactionPoint] ) {
        return YES;
    }
    return NO;
}

-(BOOL)pointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    if ( [self.plotArea pointingDeviceUpEvent:event atPoint:interactionPoint] ) {
        return YES;
    }
    return NO;
}

-(BOOL)pointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)interactionPoint
{
    if ( [self.plotArea pointingDeviceDraggedEvent:event atPoint:interactionPoint] ) {
        return YES;
    }
    return NO;
}

-(BOOL)pointingDeviceCancelledEvent:(CPTNativeEvent *)event
{
    if ( [self.plotArea pointingDeviceCancelledEvent:event] ) {
        return YES;
    }
    return NO;
}

/// @}

@end
