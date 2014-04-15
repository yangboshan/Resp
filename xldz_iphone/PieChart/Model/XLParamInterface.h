//
//  XLParamInterface.h
//  XLApp
//
//  Created by ttonway on 14-3-7.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"
#import "XLDeviceBasicParamPageBussiness.h"
#import "XLDeviceTransParamPageBussiness.h"
#import "XLPointBasicParamPageBussiness.h"
#import "XLPointTransParamPageBussiness.h"
#import "XLPointThresholdParamPageBussiness.h"
#import "XLDeviceEventParamPageBussiness.h"

typedef NS_ENUM(NSUInteger, XLParamType) {
    XLParamTypeString = 0,
    XLParamTypeNumber = 1,
    XLParamTypeSpinner = 2,
    XLParamTypeMulitValue = 3
};

@interface NSMutableDictionary (CommonParam)

@property (nonatomic) NSString *paramName;
@property (nonatomic) id paramValue;//XLParamTypeNumber 和 XLParamTypeString 都按字符串处理，在XLParamTypeSpinner时，paramValue可以为其他类型，但要与listValues中的内容匹配。
@property (nonatomic) XLParamType paramType;
@property (nonatomic) BOOL editable;

@property (nonatomic) NSArray *listValues;
@property (nonatomic) NSArray *listNames;

+ (id)paramWithName:(NSString *)name value:(id)value type:(XLParamType)type;

- (id)uneditable;

@end

@interface NSArray (paramsCopy)
- (NSArray *)paramsCopy;
@end


@interface XLViewDataDevice (Param)
- (void)queryBasicParams:(NSDictionary *)dic;
- (void)saveBasicParams:(NSArray *)params;

- (void)queryTransParams:(NSDictionary *)dic;
- (void)saveTransportParams:(NSDictionary *)params selectedType:(NSString *)typeName;

//查询一个设备下的直流模拟量
- (void)queryDCAnalogs:(NSDictionary *)dic;

- (void)queryEventParams:(NSDictionary *)dic;
- (void)saveEventParams:(NSArray *)params;

- (void)queryProtectionParams:(NSDictionary *)dic;
//- (NSArray *)queryProtectionParamsForLoop:(XLViewDataSwitchLoop *)loop;
- (void)saveProtectionParams:(NSArray *)params forLoop:(XLViewDataSwitchLoop *)loop;

- (void)queryLoopParams:(NSDictionary *)dic;
- (void)saveLoopParams:(NSArray *)params forLoop:(XLViewDataSwitchLoop *)loop;

- (void)querySystemParams:(NSDictionary *)dic;
- (void)saveSystemParams:(NSArray *)params;

- (void)queryTelemetryParams:(NSDictionary *)dic;
- (void)saveTelemetryParams:(NSArray *)params;

- (void)queryRemoteSignallingParams:(NSDictionary *)dic;
- (void)saveRemoteSignallingParams:(NSArray *)params;

- (void)queryRemoteControlParams:(NSDictionary *)dic;
- (void)saveRemoteControlParams:(NSArray *)params;

@end

@interface XLViewDataTestPoint (Param)

- (void)queryBasicParams:(NSDictionary *)dic;
- (void)saveBasicParams:(NSArray *)params;

- (void)queryTransParams:(NSDictionary *)dic;
- (void)saveTransParams:(NSArray *)params;

- (void)queryThresholdParams:(NSDictionary *)dic;
- (void)saveThresholdParams:(NSArray *)params;

@end


@interface XLParamInterface : NSObject

@end