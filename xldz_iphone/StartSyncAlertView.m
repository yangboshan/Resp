//
//  StartSyncAlertView.m
//  XLApp
//
//  Created by ttonway on 14-3-18.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "StartSyncAlertView.h"

#import "XLModelDataInterface.h"
#import "JMWhenTapped.h"
#import "SSCheckBoxView.h"
#import "Toast+UIView.h"
#import "XLSyncDeviceBussiness.h"

static BOOL showing = NO;

@implementation StartSyncAlertView
{
    NSInteger currentTextFieldTag;
    
    NSDateFormatter *dateFormatter;
}
@synthesize startTime = _startTime;
@synthesize endTime = _endTime;
@synthesize startTextField = _startTextField;
@synthesize endTextField = _endTextField;
@synthesize datePicker = _datePicker;
@synthesize timeActionSheet = _timeActionSheet;

- (id)init
{
    self = [super initWithCustomView:[self myCustomView]];
    if (self) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        self.startTime = [NSDate date];
        self.endTime = [NSDate date];

        self.title = @"手动更新数据";
        self.dismissWhenTapOutside = YES;
        __weak StartSyncAlertView *alert = self;
        [self addButtonWithTitle:@"更新"
                            type:SIAlertViewButtonTypeDefault
                         handler:^(SIAlertView *alertView) {
//                             [[XLSyncDeviceBussiness sharedXLSyncDeviceBussiness] beginSyncWithStartDate:self.startTime withEndDate:self.endTime];
//                             dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                                 NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
//                                                      alert.startTime, @"startDate",
//                                                      alert.endTime, @"endDate", nil];
//                                 BOOL b = [[XLModelDataInterface testData] updateTerminalData:dic];
//                                 if (!b) {
//                                     dispatch_time_t after = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
//                                     dispatch_after(after, dispatch_get_main_queue(), ^{
//                                         UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//                                         [window makeToast:@"WiFi未连接"];
//                                     });
//                                     
//                                 }
//                             });
                             
                         }];
        self.transitionStyle = SIAlertViewTransitionStyleDropDown;
        self.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    }
    return self;
}

- (UIView *)myCustomView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 90 + 46)];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor textWhiteColor];
    label1.text = @"开始时间";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 80, 30)];
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor textWhiteColor];
    label2.text = @"结束时间";
    self.startTextField = [[MyTextField alloc] initWithFrame:CGRectMake(100, 10, 180, 30)];
    self.endTextField = [[MyTextField alloc] initWithFrame:CGRectMake(100, 50, 180, 30)];
    self.startTextField.tag = 500;
    self.startTextField.delegate = self;
    self.endTextField.tag = 501;
    self.endTextField.delegate = self;
    SSCheckBoxView *checkbox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(10, 90, 200, 36)
                                                               style:kSSCheckBoxViewStyleGlossy
                                                             checked:NO];
    [checkbox setText:@"下次不再提醒"];
    
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:self.startTextField];
    [view addSubview:self.endTextField];
    [view addSubview:checkbox];
    
    checkbox.checked = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_update_off"];
    [checkbox whenTapped:^{
        checkbox.checked = !checkbox.checked;
        [[NSUserDefaults standardUserDefaults] setBool:checkbox.checked forKey:@"auto_update_off"];
    }];
    
    return view;
}

- (UIDatePicker *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,40, 320, 216)];
        _datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    }
    return _datePicker;
}

- (DatePickerActionSheet *)timeActionSheet
{
    if (!_timeActionSheet) {
        _timeActionSheet = [[DatePickerActionSheet alloc] init];
        _timeActionSheet.pickerDelegate = self;
    }
    return _timeActionSheet;
}

- (void)setStartTime:(NSDate *)startTime
{
    _startTime = startTime;
    self.startTextField.text = [dateFormatter stringFromDate:startTime];
}

- (void)setEndTime:(NSDate *)endTime
{
    _endTime = endTime;
    self.endTextField.text = [dateFormatter stringFromDate:endTime];
}

- (void)datePickerActionSheet:(UIActionSheet *)actionSheet didPickDate:(NSDate *)date
{
    if (currentTextFieldTag == 500) {
        self.startTime = date;
    } else if (currentTextFieldTag == 501) {
        self.endTime = date;
    }
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    currentTextFieldTag = textField.tag;
    if (textField.tag == 500 && self.startTime) {
        [self.datePicker setDate:self.startTime animated:YES];
    } else if (textField.tag == 501 && self.endTime) {
        [self.datePicker setDate:self.endTime animated:YES];
    }
    
    [self.timeActionSheet show];

    return NO;
}

- (void)show
{
    if (showing) {
        return;
    }
    [super show];
    showing = YES;
}

- (void)dismissAnimated:(BOOL)animated
{
    [super dismissAnimated:animated];
    showing = NO;
}

@end