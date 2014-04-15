//
//  XLCoreData.h
//  XLApp
//
//  Created by JY on 14-3-4.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XLExternals.h"

@interface XLCoreData : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(XLCoreData*)sharedXLCoreData;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
