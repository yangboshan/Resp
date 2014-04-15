#import "CPTAxisSet.h"

@class CPTXYAxis;

@interface CPTXYAxisSet : CPTAxisSet {
}

@property (nonatomic, readonly, retain) CPTXYAxis *xAxis;
@property (nonatomic, readonly, retain) CPTXYAxis *yAxis;

@property (nonatomic, readonly, retain) CPTXYAxis *xAxis2;
@property (nonatomic, readonly, retain) CPTXYAxis *yAxis2;
@end
