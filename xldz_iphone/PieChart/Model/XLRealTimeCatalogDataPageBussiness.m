//
//  XLRealTimeCatalogDataPageBussiness.m
//  XLApp
//
//  Created by xldz on 14-4-9.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLRealTimeCatalogDataPageBussiness.h"
#import "XLCoreData.h"
#import "XLSocketManager.h"
#import "XL3761PackFrame.h"
#import "XLDataItem.h"
#import "XLUtilities.h"
#import "RealTimeData_MeasurePoint.h"
#import "RealTimeData_Transformer.h"

@interface XLRealTimeCatalogDataPageBussiness()

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

//终端实时数据
@property(nonatomic) NSMutableDictionary *terminalDic;

//测量点实时数据
@property(nonatomic) NSMutableDictionary *pointDic;

@property(nonatomic) BOOL pointSecondFnInts;

@end

@implementation XLRealTimeCatalogDataPageBussiness


SYNTHESIZE_SINGLETON_FOR_CLASS(XLRealTimeCatalogDataPageBussiness)

//初始化方法
-(id)init{
    if (self = [super init]) {
        
        self.context = [[XLCoreData sharedXLCoreData] managedObjectContext];
        
        self.notifyName = [NSString stringWithFormat:@"__%@__notify__%d",[self class],arc4random()];
        
        self.terminalDic = [NSMutableDictionary dictionary];
        
        self.pointDic = [NSMutableDictionary dictionary];
        //注册消息通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleResponse:) name:self.notifyName object:nil];
        [self initResultArray];
        
    }
    return self;
}

//初始化要返回的数据数组
-(void)initResultArray
{
    self.terminalDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          @"", @"油温(℃)",
                          @"--", @"A相绕组温度(℃)",
                          @"--", @"B相绕组温度(℃)",
                          @"--", @"C相绕组温度(℃)",
                          @"--", @"油压",
                          @"--", @"油位",
                          @"", @"实时寿命",
                          @"", @"终端重要事件计数器当前值",
                          @"", @"终端一般事件计数器当前值",
                          nil];
    self.pointDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                     //电能量类数据
                     @"--", @"正有总电能示值",
                     @"--", @"正有费率1电能示值",
                     @"--", @"正有费率2电能示值",
                     @"--", @"正有费率3电能示值",
                     @"--", @"正有费率4电能示值",
                     @"--", @"正无总电能示值",
                     @"--", @"正无费率1电能示值",
                     @"--", @"正无费率2电能示值",
                     @"--", @"正无费率3电能示值",
                     @"--", @"正无费率4电能示值",
                     @"--", @"反有总电能示值",
                     @"--", @"反有费率1电能示值",
                     @"--", @"反有费率2电能示值",
                     @"--", @"反有费率3电能示值",
                     @"--", @"反有费率4电能示值",
                     @"--", @"反无总电能示值",
                     @"--", @"反无费率1电能示值",
                     @"--", @"反无费率2电能示值",
                     @"--", @"反无费率3电能示值",
                     @"--", @"反无费率4电能示值",
                     @"--", @"第一象限无功总电能示值",
                     @"--", @"第二象限无功总电能示值",
                     @"--", @"第三象限无功总电能示值",
                     @"--", @"第四象限无功总电能示值",
                     @"--", @"正向有功电能量",
                     @"--", @"正向无功电能量",
                     @"--", @"反向有功电能量",
                     @"--", @"反向无功电能量",
                     @"--", @"铜损有功总电能示值",
                     @"--", @"铁损有功总电能示值",
                     //需量类数据   总加组不用返回此类数据
                     @"32.7429\n04月09日14:55", @"当月正向有功总最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向有功费率1最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向有功费率2最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向有功费率3最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向有功费率4最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向无功总最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向无功费率1最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向无功费率2最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向无功费率3最大需量及发生时间",
                     @"32.7429\n04月09日14:55", @"当月正向无功费率4最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向有功总最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向有功费率1最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向有功费率2最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向有功费率3最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向有功费率4最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向无功总最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向无功费率1最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向无功费率2最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向无功费率3最大需量及发生时间",
                     @"32.6997\n04月09日14:53", @"当月反向无功费率4最大需量及发生时间",
                     //电压电流类数据   总加组不用返回此类数据
                     @"236.9", @"A相电压(V)",
                     @"235.5", @"B相电压(V)",
                     @"235.6", @"C相电压(V)",
                     @"2.560", @"A相电流(A)",
                     @"4.507", @"B相电流(A)",
                     @"8.2", @"C相电流(A)",
                     @"--", @"零序电流",
                     @"--", @"A相电压相位角(°)",
                     @"--", @"B相电压相位角(°)",
                     @"--", @"C相电压相位角(°)",
                     @"--", @"A相电流相位角(°)",
                     @"--", @"B相电流相位角(°)",
                     @"--", @"C相电流相位角(°)",
                     @"", @"A相电压、电流2～19次谐波有效值",
                     @"", @"B相电压、电流2～19次谐波有效值",
                     @"", @"C相电压、电流2～19次谐波有效值",
                     @"", @"A相电压、电流2～19次谐波含有率",
                     @"", @"B相电压、电流2～19次谐波含有率",
                     @"", @"C相电压、电流2～19次谐波含有率",
                     //功率类数据
                     @"3.2323", @"总有功功率",
                     @"0.4961", @"A相有功功率",
                     @"0.8412", @"B相有功功率",
                     @"1.8940", @"C相有功功率",
                     @"0.0664", @"总无功功率",
                     @"0.0259", @"A相无功功率",
                     @"0.1499", @"B相无功功率",
                     @"0.0564", @"C相无功功率",
                     @"3.2323", @"总视在功率",
                     @"0.4961", @"A相视在功率",
                     @"0.8535", @"B相视在功率",
                     @"1.8940", @"C相视在功率",
                     @"0.999", @"总功率因数",
                     @"0.999", @"A相功率因数",
                     @"0.986", @"B相功率因数",
                     @"0.999", @"C相功率因数",
                     nil];

}


-(void)requestData
{
    if(self.isPoint)//如果请求的是测量点的实时数据
    {
        [self requestPointData];
    }
    else//如果请求的是终端的实时数据
    {
        [self requestTerminalData];
    }
}

//获取测量点实时数据
-(void)requestTerminalData
{
    //F181,F182,F7
    if(![XLUtilities localWifiReachable])
    {
        NSArray *resultArray =[self readDataFromDBWithEntityName:@"RealTimeData_Transformer" withPredicate:nil];
        
        NSMutableDictionary *dic = [NSMutableDictionary  dictionary];
        
        if([resultArray count]>0)//数据库查询到数据
        {
            RealTimeData_Transformer *terminal = (RealTimeData_Transformer *)[resultArray objectAtIndex:0];
            
            //给self.terminalDic赋值
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtOilTemperature"] floatValue]] forKey:@"油温(℃)"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtAWindingTemperature"] floatValue]] forKey:@"A相绕组温度(℃)"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtBWindingTemperature"] floatValue]] forKey:@"B相绕组温度(℃)"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtCWindingTemperature"] floatValue]] forKey:@"C相绕组温度(℃)"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtRealLifetime"] floatValue]] forKey:@"实时寿命"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"rtImptEventCount"] integerValue]] forKey:@"终端重要事件计数器当前值"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"rtNormalEventCount"] integerValue]] forKey:@"终端一般事件计数器当前值"];
            
        }
        [self sendNotification];

    }
    else
    {
        int fnInts[] = {7,181,182};
        PACKITEM array[3];
        for(int i=0;i<3;i++)
        {
            PACKITEM item ;
            item.fn=fnInts[i];
            item.pn = 0;
            item.datalen = 0;
            array[i] = item;
        }
        self.frame = PackFrame(AFN0C, array, 3, &_outlen);
        
        self.data = [NSData dataWithBytes:self.frame length:self.outlen];
        NSLog(@"%@",[self.data description]);
        NSLog(@"发送报文为：%@",[self.data description]);
        free(self.frame);
        
        [[XLSocketManager sharedXLSocketManager] packRequestFrameWithData:self.data withNotifyName:self.notifyName];
    }
}

//获取终端实时数据
-(void)requestPointData
{
    //F181,F182,F7
    if(![XLUtilities localWifiReachable])
    {
        NSArray *resultArray =[self readDataFromDBWithEntityName:@"RealTimeData_MeasurePoint" withPredicate:nil];
        
        NSMutableDictionary *dic = [NSMutableDictionary  dictionary];
        
        if([resultArray count]>0)//数据库查询到数据
        {
            RealTimeData_Transformer *terminal = (RealTimeData_Transformer *)[resultArray objectAtIndex:0];
            
            //给self.terminalDic赋值
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtOilTemperature"] floatValue]] forKey:@"油温(℃)"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtAWindingTemperature"] floatValue]] forKey:@"A相绕组温度(℃)"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtBWindingTemperature"] floatValue]] forKey:@"B相绕组温度(℃)"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtCWindingTemperature"] floatValue]] forKey:@"C相绕组温度(℃)"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%.1f",[[terminal valueForKey:@"rtRealLifetime"] floatValue]] forKey:@"实时寿命"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"rtImptEventCount"] integerValue]] forKey:@"终端重要事件计数器当前值"];
            [self.terminalDic setObject:[NSString stringWithFormat:@"%d",[[terminal valueForKey:@"rtNormalEventCount"] integerValue]] forKey:@"终端一般事件计数器当前值"];
            
        }
        [self sendNotification];
        
    }
    else
    {
        int fnInts[] = {33,34,41,42,29};
//        int fnInts2[] = {29,35,36,25};
//        int fnInts[] = {29};
        PACKITEM array[5];
        for(int i=0;i<5;i++)
        {
            PACKITEM item ;
            item.fn = fnInts[i];
            item.pn = 0;
            item.datalen = 0;
            array[i] = item;
        }
        self.frame = PackFrame(AFN0C, array, 5, &_outlen);
        
        self.data = [NSData dataWithBytes:self.frame length:self.outlen];
        NSLog(@"%@",[self.data description]);
        NSLog(@"发送报文为：%@",[self.data description]);
        free(self.frame);
        
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
        
        //存库
        [self saveDataIntoDBWithDcs:dcs];
        
        if ([dcs.allKeys containsObject:@"F7"]) {
            NSDictionary *dic = [dcs valueForKey:@"F7"];
            
            //显示给界面
            [self getF7Set:dic];
            
        }
        
        if ([dcs.allKeys containsObject:@"F181"]) {
            NSDictionary *dic = [dcs valueForKey:@"F181"];
            
            //显示给界面
            [self getF181Set:dic];
            
        }
        
        if ([dcs.allKeys containsObject:@"F182"]) {
            NSDictionary *dic = [dcs valueForKey:@"F182"];
            
            //显示给界面
            [self getF182Set:dic];
            
        }
        
        if ([dcs.allKeys containsObject:@"F25"]) {
            NSDictionary *dic = [dcs valueForKey:@"F25"];
            
            //显示给界面
            [self getF25Set:dic];
            
        }
        
        
        [self sendNotification];
        
    });
}

-(void)getF7Set:(NSDictionary*)dic
{
    [self.terminalDic setObject:[dic valueForKey:@"当前重要事件计数器EC1值"] forKey:@"终端重要事件计数器当前值"];
    [self.terminalDic setObject:[dic valueForKey:@"当前一般事件计数器EC2值"] forKey:@"终端一般事件计数器当前值"];
}

-(void)getF181Set:(NSDictionary*)dic
{
    [self.terminalDic setObject:[dic valueForKey:@"油温"] forKey:@"油温(℃)"];
}

-(void)getF182Set:(NSDictionary*)dic
{
    [self.terminalDic setObject:[dic valueForKey:@"剩余寿命"] forKey:@"实时寿命"];
}

-(void)getF25Set:(NSDictionary*)dic
{
    
}

//发送Notification
-(void)sendNotification
{
    NSMutableDictionary *result;
    if(self.isPoint)
    {
        
        result = self.pointDic;
    }
    else
    {
        
        result = self.terminalDic;
    }
    
    
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                               self.msgDic, @"parameter",
                               result, @"result",
                               nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:XLViewDataNotification object:nil userInfo:userInfo];
}

//保存数据到数据库
-(void)saveDataIntoDBWithDcs:(NSDictionary*)dcs
{
    //存库之前先判断该设备是否已经存在于数据库中，查询条件为名称和所属用户与数据库中相同
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    //声明实体
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RealTimeData_Transformer"
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
        RealTimeData_Transformer *updateTerminal = [resultArray objectAtIndex:0];
        
        if([dcs.allKeys containsObject:@"F7"])
        {
            NSDictionary *dic = [dcs valueForKey:@"F7"];
            [updateTerminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"当前重要事件计数器EC1值"] integerValue]] forKey:@"rtImptEventCount"];
            [updateTerminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"当前一般事件计数器EC2值"] integerValue]] forKey:@"rtNormalEventCount"];
            
        }
        if([dcs.allKeys containsObject:@"F181"])
        {
            NSDictionary *dic = [dcs valueForKey:@"F181"];
            [updateTerminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"油温"] floatValue]] forKey:@"rtOilTemperature"];
            
        }
        if([dcs.allKeys containsObject:@"F182"])
        {
            NSDictionary *dic = [dcs valueForKey:@"F182"];
            
            [updateTerminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"剩余寿命"] floatValue]] forKey:@"rtRealLifetime"];
        }
        
        
        [self.context save:nil];
    }
    else
    {
        NSEntityDescription *terminal =[NSEntityDescription insertNewObjectForEntityForName:@"RealTimeData_Transformer" inManagedObjectContext:_context];
        
        if([dcs.allKeys containsObject:@"F7"])
        {
            NSDictionary *dic = [dcs valueForKey:@"F7"];
            [terminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"当前重要事件计数器EC1值"] integerValue]] forKey:@"rtImptEventCount"];
            [terminal setValue:[NSNumber numberWithInteger:[[dic valueForKey:@"当前一般事件计数器EC2值"] integerValue]] forKey:@"rtNormalEventCount"];
            
        }
        if([dcs.allKeys containsObject:@"F181"])
        {
            NSDictionary *dic = [dcs valueForKey:@"F181"];
            [terminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"油温"] floatValue]] forKey:@"rtOilTemperature"];
            
        }
        if([dcs.allKeys containsObject:@"F182"])
        {
            NSDictionary *dic = [dcs valueForKey:@"F182"];
            
            [terminal setValue:[NSNumber numberWithFloat:[[dic valueForKey:@"剩余寿命"] floatValue]] forKey:@"rtRealLifetime"];
        }
        
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
