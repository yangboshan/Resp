//
//  DeviceStatusFlagViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-20.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceStatusFlagViewController.h"

#import "Navbar.h"

@interface UILabel (ColorStyle)
@end

@implementation UILabel (ColorStyle)

- (void)foldStyle:(BOOL)fold
{
    UIColor *red = [UIColor colorWithRed:86.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    UIColor *green = [UIColor colorWithRed:43.0f/255.0f green:86.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    
    self.text = fold ? @"合" : @"分";
    self.backgroundColor = fold ? green : red;
}

- (void)changeStyle:(BOOL)change
{
    UIColor *orange = [UIColor colorWithRed:171.0f/255.0f green:86.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    UIColor *blue = [UIColor colorWithRed:0.0f/255.0f green:86.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
    
    self.text = change ? @"有\n变\n化" : @"无\n变\n化";
    self.backgroundColor = change ? orange : blue;
}

@end

@interface DeviceStatusFlagViewController ()
{
    NSArray *btnGroup1;
    NSArray *btnGroup2;
    
    NSString *notifKey;
}

@property (nonatomic) NSArray *deviceFlags;
@end

@implementation DeviceStatusFlagViewController
@synthesize deviceFlags = _deviceFlags;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setNewTitle:@"终端状态量变位标识"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    NSMutableArray *group = [NSMutableArray arrayWithCapacity:8];
    for (int tag = 1; tag <= 8; tag++) {
        UILabel *label = (UILabel *)[self.view viewWithTag:tag];
        [group addObject:label];
        label.layer.cornerRadius = 15.0;
        label.text = @"";
    }
    btnGroup1 = group;
    
    group = [NSMutableArray arrayWithCapacity:8];
    for (int tag = 11; tag <= 18; tag++) {
        UILabel *label = (UILabel *)[self.view viewWithTag:tag];
        [group addObject:label];
        label.layer.cornerRadius = 15.0;
        label.text = @"";
    }
    btnGroup2 = group;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"设备%@-终端状态量变位标识", self.device.deviceId];
    [self initData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         notifKey, @"xl-name",
                         nil];
    [self.device queryStatusFlag:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [refreshHeader endRefreshing];
            
            self.deviceFlags = result;
        });
    }
}
- (void)setDeviceFlags:(NSArray *)deviceFlags
{
    _deviceFlags = deviceFlags;
    
    NSInteger count = MIN(deviceFlags.count, btnGroup1.count);
    for (NSInteger i = 0; i < count; i++) {
        UILabel *label1 = [btnGroup1 objectAtIndex:i];
        UILabel *label2 = [btnGroup2 objectAtIndex:i];
        
        NSDictionary *flag = [deviceFlags objectAtIndex:i];
        BOOL fold = [[flag objectForKey:@"合"] boolValue];
        BOOL change = [[flag objectForKey:@"有变化"] boolValue];
        [label1 foldStyle:fold];
        [label2 changeStyle:change];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
