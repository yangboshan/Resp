//
//  DeviceViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceViewController.h"

#import "Navbar.h"
#import "JMWhenTapped.h"
#import "MJRefresh.h"
#import "DeviceSettingViewController.h"

//#import "DeviceBasicParamViewController.h"
//#import "DeviceTransParamViewController.h"
//#import "DeviceDCParamViewController.h"
//#import "DevicePointsViewController.h"
//#import "DeviceEventParamViewController.h"
#import "DataCatalogViewController.h"
#import "FMREventsViewController.h"
#import "SwitchEventsViewController.h"
#import "SwitchControlViewController.h"
#import "DeviceHelpViewController.h"


@implementation DatePickerActionSheet
{
    UIActionSheet *actionSheet;
}
@synthesize datePicker = _datePicker;

- (id)init
{
    self = [super init];
    if (self) {
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,40, 320, 216)];
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        self.datePicker.tag = 555;
        [actionSheet addSubview:self.datePicker];
        
        UIToolbar *tools=[[UIToolbar alloc]initWithFrame:CGRectMake(0, 0,320,40)];
        tools.barStyle=UIBarStyleBlackOpaque;
        [actionSheet addSubview:tools];
        
        UIBarButtonItem *doneButton=[[UIBarButtonItem alloc]initWithTitle:@"确定" style:UIBarButtonItemStyleDone target:self action:@selector(btnActinDoneClicked:)];
        doneButton.imageInsets=UIEdgeInsetsMake(200, 6, 50, 25);
        UIBarButtonItem *CancelButton=[[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(btnActinCancelClicked:)];
        
        UIBarButtonItem *flexSpace= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *array = [[NSArray alloc]initWithObjects:CancelButton,flexSpace,flexSpace,doneButton,nil];          [tools setItems:array];
        
        //picker title
        UILabel *lblPickerTitle=[[UILabel alloc]initWithFrame:CGRectMake(60,8, 200, 25)];
        lblPickerTitle.text=@"";
        lblPickerTitle.backgroundColor=[UIColor clearColor];
        lblPickerTitle.textColor=[UIColor whiteColor];
        lblPickerTitle.textAlignment=UITextAlignmentCenter;
        lblPickerTitle.font=[UIFont boldSystemFontOfSize:15];
        [tools addSubview:lblPickerTitle];
    }
    return self;
}

- (IBAction)btnActinCancelClicked:(id)sender
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    
    if ([self.pickerDelegate respondsToSelector:@selector(datePickerActionSheetCanceled:)]) {
        [self.pickerDelegate datePickerActionSheetCanceled:actionSheet];
    }
}

- (IBAction)btnActinDoneClicked:(id)sender
{
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];

    if (self.pickerDelegate) {
        [self.pickerDelegate datePickerActionSheet:actionSheet didPickDate:[self.datePicker date]];
    }
    
}

- (void)show
{
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    CGRect bounds = CGRectMake(0, 0, 320, 411);
    if (IOS_VERSION_7) {
        bounds.size.height += 88;
    }
    [actionSheet setBounds:bounds];
}

@end

@interface DeviceViewController ()
{
    NSDateFormatter *dateFormatter;
    
    MJRefreshHeaderView *refreshHeader;
}

@property (nonatomic) NSDate *deviceTime;//设备时间
@property (nonatomic) UILabel *realtimeLabel;
@property (nonatomic, retain) DatePickerActionSheet *timeActionSheet;
@end

@implementation DeviceViewController
@synthesize deviceTime = _deviceTime;
@synthesize timeActionSheet = _timeActionSheet;

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
    
    NSString *title = self.device.deviceName;
    [self.navigationItem setNewTitle:title];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    [self.settingBtn addTarget:self action:@selector(gotoDeviceSetting:) forControlEvents:UIControlEventTouchUpInside];
    [self.controlBtn addTarget:self action:@selector(gotoDeviceControl:) forControlEvents:UIControlEventTouchUpInside];
    [self.helpBtn addTarget:self action:@selector(gotoDeviceHelp:) forControlEvents:UIControlEventTouchUpInside];
    [self.realtimeDataBtn addTarget:self action:@selector(gotoDeviceRealtimeData:) forControlEvents:UIControlEventTouchUpInside];
    [self.historyDataBtn addTarget:self action:@selector(gotoDeviceHistoryData:) forControlEvents:UIControlEventTouchUpInside];
    [self.eventDataBtn addTarget:self action:@selector(gotoDeviceEventData:) forControlEvents:UIControlEventTouchUpInside];
    
    self.scrollView.contentSize = self.scrollView.bounds.size;
    [self addHeader];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd\nHH:mm:ss"];
    
    self.realtimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.realtimeLabel.font=[UIFont systemFontOfSize:10];
    self.realtimeLabel.textColor = [UIColor whiteColor];
    self.realtimeLabel.backgroundColor = [UIColor clearColor];
    self.realtimeLabel.textAlignment=UITextAlignmentCenter;
    self.realtimeLabel.numberOfLines = 2;
    self.realtimeLabel.text = @"2012-03-01\n99:99:99";
    [self.realtimeLabel sizeToFit];
    UIBarButtonItem *myButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.realtimeLabel];
    [self.navigationItem setRightBarButtonItem:myButtonItem];
    
    self.deviceTime = [self.device queryDeviceTime];
    [self.realtimeLabel whenTapped:^{
        if (self.deviceTime) {
            [self.timeActionSheet.datePicker setDate:self.deviceTime animated:YES];
        }
        [self.timeActionSheet show];
    }];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [refreshHeader free];
}

- (void)addHeader
{
    __unsafe_unretained DeviceViewController *vc = self;
    refreshHeader = [MJRefreshHeaderView header];
    refreshHeader.scrollView = self.scrollView;
    refreshHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        vc.deviceTime = [vc.device queryDeviceTime];
        [vc performSelector:@selector(doneWithView) withObject:nil];
    };
}

- (void)doneWithView
{
    [refreshHeader endRefreshing];
}

- (void)setDeviceTime:(NSDate *)deviceTime
{
    _deviceTime = deviceTime;
    self.realtimeLabel.text = deviceTime != nil ? [dateFormatter stringFromDate:deviceTime] : @"----";
}

- (DatePickerActionSheet *)timeActionSheet
{
    if (!_timeActionSheet) {
        _timeActionSheet = [[DatePickerActionSheet alloc] init];
        _timeActionSheet.pickerDelegate = self;
    }
    return _timeActionSheet;
}

- (void)datePickerActionSheet:(UIActionSheet *)actionSheet didPickDate:(NSDate *)date
{
    self.deviceTime = date;
    [self.device setDeviceTime:self.deviceTime];

}

- (IBAction)gotoDeviceSetting:(id)sender
{
    DeviceSettingViewController *controller = [[DeviceSettingViewController alloc] init];
    controller.device = self.device;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)gotoDeviceControl:(id)sender
{
    if (self.device.deviceType == DeviceTypeSwitch) {
        SwitchControlViewController *controller = [[SwitchControlViewController alloc] init];
        controller.device = self.device;
        [self.navigationController pushViewController:controller animated:YES];
    }
}
- (IBAction)gotoDeviceHelp:(id)sender
{
    DeviceHelpViewController *controller = [[DeviceHelpViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];

}
- (IBAction)gotoDeviceRealtimeData:(id)sender
{
    DataCatalogViewController *controller = [[DataCatalogViewController alloc] init];
    controller.device = self.device;
    controller.realtime = YES;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)gotoDeviceHistoryData:(id)sender
{
    DataCatalogViewController *controller = [[DataCatalogViewController alloc] init];
    controller.device = self.device;
    controller.realtime = NO;
    [self.navigationController pushViewController:controller animated:YES];
}
- (IBAction)gotoDeviceEventData:(id)sender
{
    if (self.device.deviceType == DeviceTypeFMR) {
        FMREventsViewController *controller = [[FMREventsViewController alloc] init];
        controller.device = self.device;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (self.device.deviceType == DeviceTypeSwitch) {
        SwitchEventsViewController *controller = [[SwitchEventsViewController alloc] init];
        controller.device = self.device;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
