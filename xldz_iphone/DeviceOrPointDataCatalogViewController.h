//
//  DeviceOrPointDataCatalogViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-26.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "APLSectionHeaderView.h"
#import "APLSectionInfo.h"
#import "XLModelDataInterface.h"
#import "CustomTableViewController.h"
#import "DataCatalogViewController.h"

@interface CatalogBean : NSObject
@property (nonatomic) NSString *catalog;
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *value;
@property (nonatomic) XLViewPlotType plotType;
@property (nonatomic) int idxDefine;

@property (nonatomic) BOOL hasMoreAction;
@property (nonatomic) BOOL hasValue;
@property (nonatomic) BOOL hasIndent;


@end

@interface CatalogCell : UITableViewCell

@property (nonatomic) CatalogBean *catalog;

@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *valueLabel;

@end



@interface DeviceOrPointDataCatalogViewController : CustomTableViewController <SectionHeaderViewDelegate>

@property (nonatomic, readonly) id deviceOrPoint;
@property (nonatomic) BOOL realtime;
@property (nonatomic) NSDate *refreshDate;

- (id)initWithDeviceOrPoint:(id)deviceOrPoint;

- (void)queryDataForDate:(NSDate *)date;

@end
