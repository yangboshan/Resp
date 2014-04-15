//
// Created by sureone on 2/13/14.
// Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "HomeUserTextDataViewController.h"
#import "UIButton+Bootstrap.h"
#import "HomeUserEnergyInfoViewController.h"
#import "HomeUserSaftyInfoViewController.h"
#import "HomeUserEconomicInfoViewController.h"

#import "XLModelDataInterface.h"
#import "NSDictionary+NSDictionary_Data.h"


@implementation HomeUserTextDataViewController {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    用图片做背景
    
        UIGraphicsBeginImageContext(self.view.frame.size);
        [[UIImage imageNamed:@"text_data_view_bg.png"] drawInRect:self.view.frame];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

//        self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
//    self.view.backgroundColor = [UIColor colorWithRed:20 green:20 blue:20 alpha:0];
//    [self.view setBackgroundColor:[UIColor colorWithRed:255 green:0 blue:0 alpha:1] ];
    
    [self.saftBtn customRoundStyleWithColor:[UIColor colorWithRed:124/255.0 green:0/255.0 blue:0/255.0 alpha:1]];
    [self.energyBtn customRoundStyleWithColor:[UIColor colorWithRed:37/255.0 green:112/255.0 blue:0/255.0 alpha:1]];
    [self.ecnomicBtn customRoundStyleWithColor:[UIColor colorWithRed:37/255.0 green:112/255.0 blue:0/255.0 alpha:1]];
    
    XLModelDataInterface *testData = [XLModelDataInterface testData];
    
    if([self.viewType isEqualToString:@"user"]){
        XLViewDataUserBaiscInfo *user = testData.currentUser;
        self.userNameLabel.text = [NSString stringWithFormat:@"【%@】", (user ? user.userName : @"无用户")];
        [testData addObserver:self forKeyPath:@"currentUser" options:NSKeyValueObservingOptionNew context:nil];
    }
    if([self.viewType isEqualToString:@"line"]){
        XLViewDataLine *line = [XLModelDataInterface testData].currentLine;
        self.userNameLabel.text = [NSString stringWithFormat:@"【%@】", (line ? line.lineName : @"无线路")];
        [testData addObserver:self forKeyPath:@"currentLine" options:NSKeyValueObservingOptionNew context:nil];
    }
     if([self.viewType isEqualToString:@"system"]){
        XLViewDataSystem *system = [XLModelDataInterface testData].currentSystem;
        self.userNameLabel.text = [NSString stringWithFormat:@"【%@】", (system ? system.systemName : @"无系统")];
        [testData addObserver:self forKeyPath:@"currentSystem" options:NSKeyValueObservingOptionNew context:nil];
     }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentUser"]) {
        XLViewDataUserBaiscInfo *user = [XLModelDataInterface testData].currentUser;
        self.userNameLabel.text = [NSString stringWithFormat:@"【%@】", (user ? user.userName : @"无用户")];
    }
    if ([keyPath isEqualToString:@"currentLine"]) {
        XLViewDataLine *line = [XLModelDataInterface testData].currentLine;
        self.userNameLabel.text = [NSString stringWithFormat:@"【%@】", (line ? line.lineName : @"无线路")];
    }
    if ([keyPath isEqualToString:@"currentSystem"]) {
        XLViewDataSystem *system = [XLModelDataInterface testData].currentSystem;
        self.userNameLabel.text = [NSString stringWithFormat:@"【%@】", (system ? system.systemName : @"无系统")];
    }
}

-(void)renderDataToLabel:(UILabel*)label withData:(NSDictionary*)theData withDataKey:(NSString*)key withUnit:(NSString*)unit
{
    if([theData objectForKey:key] == nil ||
       [theData objectForKey:key] == [NSNull null])
    {
        label.text = @"-";
    }else
        if([theData doubleValueForKey:key]>100000)
            label.text=[NSString stringWithFormat:@"%.0f%@",[theData doubleValueForKey:key],unit];
        else
            label.text=[NSString stringWithFormat:@"%.2f%@",[theData doubleValueForKey:key],unit];
    
}

-(void)testUpdateTheDetailFromPlotWithDoubleArray:(id)data
{
    if([data isKindOfClass:[NSDictionary class]]){
        
        
        
        NSDictionary *theData = (NSDictionary*)data;
        
        [self renderDataToLabel:self.EDRL withData:theData withDataKey:@"ed" withUnit:@"kVA"];
        
        [self renderDataToLabel:self.ZDFH withData:theData withDataKey:@"zdfh" withUnit:@"kW"];

        [self renderDataToLabel:self.DL withData:theData withDataKey:@"dl" withUnit:@"kWh"];
        [self renderDataToLabel:self.ZXFH withData:theData withDataKey:@"zxfh" withUnit:@"kW"];
        [self renderDataToLabel:self.YGSH withData:theData withDataKey:@"ygsh" withUnit:@"kWh"];
        [self renderDataToLabel:self.ZDXL withData:theData withDataKey:@"zdxl" withUnit:@"kWh"];
        [self renderDataToLabel:self.GLYS withData:theData withDataKey:@"glys" withUnit:@""];




        if([theData objectForKey:@"aqrxsj"] == nil ||
           [theData objectForKey:@"aqrxsj"] == [NSNull null])
        {
            self.AQYX.text = @"-";
        }else
            self.AQYX.text=[NSString stringWithFormat:@"%d天",(int)[theData doubleValueForKey:@"aqrxsj"]];

        
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[theData doubleValueForKey:@"sj"]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        
        
        
        if(self.plotTimeType==XLViewPlotTimeDay)
            [formatter setDateFormat:@"yy年MM月dd日"];
        else if(self.plotTimeType==XLViewPlotTime1Min ||
                self.plotTimeType==XLViewPlotTime5Min ||
                self.plotTimeType==XLViewPlotTime15Min ||
                self.plotTimeType==XLViewPlotTime30Min ||
                self.plotTimeType==XLViewPlotTime60Min
                )
            [formatter setDateFormat:@"yy年MM月dd日 HH:mm"];
        else if(self.plotTimeType==XLViewPlotTimeMonth)
            [formatter setDateFormat:@"yyyy年MM月"];
        else if(self.plotTimeType==XLViewPlotTimeYear){
            [formatter setDateFormat:@"yyyy年"];
        }else if(self.plotTimeType==XLViewPlotTimeWeek){
            [formatter setDateFormat:@"yy年MM月dd日"];
        }
        
        
        NSString *dateString = [formatter stringFromDate:date];
        
        self.LABLE_TIME.text = dateString;
        
        if(self.plotTimeType==XLViewPlotTimeDay)
            [formatter setDateFormat:@"HH:mm"];
        else if(self.plotTimeType==XLViewPlotTime1Min ||
                self.plotTimeType==XLViewPlotTime5Min ||
                self.plotTimeType==XLViewPlotTime15Min ||
                self.plotTimeType==XLViewPlotTime30Min ||
                self.plotTimeType==XLViewPlotTime60Min
                )
            [formatter setDateFormat:@"HH:mm"];
        else if(self.plotTimeType==XLViewPlotTimeMonth)
            [formatter setDateFormat:@"yy-MM-dd"];
        else if(self.plotTimeType==XLViewPlotTimeYear){
            [formatter setDateFormat:@"yyyy-MM"];
        }else if(self.plotTimeType==XLViewPlotTimeWeek){
            [formatter setDateFormat:@"yy-MM-dd"];
        }
        
        
        if([theData objectForKey:@"zdxlfssj"] == nil ||
           [theData objectForKey:@"zdxlfssj"] == [NSNull null])
        {
            self.maxConsumeLoadTime.text  = @"-";
        }else{
            date = [NSDate dateWithTimeIntervalSince1970:[theData doubleValueForKey:@"zdxlfssj"]];
//            
//            formatter = [[NSDateFormatter alloc]init];
//            
//            [formatter setDateFormat:@"HH:mm"];
            
            dateString = [formatter stringFromDate:date];
            
            self.maxConsumeLoadTime.text = dateString;
        }
        
        if([theData objectForKey:@"zdfhfssj"] == nil ||
           [theData objectForKey:@"zdfhfssj"] == [NSNull null])
        {
            self.maxLoadTime.text  = @"-";
        }else{
            date = [NSDate dateWithTimeIntervalSince1970:[theData doubleValueForKey:@"zdfhfssj"]];
            
//            formatter = [[NSDateFormatter alloc]init];
//            [formatter setDateFormat:@"HH:mm"];
            
            dateString = [formatter stringFromDate:date];
            
            self.maxLoadTime.text = dateString;
        }
        
        
        if([theData objectForKey:@"zxfhfssj"] == nil ||
           [theData objectForKey:@"zxfhfssj"] == [NSNull null])
        {
            self.minLoadTime.text  = @"-";
        }else{
            
            date = [NSDate dateWithTimeIntervalSince1970:[theData doubleValueForKey:@"zxfhfssj"]];
//            
//            formatter = [[NSDateFormatter alloc]init];
//            [formatter setDateFormat:@"HH:mm"];
            
            dateString = [formatter stringFromDate:date];
            
            self.minLoadTime.text = dateString;
        }
    }

    

    
}

-(void)updatePlotDate:(NSDate*)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yy年MM月dd日 hh:mm"];
    
    NSString *dateString = [formatter stringFromDate:date];
    
    self.LABLE_TIME.text = dateString;
}

- (IBAction)onEnergyButtonPressed:(id)sender {
    
    
    HomeUserEnergyInfoViewController *controller = [[HomeUserEnergyInfoViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
    
}

- (IBAction)onSaftyButtonPressed:(id)sender {
    HomeUserSaftyInfoViewController *controller = [[HomeUserSaftyInfoViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)onEcnomicButtonPressed:(id)sender {

    HomeUserEconomicInfoViewController  *controller = [[HomeUserEconomicInfoViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}
@end