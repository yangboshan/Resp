//
//  HistoryData_MeasurePoint_Sta.h
//  XLApp
//
//  Created by JY on 14-4-10.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface HistoryData_MeasurePoint_Sta : NSManagedObject

@property (nonatomic, retain) NSNumber * epId;
@property (nonatomic, retain) NSNumber * hdACurMax;
@property (nonatomic, retain) NSString * hdACurMaxTm;
@property (nonatomic, retain) NSNumber * hdACurOverHAccTm;
@property (nonatomic, retain) NSNumber * hdACurOverHHAccTm;
@property (nonatomic, retain) NSNumber * hdAPMaxA;
@property (nonatomic, retain) NSString * hdAPMaxATm;
@property (nonatomic, retain) NSNumber * hdAPMaxB;
@property (nonatomic, retain) NSString * hdAPMaxBTm;
@property (nonatomic, retain) NSNumber * hdAPMaxC;
@property (nonatomic, retain) NSString * hdAPMaxCTm;
@property (nonatomic, retain) NSNumber * hdAPMaxZ;
@property (nonatomic, retain) NSString * hdAPMaxZTm;
@property (nonatomic, retain) NSNumber * hdAPOverHAccTm;
@property (nonatomic, retain) NSNumber * hdAPOverHHAccTm;
@property (nonatomic, retain) NSNumber * hdAPZeroAccTmA;
@property (nonatomic, retain) NSNumber * hdAPZeroAccTmB;
@property (nonatomic, retain) NSNumber * hdAPZeroAccTmC;
@property (nonatomic, retain) NSNumber * hdAPZeroAccTmZ;
@property (nonatomic, retain) NSNumber * hdAVoltAvg;
@property (nonatomic, retain) NSNumber * hdAVoltDownLAccTm;
@property (nonatomic, retain) NSNumber * hdAVoltDownLLAccTm;
@property (nonatomic, retain) NSNumber * hdAVoltDownLRate;
@property (nonatomic, retain) NSNumber * hdAVoltMax;
@property (nonatomic, retain) NSString * hdAVoltMaxTm;
@property (nonatomic, retain) NSNumber * hdAVoltMin;
@property (nonatomic, retain) NSString * hdAVoltMinTm;
@property (nonatomic, retain) NSNumber * hdAVoltOverHAccTm;
@property (nonatomic, retain) NSNumber * hdAVoltOverHHAccTm;
@property (nonatomic, retain) NSNumber * hdAVoltOverHRate;
@property (nonatomic, retain) NSNumber * hdAVoltRegularAccTm;
@property (nonatomic, retain) NSNumber * hdAVoltRegularRate;
@property (nonatomic, retain) NSNumber * hdBCurMax;
@property (nonatomic, retain) NSString * hdBCurMaxTm;
@property (nonatomic, retain) NSNumber * hdBCurOverHAccTm;
@property (nonatomic, retain) NSNumber * hdBCurOverHHAccTm;
@property (nonatomic, retain) NSNumber * hdBVoltAvg;
@property (nonatomic, retain) NSNumber * hdBVoltDownLAccTm;
@property (nonatomic, retain) NSNumber * hdBVoltDownLLAccTm;
@property (nonatomic, retain) NSNumber * hdBVoltDownLRate;
@property (nonatomic, retain) NSNumber * hdBVoltMax;
@property (nonatomic, retain) NSString * hdBVoltMaxTm;
@property (nonatomic, retain) NSNumber * hdBVoltMin;
@property (nonatomic, retain) NSString * hdBVoltMinTm;
@property (nonatomic, retain) NSNumber * hdBVoltOverHAccTm;
@property (nonatomic, retain) NSNumber * hdBVoltOverHHAccTm;
@property (nonatomic, retain) NSNumber * hdBVoltOverHRate;
@property (nonatomic, retain) NSNumber * hdBVoltRegularAccTm;
@property (nonatomic, retain) NSNumber * hdBVoltRegularRate;
@property (nonatomic, retain) NSNumber * hdCCurMax;
@property (nonatomic, retain) NSString * hdCCurMaxTm;
@property (nonatomic, retain) NSNumber * hdCCurOverHAccTm;
@property (nonatomic, retain) NSNumber * hdCCurOverHHAccTm;
@property (nonatomic, retain) NSNumber * hdCurUnbalMax;
@property (nonatomic, retain) NSString * hdCurUnbalMaxTm;
@property (nonatomic, retain) NSNumber * hdCurUnbalOLmtAccTm;
@property (nonatomic, retain) NSNumber * hdCVoltAvg;
@property (nonatomic, retain) NSNumber * hdCVoltDownLAccTm;
@property (nonatomic, retain) NSNumber * hdCVoltDownLLAccTm;
@property (nonatomic, retain) NSNumber * hdCVoltDownLRate;
@property (nonatomic, retain) NSNumber * hdCVoltMax;
@property (nonatomic, retain) NSString * hdCVoltMaxTm;
@property (nonatomic, retain) NSNumber * hdCVoltMin;
@property (nonatomic, retain) NSString * hdCVoltMinTm;
@property (nonatomic, retain) NSNumber * hdCVoltOverHAccTm;
@property (nonatomic, retain) NSNumber * hdCVoltOverHHAccTm;
@property (nonatomic, retain) NSNumber * hdCVoltOverHRate;
@property (nonatomic, retain) NSNumber * hdCVoltRegularAccTm;
@property (nonatomic, retain) NSNumber * hdCVoltRegularRate;
@property (nonatomic, retain) NSString * hdDataTime;
@property (nonatomic, retain) NSNumber * hdDataType;
@property (nonatomic, retain) NSNumber * hdF25Filled;
@property (nonatomic, retain) NSNumber * hdF27Filled;
@property (nonatomic, retain) NSNumber * hdF28Filled;
@property (nonatomic, retain) NSNumber * hdF35Filled;
@property (nonatomic, retain) NSNumber * hdF36Filled;
@property (nonatomic, retain) NSNumber * hdF43Filled;
@property (nonatomic, retain) NSNumber * hdF44Filled;
@property (nonatomic, retain) NSNumber * hdMeasureNo;
@property (nonatomic, retain) NSNumber * hdPfSector1AccTm;
@property (nonatomic, retain) NSNumber * hdPfSector2AccTm;
@property (nonatomic, retain) NSNumber * hdPfSector3AccTm;
@property (nonatomic, retain) NSString * hdUpdateTime;
@property (nonatomic, retain) NSNumber * hdVoltUnbalMax;
@property (nonatomic, retain) NSString * hdVoltUnbalMaxTm;
@property (nonatomic, retain) NSNumber * hdVoltUnbalOLmtAccTm;
@property (nonatomic, retain) NSNumber * hdZeroCurMax;
@property (nonatomic, retain) NSString * hdZeroCurMaxTm;
@property (nonatomic, retain) NSNumber * hdZeroCurOverHHAccTm;
@property (nonatomic, retain) NSNumber * hdF33Filled;

@end
