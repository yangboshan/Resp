#import "CPTDefinitions.h"

@class CPTGraph;

@interface CPTGraphHostingView : UIView {
    @private
    CPTGraph *hostedGraph;
    BOOL collapsesLayers;
    BOOL allowPinchScaling;
    __cpt_weak UIPinchGestureRecognizer *pinchGestureRecognizer;
}

-(void) commonProcessScaleAtPoint:(CGPoint)interactionPoint withScale:(CGFloat)scale;
    
@property (nonatomic, readwrite, retain) CPTGraph *hostedGraph;
@property (nonatomic, readwrite, assign) BOOL collapsesLayers;
@property (nonatomic, readwrite, assign) BOOL allowPinchScaling;

@end
