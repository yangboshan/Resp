//
//  StartSyncAlertView.h
//  XLApp
//
//  Created by ttonway on 14-3-18.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SIAlertView.h"
#import "MyTextField.h"
#import "DeviceViewController.h"

@interface StartSyncAlertView : SIAlertView <UITextFieldDelegate, DatePickerActionSheetDelegate>

@property (nonatomic) NSDate *startTime;
@property (nonatomic) NSDate *endTime;


@property (nonatomic, retain) MyTextField *startTextField;
@property (nonatomic, retain) MyTextField *endTextField;
@property (nonatomic, retain) UIDatePicker *datePicker;
@property (nonatomic, retain) DatePickerActionSheet *timeActionSheet;

@end
