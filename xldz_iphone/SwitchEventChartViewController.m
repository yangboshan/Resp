//
//  SwitchEventChartViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-14.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SwitchEventChartViewController.h"

#import "Navbar.h"

@interface SwitchEventChartViewController ()

@end

@implementation SwitchEventChartViewController

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
	
    [self.navigationItem setNewTitle:@"录波曲线"];
    
    self.view.backgroundColor = [UIColor redColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
