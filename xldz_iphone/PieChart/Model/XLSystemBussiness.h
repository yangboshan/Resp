//
//  XLBussiness.h
//  XLApp
//
//  Created by JY on 14-3-6.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLExternals.h"
#import "XLCoreData.h"
#import "XLEntity.h"

@interface XLSystemBussiness : NSObject

+(XLSystemBussiness*)sharedXLSystemBussiness;

//新增系统
-(NSString*)addSystem:(SystemInfo*)system;

//删除系统
-(void)removeSystem:(SystemInfo*)system;

//编辑系统
-(void)editSystemfromOld:(SystemInfo*)old toNew:(SystemInfo*)news;

//从系统删除线路
-(void)removeLine:(LineInfo*)line fromSystem:(SystemInfo*)system;

//为系统添加线路
-(void)addLine:(LineInfo*)line forSystem:(SystemInfo*)system;

//获取系统线路列表
-(NSArray*)getlinelistForSystem:(SystemInfo*)system;

-(SystemInfo*)getCurrentSystem;

//---------------------------------------------------------------






//新增线路
-(NSString*)addLine:(LineInfo*)line;

//删除线路
-(void)removeLine:(LineInfo*)line;

//编辑线路
-(void)editLinefromOld:(LineInfo*)old toNew:(LineInfo*)news;

//从线路删除用户
-(void)removeUser:(UserInfo*)user fromLine:(LineInfo*)line;

//为线路添加用户
-(void)addUser:(UserInfo*)user forLine:(LineInfo*)line;

//获取线路用户列表
-(NSArray*)getUserlistForLine:(LineInfo*)line;

//---------------------------------------------------------------






//新增用户
-(void)addUser:(UserInfo*)user;

//删除用户
-(void)removeUser:(UserInfo*)user;

//编辑用户
-(void)editUserfromOld:(UserInfo*)old toNew:(UserInfo*)news;

//从用户删除测量点
-(void)removeMPoint:(MPointInfo*)mp fromUser:(UserInfo*)user;

//从用户删除设备
-(void)removeDevice:(DeviceInfo*)device fromUser:(UserInfo*)user;

//为用户添加测量点
-(void)addMPoint:(MPointInfo*)mp forUser:(UserInfo*)user;

//为用户添加设备
-(void)addDevice:(DeviceInfo*)device forUser:(UserInfo*)user;

//获取用户测量点列表
-(NSArray*)getMPointlistForUser:(UserInfo*)user;

//获取用户设备列表
-(NSArray*)getDevicelistForUser:(UserInfo*)user;

//---------------------------------------------------------------

//新增测量点
-(void)addMPoint:(MPointInfo *)mp;

//删除测量点
-(void)removeMPoint:(MPointInfo *)mp;

//编辑测量点
-(void)editMPointfromOld:(MPointInfo*)old toNew:(MPointInfo*)news;

//---------------------------------------------------------------

//新增设备
-(void)addDevice:(DeviceInfo *)device;

//删除设备
-(void)removeDevice:(DeviceInfo *)device;

//编辑设备
-(void)editDevicefromOld:(DeviceInfo*)old toNew:(DeviceInfo*)news;

//---------------------------------------------------------------

@end
