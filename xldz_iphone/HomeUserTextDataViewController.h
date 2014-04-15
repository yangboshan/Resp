//
// Created by sureone on 2/13/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "XLModelDataInterface.h"

@interface HomeUserTextDataViewController : UIViewController{
    /* 额定容量，安全运行，最大负荷，电量, 最小负荷，有功损耗，最大需量，功率因素 */
    UILabel *EDRL,*AQYX,*ZDFH,*DL,*ZXFH,*YGSH,*ZDXL,*GLYS;
    UIButton *saftBtn,*ecnomicBtn,*energyBtn;
}

@property (nonatomic, retain) IBOutlet UILabel *userNameLabel;

@property (nonatomic, retain) IBOutlet UILabel *EDRL;
@property (nonatomic, retain) IBOutlet UILabel *AQYX;
@property (nonatomic, retain) IBOutlet UILabel *ZDFH;
@property (nonatomic, retain) IBOutlet UILabel *DL;
@property (nonatomic, retain) IBOutlet UILabel *ZXFH;
@property (nonatomic, retain) IBOutlet UILabel *YGSH;
@property (nonatomic, retain) IBOutlet UILabel *ZDXL;
@property (nonatomic, retain) IBOutlet UILabel *GLYS;
@property (nonatomic, retain) IBOutlet UILabel *LABLE_TIME;

@property (weak, nonatomic) IBOutlet UILabel *maxConsumeLoadTime;

@property (weak, nonatomic) IBOutlet UILabel *maxLoadTime;

@property (weak, nonatomic) IBOutlet UILabel *minLoadTime;

@property (nonatomic, retain) IBOutlet UIButton *saftBtn;
@property (nonatomic, retain) IBOutlet UIButton *ecnomicBtn;
@property (nonatomic, retain) IBOutlet UIButton *energyBtn;

@property (nonatomic,strong) NSString *viewType;

-(void)updatePlotDate:(NSDate*)date;

-(void)testUpdateTheDetailFromPlotWithDoubleArray:(id)data;
- (IBAction)onEnergyButtonPressed:(id)sender;

- (IBAction)onSaftyButtonPressed:(id)sender;
- (IBAction)onEcnomicButtonPressed:(id)sender;


@property (nonatomic) XLViewPlotTimeType plotTimeType;
@property (nonatomic) XLViewPlotDataType plotDataType;


@end