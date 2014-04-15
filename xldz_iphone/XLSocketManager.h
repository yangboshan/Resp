//
//  XLSocketManager.h
//  XLDistributionBoxApp
//
//  Created by JY on 13-7-10.
//  Copyright (c) 2013年 XLDZ. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "XLExternals.h"

@interface XLSocketManager : NSObject
{
    
}

@property (nonatomic, retain) GCDAsyncSocket* socket;
@property (nonatomic, assign) BOOL isFromBackground;
@property (nonatomic, strong) NSString *notifyName;

+(XLSocketManager*)sharedXLSocketManager;

-(void)packRequestFrame:(NSData*)userData;

@end
