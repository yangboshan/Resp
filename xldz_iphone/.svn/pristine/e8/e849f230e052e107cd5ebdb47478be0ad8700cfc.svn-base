//
//  DeviceViewController.h
//  XLApp
//
//  Created by ttonway on 14-2-19.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XLModelDataInterface.h"

@protocol DatePickerActionSheetDelegate <NSObject>

- (void)datePickerActionSheet:(UIActionSheet *)actionSheet didPickDate:(NSDate *)date;

@optional
- (void)datePickerActionSheetCanceled:(UIActionSheet *)actionSheet;

@end

@interface DatePickerActionSheet : NSObject <UIActionSheetDelegate>

@property (nonatomic, retain) UIDatePicker *datePicker;
@property(nonatomic, assign) id<DatePickerActionSheetDelegate> pickerDelegate;

- (void)show;

@end


@interface DeviceViewController : UIViewController <DatePickerActionSheetDelegate>

@property (nonatomic) XLViewDataDevice *device;
//@property (nonatomic) XLViewDataUserBaiscInfo *ownerUser;
@property (nonatomic, retain) IBOutlet UIScrollView   *scrollView;
@property (nonatomic, retain) IBOutlet UIView   *btnContainer;
@property (nonatomic, retain) IBOutlet UIButton *settingBtn;
@property (nonatomic, retain) IBOutlet UIButton *controlBtn;
@property (nonatomic, retain) IBOutlet UIButton *helpBtn;
@property (nonatomic, retain) IBOutlet UIButton *realtimeDataBtn;
@property (nonatomic, retain) IBOutlet UIButton *historyDataBtn;
@property (nonatomic, retain) IBOutlet UIButton *eventDataBtn;

@end
