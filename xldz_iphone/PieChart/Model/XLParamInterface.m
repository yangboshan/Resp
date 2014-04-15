//
//  XLParamInterface.m
//  XLApp
//
//  Created by ttonway on 14-3-7.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLParamInterface.h"

@implementation NSMutableDictionary (CommonParam)

- (NSString *)paramName
{
    id obj = [self objectForKey:@"paramName"];
    return obj == [NSNull null] ? nil : obj;
}

- (void)setParamName:(NSString *)paramName
{
    id obj = paramName == nil ? [NSNull null] : paramName;
    [self setObject:obj forKey:@"paramName"];
}

- (id)paramValue
{
    id obj = [self objectForKey:@"paramValue"];
    return obj == [NSNull null] ? nil : obj;
}

- (void)setParamValue:(id)paramValue
{
    id obj = paramValue == nil ? [NSNull null] : paramValue;
    [self setObject:obj forKey:@"paramValue"];
}

- (XLParamType)paramType
{
    return [[self objectForKey:@"paramType"] unsignedIntegerValue];
}

- (void)setParamType:(XLParamType)paramType
{
    [self setObject:[NSNumber numberWithUnsignedInteger:paramType] forKey:@"paramType"];
}

- (BOOL)editable
{
    return [[self objectForKey:@"editable"] boolValue];
}

- (void)setEditable:(BOOL)editable
{
    [self setObject:[NSNumber numberWithBool:editable] forKey:@"editable"];
}

- (NSArray *)listValues
{
    id obj = [self objectForKey:@"listValues"];
    return obj == [NSNull null] ? nil : obj;
}

- (void)setListValues:(NSArray *)listValues
{
    id obj = listValues == nil ? [NSNull null] : listValues;
    [self setObject:obj forKey:@"listValues"];
}

- (NSArray *)listNames
{
    id obj = [self objectForKey:@"listNames"];
    return obj == [NSNull null] ? nil : obj;
}

- (void)setListNames:(NSArray *)listNames
{
    id obj = listNames == nil ? [NSNull null] : listNames;
    [self setObject:obj forKey:@"listNames"];
}

+ (id)paramWithName:(NSString *)name value:(id)value
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic.paramName = name;
    dic.paramValue = value;
    return dic;
}

+ (id)paramWithName:(NSString *)name value:(id)value type:(XLParamType)type
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic.paramName = name;
    dic.paramValue = value;
    dic.paramType = type;
    dic.editable = YES;
    return dic;
}

+ (id)paramWithName:(NSString *)name type:(XLParamType)type
{
    return [self paramWithName:name value:nil type:type];
}

- (id)uneditable
{
    self.editable = NO;
    return self;
}

@end

@implementation NSArray (paramsCopy)
- (NSArray *)paramsCopy
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    for (NSMutableDictionary *param in self) {
        [array addObject:[param mutableCopy]];
    }
    return array;
}

- (NSMutableDictionary *)paramNamed:(NSString *)name
{
    for (NSMutableDictionary *param in self) {
        if ([param.paramName isEqualToString:name]) {
            return param;
        }
    }
    return nil;
}
@end


@implementation XLViewDataDevice (Param)

- (void)queryBasicParams:(NSDictionary *)dic
{
    switch (self.deviceType) {
    case DeviceTypeFMR:
        [self queryFMRBasicParams:dic];
        return;
    case DeviceTypeSwitch:
        [self querySwitchBasicParams:dic];
        return;
    default:
        return;
    }
}

- (NSArray *)queryFMRBasicParams:(NSDictionary *)dic
{
//    if (!self.basicParams) {
//        NSMutableDictionary *deviceType = [[NSMutableDictionary paramWithName:@"设备类型" value:(self.deviceType == DeviceTypeUndefined ? @"未定义" : (self.deviceType == DeviceTypeFMR ? @"智能变压器" : @"智能开关")) type:XLParamTypeString] uneditable];
//        
//        self.basicParams = [NSArray arrayWithObjects:
//                            [NSMutableDictionary paramWithName:@"名称" value:self.deviceName type:XLParamTypeString],
//                            [[NSMutableDictionary paramWithName:@"所属用户" value:self.user.userName type:XLParamTypeString] uneditable],
//                            [[NSMutableDictionary paramWithName:@"所属线路" value:self.user.line.lineName type:XLParamTypeString] uneditable],
//                            [[NSMutableDictionary paramWithName:@"所属行业" value:self.user.businessType type:XLParamTypeString] uneditable],
//                            [NSMutableDictionary paramWithName:@"地理位置"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"设备编号"              type:XLParamTypeString],
//                            deviceType,
//                            [NSMutableDictionary paramWithName:@"制造日期"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"额定电压"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"额定电流"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"行政区划码"             type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"终端地址"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"主站地址和组地址标志"    type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"终端状态量输入参数"      type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"额定负荷"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"额定频率"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"连接组别"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"相数"                 type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"绝缘耐热等级"           type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"温升"                 type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"冷却方式"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"绝缘水平"              type:XLParamTypeString],
//                            
//                            [NSMutableDictionary paramWithName:@"条形码"               type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"二维码"               type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"照片"               type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"摄像"               type:XLParamTypeString],
//                            nil];
//    }
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   [self.basicParams paramsCopy], @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLDeviceBasicParamPageBussiness *xlDeviceBasicParamPageBussiness = [XLDeviceBasicParamPageBussiness sharedXLDeviceBasicParamPageBussiness];
    
    xlDeviceBasicParamPageBussiness.user = self.user;
    xlDeviceBasicParamPageBussiness.deviceType = self.deviceType;
    xlDeviceBasicParamPageBussiness.deviceName = self.deviceName;
    xlDeviceBasicParamPageBussiness.msgDic = dic;
    [xlDeviceBasicParamPageBussiness requestData];
    
    return [self.basicParams paramsCopy];
}

- (NSArray *)querySwitchBasicParams:(NSDictionary *)dic
{
    if (!self.basicParams) {
        self.basicParams = [NSArray arrayWithObjects:
                            [NSMutableDictionary paramWithName:@"名称" value:self.deviceName type:XLParamTypeString],
                            [[NSMutableDictionary paramWithName:@"所属用户" value:self.user.userName type:XLParamTypeString] uneditable],
                            [[NSMutableDictionary paramWithName:@"所属线路" value:self.user.line.lineName type:XLParamTypeString] uneditable],
                            [[NSMutableDictionary paramWithName:@"所属行业" value:self.user.businessType type:XLParamTypeString] uneditable],
                            [NSMutableDictionary paramWithName:@"地理位置"              type:XLParamTypeString],
                            [NSMutableDictionary paramWithName:@"操作电源"              type:XLParamTypeString],
                            [NSMutableDictionary paramWithName:@"出厂编号"              type:XLParamTypeString],
                            [NSMutableDictionary paramWithName:@"制造日期"              type:XLParamTypeString],
                            [NSMutableDictionary paramWithName:@"额定电压"              type:XLParamTypeString],
                            [NSMutableDictionary paramWithName:@"额定电流"              type:XLParamTypeString],
                            nil];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   [self.basicParams paramsCopy], @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
    return [self.basicParams paramsCopy];
}

- (void)saveBasicParams:(NSArray *)params
{
    //TODO
    self.deviceName = [params paramNamed:@"名称"].paramValue;
    self.basicParams = params;
}

- (void)queryTransParams:(NSDictionary *)dic
{
    switch (self.deviceType) {
        case DeviceTypeFMR:
            [self queryFMRTransParams:dic];
            return;
        case DeviceTypeSwitch:
            [self querySwitchTransParams:dic];
            return;
        default:
            return;
    }
}

- (NSString *)currentTransportType
{
    switch (self.transportType) {
        case DeviceTransportTypeWiFi:
            return @"WiFi";
        case DeviceTransportTypeLAN:
            return self.deviceType == DeviceTypeFMR ? @"以太网" : @"主以太网";
        case DeviceTransportTypeLAN2:
            return @"备用以太网";
        case DeviceTransportTypeGPRS:
            return @"GPRS";
        case DeviceTransportTypeNone:
            return @"无";
    }
}

- (NSDictionary *)queryFMRTransParams:(NSDictionary *)dic
{
//    NSArray *wifi, *lan, *gprs;
//    if (self.transportParams) {
//        wifi = [self.transportParams objectAtIndex:DeviceTransportTypeWiFi];
//        lan = [self.transportParams objectAtIndex:DeviceTransportTypeLAN];
//        gprs = [self.transportParams objectAtIndex:DeviceTransportTypeGPRS];
//    } else {
//        wifi = [NSArray arrayWithObjects:
//                [NSMutableDictionary paramWithName:@"SSID" type:XLParamTypeString],
//                [NSMutableDictionary paramWithName:@"端口号" type:XLParamTypeString],
//                [NSMutableDictionary paramWithName:@"密码" type:XLParamTypeString],
//                nil];
//        lan = [NSArray arrayWithObjects:
//               [NSMutableDictionary paramWithName:@"主站IP" type:XLParamTypeString],
//               [NSMutableDictionary paramWithName:@"端口号" type:XLParamTypeString],
//               [NSMutableDictionary paramWithName:@"设备IP" type:XLParamTypeString],
//               [NSMutableDictionary paramWithName:@"子网掩码" type:XLParamTypeString],
//               [NSMutableDictionary paramWithName:@"网关" type:XLParamTypeString],
//               nil];
//        gprs = [NSArray arrayWithObjects:
//                [NSMutableDictionary paramWithName:@"主站IP" type:XLParamTypeString],
//                [NSMutableDictionary paramWithName:@"端口号" type:XLParamTypeString],
//                [NSMutableDictionary paramWithName:@"APN" type:XLParamTypeString],
//                [NSMutableDictionary paramWithName:@"月通信流量门限" type:XLParamTypeString],
//                nil];
//        self.transportParams =[NSMutableArray arrayWithObjects:wifi, lan, [NSNull null], gprs, nil];
//    }
//    
//    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   [self currentTransportType], @"SELECTED_GROUP",
//                                   @[@"WiFi", @"以太网", @"GPRS"], @"GROUPS",
//                                   [wifi paramsCopy], @"WiFi",
//                                   [lan paramsCopy], @"以太网",
//                                   [gprs paramsCopy], @"GPRS",
//                                   nil];
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   result, @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLDeviceTransParamPageBussiness *xlDeviceTransParamPageBussiness = [XLDeviceTransParamPageBussiness sharedXLDeviceTransParamPageBussiness];
    
    xlDeviceTransParamPageBussiness.deviceType = self.deviceType;
    xlDeviceTransParamPageBussiness.transportTypeString = [self currentTransportType];
    xlDeviceTransParamPageBussiness.transportType = self.transportType;
    xlDeviceTransParamPageBussiness.msgDic = dic;
    [xlDeviceTransParamPageBussiness requestData];
    

    return nil;
}

- (NSDictionary *)querySwitchTransParams:(NSDictionary *)dic
{
    NSArray *wifi, *lan, *lan2, *gprs;
    if (self.transportParams) {
        wifi = [self.transportParams objectAtIndex:DeviceTransportTypeWiFi];
        lan = [self.transportParams objectAtIndex:DeviceTransportTypeLAN];
        lan2 = [self.transportParams objectAtIndex:DeviceTransportTypeLAN2];
        gprs = [self.transportParams objectAtIndex:DeviceTransportTypeGPRS];
    } else {
        wifi = [NSArray arrayWithObjects:
                [NSMutableDictionary paramWithName:@"SSID" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"端口号" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"密码" type:XLParamTypeString],
                nil];
        lan = [NSArray arrayWithObjects:
               [NSMutableDictionary paramWithName:@"主站IP" type:XLParamTypeString],
               [NSMutableDictionary paramWithName:@"子网掩码" type:XLParamTypeString],
               [NSMutableDictionary paramWithName:@"网关" type:XLParamTypeString],
               nil];
        lan2 = [NSArray arrayWithObjects:
                [NSMutableDictionary paramWithName:@"主站IP" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"端口号" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"APN" type:XLParamTypeString],
                nil];
        gprs = [NSArray arrayWithObjects:
                [NSMutableDictionary paramWithName:@"公网IP" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"公网IP端口" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"APN设置" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"专网用户名" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"失败重拨间隔" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"月最大流量限制" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"无通信自动断线时间" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"最大重试次数" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"激活短信息内容" type:XLParamTypeString],
                [NSMutableDictionary paramWithName:@"专网密码" type:XLParamTypeString],
                nil];
        self.transportParams =[NSMutableArray arrayWithObjects:wifi, lan, lan2, gprs, nil];
    }
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self currentTransportType], @"SELECTED_GROUP",
                                   @[@"WiFi", @"主以太网", @"备用以太网", @"GPRS"], @"GROUPS",
                                   [wifi paramsCopy], @"WiFi",
                                   [lan paramsCopy], @"主以太网",
                                   [lan2 paramsCopy], @"备用以太网",
                                   [gprs paramsCopy], @"GPRS",
                                   nil];
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   result, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });

    return result;
}

- (void)saveTransportParams:(NSDictionary *)params selectedType:(NSString *)typeName
{
    [self.transportParams replaceObjectAtIndex:DeviceTransportTypeWiFi withObject:[params objectForKey:@"WiFi"]];
    [self.transportParams replaceObjectAtIndex:DeviceTransportTypeGPRS withObject:[params objectForKey:@"GPRS"]];
    
    NSUInteger index;
    NSArray *array;
    if (self.deviceType == DeviceTypeFMR) {
        [self.transportParams replaceObjectAtIndex:DeviceTransportTypeLAN withObject:[params objectForKey:@"以太网"]];
        array = @[@"WiFi", @"以太网", @"", @"GPRS"];
    } else {
        [self.transportParams replaceObjectAtIndex:DeviceTransportTypeLAN withObject:[params objectForKey:@"主以太网"]];
        [self.transportParams replaceObjectAtIndex:DeviceTransportTypeLAN2 withObject:[params objectForKey:@"备用以太网"]];
        array = @[@"WiFi", @"主以太网", @"备用以太网", @"GPRS"];
    }

    if (typeName) {
        index = [array indexOfObject:typeName];
    } else {
        index = NSNotFound;
    }
    if (index == NSNotFound){
        index = DeviceTransportTypeNone;
    }
    self.transportType = (DeviceTransportType)index;
}

- (void)queryDCAnalogs:(NSDictionary *)dic
{
    if (!self.dcAnalogs) {
        NSMutableArray *array = [NSMutableArray array];
        for (NSUInteger i = 1; i < 9; i++) {
            XLViewDataDCAnalog * dc = [[XLViewDataDCAnalog alloc] init];
            dc.name = [NSString stringWithFormat:@"%d路", i];
            [array addObject:dc];
        }
        self.dcAnalogs = array;
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   self.dcAnalogs, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
}

- (void)queryEventParams:(NSDictionary *)dic
{
//    if (!self.eventParams) {
//        self.eventParams = [NSArray arrayWithObjects:
//                            [NSMutableDictionary paramWithName:@"初始化／版本变更" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"电压越限" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"电流越限" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"视在功率越限" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"电压／电流不平衡度越限" value:[NSNumber numberWithUnsignedInteger:0]],
//                            [NSMutableDictionary paramWithName:@"相序异常" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"参数变更记录" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"谐波越限告警" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"参数丢失记录" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"通信流量超门限" value:[NSNumber numberWithUnsignedInteger:0]],
//                            [NSMutableDictionary paramWithName:@"状态量变位" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"直流模拟量越限" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            [NSMutableDictionary paramWithName:@"电能表超差" value:[NSNumber numberWithUnsignedInteger:DeviceEventLevelNormal]],
//                            nil];
//    }
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   [self.eventParams paramsCopy], @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLDeviceEventParamPageBussiness *xlDeviceEventParamPageBussiness = [XLDeviceEventParamPageBussiness sharedXLDeviceEventParamPageBussiness];
    xlDeviceEventParamPageBussiness.msgDic =dic;
    [xlDeviceEventParamPageBussiness requestData];
    
    //return [self.eventParams paramsCopy];
}

- (void)saveEventParams:(NSArray *)params
{
    self.eventParams = params;
}

- (void)queryProtectionParams:(NSDictionary *)dic
{
    NSAssert(self.deviceType == DeviceTypeSwitch, @"Only Switch have loops.");
    
    if (!self.switchLoops) {
        NSMutableArray *array = [NSMutableArray array];
        
        XLViewDataSwitchLoop *loop = [[XLViewDataSwitchLoop alloc] init];
        loop.loopName = @"第一回线";
        [array addObject:loop];
        
        loop = [[XLViewDataSwitchLoop alloc] init];
        loop.loopName = @"第二回线";
        [array addObject:loop];
        
        self.switchLoops = array;
    }
    
    for (XLViewDataSwitchLoop *loop in self.switchLoops) {
        [self queryProtectionParamsForLoop:loop];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   self.switchLoops, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
//    return array;
}

- (NSMutableDictionary *)protectParam1:(NSString *)name
{
    NSMutableDictionary *param = [NSMutableDictionary paramWithName:name type:XLParamTypeSpinner];
    param.paramValue = @"投入";
    param.listValues = [NSArray arrayWithObjects:@"投入", @"退出", nil];
    return param;
}

- (NSMutableDictionary *)protectParam2:(NSString *)name
{
    NSMutableDictionary *param = [NSMutableDictionary paramWithName:name type:XLParamTypeMulitValue];
    [param setObject:@"2.0" forKey:@"定值"];
    [param setObject:@"2.0" forKey:@"最大值"];
    [param setObject:@"2.0" forKey:@"最小值"];
    return param;
}

- (NSArray *)queryProtectionParamsForLoop:(XLViewDataSwitchLoop *)loop
{
    if (!loop.protectionParams) {
        loop.protectionParams = [NSArray arrayWithObjects:
                                 [self protectParam1:@"过流二段"],
                                 [self protectParam1:@"过流三段"],
                                 [self protectParam1:@"过负荷"],
                                 [self protectParam1:@"过压"],
                                 
                                 [self protectParam2:@"电流I段"],
                                 [self protectParam2:@"电流I段时间"],
                                 [self protectParam2:@"电流II段"],
                                 [self protectParam2:@"电流II段时间"],
                                 [self protectParam2:@"电流III段"],
                                 nil];
    }
    
    return loop.protectionParams;
}

- (void)saveProtectionParams:(NSArray *)params forLoop:(XLViewDataSwitchLoop *)loop
{
    loop.protectionParams = params;
}

- (void)queryLoopParams:(NSDictionary *)dic
{
    NSAssert(self.deviceType == DeviceTypeSwitch, @"Only Switch have loops.");
    
    if (!self.switchLoops) {
        NSMutableArray *array = [NSMutableArray array];
        
        XLViewDataSwitchLoop *loop = [[XLViewDataSwitchLoop alloc] init];
        loop.loopName = @"第一回线";
        [array addObject:loop];
        
        loop = [[XLViewDataSwitchLoop alloc] init];
        loop.loopName = @"第二回线";
        [array addObject:loop];
        
        self.switchLoops = array;
    }
    
    for (XLViewDataSwitchLoop *loop in self.switchLoops) {
        [self queryLoopParamsForLoop:loop];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   self.switchLoops, @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
    //    return array;
}

- (NSArray *)queryLoopParamsForLoop:(XLViewDataSwitchLoop *)loop
{
    if (!loop.loopParams) {
        NSMutableDictionary *p1 = [NSMutableDictionary paramWithName:@"二次额定电流" type:XLParamTypeSpinner];
        p1.paramValue = @"5A";
        p1.listValues = [NSArray arrayWithObjects:@"1A", @"5A", nil];
        
        NSMutableDictionary *p2 = [NSMutableDictionary paramWithName:@"二次额定电压" type:XLParamTypeSpinner];
        p2.paramValue = @"100V";
        p2.listValues = [NSArray arrayWithObjects:@"100V", @"220V", nil];
        
        NSMutableDictionary *p3 = [NSMutableDictionary paramWithName:@"零序额定电流" type:XLParamTypeSpinner];
        p3.paramValue = @"5A";
        p3.listValues = [NSArray arrayWithObjects:@"1A", @"5A", nil];
        
        NSMutableDictionary *p4 = [NSMutableDictionary paramWithName:@"接线方式" type:XLParamTypeSpinner];
        p4.paramValue = @"线电压";
        p4.listValues = [NSArray arrayWithObjects:@"线电压", @"相电压", nil];
        
        loop.loopParams = [NSArray arrayWithObjects:
                           p1,
                           p2,
                           [NSMutableDictionary paramWithName:@"PT变比(一次额定)"      type:XLParamTypeString],
                           [NSMutableDictionary paramWithName:@"CT变比(一次额定)"         type:XLParamTypeString],
                           p3,
                           [NSMutableDictionary paramWithName:@"零序CT变比"      type:XLParamTypeString],
                           p4,
                           nil];
    }
    
    return loop.loopParams;
}

- (void)saveLoopParams:(NSArray *)params forLoop:(XLViewDataSwitchLoop *)loop
{
    loop.loopParams = params;
}

- (void)querySystemParams:(NSDictionary *)dic
{
    if (!self.systemParams) {
        self.systemParams = [NSArray arrayWithObjects:
                             [NSMutableDictionary paramWithName:@"测量回线数量" type:XLParamTypeString],
                             [NSMutableDictionary paramWithName:@"模拟量数量" type:XLParamTypeString],
                             [NSMutableDictionary paramWithName:@"数字量输入数量" type:XLParamTypeString],
                             [NSMutableDictionary paramWithName:@"遥测数量" type:XLParamTypeString],
                             [NSMutableDictionary paramWithName:@"单点遥测数量" type:XLParamTypeString],
                             [NSMutableDictionary paramWithName:@"双点遥测数量" type:XLParamTypeString],
                             [NSMutableDictionary paramWithName:@"遥控数量" type:XLParamTypeString],
                             [NSMutableDictionary paramWithName:@"电度数量" type:XLParamTypeString],
                             nil];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   [self.systemParams paramsCopy], @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
//    return [self.systemParams paramsCopy];
}

- (void)saveSystemParams:(NSArray *)params
{
    self.systemParams = params;
}

- (NSMutableDictionary *)telemetryParam:(NSString *)name
{
    NSMutableDictionary *param = [NSMutableDictionary paramWithName:name type:XLParamTypeMulitValue];
    [param setObject:@"发送" forKey:@"发送标志"];
    [param setObject:@"不发送" forKey:@"主动发送标志"];
    [param setObject:@"1" forKey:@"系数"];
    [param setObject:@"1" forKey:@"满度值"];
    [param setObject:@"0" forKey:@"修正值"];
    [param setObject:@"是" forKey:@"生成曲线类型"];
    return param;
}

- (void)queryTelemetryParams:(NSDictionary *)dic
{
    if (!self.telemetryParams) {
        self.telemetryParams = [NSArray arrayWithObjects:
                                [self telemetryParam:@"Ua1"],
                                [self telemetryParam:@"Ub1"],
                                [self telemetryParam:@"Uc1"],
                                [self telemetryParam:@"3Uo1"],
                                [self telemetryParam:@"Ia1"],
                                [self telemetryParam:@"Ib1"],
                                [self telemetryParam:@"Ic1"],
                                [self telemetryParam:@"3Io1"],
                                [self telemetryParam:@"Pa1"],
                                [self telemetryParam:@"Pb1"],
                                [self telemetryParam:@"Pc1"],
                                [self telemetryParam:@"Qa1"],
                                [self telemetryParam:@"Qb1"],
                                [self telemetryParam:@"Qc1"],
                                [self telemetryParam:@"P1"],
                                [self telemetryParam:@"Q1"],
                                [self telemetryParam:@"S1"],
                                [self telemetryParam:@"cos¢1"],
                                [self telemetryParam:@"Ia2"],
                                [self telemetryParam:@"Ib2"],
                                nil];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   [self.telemetryParams paramsCopy], @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
//    return [self.telemetryParams paramsCopy];
}

- (void)saveTelemetryParams:(NSArray *)params
{
    self.telemetryParams = params;
}

- (NSMutableDictionary *)temoteSignallingParams:(NSString *)name
{
    NSMutableDictionary *param = [NSMutableDictionary paramWithName:name type:XLParamTypeMulitValue];
    [param setObject:@"是" forKey:@"取反标志"];
    [param setObject:@"发送" forKey:@"发送标志"];
    [param setObject:@"是" forKey:@"产生SOE标志"];
    return param;
}

- (void)queryRemoteSignallingParams:(NSDictionary *)dic
{
    if (!self.remoteSignallingParams) {
        self.remoteSignallingParams = [NSArray arrayWithObjects:
                                       [self temoteSignallingParams:@"门禁"],
                                       [self temoteSignallingParams:@"温度加热启动"],
                                       [self temoteSignallingParams:@"气压报警1"],
                                       [self temoteSignallingParams:@"气压报警2"],
                                       [self temoteSignallingParams:@"开关1"],
                                       [self temoteSignallingParams:@"隔离1"],
                                       [self temoteSignallingParams:@"地刀1"],
                                       [self temoteSignallingParams:@"远方1"],
                                       [self temoteSignallingParams:@"保护动作1"],
                                       [self temoteSignallingParams:@"备用"],
                                       nil];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   [self.remoteSignallingParams paramsCopy], @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
    //return [self.remoteSignallingParams paramsCopy];
}

- (void)saveRemoteSignallingParams:(NSArray *)params
{
    self.remoteSignallingParams = params;
}

- (void)queryRemoteControlParams:(NSDictionary *)dic
{
    if (!self.remoteControlParams) {
        self.remoteControlParams = [NSArray arrayWithObjects:
                                    [NSMutableDictionary paramWithName:@"YK2[13]" value:@"1" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"YK3[13]" value:@"2" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"YK4[13]" value:@"3" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"YK5[13]" value:@"4" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"电池活化" value:@"5" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"YK7[13]" value:@"6" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"保护总复归" value:@"7" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"保留" value:@"8" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"开关1保护复归[2-1]" value:@"9" type:XLParamTypeNumber],
                                    [NSMutableDictionary paramWithName:@"保留" value:@"10" type:XLParamTypeNumber],
                                    nil];
    }
    
    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   dic, @"parameter",
                                   [self.self.remoteControlParams paramsCopy], @"result",
                                   nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    });
//    return [self.remoteControlParams paramsCopy];
}

- (void)saveRemoteControlParams:(NSArray *)params
{
    self.remoteControlParams = params;
}

@end

@implementation XLViewDataTestPoint (Param)

- (void)queryBasicParams:(NSDictionary *)dic
{
//    if (!self.basicParams) {
//        self.basicParams = [NSArray arrayWithObjects:
//                            [NSMutableDictionary paramWithName:@"名称" value:self.pointName type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"测量点号" value:self.pointNo type:XLParamTypeString],
//                            [[NSMutableDictionary paramWithName:@"所属设备" value:self.device.deviceName type:XLParamTypeString] uneditable],
//                            [[NSMutableDictionary paramWithName:@"所属线路" value:self.user.line.lineName type:XLParamTypeString] uneditable],
//                            [NSMutableDictionary paramWithName:@"PT"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"CT"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"额定电压"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"额定电流"              type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"电源接线方式"              type:XLParamTypeString],
//                            nil];
//
//    }
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   [self.basicParams paramsCopy], @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    
    XLPointBasicParamPageBussiness *xlPointBasicParamPageBussiness = [XLPointBasicParamPageBussiness sharedXLPointBasicParamPageBussiness];
    
    xlPointBasicParamPageBussiness.msgDic = dic;
    xlPointBasicParamPageBussiness.device = self.device;
    xlPointBasicParamPageBussiness.pointId = self.pointId;
    xlPointBasicParamPageBussiness.pointName =self.pointName;
    xlPointBasicParamPageBussiness.pointNo = self.pointNo;
    xlPointBasicParamPageBussiness.user = self.user;
    [xlPointBasicParamPageBussiness requestData];
    
//    return [self.basicParams paramsCopy];
}

- (void)saveBasicParams:(NSArray *)params
{
    self.pointName = [params paramNamed:@"名称"].paramValue;
    self.pointNo = [params paramNamed:@"测量点号"].paramValue;
    self.basicParams = params;
}

- (void)queryTransParams:(NSDictionary *)dic
{
//    if (!self.transParams) {
//        self.transParams = [NSArray arrayWithObjects:
//                            [NSMutableDictionary paramWithName:@"装置序号"      type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"测量点号"      type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"通信速率"      type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"端口号"        type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"通信协议类型"   type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"通信地址"      type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"费率数"        type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"示值小数位数"   type:XLParamTypeString],
//                            [NSMutableDictionary paramWithName:@"示值整数位数"   type:XLParamTypeString],
//                            nil];
//
//    }
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   [self.transParams paramsCopy], @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    XLPointTransParamPageBussiness *xlPointTransParamPageBussiness = [XLPointTransParamPageBussiness sharedXLPointTransParamPageBussiness];
    xlPointTransParamPageBussiness.msgDic = dic;
    xlPointTransParamPageBussiness.pointNo = self.pointNo;
    xlPointTransParamPageBussiness.pointName = self.pointName;
    xlPointTransParamPageBussiness.pointId = self.pointId;
    [xlPointTransParamPageBussiness requestData];
    
    
//    return [self.transParams paramsCopy];
}

- (void)saveTransParams:(NSArray *)params
{
    self.transParams = params;
}

- (void)queryThresholdParams:(NSDictionary *)dic
{
//    if (!self.thresholdParams) {
//        self.thresholdParams = [NSArray arrayWithObjects:
//                                [NSMutableDictionary paramWithName:@"电压合格上限"      type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"电压合格下限"      type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"过压门限"         type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"过压持续时间"      type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"过压恢复系数"      type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"欠压门限"         type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"欠压持续时间"      type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"欠压恢复系数"      type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"相电流上上限（过流）" type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"过流持续时间"      type:XLParamTypeString],
//                                [NSMutableDictionary paramWithName:@"过流恢复系数"      type:XLParamTypeString],
//                                nil];
//    }
//    
//    dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
//    dispatch_after(after, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
//                                   dic, @"parameter",
//                                   [self.thresholdParams paramsCopy], @"result",
//                                   nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
//    });
    
    XLPointThresholdParamPageBussiness *xlPointThresholdParamPageBussiness = [XLPointThresholdParamPageBussiness sharedXLPointThresholdParamPageBussiness];
    
    xlPointThresholdParamPageBussiness.pointNo = self.pointNo;
    xlPointThresholdParamPageBussiness.pointName = self.pointName;
    xlPointThresholdParamPageBussiness.pointId = self.pointId;
    xlPointThresholdParamPageBussiness.msgDic = dic;
    [xlPointThresholdParamPageBussiness requestData];
    
    //return [self.thresholdParams paramsCopy];
}

- (void)saveThresholdParams:(NSArray *)params
{
    self.thresholdParams = params;
}

@end


@implementation XLParamInterface
@end
