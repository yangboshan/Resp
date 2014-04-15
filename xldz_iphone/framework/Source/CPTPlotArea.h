#import "CPTAnnotationHostLayer.h"
#import "CPTGraph.h"
#import "CPTLayer.h"

@class CPTAxis;
@class CPTAxisLabelGroup;
@class CPTAxisSet;
@class CPTGridLineGroup;
@class CPTPlotGroup;
@class CPTLineStyle;
@class CPTFill;
@class CPTMeasureLine;

@interface CPTPlotArea : CPTAnnotationHostLayer {
    @private
    CPTGridLineGroup *minorGridLineGroup;
    CPTGridLineGroup *majorGridLineGroup;
    CPTAxisSet *axisSet;
    CPTPlotGroup *plotGroup;
    CPTAxisLabelGroup *axisLabelGroup;
    CPTAxisLabelGroup *axisTitleGroup;
    CPTMeasureLine* yMeasureLine;
    

    CGFloat origXOffset,OrigYOffset;
    
    CPTFill *fill;
    NSArray *topDownLayerOrder;
    CPTGraphLayerType *bottomUpLayerOrder;
    BOOL updatingLayers;
}

/// @name Layers
/// @{
@property (nonatomic, readwrite, retain) CPTGridLineGroup *minorGridLineGroup;
@property (nonatomic, readwrite, retain) CPTGridLineGroup *majorGridLineGroup;
@property (nonatomic, readwrite, retain) CPTAxisSet *axisSet;
@property (nonatomic, readwrite, retain) CPTPlotGroup *plotGroup;
@property (nonatomic, readwrite, retain) CPTAxisLabelGroup *axisLabelGroup;
@property (nonatomic, readwrite, retain) CPTAxisLabelGroup *axisTitleGroup;
@property (nonatomic, readwrite, retain) CPTMeasureLine *yMeasureLine;
@property (nonatomic, readwrite, assign) CGFloat origXOffset;
@property (nonatomic, readwrite, assign) CGFloat origYOffset;

/// @}

/// @name Layer Ordering
/// @{
@property (nonatomic, readwrite, retain) NSArray *topDownLayerOrder;
/// @}

/// @name Decorations
/// @{
@property (nonatomic, readwrite, copy) CPTLineStyle *borderLineStyle;
@property (nonatomic, readwrite, copy) CPTFill *fill;
/// @}

/// @name Axis Set Layer Management
/// @{
-(void)updateAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(void)setAxisSetLayersForType:(CPTGraphLayerType)layerType;
-(unsigned)sublayerIndexForAxis:(CPTAxis *)axis layerType:(CPTGraphLayerType)layerType;
/// @}

-(void)showMeasureLines;
-(void)showRelativeMeasureLinesAtPoint:(CGPoint)point;
-(void)showMeasureLinesAtPoint:(CGPoint)point;
-(void)hideMeasureLines;
@end
