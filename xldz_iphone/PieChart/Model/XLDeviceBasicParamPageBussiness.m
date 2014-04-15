//
//  XLDeviceBasicParamPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-3-27.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLDeviceBasicParamPageBussiness.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import "ParameterData_Terminal.h"

@interface XLDeviceBasicParamPageBussiness()

//请求报文Bytes
@property(nonatomic,assign) Byte* frame;

//请求报文Data
@property(nonatomic,strong) NSData *data;

//报文输出长度
@property(nonatomic,assign) XL_UINT16 outlen;

//notifyName
@property(nonatomic) NSString *notifyName;

//用于数据库操作的context属性
@property (nonatomic,strong) NSManagedObjectContext *context;


@end


@implementation XLDeviceBasicParamPageBussiness

SYNTHESIZE_SINGLETON_FOR_CLASS(XLDeviceBasicParamPageBussiness)

//初始化方法
-(id)init{
    if (self = [super init]) {
        
        self.context = [[XLCoreData sharedXLCoreData] managedObjectContext];
        
        self.notifyName = [NSString stringWithFormat:@"__%@__notify__%d",[self class],arc4random()];
        
        
        //注册消息通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponse:) name:self.notifyName object:nil];
    }
    return self;
}


//查询设备基本参数
-(void)requestData
{
    
    //将进度条设置为0
//    NSMutableDictionary* percentDict2 = [[NSMutableDictionary alloc]init];
//    [percentDict2 setObject:[NSString stringWithFormat:@"%f", 0.0] forKey:@"percent"];
//    [percentDict2 setObject:[self.msgDic valueForKey:@"xl-name"] forKey:@"xl-name"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewProgressPercent object:nil userInfo:percentDict2];
    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setValue:@"1A76" forKey:@"设备编号"];
//    [dic setValue:@"14年2月18日" forKey:@"制造日期"];
//    [dic setValue:@"220" forKey:@"额定电压"];
//    [dic setValue:@"5" forKey:@"额定电流"];
//    [dic setValue:@"160" forKey:@"额定负荷"];
//    [dic setValue:@"50" forKey:@"额定频率"];
//    [dic setValue:@"Y" forKey:@"连接组别"];
//    [dic setValue:@"1" forKey:@"相数"];
//    [dic setValue:@"A" forKey:@"绝热耐热等级"];
//    [dic setValue:@"A" forKey:@"绝缘水平"];
//    [dic setValue:@"油浸自冷(ONAN)" forKey:@"冷却方式"];
    
//    [self saveDataIntoDBWithEntity:dic];
    
    //调用查询参数组帧发送方法
    [self requestDeviceBasicParam];
    
    
}


//组帧发送方法
-(void)requestDeviceBasicParam
{
    //如果没连wifi，则直接返回空数据，发送通知
    if(![XLUtilities localWifiReachable])
    {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pmEpName = %@ and pmUserName = %@ and pmWireName =%@",self.deviceName,self.user.userName,self.user.line.lineName];
        NSArray *resultArray =[self readDataFromDBWithEntityName:@"ParameterData_Terminal" withPredicate:nil];
        
        NSMutableDictionary *dic = [NSMutableDictionary  dictionary];
        
        if([resultArray count]>0)//数据库查询到数据
        {
            
            
            ParameterData_Terminal *terminal = (ParameterData_Terminal *)[resultArray objectAtIndex:0];
            
            [dic setValue:[terminal valueForKey:@"pmEpNo"] forKey:@"设备编号"];
            [dic setValue:[terminal valueForKey:@"pmManufactureDate"] forKey:@"制造日期"];
            [dic setValue:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"pmRatedVoltage"] integerValue]] forKey:@"额定电压"];
            [dic setValue:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"pmRatedCurrent"] integerValue]] forKey:@"额定电流"];
            [dic setValue:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"pmRatedLoad"] integerValue]] forKey:@"额定负荷"];
            [dic setValue:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"pmRatedFrequency"] integerValue]] forKey:@"额定频率"];
            [dic setValue:[terminal valueForKey:@"pmConnGroups"] forKey:@"连接组别"];
            [dic setValue:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"pmPhaseNum"] integerValue]] forKey:@"相数"];
            [dic setValue:[terminal valueForKey:@"pmInsulationGrade"] forKey:@"绝热耐热等级"];
            [dic setValue:[terminal valueForKey:@"pmInsulationLevel"] forKey:@"绝缘水平"];
            [dic setValue:[terminal valueForKey:@"pmCoolingWay"] forKey:@"冷却方式"];
            [dic setValue:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"pmTemperatureRise"] floatValue]] forKey:@"温升"];
            
        }
        [self getF169Set:dic];
        
    }
    else
    {
        
        self.frame = PackFrameWithDadt(0x0A, 0, 169, &_outlen);
        
        self.data = [NSData dataWithBytes:self.frame length:self.outlen];
        NSLog(@"%@",[self.data description]);
        NSLog(@"发送报文为：%@",[self.data description]);
        free(self.frame);
        
//        [[XLSocketManager sharedXLSocketManager] packRequestFrame:self.data];
//        NSString *notifyName = [NSString stringWithFormat:@"__%@__notify__%d",[self class],arc4random()];
        
        [[XLSocketManager sharedXLSocketManager] packRequestFrameWithData:self.data withNotifyName:self.notifyName];
        
    }
}

//回调方法 handleResponse
-(void)handleResponse:(NSNotification*)notify
{
    NSLog(@"into handleResponse:");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"data"];
        
        NSDictionary* dcs = notify.userInfo;
        
        if ([dcs.allKeys containsObject:@"F169"]) {
            NSDictionary *dic = [dcs valueForKey:@"F169"];
            
            //显示给界面
            [self getF169Set:dic];
            //存库
            [self saveDataIntoDBWithEntity:dic];
            
        }
        
    });
}

//返回f169进行解析设置
-(void)getF169Set:(NSDictionary*)dic
{
    
    NSMutableDictionary *deviceType = [[NSMutableDictionary paramWithName:@"设备类型" value:(self.deviceType == DeviceTypeUndefined ? @"未定义" : (self.deviceType == DeviceTypeFMR ? @"智能变压器" : @"智能开关")) type:XLParamTypeString] uneditable];
    
    //字典写值
    NSArray *resultArray = [NSArray arrayWithObjects:
                    [NSMutableDictionary paramWithName:@"名称" value:self.deviceName type:XLParamTypeString],
                            
                    [[NSMutableDictionary paramWithName:@"所属用户" value:self.user.userName type:XLParamTypeString] uneditable],
                    [[NSMutableDictionary paramWithName:@"所属线路" value:self.user.line.lineName type:XLParamTypeString] uneditable],
                    [[NSMutableDictionary paramWithName:@"所属行业" value:self.user.businessType type:XLParamTypeString] uneditable],
                    [NSMutableDictionary paramWithName:@"地理位置" value:@"--" type:XLParamTypeString],
                    [NSMutableDictionary paramWithName:@"设备编号" value:[dic valueForKey:@"设备编号"] type:XLParamTypeString],
                    deviceType,
                                   [NSMutableDictionary paramWithName:@"制造日期" value:[dic valueForKey:@"制造日期"] type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"额定电压" value:[dic valueForKey:@"额定电压"]             type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"额定电流"   value:[dic valueForKey:@"额定电流"]           type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"行政区划码"  value:@"--"           type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"终端地址"    value:@"--"          type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"主站地址和组地址标志" value:@"--"   type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"终端状态量输入参数" value:@"--"     type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"额定负荷"   value:[dic valueForKey:@"额定容量"]           type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"额定频率"    value:[dic valueForKey:@"额定频率"]          type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"连接组别"     value:[dic valueForKey:@"连接组别"]         type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"相数"       value:[dic valueForKey:@"相数"]          type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"绝缘耐热等级"    value:[dic valueForKey:@"绝热耐热等级"]       type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"温升"     value:[dic valueForKey:@"温升"]            type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"冷却方式"   value:[dic valueForKey:@"冷却方式"]           type:XLParamTypeString],
                                   [NSMutableDictionary paramWithName:@"绝缘水平"   value:[dic valueForKey:@"绝缘水平"]           type:XLParamTypeString],
                                   nil];
    
    //发送字典
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                  self.msgDic, @"parameter",
                                                                  [resultArray paramsCopy], @"result",
                                                                  nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
    
    //发送进度条为100%
    NSMutableDictionary* percentDict2 = [[NSMutableDictionary alloc]init];
    [percentDict2 setObject:[NSString stringWithFormat:@"%f", 1.0] forKey:@"percent"];
    [percentDict2 setObject:[self.msgDic valueForKey:@"xl-name"] forKey:@"xl-name"];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewProgressPercent object:nil userInfo:percentDict2];
    
}

//保存数据到数据库
-(void)saveDataIntoDBWithEntity:(NSDictionary*)dic
{
    //存库之前先判断该设备是否已经存在于数据库中，查询条件为名称和所属用户与数据库中相同
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //声明实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ParameterData_Terminal"
                                              inManagedObjectContext:_context];
    
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    //设置检索条件
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pmEpName = %@ and pmUserName = %@ and pmWireName =%@",self.deviceName,self.user.userName,self.user.line.lineName];
    
    [fetchRequest setPredicate:nil];
    
    NSError *error;
    //返回检索结果
    NSArray *resultArray =[_context executeFetchRequest:fetchRequest error:&error];
    if([resultArray count]>0)
    {
        ParameterData_Terminal *updateTerminal = [resultArray objectAtIndex:0];
        
        [updateTerminal setValue:[dic valueForKey:@"设备编号"] forKey:@"pmEpNo"];
        [updateTerminal setValue:[dic valueForKey:@"连接组别"] forKey:@"pmConnGroups"];
        [updateTerminal setValue:[dic valueForKey:@"冷却方式"] forKey:@"pmCoolingWay"];
        [updateTerminal setValue:self.deviceName forKey:@"pmEpName"];
        [updateTerminal setValue:[dic valueForKey:@"绝热耐热等级"] forKey:@"pmInsulationGrade"];
        [updateTerminal setValue:[dic valueForKey:@"绝缘水平"] forKey:@"pmInsulationLevel"];
        [updateTerminal setValue:[dic valueForKey:@"制造日期"] forKey:@"pmManufactureDate"];
        [updateTerminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"相数"] integerValue]] forKey:@"pmPhaseNum"];
        [updateTerminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"额定电流"] integerValue]] forKey:@"pmRatedCurrent"];
        [updateTerminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"额定频率"] integerValue]] forKey:@"pmRatedFrequency"];
        [updateTerminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"额定负荷"] integerValue]] forKey:@"pmRatedLoad"];
        [updateTerminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"额定电压"] integerValue]] forKey:@"pmRatedVoltage"];
        [updateTerminal setValue:self.user.userName forKey:@"pmUserName"];
        [updateTerminal setValue:self.user.line.lineName forKey:@"pmWireName"];
        [updateTerminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"温升"] floatValue]] forKey:@"pmTemperatureRise"];
        
        [self.context save:nil];
    }
    else
    {
        NSEntityDescription *terminal =[NSEntityDescription insertNewObjectForEntityForName:@"ParameterData_Terminal"
                                                                     inManagedObjectContext:_context];
        
        [terminal setValue:[dic valueForKey:@"设备编号"] forKey:@"pmEpNo"];
        [terminal setValue:[dic valueForKey:@"连接组别"] forKey:@"pmConnGroups"];
        [terminal setValue:[dic valueForKey:@"冷却方式"] forKey:@"pmCoolingWay"];
        [terminal setValue:self.deviceName forKey:@"pmEpName"];
        [terminal setValue:[dic valueForKey:@"绝热耐热等级"] forKey:@"pmInsulationGrade"];
        [terminal setValue:[dic valueForKey:@"绝缘水平"] forKey:@"pmInsulationLevel"];
        [terminal setValue:[dic valueForKey:@"制造日期"] forKey:@"pmManufactureDate"];
        [terminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"相数"] integerValue]  ] forKey:@"pmPhaseNum"];
        [terminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"额定电流"] floatValue]  ] forKey:@"pmRatedCurrent"];
        [terminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"额定频率"] floatValue]  ] forKey:@"pmRatedFrequency"];
        [terminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"额定负荷"] floatValue]  ] forKey:@"pmRatedLoad"];
        [terminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"额定电压"] floatValue]  ] forKey:@"pmRatedVoltage"];
        [terminal setValue:self.user.userName forKey:@"pmUserName"];
        [terminal setValue:self.user.line.lineName forKey:@"pmWireName"];
        [terminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"温升"] floatValue]] forKey:@"pmTemperatureRise"];
        
        
        [self.context save:nil];
    }
}

//根据检索条件和表名进行数据检索
-(NSArray*)readDataFromDBWithEntityName:(NSString*)entityName withPredicate:(NSPredicate*)predicate
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //声明实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
                                              inManagedObjectContext:_context];
    //设置检索的实体类
    [fetchRequest setEntity:entity];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    //返回检索结果
    return (NSArray*)[_context executeFetchRequest:fetchRequest error:&error];
}

@end
