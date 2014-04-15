//
//  XLSyncDeviceBussiness.h
//  XLApp
//
//  Created by JY on 14-3-28.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLSyncDeviceBussiness : NSObject

//同步数据，传递下来的参数
@property (nonatomic) NSDictionary *updateMsgDic;

//测量点集合
@property (nonatomic,strong) NSArray *terDAArray;

//曲线DT集合
@property (nonatomic,strong) NSArray *curveDTArray;

//二类数据日冻结DT集合
@property (nonatomic,strong) NSArray *afnDDayDTArray;

//二类数据月冻结DT集合
@property (nonatomic,strong) NSArray *afnDMonthDTArray;

//一类数据DT集合
@property (nonatomic,strong) NSArray *afnCDTArray;

//参数DT集合
@property (nonatomic,strong) NSArray* afnADTArray;

//三类数据请求集合
//@"F1" 10 11
@property (nonatomic,strong) NSArray* afnEDTArray;

//抄读完毕发送通知名称
@property (nonatomic,strong) NSString* subViewNotifyName;

//是否是临时抄表
@property (nonatomic,assign) BOOL isTempRead;


//+(XLSyncDeviceBussiness*)sharedXLSyncDeviceBussiness;

-(void)beginSync;
-(void)beginSyncWithStartDate:(NSDate*)start withEndDate:(NSDate*)end;

@end
