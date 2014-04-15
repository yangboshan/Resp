//
//  XLUtilities.m
//  XLApp
//
//  Created by JY on 14-3-8.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "XLUtilities.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#import <ifaddrs.h>
#import "Reachability.h"


@implementation XLUtilities

+(BOOL)localWifiReachable{
    
    Reachability *reachability = [Reachability reachabilityForLocalWiFi];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == 1) {
        NSString *ipAddress = [self getIPAddress];
        if (![ipAddress isEqualToString:@"0.0.0.0"]) {
            
            NSRange range =  [ipAddress rangeOfString:@"." options:NSBackwardsSearch];
            NSRange range1 = [@"10.10.2.1" rangeOfString:@"." options:NSBackwardsSearch];
            
            if ([[ipAddress substringToIndex:range.location]
                 isEqualToString: [@"10.10.2.1" substringToIndex:range1.location]]) {
                return YES;
            }
        }
    }
    
    return NO;
}

+ (NSString *)getIPAddress
{
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = nil;
    NSString *cellAddress = nil;
    
    if(!getifaddrs(&interfaces)) {
        
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            sa_family_t sa_type = temp_addr->ifa_addr->sa_family;
            if(sa_type == AF_INET || sa_type == AF_INET6) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0
                
                
                //                NSLog(@"NAME: \"%@\" addr: %@", name, addr);
                
                NSString *type = @"en0";
                
#ifdef DEBUG
                if ([[[UIDevice currentDevice] model]
                     isEqualToString:@"iPhone Simulator"]) {
                    type = @"en1";
                }
#endif
                
                if([name isEqualToString:type]) {
                    wifiAddress = addr;
                }
                else
                    if([name isEqualToString:@"pdp_ip0"]) {
                        cellAddress = addr;
                    }
                
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    return addr ? addr : @"0.0.0.0";
}

//获取SEQ
+(NSInteger)parseSeqFieldWithData:(NSData*)data{
    
    if (!data) {
        return -1;
    }
    
    Byte* bytes = (Byte*)[data bytes];
    return bytes[13]&0x0f;
}
@end
