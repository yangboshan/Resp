//
//  XLModelDataInterface.m
//  XLApp
//
//  Created by sureone on 2/18/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "XLModelDataInterface.h"
#import "XLMainPageBussiness.h"
#import "XLSystemBussiness.h"
#import "XLRealTimeCatalogDataPageBussiness.h"
#import "XLEconomicDetailPageBussiness.h"
#import "XLEnergyDetailPageBussiness.h"
#import "XLDeviceEventPageBussiness.h"
#import "XLHistoryDataPageBussiness.h"


static XL_VIEW_DATA_TYPE common_data_history_define[]={
    
    {"电能量类数据","正有总/各费率电能示值",ONE_DATA, NULL, {0}},
    {"电能量类数据","正无总/各费率电能示值",ONE_DATA, NULL, {0}},
    {"电能量类数据","反有总/各费率电能示值",ONE_DATA, NULL, {0}},
    {"电能量类数据","反无总/各费率电能示值",ONE_DATA, NULL, {0}},
    {"电能量类数据","一象限无功电能示值", ONE_DATA, NULL, {0}},
    {"电能量类数据","二象限无功电能示值", ONE_DATA, NULL, {0}},
    {"电能量类数据","三象限无功电能示值", ONE_DATA, NULL, {0}},
    {"电能量类数据","四象限无功电能示值", ONE_DATA, NULL, {0}},
    {"电能量类数据","铜损有功总电能示值", ONE_DATA, NULL, {"value",0}},
    {"电能量类数据","铁损有功总电能示值", ONE_DATA, NULL, {"value",0}},
    
    {"电能量类数据","正向有功电能量",B_PLOT, "1,D,W,M,Y", {"v1",0}},
    {"电能量类数据","正向无功电能量",B_PLOT, "1,D,W,M,Y", {"v1",0}},
    {"电能量类数据","反向有功电能量",B_PLOT, "1,D,W,M,Y", {"v1",0}},
    {"电能量类数据","反向无功电能量",B_PLOT, "1,D,W,M,Y", {"v1",0}},
    
    
    {"需量类数据",
        "正向有功总/费率1234最大需量及发生时间",
        S_PLOT,
        "5[总费率,费率一,费率二,费率三,费率四,总最大发生时间,一最大发生时间,二最大发生时间,三最大发生时间,四最大发生时间],W,M,Y",
        {"v1","v2","v3","v4","v5","_time1","_time2","_time3","_time4","_time5",0}},
    {"需量类数据","正向有功总/ABC相最大需量及发生时间",S_PLOT,
        "4[总,A,B,C,总最大发生时间,A最大发生时间,B最大发生时间,C最大发生时间],W,M,Y",
        {"v1","v2","v3","v4","_time1","_time2","_time3","_time4",0}},
    {"需量类数据","正向无功总/费率1234最大需量及发生时间",S_PLOT, "5[总费率,费率一,费率二,费率三,费率四,总最大发生时间,一最大发生时间,二最大发生时间,三最大发生时间,四最大发生时间],W,M,Y",
        {"v1","v2","v3","v4","v5","_time1","_time2","_time3","_time4","_time5",0}},
    {"需量类数据","正向反功总/ABC相最大需量及发生时间",S_PLOT, "4[总,A,B,C,总最大发生时间,A最大发生时间,B最大发生时间,C最大发生时间],W,M,Y",
        {"v1","v2","v3","v4","_time1","_time2","_time3","_time4",0}},
    {"需量类数据","反向有功总/费率1234最大需量及发生时间",S_PLOT, "5[总费率,费率一,费率二,费率三,费率四,总最大发生时间,一最大发生时间,二最大发生时间,三最大发生时间,四最大发生时间],W,M,Y",
        {"v1","v2","v3","v4","v5","_time1","_time2","_time3","_time4","_time5",0}},
    {"需量类数据","反向有功总/ABC相最大需量及发生时间",S_PLOT, "4[总,A,B,C,总最大发生时间,A最大发生时间,B最大发生时间,C最大发生时间],W,M,Y",
        {"v1","v2","v3","v4","_time1","_time2","_time3","_time4",0}},
    {"需量类数据","反向无功总/费率1234最大需量及发生时间",S_PLOT, "5[总费率,费率一,费率二,费率三,费率四,总最大发生时间,一最大发生时间,二最大发生时间,三最大发生时间,四最大发生时间],W,M,Y",
        {"v1","v2","v3","v4","v5","_time1","_time2","_time3","_time4","_time5",0}},
    {"需量类数据","反向无功总/ABC相最大需量及发生时间",S_PLOT, "4[总,A,B,C,总最大发生时间,A最大发生时间,B最大发生时间,C最大发生时间],W,M,Y",
        {"v1","v2","v3","v4","_time1","_time2","_time3","_time4",0}},
    
    {"电压电流类数据","ABC三相电压(V)",S_PLOT, "3[A,B,C],1,5,15,30,60,D,W,M", {"a","b","c",0}},
    {"电压电流类数据","ABC三相电流(A)",S_PLOT, "3[A,B,C],1,5,15,30,60,D,W,M", {"a","b","c",0}},
    {"电压电流类数据","零序电流",S_PLOT, "1,1,5,15,30,60,D,W,M", {"value",0}},
    {"电压电流类数据","ABC电压相位角(°)",S_PLOT, "3[A,B,C],1,5,15,30,60,D,W,M", {"a","b","c",0}},
    {"电压电流类数据","ABC电流相位角(°)",S_PLOT, "3[A,B,C],1,5,15,30,60,D,W,M", {"a","b","c",0}},
    //{"电压电流类数据","A、B、C三相电压、电流2～N次谐波有效值",S_PLOT_60_D_W_M, NULL, {"a","b","c",0}},
    //{"电压电流类数据","A、B、C三相电压、电流2～N次谐波含有率",S_PLOT_60_D_W_M, NULL, {"a","b","c",0}},
    {"电压电流类数据","A/B/C相2～19次谐波电流最大值及发生时间", LIST_DATA, NULL, {"a","b","c",0}},
    {"电压电流类数据","A/B/C相2～19次谐波电压含有率及总畸变率最大值及发生时间", LIST_DATA, NULL, {"a","b","c",0}},
    {"电压电流类数据","电压统计数据",K_PLOT, "1,D,W,M", {"a","b","c",0}},
    {"电压电流类数据","电流越限统计",K_PLOT, "1,D,W,M", {"a","b","c",0}},
    {"电压电流类数据","不平衡度越限累计时间",K_PLOT, "1,D,W,M", {"a","b","c",0}},
    //{"电压电流类数据","电流不平衡度极值及其发生时间",K_PLOT_D_W_M, NULL, {"a","b","c",0}},
    
    {"功率类数据","总及三相有功功率",S_PLOT, "4[总,A,B,C],1,5,15,30,60,D,W,M", {"v1","v2","v3","v4",0}},
    {"功率类数据","总及三相无功功率",S_PLOT, "4[总,A,B,C],1,5,15,30,60,D,W,M", {"v1","v2","v3","v4",0}},
    {"功率类数据","总及三相视在功率",S_PLOT, "4[总,A,B,C],1,5,15,30,60,D,W,M", {"v1","v2","v3","v4",0}},
    {"功率类数据","总及三相功率因数",S_PLOT, "4[总,A,B,C],1,5,15,30,60,D,W,M", {"v1","v2","v3","v4",0}},
    {"功率类数据","总及分相有功功率极值及发生时间",K_PLOT, "4[总,A,B,C],D,W,M", {"t","a","b","c",0}},
    {"功率类数据","总及分相无功功率极值及发生时间",K_PLOT, "4[总,A,B,C],D,W,M", {"t","a","b","c",0}},
    {"功率类数据","视在功率越限累计时间",S_PLOT, "1,D,W,M", {"t","a","b","c",0}},
    {"功率类数据","功率因数区段累计时间",S_PLOT, "1,D,W,M", {"t","a","b","c",0}},
    
    
    {"变压器特有数据","油温(℃)",S_PLOT, "1,1,5,15,30,60,D", {"v1",0}},
    //{"变压器特有数据","油温(℃)极值及其发生时间",K_PLOT_D_W_M, NULL, {"open","close","high","low",0}},
    {"变压器特有数据","ABC相绕组温度(℃)",K_PLOT, "1,1,5,15,30,60,D,W,M", {"open","close","high","low",0}},
    //{"变压器特有数据","三相绕组温度(℃)极值及其发生时间",LIST_DATA, NULL, 0},
    {"变压器特有数据","油压",S_PLOT, "1,1,5,15,30,60,D", {"v1",0}},
    //{"变压器特有数据","油压极值及其发生时间",K_PLOT_D_W_M, NULL, {"open","close","high","low",0}},
    {"变压器特有数据","油位",S_PLOT, "1,1,5,15,30,60,D", {"v1",0}},
    //{"变压器特有数据","油位极值及其发生时间",K_PLOT_D_W_M, NULL, {"open","close","high","low",0}},
    //{"变压器特有数据","实时寿命",ONE_DATA, "lifetime", 0},
    
    //{"其他数据","终端日历时钟",ONE_DATA, "terminalCalendar", {0}},
    //{"其他数据","终端参数状态",ONE_DATA, "terminalStatusParam", {0}},
    //{"其他数据","终端事件计数器当前值",ONE_DATA, "terminalEventCounter", {0}},
    //{"其他数据","终端状态量变位标识",ONE_DATA, "terminalStatusFlag", {0}},
    {"其他数据","终端与主站当日通信流量",S_PLOT, "1,D,M", {"v1",0}},
    {"其他数据","终端与主站当月通信流量",S_PLOT, "1,D,M", {"v1",0}},
    {"其他数据","终端供电时间",B_PLOT, "1,D,M", {"v1",0}},
    {"其他数据","复位累计次数",B_PLOT, "1,D,M", {"v1",0}},
    
    {0,0,PLOT_NONE,NULL,0},
};


static XL_VIEW_DATA_TYPE common_data_realtime_define[]={
    
    {"电能量类数据","正有总电能示值",ONE_DATA, "zyfl", {0}},
    {"电能量类数据","正有费率1电能示值",ONE_DATA, "zyfl1", {0}},
    {"电能量类数据","正有费率2电能示值",ONE_DATA, "zyfl2", {0}},
    {"电能量类数据","正有费率3电能示值",ONE_DATA, "zyfl3", {0}},
    {"电能量类数据","正有费率4电能示值",ONE_DATA, "zyfl4", {0}},
    
    {"电能量类数据","正无总电能示值",ONE_DATA, "zwfl", {0}},
    {"电能量类数据","正无费率1电能示值",ONE_DATA, "zwfl1", {0}},
    {"电能量类数据","正无费率2电能示值",ONE_DATA, "zwfl2", {0}},
    {"电能量类数据","正无费率3电能示值",ONE_DATA, "zwfl3", {0}},
    {"电能量类数据","正无费率4电能示值",ONE_DATA, "zwfl4", {0}},
    
    {"电能量类数据","反有总电能示值",ONE_DATA, "fyfl", {0}},
    {"电能量类数据","反有费率1电能示值",ONE_DATA, "fyfl1", {0}},
    {"电能量类数据","反有费率2电能示值",ONE_DATA, "fyfl2", {0}},
    {"电能量类数据","反有费率3电能示值",ONE_DATA, "fyfl3", {0}},
    {"电能量类数据","反有费率4电能示值",ONE_DATA, "fyfl4", {0}},
    
    {"电能量类数据","反无总电能示值",ONE_DATA, "fwfl", {0}},
    {"电能量类数据","反无费率1电能示值",ONE_DATA, "fwfl1", {0}},
    {"电能量类数据","反无费率2电能示值",ONE_DATA, "fwfl2", {0}},
    {"电能量类数据","反无费率3电能示值",ONE_DATA, "fwfl3", {0}},
    {"电能量类数据","反无费率4电能示值",ONE_DATA, "fwfl4", {0}},
    
    {"电能量类数据","第一象限无功总电能示值", ONE_DATA, NULL, {0}},
    {"电能量类数据","第二象限无功总电能示值", ONE_DATA, NULL, {0}},
    {"电能量类数据","第三象限无功总电能示值", ONE_DATA, NULL, {0}},
    {"电能量类数据","第四象限无功总电能示值", ONE_DATA, NULL, {0}},
    {"电能量类数据","正向有功电能量",ONE_DATA, NULL, {"value",0}},
    {"电能量类数据","正向无功电能量",ONE_DATA, NULL, {"value",0}},
    {"电能量类数据","反向有功电能量",ONE_DATA, NULL, {"value",0}},
    {"电能量类数据","反向无功电能量",ONE_DATA, NULL, {"value",0}},
    {"电能量类数据","铜损有功总电能示值",ONE_DATA, NULL, {"value",0}},
    {"电能量类数据","铁损有功总电能示值",ONE_DATA, NULL, {"value",0}},
    
    {"需量类数据","当月正向有功总最大需量及发生时间",ONE_DATA, "zyflxl", {"value",0}},
    {"需量类数据","当月正向有功费率1最大需量及发生时间",ONE_DATA, "zyflxl1", {"value",0}},
    {"需量类数据","当月正向有功费率2最大需量及发生时间",ONE_DATA, "zyflxl2", {"value",0}},
    {"需量类数据","当月正向有功费率3最大需量及发生时间",ONE_DATA, "zyflxl3", {"value",0}},
    {"需量类数据","当月正向有功费率4最大需量及发生时间",ONE_DATA, "zyflxl4", {"value",0}},
    
    {"需量类数据","当月正向无功总最大需量及发生时间",ONE_DATA, "zwflxl", {"value",0}},
    {"需量类数据","当月正向无功费率1最大需量及发生时间",ONE_DATA, "zwflxl1", {"value",0}},
    {"需量类数据","当月正向无功费率2最大需量及发生时间",ONE_DATA, "zwflxl2", {"value",0}},
    {"需量类数据","当月正向无功费率3最大需量及发生时间",ONE_DATA, "zwflxl3", {"value",0}},
    {"需量类数据","当月正向无功费率4最大需量及发生时间",ONE_DATA, "zwflxl4", {"value",0}},
    
    {"需量类数据","当月反向有功总最大需量及发生时间",ONE_DATA, "fyflxl", {"value",0}},
    {"需量类数据","当月反向有功费率1最大需量及发生时间",ONE_DATA, "fyflxl1", {"value",0}},
    {"需量类数据","当月反向有功费率2最大需量及发生时间",ONE_DATA, "fyflxl2", {"value",0}},
    {"需量类数据","当月反向有功费率3最大需量及发生时间",ONE_DATA, "fyflxl3", {"value",0}},
    {"需量类数据","当月反向有功费率4最大需量及发生时间",ONE_DATA, "fyflxl4", {"value",0}},
    
    {"需量类数据","当月反向无功总最大需量及发生时间",ONE_DATA, "fwflxl", {"value",0}},
    {"需量类数据","当月反向无功费率1最大需量及发生时间",ONE_DATA, "fwflxl1", {"value",0}},
    {"需量类数据","当月反向无功费率2最大需量及发生时间",ONE_DATA, "fwflxl2", {"value",0}},
    {"需量类数据","当月反向无功费率3最大需量及发生时间",ONE_DATA, "fwflxl3", {"value",0}},
    {"需量类数据","当月反向无功费率4最大需量及发生时间",ONE_DATA, "fwflxl4", {"value",0}},
    
    
    {"电压电流类数据","A相电压(V)",ONE_DATA, NULL, {"a",0}},//TODO
    {"电压电流类数据","B相电压(V)",ONE_DATA, NULL, {"b",0}},//TODO
    {"电压电流类数据","C相电压(V)",ONE_DATA, NULL, {"c",0}},//TODO
    {"电压电流类数据","A相电流(A)",ONE_DATA, NULL, {"a",0}},
    {"电压电流类数据","B相电流(A)",ONE_DATA, NULL, {"b",0}},
    {"电压电流类数据","C相电流(A)",ONE_DATA, NULL, {"c",0}},
    {"电压电流类数据","零序电流",ONE_DATA, NULL, {"value",0}},
    {"电压电流类数据","A相电压相位角(°)",ONE_DATA, NULL, {"a",0}},
    {"电压电流类数据","B相电压相位角(°)",ONE_DATA, NULL, {"b",0}},
    {"电压电流类数据","C相电压相位角(°)",ONE_DATA, NULL, {"c",0}},
    {"电压电流类数据","A相电流相位角(°)",ONE_DATA, NULL, {"a",0}},
    {"电压电流类数据","B相电流相位角(°)",ONE_DATA, NULL, {"b",0}},
    {"电压电流类数据","C相电流相位角(°)",ONE_DATA, NULL, {"c",0}},
    {"电压电流类数据","A、B、C三相电压、电流2～19次谐波有效值",ONE_DATA_LIST, NULL, {"a","b","c",0}},
    {"电压电流类数据","A、B、C三相电压、电流2～19次谐波含有率",ONE_DATA_LIST, NULL, {"a","b","c",0}},
    //{"电压电流类数据","A/B/C相2～19次谐波电流最大值及发生时间",S_PLOT_60_D_W_M, NULL, {"a","b","c",0}},
    //{"电压电流类数据","A/B/C相2～19次谐波电压含有率及总畸变率最大值及发生时间",S_PLOT_60_D_W_M, NULL, {"a","b","c",0}},
    //{"电压电流类数据","电压统计数据",ONE_DATA, NULL, {"a","b","c",0}},
    //{"电压电流类数据","电流越限统计",ONE_DATA, NULL, {"a","b","c",0}},
    //{"电压电流类数据","电压不平衡度极值及其发生时间",ONE_DATA, NULL, {"a","b","c",0}},
    //{"电压电流类数据","电流不平衡度极值及其发生时间",ONE_DATA, NULL, {"a","b","c",0}},
    
    {"功率类数据","总有功功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","A相有功功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","B相有功功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","C相有功功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","总无功功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","A相无功功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","B相无功功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","C相无功功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","总视在功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","A相视在功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","B相视在功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","C相视在功率",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","总功率因数",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","A相功率因数",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","B相功率因数",ONE_DATA, NULL, {"t","a","b","c",0}},
    {"功率类数据","C相功率因数",ONE_DATA, NULL, {"t","a","b","c",0}},
    //{"功率类数据","总及分相有功功率极值及发生时间",ONE_DATA, NULL, {"t","a","b","c",0}},
    //{"功率类数据","总及分相无功功率极值及发生时间",ONE_DATA, NULL, {"t","a","b","c",0}},
    //{"功率类数据","视在功率越限累计时间",ONE_DATA, NULL, {"t","a","b","c",0}},
    //{"功率类数据","功率因数区段累计时间",ONE_DATA, NULL, {"t","a","b","c",0}},
    
    
    {"变压器特有数据","油温(℃)",ONE_DATA, NULL, {"value",0}},
    //{"变压器特有数据","油温(℃)极值及其发生时间",ONE_DATA, NULL, {"open","close","high","low",0}},
    {"变压器特有数据","A相绕组温度(℃)",ONE_DATA, NULL, {"open","close","high","low",0}},
    {"变压器特有数据","B相绕组温度(℃)",ONE_DATA, NULL, {"open","close","high","low",0}},
    {"变压器特有数据","C相绕组温度(℃)",ONE_DATA, NULL, {"open","close","high","low",0}},
    //{"变压器特有数据","三相绕组温度(℃)极值及其发生时间",ONE_DATA, NULL, 0},
    {"变压器特有数据","油压",ONE_DATA, NULL, {"value",0}},
    //{"变压器特有数据","油压极值及其发生时间",ONE_DATA, NULL, {"open","close","high","low",0}},
    {"变压器特有数据","油位",ONE_DATA, NULL, {"value",0}},
    //{"变压器特有数据","油位极值及其发生时间",ONE_DATA, NULL, {"open","close","high","low",0}},
    {"变压器特有数据","实时寿命",ONE_DATA, "lifetime", 0},
    
    //{"其他数据","终端日历时钟",ONE_DATA, "terminalCalendar", {0}},
    {"其他数据","终端参数状态",DEVICE_PARAM_STATUS, "terminalStatusParam", {0}},
    {"其他数据","终端重要事件计数器当前值",ONE_DATA, "terminalEventCounter", {0}},
    {"其他数据","终端一般事件计数器当前值",ONE_DATA, "terminalEventCounter", {0}},
    {"其他数据","终端状态量变位标识",DEVICE_STATUS_FLAG, "terminalStatusFlag", {0}},
    //{"其他数据","终端与主站当日、月通信流量",ONE_DATA, NULL, {"value",0}},
    //{"其他数据","终端供电时间、复位累计次数",ONE_DATA, NULL, {"value",0}},
    
    {0,0,PLOT_NONE,NULL,0},
};



XL_VIEW_DATA_TYPE* getTestPointDataDefines(BOOL realtime) {
    return realtime ? common_data_realtime_define : common_data_history_define;
}




@implementation XLViewDataSystem
@end
@implementation XLViewDataLine
@end
@implementation XLViewDataTPCurrAngle
@end

@implementation XLViewDataTPCurr
@end


@implementation XLViewDataSumAndTPRealPower
@end


@implementation XLViewDataSumAndTPPowerFactor
@end


@implementation XLViewDataSumAndTPReactivePower
@end

@implementation XLViewDataTPVolt
@end

@implementation XLViewDataTPVoltAngle
@end

@implementation XLViewDataPlotData

-(id)initWithTestData{
    self = [super init];
    
    self.arrayCurrAngleData = [[NSMutableArray alloc]init];
    self.arrayPowerFactorData = [[NSMutableArray alloc]init];
    self.arrayReactivePowerData = [[NSMutableArray alloc]init];
    self.arrayRealPowerData = [[NSMutableArray alloc]init];
    self.arrayVoltAngleData = [[NSMutableArray alloc]init];
    self.arrayVoltData = [[NSMutableArray alloc]init];
    self.arrayCurrData = [[NSMutableArray alloc]init];

    
    return self;
}
@end

@implementation XLViewDataDCAnalog
@end
@implementation XLViewDataSwitchLoop
@end

@implementation XLViewDataDevice
{
    NSDate *deviceTime;
}
//- (NSString *)userName {
//    return self.user.userName;
//}
//- (NSString *)lineName {
//    return self.user.lineName;
//}
//-(NSString *)businessName {
//    return self.user.businessType;
//}

- (void)setDeviceTime:(NSDate *)date
{
    deviceTime = date;
}

- (NSDate *)queryDeviceTime
{
    if (!deviceTime) {
        deviceTime = [NSDate date];;
    }
    return deviceTime;
}

- (void)queryEvents:(NSDictionary *)dic
{
    if (self.deviceType == DeviceTypeFMR) {
        [self queryFMREvents:dic];
        return;
    } else if (self.deviceType == DeviceTypeSwitch) {
        [self querySwitchEvents:dic];
        return;
    }
    return;
}

- (NSArray *)queryFMREvents:(NSDictionary *)dic
{
    NSDictionary *event1 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"初始化版本变更", @"事件名称",
                            [NSDate date], @"发生时间",
                            @"发生", @"发生/恢复",
                            @"重要", @"事件性质",
                            nil];
    NSDictionary *event2 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"停／上电", @"事件名称",
                            [NSDate date], @"发生时间",
                            @"恢复", @"发生/恢复",
                            @"一般", @"事件性质",
                            nil];
    NSDictionary *event3 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"电压回路异常", @"事件名称",
                            [NSDate date], @"发生时间",
                            @"发生", @"发生/恢复",
                            @"重要", @"事件性质",
                            nil];
    NSDictionary *event4 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"电压／电流不平衡度", @"事件名称",
                            [NSDate date], @"发生时间",
                            @"恢复", @"发生/恢复",
                            @"一般", @"事件性质",
                            nil];
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   [NSArray arrayWithObjects:event1, event2, event3, event4, nil], @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
    return [NSArray arrayWithObjects:event1, event2, event3, event4, nil];
}

- (NSArray *)querySwitchEvents:(NSDictionary *)dic
{
    NSString *type = [dic objectForKey:@"event-type"];
    BOOL loadMore = [[dic objectForKey:@"load-more"] boolValue];//加载更多
    
    NSString *content = @"XXXXXXXXXXXXXXXXXXXXXXXXXXXYXYXYXYYXYXYHFIASHFAHFASFHLJASHFKHASFJAS;JF;ASJF;AS";
    NSDictionary *event1 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"动作事件", @"事件类型",
                            @"1", @"序号",
                            @"time", @"发生时间",
                            content, @"事件内容",
                            nil];
    NSDictionary *event2 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"动作事件", @"事件类型",
                            @"2", @"序号",
                            @"time", @"发生时间",
                            content, @"事件内容",
                            nil];
    
    NSDictionary *event3 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"操作事件", @"事件类型",
                            @"1", @"序号",
                            @"time", @"发生时间",
                            content, @"事件内容",
                            nil];
    NSDictionary *event4 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"操作事件", @"事件类型",
                            @"2", @"序号",
                            @"time", @"发生时间",
                            content, @"事件内容",
                            nil];
    
    NSDictionary *event5 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"告警事件", @"事件类型",
                            @"1", @"序号",
                            @"time", @"发生时间",
                            content, @"事件内容",
                            nil];
    NSDictionary *event6 = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"告警事件", @"事件类型",
                            @"2", @"序号",
                            @"time", @"发生时间",
                            content, @"事件内容",
                            nil];
    
    __block NSUInteger count = 0;
    NSDictionary *(^newSOEEvent)(NSString *) = ^(NSString * name)
    {
        count++;
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"SOE事件", @"事件类型",
                [NSString stringWithFormat:@"%d", count], @"序号",
                name, @"名称",
                @"合", @"事件状态",
                @"time", @"发生时间",
                nil];
    };
    
    NSArray *allEvents = [NSArray arrayWithObjects:event1, event2, event3, event4, event5, event6,
                          newSOEEvent(@"门禁"),
                          newSOEEvent(@"气压报警1"),
                          newSOEEvent(@"气压报警2"),
                          newSOEEvent(@"开关1"),
                          newSOEEvent(@"隔离1"),
                          newSOEEvent(@"地刀1"),
                          newSOEEvent(@"远方1"),
                          newSOEEvent(@"保护动作1"),
                          newSOEEvent(@"保护异常1"),
                          newSOEEvent(@"开关2"),
                          nil];
    
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *event in allEvents) {
        if ([[event objectForKey:@"事件类型"] isEqualToString:type]) {
            [array addObject:event];
        }
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   array, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
    return array;
}

- (void)queryRemoteControls:(NSDictionary *)dic
{
    NSArray *array = nil;
    if (self.deviceType == DeviceTypeSwitch) {
        __block NSUInteger count = 0;
        NSMutableDictionary *(^newControl)(NSString *) = ^(NSString * name)
        {
            count++;
            return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                    name, @"名称",
                    [NSString stringWithFormat:@"%d", count], @"遥控号",
                    @"分", @"遥控操作",
                    nil];
        };
        
        array = [NSArray arrayWithObjects:
                 newControl(@"YK1[13]"),
                 newControl(@"YK2[13]"),
                 newControl(@"YK3[13]"),
                 newControl(@"YK4[13]"),
                 newControl(@"YK5[13]"),
                 newControl(@"电池活化"),
                 newControl(@"YK7[13]"),
                 newControl(@"保护总复归"),
                 newControl(@"保留"),
                 newControl(@"开关1保护复归[2-1]"),
                 nil];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   array, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
    //return array;
}

- (void)presetRemoteControls:(NSMutableDictionary *)control
{
}

- (void)executeRemoteControls:(NSDictionary *)dic
{
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   @"执行成功", @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewOperationDone object:nil userInfo:userInfo];
    });

}

- (void)cancelRemoteControls:(NSDictionary *)dic
{
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   @"取消成功", @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewOperationDone object:nil userInfo:userInfo];
    });

}

- (void)queryCatalogData:(NSDictionary *)dic
{
    NSAssert(self.deviceType == DeviceTypeFMR, @"only FMR should call queryCatalogData");
    BOOL realtime = [[dic objectForKey:@"realtime"] boolValue];
    if (realtime) {
        [self queryRealtimeCatalogData:dic];
    } else {
        [self queryHistoryCatalogData:dic];
    }
}

- (void)queryRealtimeCatalogData:(NSDictionary *)dic
{
//    NSString *catalog = [dic objectForKey:@"catalog"];
//    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
//                          @"XXX", @"油温(℃)",
//                          @"XXX", @"ABC相绕组温度(℃)",
//                          @"XXX", @"油压",
//                          @"XXX", @"油位",
//                          @"XXX", @"实时寿命",
//                          @"XXX", @"终端重要事件计数器当前值",
//                          @"XXX", @"终端一般事件计数器当前值",
//                          nil];
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   data, @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    
    XLRealTimeCatalogDataPageBussiness *xlRealTimeCatalogDataPageBussiness = [XLRealTimeCatalogDataPageBussiness sharedXLRealTimeCatalogDataPageBussiness];
    
    xlRealTimeCatalogDataPageBussiness.msgDic = dic;
    xlRealTimeCatalogDataPageBussiness.isPoint = NO;
    [xlRealTimeCatalogDataPageBussiness requestData];
}

- (void)queryHistoryCatalogData:(NSDictionary *)dic
{
    NSString *catalog = [dic objectForKey:@"catalog"];
    NSDictionary *data = [NSDictionary dictionary];
                          
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   data, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}

- (void)queryCatalog2DataForCategroy:(NSDictionary *)dic
{
    NSAssert(self.deviceType == DeviceTypeSwitch, @"only Switch should call queryCatalog2DataForCategroy");
    BOOL realtime = [[dic objectForKey:@"realtime"] boolValue];
    NSDate *date = [dic objectForKey:@"time"];//查询时间
    NSString *category = [dic objectForKey:@"category"];
    BOOL loadMore = [[dic objectForKey:@"load-more"] boolValue];//加载更多
    
    NSArray *array;
    if ([category rangeOfString:@"遥测"].location != NSNotFound) {
        NSDictionary *(^newItem)(NSString *) = ^(NSString *title)
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    title, @"名称",
                    @"220V", @"实际值",
                    @"文本展示，不可编辑", @"品质描述",
                    nil];
        };
        array = [NSArray arrayWithObjects:
                 newItem(@"Ua1"),
                 newItem(@"Ub1"),
                 newItem(@"Uc1"),
                 newItem(@"3Uo1"),
                 newItem(@"Ia1"),
                 nil];
    } else if ([category rangeOfString:@"遥信"].location != NSNotFound) {
        NSDictionary *(^newItem)(NSString *) = ^(NSString *title)
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    title, @"名称",
                    @"合", @"实际值",
                    @"文本展示，不可编辑", @"品质描述",
                    nil];
        };
        array = [NSArray arrayWithObjects:
                 newItem(@"门禁"),
                 newItem(@"温度加热启动"),
                 newItem(@"气压报警1"),
                 newItem(@"气压报警2"),
                 newItem(@"开关1"),
                 nil];
    } else if ([category rangeOfString:@"遥控"].location != NSNotFound) {
        NSDictionary *(^newItem)(NSString *) = ^(NSString *title)
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    title, @"名称",
                    @"合", @"遥控号",
                    @"文本展示，不可编辑", @"压板",
                    nil];
        };
        array = [NSArray arrayWithObjects:
                 newItem(@"YK1"),
                 newItem(@"温度加热启动"),
                 newItem(@"气压报警1"),
                 newItem(@"气压报警2"),
                 nil];
    } else if ([category rangeOfString:@"运行状态"].location != NSNotFound) {
        NSDictionary *(^newItem)(NSString *) = ^(NSString *title)
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    title, @"名称",
                    @"正常", @"数据展示",
                    nil];
        };
        array = [NSArray arrayWithObjects:
                 newItem(@"告警状态"),
                 newItem(@"网络状态"),
                 newItem(@"零流状态"),
                 newItem(@"开关状态"),
                 newItem(@"过流状态"),
                 nil];
    } else if ([category rangeOfString:@"回线"].location != NSNotFound) {
        NSDictionary *(^newItem)(NSString *) = ^(NSString *title)
        {
            return [NSDictionary dictionaryWithObjectsAndKeys:
                    title, @"名称",
                    @"文本展示，不可编辑", @"数据",
                    nil];
        };
        array = [NSArray arrayWithObjects:
                 newItem(@"Ua1"),
                 newItem(@"Ub1"),
                 newItem(@"Uc1"),
                 nil];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   array, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}

- (void)queryParamStatus:(NSDictionary *)dic
{
    NSDictionary *(^newItem)(NSString *) = ^(NSString *title)
    {
        static BOOL flag = NO;
        flag = !flag;
        return [NSDictionary dictionaryWithObjectsAndKeys:
                title, @"title",
                [NSNumber numberWithBool:flag], @"status",
                nil];
    };
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:248];
    for (int i = 1; i <= 248; i++) {
        NSString *str = [NSString stringWithFormat:@"F%d", i];
        [array addObject:newItem(str)];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   array, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}

- (void)queryStatusFlag:(NSDictionary *)dic
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:8];
    for (int i = 0; i <= 8; i++) {
        BOOL folded = arc4random() % 100 > 50;
        BOOL changed = arc4random() % 100 > 50;
        NSDictionary *el = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:folded], @"合",
                            [NSNumber numberWithBool:changed], @"有变化",
                            nil];
        [array addObject:el];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   array, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}

- (void)querySwitchStatics:(NSDictionary *)dic
{
    NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"正常", @"过流状态",
                            @"正常", @"告警状态",
                            @"不正常", @"零流状态",
                            @"正常", @"网络状态",
                            @"正常", @"运行状态",
                            
                            @"合", @"合分闸状态",
                            
                            @"XXX", @"三相电压",
                            @"XXX", @"电流",
                            @"XXX", @"零序电压",
                            @"XXX", @"电流",
                            nil];
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   result, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}

@end

@implementation XLViewDataTestPoint

- (NSString *)deviceName {
    return self.device.deviceName;
}
//- (NSString *)lineName {
//    return self.user.lineName;
//}

-(void)reloadTestData{
    self.dataDay = [[XLViewDataPlotData alloc]initWithTestData];
    
    //一天秒数
    int oneDay = 24*60*60;
    
    //总/三相平均有功功率
    //时间， 电量，总功率最大， 总功率最小，开始总功率，结束总功率，额定功率，A相功率，B相功率，C相功率，最大负荷，最小负荷，最大需量，有功损耗，功率因素
    double dayBase[17] = {1000,300,100,150,250,500,60,70,90,400,100,600,90,0.75,24*60*60,24*60*60,24*60*60,};
    
    //生成30天随机数据
    
    for(int i=0;i<30;i++){
        XLViewDataSumAndTPRealPower *data = [[XLViewDataSumAndTPRealPower alloc]init];
        
        int randData[17];
        
        for(int j=0;j<17;j++){
            if(dayBase[j]>999){
                
                int r = (arc4random() % 201) + 100;
                randData[j]=dayBase[j]-r;
            }
            
            if(dayBase[j]>=150 && dayBase[j]<=999){
                
                int r = (arc4random() % 51);
                randData[j]=dayBase[j]-r;
            }
            
            if(dayBase[j]<150){
                
                int r = (arc4random() % 31);
                randData[j]=dayBase[j]-r;
            }
            if(dayBase[j]==24*60*60){
                
                int r = (arc4random() % 23*60*60);
                randData[j]=r;
            }
        }
        data.tmData = oneDay*i;
        
        data.consume=randData[0];
        data.totalPowerMax=randData[1];
        data.totalPowerMin=randData[2];
        
        int r = (arc4random() % 100);
        
        
        if(r%2==0){
            data.totalPowerStart=randData[3];
            data.totalPowerEnd=randData[4];
        }
        
        if(r%2==1){
            data.totalPowerStart=randData[4];
            data.totalPowerEnd=randData[3];
        }
        
        data.totalPowerRated=dayBase[5];
        data.aPower=randData[6];
        data.bPower=randData[7];
        data.cPower=randData[8];
        data.maxLoad=randData[9];
        data.minLoad=randData[10];
        data.maxConsume=randData[11];
        data.maxRealLost=randData[12];
        data.powerFactor=randData[13];
        data.powerFactor=dayBase[13];
        data.totalPower=abs(data.totalPowerStart-data.totalPowerEnd)/2+MIN(data.totalPowerStart,data.totalPowerEnd);
        [self.dataDay.arrayRealPowerData addObject:data];
        
        data.maxLoadTime=randData[14];
        data.minLoadTime=randData[15];
        data.maxConsumeTime=randData[16];
        
        data.saftRuningTotal=500;
    }
}

-(id)initWithTestData{
    self = [super init];
    [self reloadTestData];
    return self;
}

- (void)queryCatalogData:(NSDictionary *)dic
{
    BOOL realtime = [[dic objectForKey:@"realtime"] boolValue];
    if (realtime) {
        [self queryRealtimeCatalogData:dic];
    } else {
        [self queryHistoryCatalogData:dic];
    }
}
                          
- (void)queryRealtimeCatalogData:(NSDictionary *)dic
{
//    NSString *catalog = [dic objectForKey:@"catalog"];//只返回相应catalog数据即可
//    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
//                          //电能量类数据
//                          @"XXX", @"正有总电能示值",
//                          @"XXX", @"正有费率1电能示值",
//                          @"XXX", @"正有费率2电能示值",
//                          @"XXX", @"正有费率3电能示值",
//                          @"XXX", @"正有费率4电能示值",
//                          @"XXX", @"正无总电能示值",
//                          @"XXX", @"正无费率1电能示值",
//                          @"XXX", @"正无费率2电能示值",
//                          @"XXX", @"正无费率3电能示值",
//                          @"XXX", @"正无费率4电能示值",
//                          @"XXX", @"反有总电能示值",
//                          @"XXX", @"反有费率1电能示值",
//                          @"XXX", @"反有费率2电能示值",
//                          @"XXX", @"反有费率3电能示值",
//                          @"XXX", @"反有费率4电能示值",
//                          @"XXX", @"反无总电能示值",
//                          @"XXX", @"反无费率1电能示值",
//                          @"XXX", @"反无费率2电能示值",
//                          @"XXX", @"反无费率3电能示值",
//                          @"XXX", @"反无费率4电能示值",
//                          @"XXX", @"第一象限无功总电能示值",
//                          @"XXX", @"第二象限无功总电能示值",
//                          @"XXX", @"第三象限无功总电能示值",
//                          @"XXX", @"第四象限无功总电能示值",
//                          @"XXX", @"正向有功电能量",
//                          @"XXX", @"正向无功电能量",
//                          @"XXX", @"反向有功电能量",
//                          @"XXX", @"反向无功电能量",
//                          @"XXX", @"铜损有功总电能示值",
//                          @"XXX", @"铁损有功总电能示值",
//                          //需量类数据   总加组不用返回此类数据
//                          @"数值\n时间", @"当月正向有功总最大需量及发生时间",
//                          @"数值\n时间", @"当月正向有功费率1最大需量及发生时间",
//                          @"数值\n时间", @"当月正向有功费率2最大需量及发生时间",
//                          @"数值\n时间", @"当月正向有功费率3最大需量及发生时间",
//                          @"数值\n时间", @"当月正向有功费率4最大需量及发生时间",
//                          @"数值\n时间", @"当月正向无功总最大需量及发生时间",
//                          @"数值\n时间", @"当月正向无功费率1最大需量及发生时间",
//                          @"数值\n时间", @"当月正向无功费率2最大需量及发生时间",
//                          @"数值\n时间", @"当月正向无功费率3最大需量及发生时间",
//                          @"数值\n时间", @"当月正向无功费率4最大需量及发生时间",
//                          @"数值\n时间", @"当月反向有功总最大需量及发生时间",
//                          @"数值\n时间", @"当月反向有功费率1最大需量及发生时间",
//                          @"数值\n时间", @"当月反向有功费率2最大需量及发生时间",
//                          @"数值\n时间", @"当月反向有功费率3最大需量及发生时间",
//                          @"数值\n时间", @"当月反向有功费率4最大需量及发生时间",
//                          @"数值\n时间", @"当月反向无功总最大需量及发生时间",
//                          @"数值\n时间", @"当月反向无功费率1最大需量及发生时间",
//                          @"数值\n时间", @"当月反向无功费率2最大需量及发生时间",
//                          @"数值\n时间", @"当月反向无功费率3最大需量及发生时间",
//                          @"数值\n时间", @"当月反向无功费率4最大需量及发生时间",
//                          //电压电流类数据   总加组不用返回此类数据
//                          @"XXX", @"ABC相电压(V)",
//                          @"XXX", @"ABC相电流(A)",
//                          @"XXX", @"零序电流",
//                          @"XXX", @"ABC相电压相位角(°)",
//                          @"XXX", @"ABC相电流相位角(°)",
//                          @"XXX", @"A、B、C三相电压、电流2～19次谐波有效值",
//                          @"XXX", @"A、B、C三相电压、电流2～19次谐波含有率",
//                          //功率类数据
//                          @"XXX", @"总有功功率",
//                          @"XXX", @"A相有功功率",
//                          @"XXX", @"B相有功功率",
//                          @"XXX", @"C相有功功率",
//                          @"XXX", @"总无功功率",
//                          @"XXX", @"A相无功功率",
//                          @"XXX", @"B相无功功率",
//                          @"XXX", @"C相无功功率",
//                          @"XXX", @"总视在功率",
//                          @"XXX", @"A相视在功率",
//                          @"XXX", @"B相视在功率",
//                          @"XXX", @"C相视在功率",
//                          @"XXX", @"总功率因数",
//                          @"XXX", @"A相功率因数",
//                          @"XXX", @"B相功率因数",
//                          @"XXX", @"C相功率因数",
//                          nil];
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   data, @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLRealTimeCatalogDataPageBussiness *xlRealTimeCatalogDataPageBussiness = [XLRealTimeCatalogDataPageBussiness sharedXLRealTimeCatalogDataPageBussiness];
    
    xlRealTimeCatalogDataPageBussiness.isPoint = YES;
    xlRealTimeCatalogDataPageBussiness.msgDic = dic;
    [xlRealTimeCatalogDataPageBussiness requestData];

}

- (void)queryHistoryCatalogData:(NSDictionary *)dic
{
    NSString *catalog = [dic objectForKey:@"catalog"];//只返回相应catalog数据即可
    NSDate *date = [dic objectForKey:@"time"];//查询时间
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          //电能量类数据
                          @"XXX", @"正有总/各费率电能示值",
                          @"XXX", @"正无总/各费率电能示值",
                          @"XXX", @"反有总/各费率电能示值",
                          @"XXX", @"反无总/各费率电能示值",
                          @"XXX", @"一象限无功电能示值",
                          @"XXX", @"二象限无功电能示值",
                          @"XXX", @"三象限无功电能示值",
                          @"XXX", @"四象限无功电能示值",
                          @"XXX", @"铜损有功总电能示值",
                          @"XXX", @"铁损有功总电能示值",
                          nil];
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   data, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}

- (void)query2_19ListData:(NSDictionary *)dic
{
    /*
     * 实时：
     * A、B、C三相电压、电流2～19次谐波有效值
     * A、B、C三相电压、电流2～19次谐波含有率
     * 历史：
     * A/B/C相2～19次谐波电流最大值及发生时间
     * A/B/C相2～19次谐波电压含有率及总畸变率最大值及发生时间
     */
    NSString *category = [dic objectForKey:@"category"];
    BOOL realtime = [[dic objectForKey:@"realtime"] boolValue];
    if (!realtime) {//历史数据
        NSDate *date = [dic objectForKey:@"time"];//查询时间
        XLViewPlotTimeType timeType = [[dic objectForKey:@"plotTimeType"] intValue];
    }

    NSArray *columns;
    NSMutableArray *datas = [NSMutableArray arrayWithCapacity:18];
    if ([category isEqualToString:@"A、B、C三相电压、电流2～19次谐波有效值"]) {
        columns = [NSArray arrayWithObjects:@"A相\n电压", @"B相\n电压", @"C相\n电压", @"A相\n电流", @"B相\n电流", @"C相\n电流", nil];
        for (NSUInteger i = 2; i <= 19; i++) {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            for (NSString *col in columns) {
                [row setObject:@"XXX" forKey:col];
            }
            [datas addObject:row];
        }
    } else if ([category isEqualToString:@"A、B、C三相电压、电流2～19次谐波含有率"]) {
        columns = [NSArray arrayWithObjects:@"A相\n电压", @"B相\n电压", @"C相\n电压", @"A相\n电流", @"B相\n电流", @"C相\n电流", nil];
        for (NSUInteger i = 2; i <= 19; i++) {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            for (NSString *col in columns) {
                [row setObject:@"XXX" forKey:col];
            }
            [datas addObject:row];
        }
    } else if ([category isEqualToString:@"A/B/C相2～19次谐波电流最大值及发生时间"]) {
        columns = [NSArray arrayWithObjects:@"A相", @"B相", @"C相", nil];
        for (NSUInteger i = 2; i <= 19; i++) {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            for (NSString *col in columns) {
                [row setObject:@"120V\n2014-4-5\n10:12:54" forKey:col];
            }
            [datas addObject:row];
        }
    } else if ([category isEqualToString:@"A/B/C相2～19次谐波电压含有率及总畸变率最大值及发生时间"]) {
        columns = [NSArray arrayWithObjects:@"A相", @"B相", @"C相", nil];
        for (NSUInteger i = 2; i <= 19; i++) {
            NSMutableDictionary *row = [NSMutableDictionary dictionary];
            for (NSString *col in columns) {
                [row setObject:@"50%\n20%\n2014-4-5\n10:12:54" forKey:col];
            }
            [datas addObject:row];
        }
    }
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   datas, @"result",
                                   columns, @"column",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}




@end

@implementation XLViewDataUserSumGroup
@synthesize positiveTestPoints = _positiveTestPoints;
@synthesize negativeTestPoints = _negativeTestPoints;

- (NSMutableArray *)positiveTestPoints {
    if (!_positiveTestPoints) {
        _positiveTestPoints = [NSMutableArray array];
    }
    return _positiveTestPoints;
}

- (NSMutableArray *)negativeTestPoints {
    if (!_negativeTestPoints) {
        _negativeTestPoints = [NSMutableArray array];
    }
    return _negativeTestPoints;
}

@end


@implementation XLViewDataUserBaiscInfo

@synthesize currentTestPointOrGroup = _currentTestPointOrGroup;
@synthesize defaultSumGroup = _defaultSumGroup;
@synthesize line = _line;

- (id)init
{
    self = [super init];
    if (self) {
        XLViewDataUserSumGroup *group = [[XLViewDataUserSumGroup alloc] init];
        group.groupId = @"1";
        group.groupName = @"总用电";
        group.attention = YES;
        group.isDefault = YES;
        self.sumGroups = [NSMutableArray arrayWithObject:group];
    }
    return self;
}

- (NSString *)lineName{
    return _line.lineName;
}

- (void)addSumGroup:(XLViewDataUserSumGroup *)group {
    [self.sumGroups addObject:group];
}

- (XLViewDataUserSumGroup *)defaultSumGroup {
    if (self.sumGroups.count > 0) {
        XLViewDataUserSumGroup *group = [self.sumGroups objectAtIndex:0];
        if (group.isDefault) {
            return group;
        }
    }
    return nil;
}

- (void)queryStatistics:(NSDictionary *)dic
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @YES, @"经济性",//YES代表绿色，NO为红色
                                   @NO, @"安全性",
                                   @YES, @"电能质量",
                                   
                                   @"2000.00kVA", @"额定容量",
                                   @"423.00kW", @"最大负荷",
                                   @"72.00kW", @"最小负荷",
                                   @"635.00kWh", @"最大需量",
                                   @"496天", @"安全运行",
                                   @"0.43kWh", @"电量",
                                   @"90.00kWh", @"有功损耗",
                                   @"0.61", @"功率因素",
                                   nil];
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   result, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}

@end

@implementation XLModelDataInterface{
    NSMutableArray* arraySystem;
    NSMutableArray* arrayLine;
    NSMutableArray* arrayUserBasicInfo;
    NSMutableArray* arrayDevice;
    NSMutableArray* arrayTestPoint;
}

@synthesize currentUser = _currentUser;
@synthesize currentLine = _currentLine;
@synthesize currentSystem = _currentSystem;

static XLModelDataInterface *sharedSingleton = nil;

+(XLModelDataInterface *)testData
{
    @synchronized(self)
    {
        if ( sharedSingleton == nil ) {
            sharedSingleton = [[self alloc] init];
        }
    }
    return sharedSingleton;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if ( sharedSingleton == nil ) {
            return [super allocWithZone:zone];
        }
    }
    return sharedSingleton;
}

-(id)init
{
    Class thisClass = [self class];
    
    @synchronized(thisClass)
    {
        if ( sharedSingleton == nil ) {
            if ( (self = [super init]) ) {
                [self setupTestData];
                sharedSingleton = self;
            }
        }
    }
    
    return sharedSingleton;
}

-(id)copyWithZone:(NSZone *)zone
{
    return self;
}

-(void)setupTestData{
    arraySystem = [[NSMutableArray alloc] init];
    arrayLine = [[NSMutableArray alloc] init];
    arrayUserBasicInfo = [[NSMutableArray alloc] init];
    arrayDevice = [[NSMutableArray alloc] init];
    arrayTestPoint = [[NSMutableArray alloc] init];
    
//    SystemInfo* sysInfo = [[XLSystemBussiness sharedXLSystemBussiness] getCurrentSystem];
    XLViewDataSystem *system = [[XLViewDataSystem alloc] init];
    system.systemId = @"1";
    system.systemName = @"默认系统";
    system.systemInfo = @"XXX";
    
    [arraySystem addObject:system];
    _currentSystem = system;
    
    XLViewDataLine *line = [[XLViewDataLine alloc] init];
    line.lineId = @"1";
    line.lineNo = @"1";
    line.lineName = @"默认线路";
    line.system = system;
    line.attention = YES;
    line.isDefault = YES;
    [arrayLine addObject:line];
    _currentLine = line;

    XLViewDataUserBaiscInfo* xlViewDataUserBaiscInfo= [[XLViewDataUserBaiscInfo alloc] init];
    xlViewDataUserBaiscInfo.userId=@"1";
    xlViewDataUserBaiscInfo.userName=@"新联庄排路";
    xlViewDataUserBaiscInfo.line = line;
    xlViewDataUserBaiscInfo.address=@"双龙大道";
    xlViewDataUserBaiscInfo.capacity=@"100kVA";
    xlViewDataUserBaiscInfo.userNo = @"30";
    xlViewDataUserBaiscInfo.attention = YES;
    [arrayUserBasicInfo addObject:xlViewDataUserBaiscInfo];
    _currentUser = xlViewDataUserBaiscInfo;
    
    XLViewDataDevice *device1 = [[XLViewDataDevice alloc] init];
    device1.deviceId = @"1";
    device1.deviceType = DeviceTypeFMR;
    device1.user = xlViewDataUserBaiscInfo;
    device1.deviceName = @"变压器1＃";
    device1.latitude = 31.867037;
    device1.longitude = 118.824720;
    XLViewDataDevice *device2 = [[XLViewDataDevice alloc] init];
    device2.deviceId = @"2";
    device2.deviceType = DeviceTypeFMR;
    device2.user = xlViewDataUserBaiscInfo;
    device2.deviceName = @"变压器2＃";
    device2.latitude = 31.867037;
    device2.longitude = 118.824720 - 0.02;
    XLViewDataDevice *device3 = [[XLViewDataDevice alloc] init];
    device3.deviceId = @"3";
    device3.deviceType = DeviceTypeSwitch;
    device3.user = xlViewDataUserBaiscInfo;
    device3.deviceName = @"开关1＃";
    device3.latitude = 31.867037 + 0.05;
    device3.longitude = 118.824720;;
    XLViewDataDevice *device4 = [[XLViewDataDevice alloc] init];
    device4.deviceId = @"4";
    device4.deviceType = DeviceTypeSwitch;
    device4.user = xlViewDataUserBaiscInfo;
    device4.deviceName = @"开关2＃";
    [arrayDevice addObject:device1];
    [arrayDevice addObject:device2];
    [arrayDevice addObject:device3];
    [arrayDevice addObject:device4];
    
    //xlViewDataUserBaiscInfo.devices = [NSMutableArray arrayWithObjects:device1, device2, device3, device4, nil];
    
    XLViewDataTestPoint *point1 = [[XLViewDataTestPoint alloc] initWithTestData];
    point1.pointId = @"1";
    point1.pointNo = @"1";
    point1.pointName = @"进线1#计量";
    point1.attention = YES;
    point1.user = xlViewDataUserBaiscInfo;
    point1.device = device1;
    
    XLViewDataTestPoint *point2 = [[XLViewDataTestPoint alloc] init];
    point2.pointId = @"2";
    point2.pointNo = @"2";
    point2.pointName = @"进线2#计量";
    point2.attention = YES;
    point2.user = xlViewDataUserBaiscInfo;
    point2.device = device3;
    XLViewDataTestPoint *point3 = [[XLViewDataTestPoint alloc] init];
    point3.pointId = @"3";
    point3.pointNo = @"3";
    point3.pointName = @"照明回路1";
    point3.user = xlViewDataUserBaiscInfo;
    point3.device = device3;
    XLViewDataTestPoint *point4 = [[XLViewDataTestPoint alloc] init];
    point4.pointId = @"4";
    point4.pointNo = @"4";
    point4.pointName = @"照明回路2";
    point4.user = xlViewDataUserBaiscInfo;
    point4.device = device1;
    XLViewDataTestPoint *point5 = [[XLViewDataTestPoint alloc] init];
    point5.pointId = @"5";
    point5.pointNo = @"5";
    point5.pointName = @"低压总进";
    point5.user = xlViewDataUserBaiscInfo;
    point5.device = device1;
    XLViewDataTestPoint *point6 = [[XLViewDataTestPoint alloc] init];
    point6.pointId = @"6";
    point6.pointNo = @"6";
    point6.pointName = @"进线3#计量";
    point6.user = xlViewDataUserBaiscInfo;
    point6.device = device1;
    NSArray *pa = [NSArray arrayWithObjects:point1, point2, point3, point4, point5, point6, nil];
    [arrayTestPoint addObjectsFromArray:pa];
    
    
    [xlViewDataUserBaiscInfo.defaultSumGroup.positiveTestPoints addObjectsFromArray:[self queryTestPointsForUser:xlViewDataUserBaiscInfo]];
    
    //xlViewDataUserBaiscInfo.testPoints = [NSMutableArray arrayWithObjects:point1,point2,nil];
}

- (NSArray *)getAllUserBasicInfo {
    return arrayUserBasicInfo;
}

- (NSArray *)queryAllSystems {
    return arraySystem;
}

- (void)createSystem:(XLViewDataSystem *)system {
    NSInteger _id = 0;
    for(XLViewDataSystem * item in arraySystem){
        NSInteger systemId = item.systemId;
        if(systemId > _id){
            _id = systemId;
        }
    }
    
    system.systemId = [NSString stringWithFormat:@"%d", (_id + 1)];
    if (!arraySystem) {
        arraySystem = [NSMutableArray array];
    }
    [arraySystem addObject:system];
}

- (BOOL)deleteSystem:(NSString *)systemId {
    for(XLViewDataSystem * item in arraySystem){
        if([item.systemId isEqualToString:systemId]){
            [arraySystem removeObject:item];
            return YES;
        }
        
    }
    return NO;

}

- (NSArray *)queryAllLines {
    return arrayLine;
}

- (NSArray *)queryUserForLine:(XLViewDataLine *)line {
    NSMutableArray *array = [NSMutableArray array];
    for(XLViewDataUserBaiscInfo * user in arrayUserBasicInfo){
        if([user.line isEqual:line]){
            [array addObject:user];
        }
    }
    
    return array;
}

- (NSArray *)queryLinesForSystem:(XLViewDataSystem *)system {
    NSMutableArray *array = [NSMutableArray array];
    for(XLViewDataLine * line in arrayLine){
        if([line.system isEqual:system]){
            [array addObject:line];
        }
    }
    
    return array;
}

- (void)createLine:(XLViewDataLine *)line {
    NSInteger _id = 0;
    for(XLViewDataLine * item in arrayLine){
        NSInteger lineId = item.lineId.integerValue;
        if(lineId > _id){
            _id = lineId;
        }
    }
    
    line.lineId = [NSString stringWithFormat:@"%d", (_id + 1)];
    if (!arrayLine) {
        arrayLine = [NSMutableArray array];
    }
    [arrayLine addObject:line];
}

- (BOOL)deleteLine:(NSString*)lineId {
    for(XLViewDataLine * item in arrayLine){
        if([item.lineId isEqualToString:lineId]){
            NSArray *users = [self queryUserForLine:item];
            for (XLViewDataUserBaiscInfo *user in users) {
                user.line = nil;
            }
            
            [arrayLine removeObject:item];
            return YES;
        }
    }
    return NO;
}

- (void)createUserBasicInfo:(XLViewDataUserBaiscInfo *)user {
    NSInteger _id = 0;
    for(XLViewDataUserBaiscInfo * item in arrayUserBasicInfo){
        NSInteger userId = item.userId.integerValue;
        if(userId > _id){
            _id = userId;
        }
    }
    
    user.userId = [NSString stringWithFormat:@"%d", (_id + 1)];
    if (!arrayUserBasicInfo) {
        arrayUserBasicInfo = [NSMutableArray array];
    }
    [arrayUserBasicInfo addObject:user];
}

- (BOOL)deleteUserBasicInfo:(NSString*)userId {
    for(XLViewDataUserBaiscInfo * item in arrayUserBasicInfo){
        if([item.userId isEqualToString:userId]){
            NSArray *devices = [self queryDevicesForUser:item];
            for (XLViewDataDevice *device in devices) {
                device.user = nil;
            }
            
            [arrayUserBasicInfo removeObject:item];
            return YES;
        }
        
    }
    return NO;
}

- (XLViewDataUserBaiscInfo*) getUserBasicInfo:(NSString*)userId {
    for(XLViewDataUserBaiscInfo * item in arrayUserBasicInfo){
        if([item.userId isEqualToString:userId]){
            return item;
        }

    }
    return nil;
}

- (void)createDevice:(XLViewDataDevice *)device {
    NSInteger _id = 0;
    for(XLViewDataDevice * item in arrayDevice){
        NSInteger deviceId = item.deviceId.integerValue;
        if(deviceId > _id){
            _id = deviceId;
        }
    }
    
    device.deviceId = [NSString stringWithFormat:@"%d", (_id + 1)];
    if (!arrayDevice) {
        arrayDevice = [NSMutableArray array];
    }
    [arrayDevice addObject:device];
}

- (void)deleteDevices:(NSArray *)devices
{
    [arrayDevice removeObjectsInArray:devices];
    
    for (XLViewDataTestPoint *point in arrayTestPoint) {
        if (point.device && [devices containsObject:point.device]) {
            point.device = nil;
        }
    }
    
    for(XLViewDataDevice * item in devices){
        item.user = nil;
    }
}

- (NSArray *)queryDevicesForUser:(XLViewDataUserBaiscInfo *)user
{
    NSMutableArray *array = [NSMutableArray array];
    for(XLViewDataDevice * device in arrayDevice){
        if([device.user isEqual:user]){
            [array addObject:device];
        }
    }
    
    return array;
}

- (NSArray *)queryTestPointsForDevice:(XLViewDataDevice *)device {
    NSMutableArray *array = [NSMutableArray array];
    for(XLViewDataTestPoint * item in arrayTestPoint){
        if([item.device isEqual:device]){
            [array addObject:item];
        }
    }
    
    return array;
}

- (NSArray *)queryTestPointsForUser:(XLViewDataUserBaiscInfo *)user {
    NSMutableArray *array = [NSMutableArray array];
    for(XLViewDataTestPoint * item in arrayTestPoint){
        if([item.user isEqual:user]){
            [array addObject:item];
        }
    }
    
    return array;
}

- (NSArray *)queryTestPointsWithAttentionForUser:(XLViewDataUserBaiscInfo *)user
{
    NSMutableArray *array = [NSMutableArray array];
    for(XLViewDataTestPoint * item in arrayTestPoint){
        if([item.user isEqual:user] && item.attention){
            [array addObject:item];
        }
    }
    
    return array;

}

- (void)createTestPoint:(XLViewDataTestPoint *)point {
    NSInteger _id = 0;
    for(XLViewDataTestPoint *item in arrayTestPoint){
        NSInteger pointId = item.pointId.integerValue;
        if(pointId > _id){
            _id = pointId;
        }
    }
    
    point.pointId = [NSString stringWithFormat:@"%d", (_id + 1)];
    if (!arrayTestPoint) {
        arrayTestPoint = [NSMutableArray array];
    }
    [arrayTestPoint addObject:point];
}

- (void)deleteTestPoints:(NSArray *)points
{
    [arrayTestPoint removeObjectsInArray:points];
    
    for (XLViewDataUserBaiscInfo *user in arrayUserBasicInfo) {
        for (XLViewDataUserSumGroup *sum in user.sumGroups) {
            [sum.positiveTestPoints removeObjectsInArray:points];
            [sum.negativeTestPoints removeObjectsInArray:points];
        }
    }
    
    for(XLViewDataTestPoint *point in points){
        point.user = nil;
        point.device = nil;
    }
}

- (BOOL)isDeviceOnline:(XLViewDataDevice *)device
{
    static XLViewDataDevice *onlineDevice = nil;
    if (!device) {
        return NO;
    }
    if (!onlineDevice) {
        onlineDevice = device;
    }
    return [device isEqual:onlineDevice];
}


//获取测量点曲线数据
-(XLViewDataPlotData*) getPlotData:(XLViewPlotTimeType)tmType    //数据周期类型
                 atUser:(NSString*)userId    //用户ID
            atTestPoint:(NSString*)pointId  //测量点ID
{
    
    XLViewDataUserBaiscInfo* user = [self getUserBasicInfo:userId];
    
    if(user!=nil){
        XLViewDataTestPoint* tp = [arrayTestPoint objectAtIndex:0];//[user.testPoints objectAtIndex:0];
        [tp reloadTestData];
        if(tmType==XLViewPlotTimeDay){
            
            return tp.dataDay;
            
        }
    }
    
    return nil;
}

- (void)queryAllEvents:(NSDictionary *)dic
{
//    NSDictionary *event1 = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"初始化版本变更", @"事件名称",
//                            [NSDate dateWithTimeIntervalSinceNow:0], @"发生时间",
//                            @"发生", @"发生/恢复",
//                            @"重要", @"事件性质",
//                            nil];
//    NSDictionary *event2 = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"停／上电", @"事件名称",
//                            [NSDate dateWithTimeIntervalSinceNow:-1], @"发生时间",
//                            @"恢复", @"发生/恢复",
//                            @"一般", @"事件性质",
//                            nil];
//    NSDictionary *event3 = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"电压回路异常", @"事件名称",
//                            [NSDate dateWithTimeIntervalSinceNow:-2], @"发生时间",
//                            @"发生", @"发生/恢复",
//                            @"重要", @"事件性质",
//                            nil];
//    NSDictionary *event4 = [NSDictionary dictionaryWithObjectsAndKeys:
//                            @"电压／电流不平衡度", @"事件名称",
//                            [NSDate dateWithTimeIntervalSinceNow:-3], @"发生时间",
//                            @"恢复", @"发生/恢复",
//                            @"一般", @"事件性质",
//                            nil];
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   [NSArray arrayWithObjects:event1, event2, event3, event4, nil], @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLDeviceEventPageBussiness *xlDeviceEventPageBussiness =[XLDeviceEventPageBussiness sharedXLDeviceEventPageBussiness];
    xlDeviceEventPageBussiness.msgDic = dic;
    [xlDeviceEventPageBussiness requestData];
    
    
    //return [NSArray arrayWithObjects:event1, event2, event3, event4, nil];
}

static int generateRandData(double* dayBase,int ipt_len,double* randData){
    
    for(int j=0;j<ipt_len;j++){
        if(dayBase[j]>999){
            
            int r = (arc4random() % 201) + 100;
            randData[j]=dayBase[j]-r;
        }
        
        if(dayBase[j]>=150 && dayBase[j]<=999){
            
            int r = (arc4random() % 51);
            if(r%2==0)
                randData[j]=dayBase[j]-r;
            else
                randData[j]=dayBase[j]+r;
        }
        
        if(dayBase[j]<150 && dayBase[j]>100){
            
            int r = (arc4random() % 60);
            
            if(r%2==0)
                randData[j]=dayBase[j]-r;
            else
                randData[j]=dayBase[j]+r;
        }
        
        if(dayBase[j]<=100 && dayBase[j]>50){
            
            int r = (arc4random() % 31);
            randData[j]=dayBase[j]-r;
        }
        
        if(dayBase[j]<=50 && dayBase[j]>20){
            
            int r = (arc4random() % 10);
            randData[j]=dayBase[j]-r;
        }
        if(dayBase[j]<=20 && dayBase[j]>8){
            
            int r = (arc4random() % 5);
            randData[j]=dayBase[j]-r;
        }
        
        if(dayBase[j]<=8){
            
            int r = (arc4random() % 10);
            randData[j]=dayBase[j]-r;
        }
        
        
        
        if(dayBase[j]<1){
            
            float r = (arc4random() % 89)+10;
            randData[j]=r/100;
        }
        if(dayBase[j]==24*60*60){
            
            int r = (arc4random() % 23*60*60);
            randData[j]=r;
        }
    }
    return ipt_len;
}

-(void) loadTestDataForPlotByName:(NSDictionary*)paramDict intoArray:(NSMutableArray*)array{
    
    
//    [NSNumber numberWithInt:self.plotDataType],@"plot-type",
//    //如果 plot-type 为 XLViewPlotDataByName 类型
//    //根据 plot-name 确定曲线数据类型
//    self.plotDataTitle,@"plot-name",
//    //返回的数据字典所包含的keys
//    self.dataMapKeys,@"data-map-keys",
    
    
    NSString *plotName = [paramDict objectForKey:@"plot-name"];
    
    NSArray *dataMapKeys = [paramDict objectForKey:@"data-map-keys"];
    
    
    double *dataBase;
    
    BOOL isKData=NO;
    
    
    if([[dataMapKeys objectAtIndex:0] isEqualToString:@"open"]){
        
        isKData=YES;
        double vs[4]={200,350,500,150};
            dataBase=vs;
        
        
    }else{
        
        dataBase = (double*)malloc(dataMapKeys.count*sizeof(double));
        for(int i=0;i<dataMapKeys.count;i++){
            dataBase[i]=500;
        }
    }

    
    int siz=dataMapKeys.count;
    
    //生成30天随机数据
    
    for(int i=0;i<30;i++){
        //                if(i<6){
        //                    [array addObject:[NSNull null]];
        //                    continue;
        //                }
        
        NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
        double randData[siz];
        generateRandData(dataBase, siz, randData);
        
        NSString* key;
        
        for(int i=0;i<dataMapKeys.count;i++){
            
            key = [dataMapKeys objectAtIndex:i];
            [map setObject:[NSNumber numberWithDouble:randData[i]] forKey:key];
        }
        
        if(isKData){
            
            if(i % 2==1){
                
                [map setObject:[NSNumber numberWithDouble:randData[0]] forKey:@"close"];
                [map setObject:[NSNumber numberWithDouble:randData[1]] forKey:@"open"];
                
            }
            
        }
        

        [array addObject:map];
        
    }
    
    
    
}

-(NSMutableDictionary*) getCurrentPlotData:(NSDictionary*)paramDict{
    

    int plotDataType = [(NSNumber*)[paramDict objectForKey:@"plot-type"] intValue];
    NSMutableDictionary* retDict = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    switch (plotDataType){
        case XLViewPlotDataByName:
            
            [self loadTestDataForPlotByName:paramDict intoArray:array];

            [retDict setObject:array forKey:@"array1"];
            return retDict;
            
            break;
            //总/三相平均有功功率
            //只需要 ax,bx,cx,pj 四个值
        case XLViewPlotDataSumAndTPRealPowerScatter:
        case XLViewPlotDataSumAndTPReactivePowerScatter:
            //总/三相平均有功功率
        case XLViewPlotDataSumAndTPRealPower:
            
        {
            /*
             时间   //sj
             电量   //dl
             总功率最大  //zglzd
             总功率最小  //zglzx
             开始总功率  //kszgl
             结束总功率  //jszgl
             额定功率  //edgl
             A相功率  //axgl
             B相功率  //bxgl
             C相功率  //cxgl
             最大负荷  //zdfh
             最小负荷  //zxfh
             最大需量  //zdxl
             有功损耗  //ygsh
             功率因素  //glys
             最大负荷发生时间  //zdfhfssj
             最小负荷发生时间  //zxfhfssj
             最大需量发生时间  //zdxlfssj
             安全运行时间     //aqrxsj
             总功率平均       //pj
             */
            
            double dataBase[18] = {0.9,300,100,150,250,500,60,70,90,400,100,600,90,0.75,24*60*60,24*60*60,24*60*60,500};
            int siz=sizeof(dataBase)/sizeof(double);
            
            //生成30天随机数据
            
            for(int i=0;i<30;i++){
//                if(i<6){
//                    [array addObject:[NSNull null]];
//                    continue;
//                }
                
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                double randData[siz];
                generateRandData(dataBase, siz, randData);
                
                [map setObject:[NSNumber numberWithDouble:randData[0]] forKey:@"dl"];
                [map setObject:[NSNumber numberWithDouble:randData[1]] forKey:@"high"];
                [map setObject:[NSNumber numberWithDouble:randData[2]] forKey:@"low"];
                [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"open"];
                [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"close"];
                [map setObject:[NSNumber numberWithDouble:2000] forKey:@"ed"];
                [map setObject:[NSNumber numberWithDouble:randData[6]] forKey:@"ax"];
                [map setObject:[NSNumber numberWithDouble:randData[7]] forKey:@"bx"];
                [map setObject:[NSNumber numberWithDouble:randData[8]] forKey:@"cx"];
                [map setObject:[NSNumber numberWithDouble:randData[9]] forKey:@"zdfh"];
                [map setObject:[NSNumber numberWithDouble:randData[10]] forKey:@"zxfh"];
                [map setObject:[NSNumber numberWithDouble:randData[11]] forKey:@"zdxl"];
                [map setObject:[NSNumber numberWithDouble:randData[12]] forKey:@"ygsh"];
                [map setObject:[NSNumber numberWithDouble:randData[13]] forKey:@"glys"];
                [map setObject:[NSNumber numberWithDouble:randData[14]] forKey:@"zdfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[15]] forKey:@"zxfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[16]] forKey:@"zdxlfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[17]] forKey:@"aqrxsj"];
                [map setObject:[NSNumber numberWithDouble:(abs(randData[3]-randData[4])/2+MIN(randData[3],randData[4]))] forKey:@"pj"];
                int r = (arc4random() % 100);
                if(r%2==0){
                    [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"open"];
                    [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"close"];
                }
                
                if(r%2==1){
                    [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"open"];
                    [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"close"];
                }
                
                [array addObject:map];
                
            }
            
            [retDict setObject:array forKey:@"array1"];
                        return retDict;
        }
            break;
            
            ////对于scatterline只需要 ax,bx,cx,pj 四个值
            
        case XLViewPlotDataSumAndTPPowerFactorScatter:
            //总/三相功率因素
        case XLViewPlotDataSumAndTPPowerFactor:
        {
            /*
             时间   //sj
             电量   //dl
             总功率因素最大  //high
             总功率因素最小  //low
             开始总功率因素  //open
             结束总功率因素  //close
             额定功率  //edgl
             A相功率因素  //ax
             B相功率因素  //bx
             C相功率因素  //cx
             最大负荷  //zdfh
             最小负荷  //zxfh
             最大需量  //zdxl
             有功损耗  //ygsh
             功率因素  //glys
             最大负荷发生时间  //zdfhfssj
             最小负荷发生时间  //zxfhfssj
             最大需量发生时间  //zdxlfssj
             安全运行时间     //aqrxsj
             总功率因素平均       //pj
             */
            
            double dataBase[18] = {10000000,0.9,0.3,0.8,0.6,500,0.8,0.9,0.75,400,100,600,90,0.75,24*60*60,24*60*60,24*60*60,500};
            int siz=sizeof(dataBase)/sizeof(double);
            
            //生成30天随机数据
            
            for(int i=0;i<30;i++){
                
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                double randData[siz];
                generateRandData(dataBase, siz, randData);
                
                [map setObject:[NSNumber numberWithDouble:randData[0]] forKey:@"dl"];
                [map setObject:[NSNumber numberWithDouble:randData[1]] forKey:@"high"];
                [map setObject:[NSNumber numberWithDouble:randData[2]] forKey:@"low"];
                [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"open"];
                [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"close"];
                [map setObject:[NSNumber numberWithDouble:500] forKey:@"ed"];
                [map setObject:[NSNumber numberWithDouble:randData[6]] forKey:@"ax"];
                [map setObject:[NSNumber numberWithDouble:randData[7]] forKey:@"bx"];
                [map setObject:[NSNumber numberWithDouble:randData[8]] forKey:@"cx"];
                [map setObject:[NSNumber numberWithDouble:randData[9]] forKey:@"zdfh"];
                [map setObject:[NSNumber numberWithDouble:randData[10]] forKey:@"zxfh"];
                [map setObject:[NSNumber numberWithDouble:randData[11]] forKey:@"zdxl"];
                [map setObject:[NSNumber numberWithDouble:randData[12]] forKey:@"ygsh"];
                [map setObject:[NSNumber numberWithDouble:randData[13]] forKey:@"glys"];
                [map setObject:[NSNumber numberWithDouble:randData[14]] forKey:@"zdfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[15]] forKey:@"zxfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[16]] forKey:@"zdxlfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[17]] forKey:@"aqrxsj"];
                [map setObject:[NSNumber numberWithDouble:(abs(randData[3]-randData[4])/2+MIN(randData[3],randData[4]))] forKey:@"pj"];
                int r = (arc4random() % 100);
                if(r%2==0){
                    [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"open"];
                    [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"close"];
                }
                
                if(r%2==1){
                    [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"open"];
                    [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"close"];
                }
                
                [array addObject:map];
                
            }
            
            
            [retDict setObject:array forKey:@"array1"];
            return retDict;
        }
            break;
            
            //总/三相平均无功功率
        case XLViewPlotDataSumAndTPReactivePower:
            
        {
            /*
             时间   //sj
             电量   //dl
             总功率最大  //zglzd
             总功率最小  //zglzx
             开始总功率  //kszgl
             结束总功率  //jszgl
             额定功率  //edgl
             A相功率  //axgl
             B相功率  //bxgl
             C相功率  //cxgl
             最大负荷  //zdfh
             最小负荷  //zxfh
             最大需量  //zdxl
             有功损耗  //ygsh
             功率因素  //glys
             最大负荷发生时间  //zdfhfssj
             最小负荷发生时间  //zxfhfssj
             最大需量发生时间  //zdxlfssj
             安全运行时间     //aqrxsj
             总功率平均       //zglpj
             */
            
            double dataBase[18] = {0.9,300,100,150,250,500,60,70,90,400,100,600,90,0.75,24*60*60,24*60*60,24*60*60,500};
            int siz=sizeof(dataBase)/sizeof(double);
            
            //生成30天随机数据
            
            for(int i=0;i<30;i++){
                
//                if(i>24){
//                    [array addObject:[NSNull null]];
//                    continue;
//                }
                
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                double randData[siz];
                generateRandData(dataBase, siz, randData);
                
                [map setObject:[NSNumber numberWithDouble:randData[0]] forKey:@"dl"];
                [map setObject:[NSNumber numberWithDouble:randData[1]] forKey:@"high"];
                [map setObject:[NSNumber numberWithDouble:randData[2]] forKey:@"low"];
                [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"open"];
                [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"close"];
                [map setObject:[NSNumber numberWithDouble:500] forKey:@"ed"];
                [map setObject:[NSNumber numberWithDouble:randData[6]] forKey:@"ax"];
                [map setObject:[NSNumber numberWithDouble:randData[7]] forKey:@"bx"];
                [map setObject:[NSNumber numberWithDouble:randData[8]] forKey:@"cx"];
                [map setObject:[NSNumber numberWithDouble:randData[9]] forKey:@"zdfh"];
                [map setObject:[NSNumber numberWithDouble:randData[10]] forKey:@"zxfh"];
                [map setObject:[NSNumber numberWithDouble:randData[11]] forKey:@"zdxl"];
                [map setObject:[NSNumber numberWithDouble:randData[12]] forKey:@"ygsh"];
                [map setObject:[NSNumber numberWithDouble:randData[13]] forKey:@"glys"];
                [map setObject:[NSNumber numberWithDouble:randData[14]] forKey:@"zdfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[15]] forKey:@"zxfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[16]] forKey:@"zdxlfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[17]] forKey:@"aqrxsj"];
                [map setObject:[NSNumber numberWithDouble:(abs(randData[3]-randData[4])/2+MIN(randData[3],randData[4]))] forKey:@"pj"];
                int r = (arc4random() % 100);
                if(r%2==0){
                    [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"open"];
                    [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"close"];
                }
                
                if(r%2==1){
                    [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"open"];
                    [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"close"];
                }
                
                [array addObject:map];
                
            }
            
            [retDict setObject:array forKey:@"array1"];
            return retDict;
        }
            
            break;
            //三相电流  下面是三相电压ax2,bx2,cx2
        case XLViewPlotDataTPCurr:
        {
            /*
             时间   //sj
             电量   //dl
             
             额定功率  //edgl
             A相电流  //axgl   red
             B相电流  //bxgl   green
             C相电流  //cxgl   yellow
             最大负荷  //zdfh
             最小负荷  //zxfh
             最大需量  //zdxl
             有功损耗  //ygsh
             功率因素  //glys
             最大负荷发生时间  //zdfhfssj
             最小负荷发生时间  //zxfhfssj
             最大需量发生时间  //zdxlfssj
             安全运行时间     //aqrxsj
             
             合格上限电流      //hgsxdl
             合格下限电流      //hgxxdl
             */
            
            NSMutableArray* array2 = [[NSMutableArray alloc]init];
            double dataBase[16] = {1000,3,1,-2,500,100,600,90,0.75,24*60*60,24*60*60,24*60*60,500,240,230,220};
            int siz=sizeof(dataBase)/sizeof(double);
            
            //生成30天随机数据
            
            for(int i=0;i<30;i++){
                
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                
                NSMutableDictionary *map2 = [[NSMutableDictionary alloc]init];
                double randData[siz];
                generateRandData(dataBase, siz, randData);
                
                [map setObject:[NSNumber numberWithDouble:randData[0]] forKey:@"dl"];
                [map setObject:[NSNumber numberWithDouble:500] forKey:@"edgl"];
                [map setObject:[NSNumber numberWithDouble:randData[1]] forKey:@"ax"];
                [map setObject:[NSNumber numberWithDouble:randData[2]] forKey:@"bx"];
                [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"cx"];
                [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"zdfh"];
                [map setObject:[NSNumber numberWithDouble:randData[5]] forKey:@"zxfh"];
                [map setObject:[NSNumber numberWithDouble:randData[6]] forKey:@"zdxl"];
                [map setObject:[NSNumber numberWithDouble:randData[7]] forKey:@"ygsh"];
                [map setObject:[NSNumber numberWithDouble:randData[8]] forKey:@"glys"];
                [map setObject:[NSNumber numberWithDouble:randData[9]] forKey:@"zdfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[10]] forKey:@"zxfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[11]] forKey:@"zdxlfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[12]] forKey:@"aqrxsj"];
                [map setObject:[NSNumber numberWithDouble:2] forKey:@"hgsx"];
                [map setObject:[NSNumber numberWithDouble:3] forKey:@"hgxx"];
                [map setObject:[NSNumber numberWithDouble:4] forKey:@"hgssx"];
                [map setObject:[NSNumber numberWithDouble:5] forKey:@"hgxxx"];
                
                [map2 setObject:[NSNumber numberWithDouble:randData[13]] forKey:@"ax"];
                [map2 setObject:[NSNumber numberWithDouble:randData[14]] forKey:@"bx"];
                [map2 setObject:[NSNumber numberWithDouble:randData[15]] forKey:@"cx"];
                
                [array addObject:map];
                [array2 addObject:map2];
                
            }
            

            [retDict setObject:array2 forKey:@"array2"];
            [retDict setObject:array forKey:@"array1"];
            return retDict;
        }
            break;
            
            //三相电压  下面是三相电流ax2,bx2,cx2
        case XLViewPlotDataTPVolt:
        {
            /*
             时间   //sj
             电量   //dl
             额定功率  //edgl
             A相电压  //axgy
             B相电压  //bxgy
             C相电压  //cxgy
             最大负荷  //zdfh
             最小负荷  //zxfh
             最大需量  //zdxl
             有功损耗  //ygsh
             功率因素  //glys
             最大负荷发生时间  //zdfhfssj
             最小负荷发生时间  //zxfhfssj
             最大需量发生时间  //zdxlfssj
             安全运行时间     //aqrxsj
             
             合格上限电压      //hgsx
             合格下限电压      //hgxx
             */
            
            NSMutableArray* array2 = [[NSMutableArray alloc]init];
            double dataBase[16] = {1000,230,220,240,500,100,600,90,0.75,24*60*60,24*60*60,24*60*60,500,4,1,-5};
            int siz=sizeof(dataBase)/sizeof(double);
            
            //生成30天随机数据
            
            for(int i=0;i<30;i++){
                
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                
                NSMutableDictionary *map2 = [[NSMutableDictionary alloc]init];
                double randData[siz];
                generateRandData(dataBase, siz, randData);
                
                [map setObject:[NSNumber numberWithDouble:randData[0]] forKey:@"dl"];
                [map setObject:[NSNumber numberWithDouble:500] forKey:@"ed"];
                [map setObject:[NSNumber numberWithDouble:randData[1]] forKey:@"ax"];
                [map setObject:[NSNumber numberWithDouble:randData[2]] forKey:@"bx"];
                [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"cx"];
                [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"zdfh"];
                [map setObject:[NSNumber numberWithDouble:randData[5]] forKey:@"zxfh"];
                [map setObject:[NSNumber numberWithDouble:randData[6]] forKey:@"zdxl"];
                [map setObject:[NSNumber numberWithDouble:randData[7]] forKey:@"ygsh"];
                [map setObject:[NSNumber numberWithDouble:randData[8]] forKey:@"glys"];
                [map setObject:[NSNumber numberWithDouble:randData[9]] forKey:@"zdfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[10]] forKey:@"zxfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[11]] forKey:@"zdxlfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[12]] forKey:@"aqrxsj"];
                
                
                [map2 setObject:[NSNumber numberWithDouble:randData[13]] forKey:@"ax"];
                [map2 setObject:[NSNumber numberWithDouble:randData[14]] forKey:@"bx"];
                [map2 setObject:[NSNumber numberWithDouble:randData[15]] forKey:@"cx"];
                
                [map setObject:[NSNumber numberWithDouble:240] forKey:@"hgssx"];
                [map setObject:[NSNumber numberWithDouble:200] forKey:@"hgxxx"];
                [map setObject:[NSNumber numberWithDouble:230] forKey:@"hgsx"];
                [map setObject:[NSNumber numberWithDouble:210] forKey:@"hgxx"];
                
                
                
                [array addObject:map];
                
                [array2 addObject:map2];
                
            }
            
            [retDict setObject:array2 forKey:@"array2"];
            [retDict setObject:array forKey:@"array1"];
            return retDict;
        }
            break;
            
            
            
#if (0)
            
            
            
            //三相电压相位角
            //三相电流相位角
        case XLViewPlotDataTPVoltAngle:
        case XLViewPlotDataTPCurrAngle:
        {
            /*
             时间   //sj
             电量   //dl
             额定功率  //edgl
             A相位角  //axwj
             B相位角  //bxwj
             C相位角  //cxwj
             最大负荷  //zdfh
             最小负荷  //zxfh
             最大需量  //zdxl
             有功损耗  //ygsh
             功率因素  //glys
             最大负荷发生时间  //zdfhfssj
             最小负荷发生时间  //zxfhfssj
             最大需量发生时间  //zdxlfssj
             安全运行时间     //aqrxsj
             
             */
            
            double dataBase[12] = {1000,120,120,120,500,100,600,90,0.75,24*60*60,24*60*60,24*60*60,500};
            int siz=sizeof(dataBase)/sizeof(double);
            
            //生成30天随机数据
            
            for(int i=0;i<30;i++){
                
                NSMutableDictionary *map = [[NSMutableDictionary alloc]init];
                double randData[siz];
                generateRandData(dataBase, siz, randData);
                
                [map setObject:[NSNumber numberWithDouble:randData[0]] forKey:@"dl"];
                [map setObject:[NSNumber numberWithDouble:500] forKey:@"ed"];
                [map setObject:[NSNumber numberWithDouble:randData[1]] forKey:@"ax"];
                [map setObject:[NSNumber numberWithDouble:randData[2]] forKey:@"bx"];
                [map setObject:[NSNumber numberWithDouble:randData[3]] forKey:@"cx"];
                [map setObject:[NSNumber numberWithDouble:randData[4]] forKey:@"zdfh"];
                [map setObject:[NSNumber numberWithDouble:randData[5]] forKey:@"zxfh"];
                [map setObject:[NSNumber numberWithDouble:randData[6]] forKey:@"zdxl"];
                [map setObject:[NSNumber numberWithDouble:randData[7]] forKey:@"ygsh"];
                [map setObject:[NSNumber numberWithDouble:randData[8]] forKey:@"glys"];
                [map setObject:[NSNumber numberWithDouble:randData[9]] forKey:@"zdfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[10]] forKey:@"zxfhfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[11]] forKey:@"zdxlfssj"];
                [map setObject:[NSNumber numberWithDouble:randData[12]] forKey:@"aqrxsj"];
                
                
                [array addObject:map];
                
            }

            [retDict setObject:array forKey:@"array1"];
            return retDict;
        }
            break;
            
#endif
            
    }
    
    return nil;
    
}

#pragma mark 后台数据获取接口
// 首页曲线数据获取接口


-(void)requestPlotData:(NSDictionary *)msgDic{
    
    
    NSString* xlName = [msgDic objectForKey:@"xl-name"];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

//            NSMutableDictionary* dict = [self getCurrentPlotData:msgDic];
//            NSMutableDictionary* dict2 = [[NSMutableDictionary alloc]init];
//            int i=0;
//            while(i<20){
//                [dict2 setObject:[NSNumber numberWithFloat:i/19.] forKey:@"percent"];
//                [dict2 setObject:xlName forKey:@"xl-name"];
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:XLViewProgressPercent object:nil userInfo:dict2];
//                [NSThread sleepForTimeInterval:0.01];
//                i++;
//            }
//            [dict setObject:msgDic forKey:@"parameter"];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:dict];
    
    if([[msgDic valueForKey:@"plot-type"] integerValue] == XLViewPlotDataByName)//历史数据
//    if(0)//历史数据
    {
//        NSMutableDictionary* dict = [self getCurrentPlotData:msgDic];
//        NSMutableDictionary* dict2 = [[NSMutableDictionary alloc]init];
//        int i=0;
//        while(i<20){
//            [dict2 setObject:[NSNumber numberWithFloat:i/19.] forKey:@"percent"];
//            [dict2 setObject:xlName forKey:@"xl-name"];
//            
//            [[NSNotificationCenter defaultCenter] postNotificationName:XLViewProgressPercent object:nil userInfo:dict2];
//            [NSThread sleepForTimeInterval:0.01];
//            i++;
//        }
//        [dict setObject:msgDic forKey:@"parameter"];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:dict];
        
        XLHistoryDataPageBussiness *xlHistoryDataPageBussiness =[XLHistoryDataPageBussiness sharedXLHistoryDataPageBussiness];
        
        xlHistoryDataPageBussiness.refDate = [msgDic valueForKey:@"start-date"];
        xlHistoryDataPageBussiness.plotDataType = [[msgDic valueForKey:@"plot-type"] integerValue];
        xlHistoryDataPageBussiness.msgDic = msgDic;
        if([[msgDic valueForKey:@"plot-time-type"]  isEqual: @""] || nil == [msgDic valueForKey:@"plot-time-type"])
        {
            xlHistoryDataPageBussiness.plotTimeType = 0;
        }
        else
        {
            
            xlHistoryDataPageBussiness.plotTimeType = [[msgDic valueForKey:@"plot-time-type"] integerValue];
        }
        xlHistoryDataPageBussiness.xlName = [msgDic valueForKey:@"xl-name"];
        
        NSLog(@"调用requestData");
        [xlHistoryDataPageBussiness requestData];

    }
    else
    {
        
        XLMainPageBussiness *xlMainPageBussiness =[XLMainPageBussiness sharedXLMainPageBussiness];
//        if(!xlMainPageBussiness)
//        {
//            //            xlMainPageBussiness = [[XLMainPageBussiness alloc] init];
//            xlMainPageBussiness = [XLMainPageBussiness sharedXLMainPageBussiness];
//        }
        
        xlMainPageBussiness.refDate = [msgDic valueForKey:@"start-date"];
        xlMainPageBussiness.plotDataType = [[msgDic valueForKey:@"plot-type"] integerValue];
        xlMainPageBussiness.msgDic = msgDic;
        if(![[msgDic valueForKey:@"xl-name"] isEqualToString:@"plotdata-detail"])
        {
            if([[msgDic valueForKey:@"plot-time-type"]  isEqual: @""] || nil == [msgDic valueForKey:@"plot-time-type"])
            {
                xlMainPageBussiness.plotTimeType = 0;
            }
            else
            {
                
                xlMainPageBussiness.plotTimeType = [[msgDic valueForKey:@"plot-time-type"] integerValue];
            }
        }
        xlMainPageBussiness.xlName = [msgDic valueForKey:@"xl-name"];
        
        NSLog(@"调用requestData");
        [xlMainPageBussiness requestData];

    }
    
    
//    });
}

// 首页－>经济性-测量点列表

- (void)requestTestPointListForEconomic:(NSDictionary *)paramDict{

//    NSString *ulsNo = [paramDict objectForKey:@"ulsNo"];// 用户／线路／系统 识别号，
//    
//    
//    NSArray* result = [NSArray arrayWithObjects:
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"测量点1",@"tpName",@"1",@"tpNo",@"green",@"tpStatus", nil],
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"测量点2",@"tpName",@"2",@"tpNo",@"red",@"tpStatus", nil],
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"测量点3",@"tpName",@"3",@"tpNo",@"green",@"tpStatus", nil],
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"测量点4",@"tpName",@"4",@"tpNo",@"green",@"tpStatus", nil],
//                       nil];
//    
//    
//    
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   paramDict, @"parameter",
//                                   result, @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLEconomicDetailPageBussiness *xlEconomicDetailPageBussiness = [XLEconomicDetailPageBussiness sharedXLEconomicDetailPageBussiness];
    
    xlEconomicDetailPageBussiness.msgDic = paramDict;
    NSArray *result = [xlEconomicDetailPageBussiness AllMtrNoStatus];
    
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               paramDict, @"parameter",
                               result, @"result",
                               nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];

}

// 首页－>电能质量-测量点列表

- (void)requestTestPointListForEnergy:(NSDictionary *)paramDict{
    
//    NSString *ulsNo = [paramDict objectForKey:@"ulsNo"];// 用户／线路／系统 识别号，
//    
//    
//    NSArray* result = [NSArray arrayWithObjects:
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"测量点1",@"tpName",@"1",@"tpNo",@"green",@"tpStatus", nil],
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"测量点2",@"tpName",@"2",@"tpNo",@"red",@"tpStatus", nil],
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"测量点3",@"tpName",@"3",@"tpNo",@"green",@"tpStatus", nil],
//                       [NSDictionary dictionaryWithObjectsAndKeys:@"测量点4",@"tpName",@"4",@"tpNo",@"green",@"tpStatus", nil],
//                       nil];
//    
//    
//    
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   paramDict, @"parameter",
//                                   result, @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLEnergyDetailPageBussiness *xlEnergyDetailPageBussiness = [XLEnergyDetailPageBussiness sharedXLEnergyDetailPageBussiness];
    xlEnergyDetailPageBussiness.msgDic = paramDict;
    NSArray *result = [xlEnergyDetailPageBussiness AllMtrNoStatus];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               paramDict, @"parameter",
                               result, @"result",
                               nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];

    
}


// 首页－>电能质量->测量点－>详细数据获取接口

- (void)requestEnergyDetailData:(NSDictionary *)paramDict
{

//    NSDate *date = [paramDict objectForKey:@"time"];//查询时间
//
//
//
//    NSMutableArray* testArrayValue =
//            [NSMutableArray arrayWithObjects:
//
//                    @"220V",@"220V",@"220V",
//                    @"220V",@"220V",@"95%",
//                    @"220V",@"220V",@"100%",
//                    @"220V",@"220V",@"90%",
//
//                    @"0.65",
//                    @"30%",@"20%",@"80分钟",
//                    @"30%",@"20%",@"80分钟",
//
//                    [NSArray arrayWithObjects:
//                            //总谐波
//                                [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //2次谐波
//                            [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //3次谐波
//                            [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //4次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //5次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //6次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //7次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //8次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //9次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //10次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //11次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //12次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //12次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //14次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //15次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //16次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //17次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //18次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"90分钟",@"va",@"90分钟",@"vb",@"90分钟",@"vc",@"90分钟",@"ca",@"90分钟",@"cb",@"90分钟",@"cc",nil],
//                            //19次谐波
//                                    [NSDictionary dictionaryWithObjectsAndKeys:@"190分钟",@"va",@"190分钟",@"vb",@"190分钟",@"vc",@"190分钟",@"ca",@"190分钟",@"cb",@"190分钟",@"cc",nil],
//
//
//                    nil],nil
//            ];
//    NSDictionary* testDict = [NSMutableDictionary dictionaryWithObjects:testArrayValue forKeys:
//            [NSArray arrayWithObjects:
//                    //电压合格率
//                    @"dyhgl_ssz_a",@"dyhgl_ssz_b",@"dyhgl_ssz_c",
//                    @"dyhgl_hgsx_a",@"dyhgl_hgxx_a",@"dyhgl_hgl_a",
//                    @"dyhgl_hgsx_b",@"dyhgl_hgxx_b",@"dyhgl_hgl_b",
//                    @"dyhgl_hgsx_c",@"dyhgl_hgxx_c",@"dyhgl_hgl_c",
//                    //三相电流不平衡度越限
//                    @"dybph_ssz",
//                    @"dybph_r1",@"dybph_r2", @"dybph_r3",
//                    @"dybph_y1",@"dybph_y2", @"dybph_y3",
//                    //谐波越限
//                    @"xbyx",
//                    nil]
//    ];
//
//
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                paramDict, @"parameter",
//                testDict, @"result",
//                nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLEnergyDetailPageBussiness *xlEnergyDetailPageBussiness = [XLEnergyDetailPageBussiness sharedXLEnergyDetailPageBussiness];
    
    xlEnergyDetailPageBussiness.msgDic = paramDict;
    [xlEnergyDetailPageBussiness requestData];
}



// 首页－>经济性->测量点－>详细数据获取接口

- (void)requestEconomicDetialData:(NSDictionary *)paramDict
{
    
//    NSDate *date = [paramDict objectForKey:@"time"];//查询时间
//
//    
//    
//    NSMutableArray* testArrayValue =
//    [NSMutableArray arrayWithObjects:
//     
//     @"0.72",@"0.8",@"0.5",@"0.73",
//     @"80分钟",@"80分钟",@"80分钟",
//     @"80分钟",@"80分钟",@"80分钟",
//     
//     @"0.8",
//     @"30%",@"20%",@"80分钟",
//     @"30%",@"20%",@"80分钟",
//     
//     @"80%",@"80分钟",
//     
//     @"误差正常",
//     
//     @"误差正常",
//     @"3000kWh",@"2900kWh",@"300kWh",@"200kWh",
//     
//     nil];
//    NSDictionary* testDict = [NSMutableDictionary dictionaryWithObjects:testArrayValue forKeys:
//                              [NSArray arrayWithObjects:
//                               //功率因素
//                               @"glys_ssz_z",@"glys_ssz_a",@"glys_ssz_b",@"glys_ssz_c",
//                               @"rljsj_1",@"rljsj_2",@"rljsj_3",
//                               @"yljsj_1",@"yljsj_2",@"yljsj_3",
//                               //三相电流不平衡度越限
//                               @"dlbph_ssz",
//                               @"dlbph_r1",@"dlbph_r2", @"dlbph_r3",
//                               @"dlbph_y1",@"dlbph_y2", @"dlbph_y3",
//                               //日负载率
//                               @"rfzl_pj",@"rfzl_sj",
//                               //防窃电
//                               @"fqd",
//                               //电量／功率误差情况
//                               @"wcjg",
//                               @"jxygdl",@"cxygdl",@"jxwgdl",@"cxwgdl",
//                               nil]
//                              ];
//    
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   paramDict, @"parameter",
//                                   testDict, @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    
    XLEconomicDetailPageBussiness *xlEconomicDetailPageBussiness = [XLEconomicDetailPageBussiness sharedXLEconomicDetailPageBussiness];
    xlEconomicDetailPageBussiness.msgDic = paramDict;
    
    [xlEconomicDetailPageBussiness requestData];
}


// 请求设备账号列表

- (void)requestDeviceAccountList:(NSDictionary *)paramDict
{
    
    
    NSString *devId =[paramDict objectForKey:@"device-id"]; //请求的设备编号
    

    NSDictionary* testAccountList = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [NSArray arrayWithObjects:
                                      [NSDictionary dictionaryWithObjectsAndKeys:@"用户1",@"name"/*姓名*/,@"YES",@"query"/*查询权限*/,@"YES",@"setup"/*参数设置权限*/,@"YES",@"operation"/*控制权限*/, nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:@"用户2",@"name"/*姓名*/,@"YES",@"query"/*查询权限*/,@"NO",@"setup"/*参数设置权限*/,@"YES",@"operation"/*控制权限*/, nil],
                                      [NSDictionary dictionaryWithObjectsAndKeys:@"用户3",@"name"/*姓名*/,@"YES",@"query"/*查询权限*/,@"NO",@"setup"/*参数设置权限*/,@"NO",@"operation"/*控制权限*/, nil],
                                      nil],
                                     @"account-list", nil];
    
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   paramDict, @"parameter",
                                   testAccountList, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}



- (NSArray *)queryDevicesInMap {
    return arrayDevice;
}


- (BOOL)connectToDevice
{
    [NSThread sleepForTimeInterval:2.0];
    return YES;
}

- (void)startSyncData
{
    [NSThread sleepForTimeInterval:20.0];
}

- (void)checkWifiConnect:(NSDictionary*)msgDic
{
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewWifiConnected object:nil userInfo:nil];
    });
}

- (BOOL)updateTerminalData:(NSDictionary*)msgDic
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableDictionary* dict2 = [[NSMutableDictionary alloc]init];
        int i=0;
        while(i<20){
            [dict2 setObject:[NSNumber numberWithFloat:i/19.] forKey:@"percent"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:XLViewUpdatePercent object:nil userInfo:dict2];
            [NSThread sleepForTimeInterval:1.01];
            i++;
        }
        
        
    });
    
    return YES;
}

@end

