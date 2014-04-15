//
//  XLBussiness.m
//  XLApp
//
//  Created by JY on 14-3-6.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLSystemBussiness.h"
#import <objc/message.h>

@interface XLSystemBussiness()


@property (nonatomic,strong) NSManagedObjectContext *contextParent;

@end

@implementation XLSystemBussiness

SYNTHESIZE_SINGLETON_FOR_CLASS(XLSystemBussiness)

-(id)init{
    
    if (self = [super init]) {
        self.contextParent = [[XLCoreData sharedXLCoreData] managedObjectContext];
    }
    return self;
}


-(NSString*)getCurrentDate{
    
    NSDate* date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

#pragma mark - 系统相关

//新增系统
-(NSString*)addSystem:(SystemInfo*)system{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    SystemInfo *systemInfo = [NSEntityDescription insertNewObjectForEntityForName:@"SystemInfo" inManagedObjectContext:context];
    
    NSString* sysId = [[NSUUID UUID] UUIDString];
    
    [systemInfo setValue:[system valueForKey:@"name"] forKey:@"name"];
    [systemInfo setValue:[system valueForKey:@"desc"] forKey:@"desc"];
    [systemInfo setValue:sysId forKey:@"id"];
    [systemInfo setValue:[self getCurrentDate] forKey:@"updateTime"];

    [context save:nil];
    
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
    return sysId;
}

//删除系统
-(void)removeSystem:(SystemInfo*)system{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    [context deleteObject:system];
    [context save:nil];
    
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//编辑系统
-(void)editSystemfromOld:(SystemInfo*)old toNew:(SystemInfo*)news{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([old class], &outCount);
    
    for(int i =0; i<outCount;i++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([name isEqualToString:@"id"]) {
            continue;
        }
        [old setValue:[news valueForKey:name] forKey:name];
    }
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//从系统删除线路
-(void)removeLine:(LineInfo*)line fromSystem:(SystemInfo*)system{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SystemLineRelation"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@ and childid = %@",
                              system.id,line.id];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *array = (NSMutableArray*)[context executeFetchRequest:fetchRequest error:&error];
    SystemLineRelation* sysline = (SystemLineRelation*)[array objectAtIndex:0];
    [context deleteObject:sysline];
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//为系统添加线路
-(void)addLine:(LineInfo*)line forSystem:(SystemInfo*)system{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    SystemLineRelation *sysline = [NSEntityDescription insertNewObjectForEntityForName:@"SystemLineRelation" inManagedObjectContext:context];
    
    [sysline setValue:system.id forKey:@"id"];
    [sysline setValue:line.id forKey:@"childid"];
    [sysline setValue:[self getCurrentDate] forKey:@"updateTime"];
    
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//获取系统线路列表
-(NSArray*)getlinelistForSystem:(SystemInfo*)system{
    
    NSMutableArray *linelist = [NSMutableArray array];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SystemLineRelation"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@",system.id];
    [fetchRequest setPredicate:predicate];

    NSError* error;
    NSArray *array = (NSMutableArray*)[context executeFetchRequest:fetchRequest error:&error];
    
    for(SystemLineRelation *sysline in array){
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineInfo"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        predicate = [NSPredicate predicateWithFormat:@"id = %@",sysline.childid];
        [fetchRequest setPredicate:predicate];
        
        NSError* error;
        array = (NSMutableArray*)[context executeFetchRequest:fetchRequest error:&error];
        [linelist addObject:[array objectAtIndex:0]];
    }
    
    return linelist;
}

-(SystemInfo*)getCurrentSystem{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SystemInfo" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSArray* temp = [context executeFetchRequest:fetchRequest error:nil];
    SystemInfo* sys = (SystemInfo*)[temp objectAtIndex:0];
    
    NSLog(@"%@",[sys valueForKey:@"id"]);
    return sys;
}





#pragma mark - 线路相关
//新增线路
-(NSString*)addLine:(LineInfo*)line{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    NSString* lineId = [[NSUUID UUID] UUIDString];
    
    LineInfo *lineInfo = [NSEntityDescription insertNewObjectForEntityForName:@"LineInfo" inManagedObjectContext:context];
    
    [lineInfo setValue:[line valueForKey:@"name"] forKey:@"name"];
    [lineInfo setValue:[line valueForKey:@"desc"] forKey:@"desc"];
    [lineInfo setValue:lineId forKey:@"id"];
    [lineInfo setValue:[self getCurrentDate] forKey:@"updateTime"];
    
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
    
    return lineId;
}

//删除线路
-(void)removeLine:(LineInfo*)line{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    [context deleteObject:line];
    [context save:nil];
    [self.contextParent save:nil];
}

//编辑线路
-(void)editLinefromOld:(LineInfo*)old toNew:(LineInfo*)news{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([old class], &outCount);
    
    for(int i =0; i<outCount;i++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([name isEqualToString:@"id"]) {
            continue;
        }
        [old setValue:[news valueForKey:name] forKey:name];
    }
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//从线路删除用户
-(void)removeUser:(UserInfo*)user fromLine:(LineInfo*)line{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineUserRelation"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@ and childid = %@",
                              line.id,user.id];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *array = (NSMutableArray*)[context executeFetchRequest:fetchRequest error:&error];
    LineUserRelation* lineUser = (LineUserRelation*)[array objectAtIndex:0];
    [context deleteObject:lineUser];
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//为线路添加用户
-(void)addUser:(UserInfo*)user forLine:(LineInfo*)line{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    LineUserRelation *lineUser = [NSEntityDescription insertNewObjectForEntityForName:@"LineUserRelation" inManagedObjectContext:context];
    
    [lineUser setValue:line.id forKey:@"id"];
    [lineUser setValue:user.id forKey:@"childid"];
    [lineUser setValue:[self getCurrentDate] forKey:@"updateTime"];
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//获取线路用户列表
-(NSArray*)getUserlistForLine:(LineInfo*)line{
    
    NSMutableArray *linelist = [NSMutableArray array];
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineUserRelation"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@",line.id];
    [fetchRequest setPredicate:predicate];
    
    NSError* error;
    NSArray *array = (NSMutableArray*)[context executeFetchRequest:fetchRequest error:&error];
    
    for(LineUserRelation *lineUser in array){
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"LineInfo"
                                                  inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        predicate = [NSPredicate predicateWithFormat:@"id = %@",lineUser.childid];
        [fetchRequest setPredicate:predicate];
        
        NSError* error;
        array = (NSMutableArray*)[context executeFetchRequest:fetchRequest error:&error];
        [linelist addObject:[array objectAtIndex:0]];
    }
    
    return linelist;

}


#pragma mark - 用户相关
//新增用户
-(void)addUser:(UserInfo*)user{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    UserInfo *userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:context];
    
    [userInfo setValue:[user valueForKey:@"name"] forKey:@"name"];
    [userInfo setValue:[user valueForKey:@"desc"] forKey:@"desc"];
    [userInfo setValue:[user valueForKey:@"industry"] forKey:@"industry"];
    [userInfo setValue:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [userInfo setValue:[self getCurrentDate] forKey:@"updateTime"];
    
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//删除用户
-(void)removeUser:(UserInfo*)user{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    [context deleteObject:user];
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];

}

//编辑用户
-(void)editUserfromOld:(UserInfo*)old toNew:(UserInfo*)news{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([old class], &outCount);
    
    for(int i =0; i<outCount;i++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([name isEqualToString:@"id"]) {
            continue;
        }
        [old setValue:[news valueForKey:name] forKey:name];
    }
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//从用户删除测量点
-(void)removeMPoint:(MPointInfo*)mp fromUser:(UserInfo*)user{
    
 
}

//从用户删除设备
-(void)removeDevice:(DeviceInfo*)device fromUser:(UserInfo*)user{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"UserDeviceRelation"
                                              inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@ and childid = %@",
                              user.id,device.id];
    
    [fetchRequest setPredicate:predicate];
    
    NSError *error;
    NSArray *array = (NSMutableArray*)[context executeFetchRequest:fetchRequest error:&error];
    UserDeviceRelation* userDevice = (UserDeviceRelation*)[array objectAtIndex:0];
    [context deleteObject:userDevice];
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//为用户添加测量点
-(void)addMPoint:(MPointInfo*)mp forUser:(UserInfo*)user{
    
}

//为用户添加设备
-(void)addDevice:(DeviceInfo*)device forUser:(UserInfo*)user{
    
}

-(NSArray*)getMPointlistForUser:(UserInfo*)user{
    return nil;
}

//获取用户设备列表
-(NSArray*)getDevicelistForUser:(UserInfo*)user{
    return nil;
}

#pragma mark - 测量点相关
//新增测量点
-(void)addMPoint:(MPointInfo *)mp{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    MPointInfo *mpinfo = [NSEntityDescription insertNewObjectForEntityForName:@"MPointInfo" inManagedObjectContext:context];
    
    [mpinfo setValue:[mp valueForKey:@"name"] forKey:@"name"];
    [mpinfo setValue:[mp valueForKey:@"desc"] forKey:@"desc"];
    [mpinfo setValue:[mp valueForKey:@"mid"] forKey:@"mid"];
    [mpinfo setValue:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [mpinfo setValue:[self getCurrentDate] forKey:@"updateTime"];
    
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//删除测量点
-(void)removeMPoint:(MPointInfo *)mp{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    [context deleteObject:mp];
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//编辑测量点
-(void)editMPointfromOld:(MPointInfo*)old toNew:(MPointInfo*)news{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([old class], &outCount);
    
    for(int i =0; i<outCount;i++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([name isEqualToString:@"id"]) {
            continue;
        }
        [old setValue:[news valueForKey:name] forKey:name];
    }
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

#pragma mark 设备相关

//新增设备
-(void)addDevice:(DeviceInfo *)device{
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    SystemInfo *systemInfo = [NSEntityDescription insertNewObjectForEntityForName:@"SystemInfo" inManagedObjectContext:context];
    
    [systemInfo setValue:[device valueForKey:@"name"] forKey:@"name"];
    [systemInfo setValue:[device valueForKey:@"desc"] forKey:@"desc"];
    [systemInfo setValue:[[NSUUID UUID] UUIDString] forKey:@"id"];
    [systemInfo setValue:[self getCurrentDate] forKey:@"updateTime"];
    
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//删除设备
-(void)removeDevice:(DeviceInfo *)device{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    [context deleteObject:device];
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}

//编辑设备
-(void)editDevicefromOld:(DeviceInfo*)old toNew:(DeviceInfo*)news{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
    [context setParentContext:self.contextParent];
    
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([old class], &outCount);
    
    for(int i =0; i<outCount;i++){
        
        objc_property_t property = properties[i];
        NSString *name = [NSString stringWithUTF8String:property_getName(property)];
        
        if ([name isEqualToString:@"id"]) {
            continue;
        }
        [old setValue:[news valueForKey:name] forKey:name];
    }
    [context save:nil];
    [self.contextParent performBlock:^{
        [self.contextParent save:nil];
    }];
}
@end
