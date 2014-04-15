//
//  HomeUserBottomDetailViewController.m
//  XLApp
//
//  Created by sureone on 2/14/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "HomeUserBottomDetailViewController.h"

@interface HomeUserBottomDetailViewController ()

@end



@implementation HomeUserBottomDetailViewController{
    UIButton *basicBtn,*analysisBtn,*compareBtn,*relatedBtn;
}

@synthesize buttonsBarHolder;

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
    
    [self setupButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buttonPressed:(id)sender {
    NSLog(@"Button %@ has been pressed in tabView", sender);
}

-(void)setupButtons
{
    
    float width = self.view.frame.size.width;
    float height = self.buttonsBarHolder.frame.size.height;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [button setTitle:@"基本情况" forState:UIControlStateNormal];
    
    [button setFrame:CGRectMake(0,0,width/4,height)];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0, 0.0, 0.0 )];
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [buttonsBarHolder addSubview:button];
    
    basicBtn = button;
    
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [button setTitle:@"分析报告" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(width/4,0,width/4,height)];
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [buttonsBarHolder addSubview:button];
    
    analysisBtn = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [button setTitle:@"行业对标" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(width/2,0,width/4,height)];
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [buttonsBarHolder addSubview:button];
    
    compareBtn = button;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [button setTitle:@"相关设备" forState:UIControlStateNormal];
    [button setFrame:CGRectMake(width*3/4,0,width/4,height)];
    
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [buttonsBarHolder addSubview:button];
    
    relatedBtn = button;
    

   
    
    
    [basicBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [relatedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [compareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [analysisBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    UIImage * backgroundImg = [UIImage imageNamed:@"bottom_detail_button_middle_normal_bg.png"];
    
    //    backgroundImg = [backgroundImg resizableImageWithCapInsets:UIEdgeInsetsMake(2,2, 2, 2)];
    
    [analysisBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    [compareBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];

    
    backgroundImg = [UIImage imageNamed:@"botton_detail_button_left_normal_bg.png"];
    [basicBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    backgroundImg = [UIImage imageNamed:@"bottom_detail_button_right_normal_bg.png"];
    [relatedBtn setBackgroundImage:backgroundImg forState:UIControlStateNormal];
    
    
    
    
    
    
    
    
    //
    //    UIImage *image = [[UIImage imageNamed:@"tab_bar_bg"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //	[button setBackgroundImage:image forState:UIControlStateNormal];
    //	[button setBackgroundImage:image forState:UIControlStateHighlighted];
    
}


@end
