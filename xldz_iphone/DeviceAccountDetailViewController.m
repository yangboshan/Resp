//
//  DeviceAccountDetailViewController.m
//  XLApp
//
//  Created by sureone on 4/1/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "DeviceAccountDetailViewController.h"
#import "UIButton+Bootstrap.h"

#import "MBProgressHUD.h"
#import "Navbar.h"
@interface DeviceAccountDetailViewController ()

@end

@implementation DeviceAccountDetailViewController

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
    [self.navigationItem setNewTitle:_theTitle];
    [self.view setBackgroundColor:[UIColor blackColor]];

    
    [self.btnSave successStyle];
        [self.btnDel dangerStyle];
    
    
    
           [self.btnSave addTarget:self action:@selector(saveAccount:) forControlEvents:UIControlEventTouchUpInside];
    
           [self.btnDel addTarget:self action:@selector(delAccount:) forControlEvents:UIControlEventTouchUpInside];
    
    self.swOperation.on=NO;
        self.swQuery.on=NO;
        self.swSetup.on=NO;
    if([_editMode isEqualToString:@"new"]){
        self.btnDel.hidden=YES;
    }else{
        self.tvName.text = [_accountDict objectForKey:@"name"];
        
        
        if([[_accountDict objectForKey:@"setup"] isEqualToString:@"YES"]){
            self.swSetup.on=YES;
        }
        if([[_accountDict objectForKey:@"query"] isEqualToString:@"YES"]){
            self.swQuery.on=YES;
        }
        if([[_accountDict objectForKey:@"operation"] isEqualToString:@"YES"]){
            self.swOperation.on=YES;
        }
    }
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)delAccount:(id)sender
{
    
}

- (IBAction)editAccount:(id)sender
{
    
}

@end
