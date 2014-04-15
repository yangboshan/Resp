//
//  HomeUserIndustryCompareViewController.m
//  XLApp
//
//  Created by sureone on 2/18/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "HomeUserIndustryCompareViewController.h"
#import "Navbar.h"

@interface HomeUserIndustryCompareViewController ()

@end

@implementation HomeUserIndustryCompareViewController
{
    BOOL navbarHidden;
}

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
    self.title = @"行业对标";
    [self.navigationItem setNewTitle:@"行业对标"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    UIBarButtonItem *returnButtonItem = [[UIBarButtonItem alloc] init];
    returnButtonItem.title = @"返回";
    self.navigationItem.backBarButtonItem = returnButtonItem;
    
    if (IOS_VERSION_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    navbarHidden = self.navigationController.navigationBarHidden;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = navbarHidden;
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

@end
