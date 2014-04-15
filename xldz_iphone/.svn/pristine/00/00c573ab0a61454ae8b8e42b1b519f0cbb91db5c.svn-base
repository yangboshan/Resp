//
//  TestPointEconomicDetialViewController.m
//  XLApp
//
//  Created by sureone on 2/23/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "TestPointEconomicDetialViewController.h"
#import "Navbar.h"

#import "NSDictionary+NSDictionary_Data.h"

#import "XLModelDataInterface.h"

#import "MBProgressHUD.h"
@interface TestPointEconomicDetialViewController ()

@end

@implementation TestPointEconomicDetialViewController

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
    // Do any additional setup after loading the view from its nib.
    
    
    self.title = _tpName;
    [self.navigationItem setNewTitle:_tpName];
    
    CGRect origRc = self.viewPowerFactor.frame;
    self.viewPowerFactor.frame=CGRectMake(0, 0, origRc.size.width,origRc.size.height);
    [self.scrollContainerView addSubview:self.viewPowerFactor];
    
    
    self.viewBlance.frame=CGRectMake(0,
            _viewPowerFactor.frame.origin.y+_viewPowerFactor.frame.size.height+10, _viewBlance.frame.size.width,_viewBlance.frame.size.height);
    [self.scrollContainerView addSubview:self.viewBlance];

//
    self.viewDayLoad.frame=CGRectMake(0, _viewBlance.frame.origin.y+_viewBlance.frame.size.height+10, _viewDayLoad.frame.size.width,_viewDayLoad.frame.size.height);
    [self.scrollContainerView addSubview:self.viewDayLoad];
    
    self.viewLost.frame=CGRectMake(0, _viewDayLoad.frame.origin.y+_viewDayLoad.frame.size.height+10, _viewLost.frame.size.width,_viewLost.frame.size.height);
    [self.scrollContainerView addSubview:self.viewLost];
    
    self.viewCosumePower.frame=CGRectMake(0, _viewLost.frame.origin.y+_viewLost.frame.size.height+10, _viewCosumePower.frame.size.width,_viewCosumePower.frame.size.height);
    [self.scrollContainerView addSubview:self.viewCosumePower];
    
    self.scrollContainerView.contentSize = CGSizeMake(320, _viewCosumePower.frame.origin.y+_viewCosumePower.frame.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTheNotify:) name:XLViewDataNotification object:nil];
    
    [self requestDataFromDevice:_tpNo withDate:nil];
    
    


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestDataFromDevice:(NSString*)testPointId withDate:(NSDate*)theDate
{
    
    NSMutableDictionary *notificationDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSString stringWithFormat:@"economic-detail"], @"xl-name",
                                            theDate, @"time",
                                            testPointId,@"tpId",
                                            nil];
    
    [self showLoadingProgress];
    
    [[XLModelDataInterface testData] requestEconomicDetialData:notificationDic];
    

}

-(void)showLoadingProgress{
    //    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    //	[self.view addSubview:loadingView];
    //
    //	// Regiser for HUD callbacks so we can remove it from the window at the right time
    //	loadingView.delegate = self;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES ];
	
    //
    //	// Show the HUD while the provided method executes in a new thread
    //	[loadingView showWhileExecuting:@selector(doTestLoad) onTarget:self withObject:nil animated:YES];
    
    
    
}

-(void)hideLoadingProgress{
    //    loadingView = [[MBProgressHUD alloc] initWithView:self.view];
    //	[self.view addSubview:loadingView];
    //
    //	// Regiser for HUD callbacks so we can remove it from the window at the right time
    //	loadingView.delegate = self;
    
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
	
    //
    //	// Show the HUD while the provided method executes in a new thread
    //	[loadingView showWhileExecuting:@selector(doTestLoad) onTarget:self withObject:nil animated:YES];
}



- (void)handleTheNotify:(NSNotification *)notification{
    NSDictionary *resp =(NSDictionary*) notification.userInfo;
    
    NSDictionary* result = [resp objectForKey:@"result"];
    NSDictionary* param = [resp objectForKey:@"parameter"];
    
    if (![[param objectForKey:@"xl-name"] isEqualToString:@"economic-detail"]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleDeviceData:result];
        [self hideLoadingProgress];
        
    });
    
    
}

-(void)handleDeviceData:(NSDictionary*)dataDict{
    
    NSArray *views = [NSArray arrayWithObjects:_viewBlance,_viewCosumePower,_viewPowerFactor,_viewDayLoad,_viewLost, nil];
    for (UIView *subview in views) {
        if ([subview isKindOfClass:[UIView class]]) {
            for (UIView *labelView in subview.subviews) {
                if ([labelView isKindOfClass:[UILabel class]]) {
                    UILabel *key = (UILabel *)labelView;
                    NSString *ident = key.restorationIdentifier;
                    
                    if(ident!=nil){
                        NSString* value = [dataDict objectForKey:ident];
                        if(value==nil) value = @"-";
                        key.text = value;
                    }
                    NSLog(@"%@",ident);
                }
            }
        }
    }
    
}



- (void) getTestData:(NSString*)testPointId withDate:(NSDate*)theDate
{
    

    
    
    
//    NSMutableArray* arrayValue =
//        [NSMutableArray arrayWithObjects:
//         
//         @"0.72",@"0.8",@"0.5",@"0.73",
//         @"80分钟",@"80分钟",@"80分钟",
//         @"80分钟",@"80分钟",@"80分钟",
//         
//         @"0.8",
//         @"30%",@"20%",@"80分钟",
//         @"30%",@"20%",@"80分钟",
//         
//         @"80%",@"80分钟",
//         
//         @"误差正常",
//         
//         @"误差正常",
//         @"3000kWh",@"2900kWh",@"300kWh",@"200kWh",
//         
//         nil];
//    NSDictionary* dataDict = [NSMutableDictionary dictionaryWithObjects:arrayValue forKeys:
//                          [NSArray arrayWithObjects:
//                           //功率因素
//                           @"glys_ssz_z",@"glys_ssz_a",@"glys_ssz_b",@"glys_ssz_c",
//                           @"rljsj_1",@"rljsj_2",@"rljsj_3",
//                           @"yljsj_1",@"yljsj_2",@"yljsj_3",
//                           //三相电流不平衡度越限
//                           @"dlbph_ssz",
//                           @"dlbph_r1",@"dlbph_r2", @"dlbph_r3",
//                           @"dlbph_y1",@"dlbph_y2", @"dlbph_y3",
//                           //日负载率
//                           @"rfzl_pj",@"rfzl_sj",
//                           //防窃电
//                           @"fqd",
//                           //电量／功率误差情况
//                           @"wcjg",
//                           @"jxygdl",@"cxygdl",@"jxwgdl",@"cxwgdl",
//                           nil]
//                          ];
//    
//    return dataDict;
    
}



@end
