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
@property (nonatomic, strong) __block NSString *notifyName;

+(XLSocketManager*)sharedXLSocketManager;

-(void)packRequestFrame:(NSData*)userData;
-(void)packRequestFrameWithData:(NSData*)userData withNotifyName:(NSString*)notify;

@end
