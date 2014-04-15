//
//  TestPointEnergyDetailViewController.m
//  XLApp
//
//  Created by sureone on 2/25/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "TestPointEnergyDetailViewController.h"
#import "Navbar.h"
#import "XLModelDataInterface.h"
#import "MBProgressHUD.h"

@interface TestPointEnergyDetailViewController ()

@property (nonatomic,retain) NSMutableArray *arrayXB;
@end

@implementation TestPointEnergyDetailViewController

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
    
    if(self.arrayXB==nil){
        self.arrayXB = [[NSMutableArray alloc]initWithCapacity:6*19];
    }
    
    CGRect origRc = self.viewVoltage.frame;
    self.viewVoltage.frame=CGRectMake(0, 0, origRc.size.width,origRc.size.height);
    [self.viewScrollContainer addSubview:self.viewVoltage];
    
    
    self.viewBalence.frame=CGRectMake(0,
                                     _viewVoltage.frame.origin.y+_viewVoltage.frame.size.height+10, _viewBalence.frame.size.width,_viewBalence.frame.size.height);
    [self.viewScrollContainer addSubview:self.viewBalence];
    
    //
    self.viewXB.frame=CGRectMake(0, _viewBalence.frame.origin.y+_viewBalence.frame.size.height+10, _viewXB.frame.size.width,_viewXB.frame.size.height);

    
    
    CGSize size = self.viewXB.frame.size;
    
    CGPoint nlocation = self.viewXB.frame.origin;
    CGPoint vlocation = self.viewXB.frame.origin;

    float nwidth,nhight,vwidth,vhight;
    
    nwidth = 50;
    nhight=29;
    vhight=29;
    vwidth=27;
    
    nlocation.y=62;
    nlocation.x=0;
    
    vlocation.y=62;
    vlocation.x=57;
    
    float xOffset=46;
    float yOffset=4;
    
    


    for(int i=1;i<20;i++){
        
        
        
        UILabel* name = [[UILabel alloc]initWithFrame:CGRectMake(nlocation.x, nlocation.y, nwidth, nhight)];
        if(i>1)
            name.text=[[NSString alloc]initWithFormat:@"%d次谐波越限时间",i];
        else
            name.text=[[NSString alloc]initWithFormat:@"总谐波越限时间"];
        name.textColor=[UIColor whiteColor];
        name.font=[UIFont systemFontOfSize:12];
                [self.viewXB addSubview:name];
        name.lineBreakMode=NSLineBreakByWordWrapping;
        name.textAlignment=NSTextAlignmentCenter;
        name.numberOfLines=0;
        vlocation.x=57;
        
        NSArray* ids = [NSArray arrayWithObjects:@"va",@"vb",@"vc",@"ca",@"cb",@"cc",nil];
        
        for(int j=0;j<6;j++){
                UILabel* value = [[UILabel alloc]initWithFrame:CGRectMake(vlocation.x, vlocation.y, vwidth, vhight)];
            vlocation.x+=xOffset;
            
            [self.arrayXB addObject:value];
            
            value.restorationIdentifier=[NSString stringWithFormat:@"xb-%d-%@",i-1,(NSString*)[ids objectAtIndex:j]];

            value.text=@"-";
            value.textColor=[UIColor greenColor];
            value.font=[UIFont systemFontOfSize:12];

            value.lineBreakMode=NSLineBreakByWordWrapping;
            value.textAlignment=NSTextAlignmentCenter;
            value.numberOfLines=0;
            
            [self.viewXB addSubview:value];
        }
        
        nlocation.y+=nhight;
        vlocation.y+=nhight;
        
        nlocation.y+=yOffset;
        vlocation.y+=yOffset;
        
        UILabel* line = [[UILabel alloc]initWithFrame:CGRectMake(2, nlocation.y, 316, 0.5)];
        line.backgroundColor=[UIColor lightGrayColor];
        
        [self.viewXB addSubview:line];
        
        nlocation.y+=yOffset;
        vlocation.y+=yOffset;

        
    }
        self.viewXB.frame=CGRectMake(0, _viewBalence.frame.origin.y+_viewBalence.frame.size.height+10, _viewXB.frame.size.width,nlocation.y);
        [self.viewScrollContainer addSubview:self.viewXB];
    
    self.viewScrollContainer.contentSize = CGSizeMake(320, _viewXB.frame.origin.y+nlocation.y);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTheNotify:) name:XLViewDataNotification object:nil];
    
    [self requestDataFromDevice:_tpNo withDate:nil];


}


- (void)requestDataFromDevice:(NSString*)testPointId withDate:(NSDate*)theDate
{
    
    NSMutableDictionary *notificationDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSString stringWithFormat:@"energy-detail"], @"xl-name",
                                            theDate, @"time",
                                            testPointId,@"tpId",
                                            nil];
    
    [self showLoadingProgress];
    
    [[XLModelDataInterface testData] requestEnergyDetailData:notificationDic];
    
    
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
    
    if (![[param objectForKey:@"xl-name"] isEqualToString:@"energy-detail"]) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleDeviceData:result];
        [self hideLoadingProgress];
        
    });
    
    
}

-(void)handleDeviceData:(NSDictionary*)dataDict{
    
    NSArray *views = [NSArray arrayWithObjects:_viewBalence,_viewVoltage,_viewXB, nil];
    
    NSArray *xbs = [dataDict objectForKey:@"xbyx"];
    for (UIView *subview in views) {
        if ([subview isKindOfClass:[UIView class]]) {
            for (UIView *labelView in subview.subviews) {
                if ([labelView isKindOfClass:[UILabel class]]) {
                    UILabel *key = (UILabel *)labelView;
                    NSString *ident = key.restorationIdentifier;
                    
                    

                    
                    if(ident!=nil){
                        if([ident hasPrefix:@"xb-"]){
                            
                            
                            NSString *subString;
                            NSScanner *scanner = [NSScanner scannerWithString:ident];
                            [scanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:nil];
                            [scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&subString];
                            
                            int index = [subString integerValue];
                            
                            NSDictionary* item = [xbs objectAtIndex:index];
                            
                            subString= [ident substringWithRange:NSMakeRange(ident.length-2, 2)];
                            
                            NSString* value = [item objectForKey:subString];
                            if(value==nil) value = @"-";
                            key.text = value;
                            
                            
                            
                        }else{
                            NSString* value = [dataDict objectForKey:ident];
                            if(value==nil) value = @"-";
                            key.text = value;
                        }
                        
                    }
                    NSLog(@"%@",ident);
                }
            }
        }
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
