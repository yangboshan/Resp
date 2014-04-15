//
//  XLModelDataInterface.h
//  XLApp
//
//  Created by sureone on 2/18/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>

#define XLViewDataNotification @"XLViewDataNotification"
#define XLViewProgressPercent @"XLViewProgressPercent"
#define XLViewWifiConnected @"XLViewWifiConnected"
#define XLViewUpdatePercent @"XLViewUpdatePercent"
#define XLViewOperationDone @"XLViewOperationDone"

#define NotificationName(dic) [[dic objectForKey:@"parameter"] objectForKey:@"xl-name"]
#define NotificationResult(dic) [dic objectForKey:@"result"]

@protocol UIUpdateDelegate
-(void)showPercentProgress:(float)percent;
@end



@class XLViewDataUserBaiscInfo;

@interface XLViewDataSystem : NSObject

@property (nonatomic) NSString *systemId;
@property (nonatomic) NSString *systemName;
@property (nonatomic) NSString *systemInfo;

@end

@interface XLViewDataLine : NSObject

@property (nonatomic) NSString *lineId;
@property (nonatomic) NSString *lineName;
@property (nonatomic) XLViewDataSystem *system;
@property (nonatomic) NSString *lineNo;
@property (nonatomic) NSString *lineInfo;

@property (nonatomic) BOOL attention;
@property (nonatomic) BOOL isDefault;//默认线路不可删除

@end


@interface XLViewDataDCAnalog : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *antumStartValue;//量程起始值
@property (nonatomic) NSString *antumEndValue;//量程终止值
@property (nonatomic) NSString *maxValue;//上限
@property (nonatomic) NSString *minValue;//下限
@property (nonatomic) NSString *frozenDensity;//冻结密度

@end

@interface XLViewDataSwitchLoop : NSObject

@property (nonatomic) NSString *loopName;
//@property (nonatomic) NSString *ratedCurrent2;//二次额定电流
//@property (nonatomic) NSString *ratedVoltage2;//二次额定电压
//@property (nonatomic) NSString *ptRatio;//PT变比(一次额定)
//@property (nonatomic) NSString *ctRatio;//CT变比(一次额定)
//@property (nonatomic) NSString *zeroRatedCurrent;//零序额定电流
//@property (nonatomic) NSString *zeroCTRatio;//零序CT变比
//@property (nonatomic) NSString *connectType;//接线方式

//回路参数
@property (nonatomic) NSArray *loopParams;
//开关 － 保护参数
@property (nonatomic) NSArray *protectionParams;

@end

typedef NS_ENUM(NSUInteger, DeviceType) {
    DeviceTypeUndefined = 0,
    DeviceTypeFMR = 1,//变压器
    DeviceTypeSwitch = 2//开关
};
typedef NS_ENUM(NSUInteger, DeviceTransportType) {
    DeviceTransportTypeWiFi = 0,
    DeviceTransportTypeLAN = 1,
    DeviceTransportTypeLAN2 = 2,
    DeviceTransportTypeGPRS = 3,
    DeviceTransportTypeNone = 4
};
typedef NS_ENUM(NSUInteger, DeviceEventLevel) {
    DeviceEventLevelNormal = 0,
    DeviceEventLevelImportant = 1
};

@interface XLViewDataDevice : NSObject
@property (nonatomic) NSString *deviceId;
@property (nonatomic) NSString *deviceName;//名称

@property (nonatomic) XLViewDataUserBaiscInfo *user;
@property (nonatomic) BOOL online;
@property (nonatomic) DeviceType deviceType;

@property (nonatomic) NSArray *dcAnalogs;
@property (nonatomic) NSArray *switchLoops;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

//基本参数
@property (nonatomic) NSArray *basicParams;
//通信参数
@property (nonatomic) DeviceTransportType transportType;
@property (nonatomic) NSMutableArray *transportParams;
//事件参数
@property (nonatomic) NSArray *eventParams;
//开关 － 系统参数
@property (nonatomic) NSArray *systemParams;
//开关 － 遥测参数
@property (nonatomic) NSArray *telemetryParams;
//开关 － 遥信参数
@property (nonatomic) NSArray *remoteSignallingParams;
//开关 － 遥控参数
@property (nonatomic) NSArray *remoteControlParams;

////基本参数
//@property (nonatomic, readonly) NSString *userName;//所属用户
//@property (nonatomic, readonly) NSString *lineName;//所属线路
//@property (nonatomic, readonly) NSString *businessName;//所属行业
//@property (nonatomic) NSString *location;//地理位置
//@property (nonatomic) NSString *deviceNo;//设备编号
////@property (nonatomic) NSString *deviceType;//设备类型
//@property (nonatomic) NSString *manufactureDate;//制造日期
//@property (nonatomic) NSString *retedVoltage;//额定电压
//@property (nonatomic) NSString *retedCurrent;//额定电流
//@property (nonatomic) NSString *areaCode;//行政区划码
//@property (nonatomic) NSString *terminalAddress;//终端地址
//@property (nonatomic) NSString *hostFlag;//主站地址和组地址标志
//@property (nonatomic) NSString *hostInputParam;//终端状态量输入参数
//@property (nonatomic) NSString *retedLoad;//额定负荷
//@property (nonatomic) NSString *retedFreq;//额定频率
//@property (nonatomic) NSString *groupType;//连接组别
//@property (nonatomic) NSString *phaseNum;//相数
//@property (nonatomic) NSString *insulationLevel;//绝缘耐热等级
//@property (nonatomic) NSString *deltaTemperature;//温升
//@property (nonatomic) NSString *coolingType;//冷却方式
//@property (nonatomic) NSString *insulationHoriz;//绝缘水平
//
////通信参数 － WiFi
//@property (nonatomic) NSString *wifiSSID;//SSID
//@property (nonatomic) NSString *wifiPort;//端口号
//@property (nonatomic) NSString *wifiPwd;//密码
//
////通信参数 － 以太网
//@property (nonatomic) NSString *lanIP;//主站IP
//@property (nonatomic) NSString *lanPort;//端口号
//@property (nonatomic) NSString *lanDeviceIP;//设备IP
//@property (nonatomic) NSString *lanMask;//子网掩码
//@property (nonatomic) NSString *lanGateway;//网关
//
////通信参数 － GPRS
//@property (nonatomic) NSString *gprsIP;//主站IP
//@property (nonatomic) NSString *gprsPort;//端口号
//@property (nonatomic) NSString *gprsAPN;//APN
//@property (nonatomic) NSString *gprsThreshold;//月通信流量门限
//
////事件参数
//@property (nonatomic) DeviceEventLevel eventInit;//初始化／版本变更
//@property (nonatomic) DeviceEventLevel eventOverVoltage;//电压越限
//@property (nonatomic) DeviceEventLevel eventOverCurrent;//电流越限
//@property (nonatomic) DeviceEventLevel eventOverApparentPower;//视在功率越限
//@property (nonatomic) DeviceEventLevel eventOverUnbalance;//电压／电流不平衡度越限
//@property (nonatomic) DeviceEventLevel eventPhaseException;//相序异常
//@property (nonatomic) DeviceEventLevel eventParamChanged;//参数变更记录
//@property (nonatomic) DeviceEventLevel eventHarmonicOverLimit;//谐波越限告警
//@property (nonatomic) DeviceEventLevel eventParamLost;//参数丢失记录
//@property (nonatomic) DeviceEventLevel eventDataOverLimit;//通信流量超门限
//@property (nonatomic) DeviceEventLevel eventStatusChanged;//状态量变位

//实时数据／历史数据中需要显示的数值
@property (nonatomic) NSString *lifetime;//实时寿命
@property (nonatomic) NSString *terminalCalendar;//终端日历时钟
@property (nonatomic) NSString *terminalStatusParam;//终端参数状态
@property (nonatomic) NSString *terminalEventCounter;//终端事件计数器当前值
@property (nonatomic) NSString *terminalStatusFlag;//终端状态量变位标识


//查询、设置设备时间
- (NSDate *)queryDeviceTime;
- (void)setDeviceTime:(NSDate *)date;
//事件数据
- (void)queryEvents:(NSDictionary *)dic;
//控制操作
- (void)queryRemoteControls:(NSDictionary *)dic;
- (void)presetRemoteControls:(NSMutableDictionary *)control;
- (void)executeRemoteControls:(NSDictionary *)dic;
- (void)cancelRemoteControls:(NSDictionary *)dic;
//查询实时数据／历史数据需要显示的ONE_DATA、ONE_DATA_LIST数据
- (void)queryCatalogData:(NSDictionary *)dic;//变压器
- (void)queryCatalog2DataForCategroy:(NSDictionary *)dic;//开关
//查询终端参数状态
- (void)queryParamStatus:(NSDictionary *)dic;
//查询终端状态量变位标识
- (void)queryStatusFlag:(NSDictionary *)dic;
//查询开关主页需要的信息
- (void)querySwitchStatics:(NSDictionary *)dic;
@end


/*曲线数据集合*/
@interface XLViewDataPlotData : NSObject
/*总/三相平均有功功率*/
@property (nonatomic) NSMutableArray *arrayRealPowerData;
/*总/三相平均无功功 率*/
@property (nonatomic) NSMutableArray *arrayReactivePowerData;
@property (nonatomic) NSMutableArray *arrayPowerFactorData;
/*三相电压*/
@property (nonatomic) NSMutableArray *arrayVoltData;
/*三相电流*/
@property (nonatomic) NSMutableArray *arrayCurrData;
/*电压相位角*/
@property (nonatomic) NSMutableArray *arrayVoltAngleData;
/*电流相位角*/
@property (nonatomic) NSMutableArray *arrayCurrAngleData;
@end


/*
 测量点
 */
@interface XLViewDataTestPoint : NSObject
@property (nonatomic) NSString *pointId;
@property (nonatomic) NSString *pointName;//名称
@property (nonatomic) NSString *pointNo;//测量点号

@property (nonatomic) XLViewDataDevice *device;
@property (nonatomic) XLViewDataUserBaiscInfo *user;
@property (nonatomic) BOOL attention;

@property (nonatomic) BOOL online;

//基本参数
@property (nonatomic) NSArray *basicParams;
//通讯参数
@property (nonatomic) NSArray *transParams;
//变压器 － 越限参数
@property (nonatomic) NSArray *thresholdParams;

////基本参数
//@property (nonatomic) NSString *pointName;//名称
//@property (nonatomic) NSString *pointNo;//测量点号
//@property (nonatomic, readonly) NSString *deviceName;//所属设备
//@property (nonatomic, readonly) NSString *lineName;//所属线路
//@property (nonatomic) NSString *pt;//PT
//@property (nonatomic) NSString *ct;//CT
//@property (nonatomic) NSString *retedVoltage;//额定电压
//@property (nonatomic) NSString *retedCurrent;//额定电流
//@property (nonatomic) NSString *connectionType;//电源接线方式
//
////通讯参数
//@property (nonatomic) NSString *equipmentNo;//装置序号
//@property (nonatomic) NSString *pointNoTrans;//测量点号
//@property (nonatomic) NSString *trafficRate;//通信速率
//@property (nonatomic) NSString *port;//端口号
//@property (nonatomic) NSString *protocolType;//通信协议类型
//@property (nonatomic) NSString *transAddress;//通信地址
//@property (nonatomic) NSString *wasteRate;//费率数
//@property (nonatomic) NSString *decimalDigits;//示值小数位数
//@property (nonatomic) NSString *integerDigits;//示值整数位数
//
////越限参数
//@property (nonatomic) NSString *maxVoltage;//电压合格上限
//@property (nonatomic) NSString *minVoltage;//电压合格下限
//@property (nonatomic) NSString *overVoltage;//过压门限
//@property (nonatomic) NSString *overVoltageDuration;//过压持续时间
//@property (nonatomic) NSString *overVoltageRecovery;//过压恢复系数
//@property (nonatomic) NSString *underVoltage;//欠压门限
//@property (nonatomic) NSString *underVoltageDuration;//欠压持续时间
//@property (nonatomic) NSString *underVoltageRecovery;//欠压恢复系数
//@property (nonatomic) NSString *overCurrent;//相电流上限（过流）
//@property (nonatomic) NSString *overCurrentDuration;//过流持续时间
//@property (nonatomic) NSString *overCurrentRecovery;//过流恢复系数

//测试曲线数据
@property (nonatomic) XLViewDataPlotData *dataDay;
@property (nonatomic) XLViewDataPlotData *data1Min;
@property (nonatomic) XLViewDataPlotData *data5Min;

//实时参数
//@property (nonatomic) NSString *zyfl;//正有总费率电能示值
//@property (nonatomic) NSString *zyfl1;//正有费率1电能示值
//@property (nonatomic) NSString *zyfl2;//正有费率2电能示值
//@property (nonatomic) NSString *zyfl3;//正有费率3电能示值
//@property (nonatomic) NSString *zyfl4;//正有费率4电能示值
//
//@property (nonatomic) NSString *zwfl;//正无总费率电能示值
//@property (nonatomic) NSString *zwfl1;//正无费率1电能示值
//@property (nonatomic) NSString *zwfl2;//正无费率2电能示值
//@property (nonatomic) NSString *zwfl3;//正无费率3电能示值
//@property (nonatomic) NSString *zwfl4;//正无费率4电能示值
//
//@property (nonatomic) NSString *fyfl;//反有总费率电能示值
//@property (nonatomic) NSString *fyfl1;//反有费率1电能示值
//@property (nonatomic) NSString *fyfl2;//反有费率2电能示值
//@property (nonatomic) NSString *fyfl3;//反有费率3电能示值
//@property (nonatomic) NSString *fyfl4;//反有费率4电能示值
//
//@property (nonatomic) NSString *fwfl;//反无总费率电能示值
//@property (nonatomic) NSString *fwfl1;//反无费率1电能示值
//@property (nonatomic) NSString *fwfl2;//反无费率2电能示值
//@property (nonatomic) NSString *fwfl3;//反无费率3电能示值
//@property (nonatomic) NSString *fwfl4;//反无费率4电能示值
//
//@property (nonatomic) NSString *zyflxl;//正向有功总费率最大需量及发生时间
//@property (nonatomic) NSString *zyflxl1;//正向有功费率1最大需量及发生时间
//@property (nonatomic) NSString *zyflxl2;//正向有功费率2最大需量及发生时间
//@property (nonatomic) NSString *zyflxl3;//正向有功费率3最大需量及发生时间
//@property (nonatomic) NSString *zyflxl4;//正向有功费率4最大需量及发生时间
//
//@property (nonatomic) NSString *zwflxl;//正向无功总费率最大需量及发生时间
//@property (nonatomic) NSString *zwflxl1;//正向无功费率1最大需量及发生时间
//@property (nonatomic) NSString *zwflxl2;//正向无功费率2最大需量及发生时间
//@property (nonatomic) NSString *zwflxl3;//正向无功费率3最大需量及发生时间
//@property (nonatomic) NSString *zwflxl4;//正向无功费率4最大需量及发生时间
//
//@property (nonatomic) NSString *fyflxl;//反向有功总费率最大需量及发生时间
//@property (nonatomic) NSString *fyflxl1;//反向有功费率1最大需量及发生时间
//@property (nonatomic) NSString *fyflxl2;//反向有功费率2最大需量及发生时间
//@property (nonatomic) NSString *fyflxl3;//反向有功费率3最大需量及发生时间
//@property (nonatomic) NSString *fyflxl4;//反向有功费率4最大需量及发生时间
//
//@property (nonatomic) NSString *fwflxl;//反向无功总费率最大需量及发生时间
//@property (nonatomic) NSString *fwflxl1;//反向无功费率1最大需量及发生时间
//@property (nonatomic) NSString *fwflxl2;//反向无功费率2最大需量及发生时间
//@property (nonatomic) NSString *fwflxl3;//反向无功费率3最大需量及发生时间
//@property (nonatomic) NSString *fwflxl4;//反向无功费率4最大需量及发生时间

-(void)reloadTestData;

//查询实时数据／历史数据需要显示的ONE_DATA、ONE_DATA_LIST数据
- (void)queryCatalogData:(NSDictionary *)dic;
//查询2——19次谐波数据
- (void)query2_19ListData:(NSDictionary *)dic;

@end

/*
 用户总加组
 */
@interface XLViewDataUserSumGroup : XLViewDataTestPoint
@property (nonatomic) NSString *groupId;
@property (nonatomic) NSString *groupName;

@property (nonatomic) NSMutableArray *positiveTestPoints;
@property (nonatomic) NSMutableArray *negativeTestPoints;

@property (nonatomic) BOOL attention;
@property (nonatomic) BOOL isDefault;
@end

typedef enum _XLViewPlotType{
    PLOT_NONE,
    PLOT_DETAIL,   //从主页来的详细曲线数据
    ONE_DATA,
    ONE_DATA_LIST,//实时数据  A、B、C三相电压、电流2～19次谐波含有率	数值-可展开到子界面展示
    LIST_DATA,//历史数据  A/B/C相2～19次谐波电流最大值及发生时间
    DEVICE_PARAM_STATUS,//终端参数状态
    DEVICE_STATUS_FLAG,//终端状态量变位标识
    SWITCH_DATA,
    
    //曲线
    S_PLOT,
    //柱状
    B_PLOT,
    //k线
    K_PLOT,

    
}XLViewPlotType;


typedef struct{
    char* category;
    char* title;
    XLViewPlotType plot_type;
    char* valueProperty;
    char* keys[28];
}XL_VIEW_DATA_TYPE;




/*曲线数据枚举类型定义*/


typedef enum _XLViewPlotDataType {
    XLViewPlotDataTypeNoneForEdMenu,
    XLViewPlotDataSumAndTPRealPower,     //总/三相平均有功功率K线
    XLViewPlotDataSumAndTPReactivePower, //总/三相平均无功功率K线
    XLViewPlotDataSumAndTPPowerFactor,   //总/三相功率因素K线
    XLViewPlotDataTPVolt,                //三相电压
    XLViewPlotDataTPCurr,                //三相电流
    XLViewPlotDataTPVoltAngle,           //三相电压相位角
    XLViewPlotDataTPCurrAngle,           //三相电流相位角


    //实时数据子页面
    XLViewPlotDataZeroCurr, //零序电流
    XLViewPlotDataTPXieBoValue,  //A、B、C三相电压、电流2～N次谐波有效值
    XLViewPlotDataTPXieBoFactor, //A、B、C三相电压、电流2～N次谐波含有率
    XLVIewPlotDataTPXieBoMax,    //A/B/C相2～19次谐波电压含有率及总畸变率最大值及发生时间
    XLViewPlotDataVoltStat,         //电压统计数据
    XLViewPlotDataCurrStat,         //电流越限统计
    XLViewPlotDataCurrBalence,      //电压不平衡度极值及其发生时间
    XLViewPlotDataVoltBalence,      //电流不平衡度极值及其发生时间
    XLViewPlotDataConsume,             //电量
    XLViewPlotDataXuliang,             //需量
    XLViewPlotDataSumAndTPRealPowerScatter,     //总/三相平均有功功率曲线
    XLViewPlotDataSumAndTPReactivePowerScatter, //总/三相平均无功功率曲线
    XLViewPlotDataSumAndTPPowerFactorScatter, //总/三相功率因素曲线
    
    
    //历史数据
    
    XLViewPlotDataByName,
    

    
    


}XLViewPlotDataType;
typedef enum _XLViewPlotTimeType {
    XLViewPlotTimeNone,
    XLViewPlotTime1Min, //一分钟实时
    XLViewPlotTime5Min, //5分钟实时
    XLViewPlotTime15Min, //15分钟实时
    XLViewPlotTime30Min, //30分钟实时
    XLViewPlotTime60Min, //60分钟实时
    XLViewPlotTimeDay, //日历史
    XLViewPlotTimeWeek, //周历史
    XLViewPlotTimeMonth, //月历史
    XLViewPlotTimeYear, //年历史

}XLViewPlotTimeType;


/*  总/三相平均有功功率
    时间   //sj
    电量   //dl
    总功率 //zgl
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
 */

/*总/三相平均有功功率*/
@interface XLViewDataSumAndTPRealPower : NSObject

@property (nonatomic) double tmData;  //时间
@property (nonatomic) double consume; // 电量
@property (nonatomic) double totalPower; // 总功率
@property (nonatomic) double totalPowerMax; // 总功率最大
@property (nonatomic) double totalPowerMin; //  总功率最小
@property (nonatomic) double totalPowerStart; // 开始总功率
@property (nonatomic) double totalPowerEnd; //  结束总功率
@property (nonatomic) double totalPowerRated; //  额定功率
@property (nonatomic) double aPower; // A相功率
@property (nonatomic) double bPower; //  B相功率
@property (nonatomic) double cPower; //  C相功率
@property (nonatomic) double maxLoad; //  最大负荷
@property (nonatomic) double minLoad; //  最小负荷
@property (nonatomic) double maxConsume; // 最大需量
@property (nonatomic) double maxRealLost; // 有功损耗
@property (nonatomic) double powerFactor; // 功率因素
@property (nonatomic) double maxLoadTime; //最大负荷发生时间
@property (nonatomic) double minLoadTime; //最小负荷发生时间
@property (nonatomic) double maxConsumeTime; //最大需量发生时间
@property (nonatomic,retain) NSString *dataTime;
@property (nonatomic) double saftRuningTotal; //安全运行时间




@end


/*总/三相平均无功功 率*/
@interface XLViewDataSumAndTPReactivePower : NSObject

@property (nonatomic) NSInteger tmData;  //时间
@property (nonatomic) double consume; // 电量
@property (nonatomic) double totalPowerMax; // 总功率最大
@property (nonatomic) double totalPowerMin; //  总功率最小
@property (nonatomic) double totalPowerStart; // 开始总功率
@property (nonatomic) double totalPowerEnd; //  结束总功率
@property (nonatomic) double totalPowerRated; //  额定功率
@property (nonatomic) double aPower; // A相功率
@property (nonatomic) double bPower; //  B相功率
@property (nonatomic) double cPower; //  C相功率
@property (nonatomic) double maxLoad; //  最大负荷
@property (nonatomic) double minLoad; //  最小负荷
@property (nonatomic) double maxConsume; // 最大需量
@property (nonatomic) double maxRealLost; // 有功损耗
@property (nonatomic) double powerFactor; // 功率因素

@end


/*总/三相功率因素*/
@interface XLViewDataSumAndTPPowerFactor : NSObject
@property (nonatomic) NSInteger tmData;  //时间
@property (nonatomic) double consume; // 电量
@property (nonatomic) double totalPowerFactor; // 总功率因素
@property (nonatomic) double aPowerFactor; // A相功率因素
@property (nonatomic) double bPowerFactor; // B相功率因素
@property (nonatomic) double cPowerFactor; // C相功率因素
@end


/*
三相电压,
*/

@interface XLViewDataTPVolt : NSObject

@property (nonatomic) NSInteger tmData;  //时间
@property (nonatomic) double consume; // 电量
@property (nonatomic) double totalVolt; // 总电压
@property (nonatomic) double aVolt; // A相电压
@property (nonatomic) double bVolt; // B相电压
@property (nonatomic) double cVolt; // C相电压
@end


/*
三相电流
 */
@interface XLViewDataTPCurr : NSObject

@property (nonatomic) NSInteger tmData;  //时间
@property (nonatomic) double consume; // 电量
@property (nonatomic) double totalCurr; // 总电压
@property (nonatomic) double aCurr; // A相电流
@property (nonatomic) double bCurr; // B相电流
@property (nonatomic) double cCurr; // C相电流
@end

/*
电压相位角
*/

@interface XLViewDataTPVoltAngle : NSObject

@property (nonatomic) NSInteger tmData;  //时间
@property (nonatomic) double consume; // 电量
@property (nonatomic) double aAngle; // A相电压相位角
@property (nonatomic) double bAngle; // B相电压相位角
@property (nonatomic) double cAngle; // C相电压相位角
@end


/*
电流相位角
*/

@interface XLViewDataTPCurrAngle : NSObject

@property (nonatomic) NSInteger tmData;  //时间
@property (nonatomic) double consume; // 电量
@property (nonatomic) double aAngle; // A相电流相位角
@property (nonatomic) double bAngle; // B相电流相位角
@property (nonatomic) double cAngle; // C相电流相位角
@end



/*
 用户名称:新联电子
 联系电话:XXXXXXXXXXX
 所属线路:10KVXX 线
 合同容量:800kVA
 年产值 :1000 万
 负荷性质:1 类/2 类/3 类
 地 址:南京市江宁区家园中路28号
 联系人 :XXX
 计量方式:高供高计
 用电性质:普通工业
 所属行业:电子信息
 */

@interface XLViewDataUserBaiscInfo : NSObject {
}

@property(nonatomic) NSString *userId;  //用户名称
@property(nonatomic) NSString *userName; //用户名称
@property(nonatomic) NSString *capacity;  //合同容量
@property(nonatomic) NSString *contactNo;  //联系电话
@property(nonatomic) NSString *annualProduce; //年产值
@property(nonatomic) NSString *loadType;   //负荷性质
@property(nonatomic) NSString *address;   //地 址
@property(nonatomic) NSString *contactName; //联系人
@property(nonatomic) NSString *measureType;  //计量方式
@property(nonatomic) NSString *electType;   //用电性质
@property(nonatomic) NSString *businessType; //所属行业
//@property(nonatomic, readonly) NSString *lineName; //所属线路
@property (nonatomic) NSString *userInfo; //一般信息
@property (nonatomic) NSString *userNo;   //用户ID

@property (nonatomic) BOOL attention;
@property (nonatomic) BOOL online;

//@property (nonatomic) BOOL economic;//经济性
//@property (nonatomic) BOOL safty;//安全性   YES安全  NO不安全
//@property (nonatomic) BOOL energy;//电能质量

@property (nonatomic) XLViewDataLine *line;

//@property (nonatomic) NSMutableArray *devices;
//@property (nonatomic) NSMutableArray *testPoints;
@property (nonatomic) NSMutableArray *sumGroups;

@property (nonatomic) id currentTestPointOrGroup;
@property (nonatomic, readonly) XLViewDataUserSumGroup *defaultSumGroup;

- (void)addSumGroup:(XLViewDataUserSumGroup *)group;

- (void)queryStatistics:(NSDictionary *)dic;

@end



@interface XLModelDataInterface : NSObject{

}

@property (nonatomic) XLViewDataUserBaiscInfo *currentUser;
@property (nonatomic) XLViewDataLine *currentLine;
@property (nonatomic) XLViewDataSystem *currentSystem;

//获取单例
+(XLModelDataInterface*)testData;

//获取所有用户列表
- (NSArray *)getAllUserBasicInfo;
//获取用户基本情况接口
-(XLViewDataUserBaiscInfo*)getUserBasicInfo:(NSString*)userId;
//新建用户
- (void)createUserBasicInfo:(XLViewDataUserBaiscInfo *)user;
//删除用户
- (BOOL)deleteUserBasicInfo:(NSString*)userId;

//新建设备
- (void)createDevice:(XLViewDataDevice *)device;
//查询一个用户下的所有设备
- (NSArray *)queryDevicesForUser:(XLViewDataUserBaiscInfo *)user;
//删除设备
- (void)deleteDevices:(NSArray *)devices;

//查询设备下的测量点
- (NSArray *)queryTestPointsForDevice:(XLViewDataDevice *)device;
//查询用户下所有测量点
- (NSArray *)queryTestPointsForUser:(XLViewDataUserBaiscInfo *)user;
//查询用户关注的所有测量点
- (NSArray *)queryTestPointsWithAttentionForUser:(XLViewDataUserBaiscInfo *)user;
//新建测量点
- (void)createTestPoint:(XLViewDataTestPoint *)point;
//删除测量点
- (void)deleteTestPoints:(NSArray *)points;


- (NSArray *)queryAllSystems;
- (void)createSystem:(XLViewDataSystem *)system;
- (BOOL)deleteSystem:(NSString *)systemId;

- (NSArray *)queryAllLines;
- (NSArray *)queryLinesForSystem:(XLViewDataSystem *)system;
- (void)createLine:(XLViewDataLine *)line;
- (BOOL)deleteLine:(NSString*)lineId;

- (NSArray *)queryUserForLine:(XLViewDataLine *)line;

//获取地图上显示的设备
- (NSArray *)queryDevicesInMap;

//获取设备是否在线
- (BOOL)isDeviceOnline:(XLViewDataDevice *)device;

//查询所有事件数据
- (void)queryAllEvents:(NSDictionary *)dic;

//获取测量点曲线数据
-(XLViewDataPlotData*) getPlotData:(XLViewPlotTimeType)tmType    //数据周期类型
                         atUser:(NSString*)userId    //用户ID
                    atTestPoint:(NSString*)pointId;  //测量点ID

//获取经济性信息
-(NSArray *)getEconomicInfo;


#pragma mark 后台数据获取接口


-(void)requestPlotData:(NSDictionary *)msgDic;

//查看当前是否有智能设备的WiFi相连
- (void)checkWifiConnect:(NSDictionary*)msgDic;
//msgDis包含起始时间，结束时间
- (BOOL)updateTerminalData:(NSDictionary*)msgDic;

- (void)requestEconomicDetialData:(NSDictionary *)paramDict;
- (void)requestEnergyDetailData:(NSDictionary *)paramDict;
- (void)requestTestPointListForEnergy:(NSDictionary *)paramDict;
- (void)requestTestPointListForEconomic:(NSDictionary *)paramDict;
//请求设备用户列表
- (void)requestDeviceAccountList:(NSDictionary *)paramDict;

//- (BOOL)connectToDevice;
//- (void)startSyncData;
@end




XL_VIEW_DATA_TYPE* getTestPointDataDefines(BOOL realtime);
