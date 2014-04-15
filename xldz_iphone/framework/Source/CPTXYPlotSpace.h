#import "CPTDefinitions.h"
#import "CPTPlotSpace.h"

@class CPTPlotRange;

@interface CPTXYPlotSpace : CPTPlotSpace {
    @private
    //定义坐标轴x的范围（数据空间)     
    CPTPlotRange *xRange;
    CPTPlotRange *yRange;
    CPTPlotRange *globalXRange;
    CPTPlotRange *globalYRange;
    CPTScaleType xScaleType;
    CPTScaleType yScaleType;
    CGPoint lastDragPoint;
    CGPoint lastDisplacement;
    NSTimeInterval lastDragTime;
    NSTimeInterval lastDeltaTime;
    BOOL isDragging;
    BOOL allowsMomentum;
    BOOL elasticGlobalXRange;
    BOOL elasticGlobalYRange;
    NSMutableArray *animations;
}

@property (nonatomic, readwrite, copy) CPTPlotRange *xRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *yRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *globalXRange;
@property (nonatomic, readwrite, copy) CPTPlotRange *globalYRange;
@property (nonatomic, readwrite, assign) CPTScaleType xScaleType;
@property (nonatomic, readwrite, assign) CPTScaleType yScaleType;
@property (nonatomic, readwrite, copy) CPTPlotRange *fixedXRange;
@property (nonatomic,readwrite, copy) CPTPlotRange *fixedYRange;

@property (nonatomic, readwrite) BOOL allowsMomentum;
@property (nonatomic, readwrite) BOOL elasticGlobalXRange;
@property (nonatomic, readwrite) BOOL elasticGlobalYRange;

@end
