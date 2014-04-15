//
//  AppSettingViewController.m
//  XLApp
//
//  Created by sureone on 4/1/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "AppSettingViewController.h"
#import "navbar.h"

@interface AppSettingViewController ()

@end

@implementation AppSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setNewTitle:@"应用设置"];
    
   
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}




#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{

    
    return 32.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    if(section==0)
        return 2;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell= [self.tableView dequeueReusableCellWithIdentifier:@"setting-cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"setting-cell"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        [cell.contentView setBackgroundColor:[UIColor blackColor]];
        
        if ([indexPath section] == 0) {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(250, 10, 60, 30)];
            textField.adjustsFontSizeToFitWidth = YES;
            textField.textColor = [UIColor blackColor];
            if ([indexPath row] == 0) {
                
                textField.placeholder = @"30";
                textField.keyboardType = UIKeyboardTypeDecimalPad;
                textField.returnKeyType = UIReturnKeyNext;
                
                
            }
            if ([indexPath row] == 1) {
                
                    textField.placeholder = @"40";
                    textField.keyboardType = UIKeyboardTypeDecimalPad;
                    textField.returnKeyType = UIReturnKeyDone;
            }
            
            textField.backgroundColor = [UIColor whiteColor];
            textField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
            textField.textAlignment = UITextAlignmentRight;
            textField.tag = 0;
            //textField = self;
            
            textField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
            [textField setEnabled: YES];
            
            [cell.contentView addSubview:textField];
                
            
        }
    }
    if ([indexPath section] == 0) { // Email & Password Section
        [cell.textLabel setTextColor:[UIColor lightGrayColor]];
        if ([indexPath row] == 0) { // Email
            cell.textLabel.text = @"存储容量限制(M)";
        }
        if ([indexPath row] == 1){
            cell.textLabel.text = @"数据流量限制(M)";
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

        if (section == 0)
        {
            return @"数据限制";
        }

    return @"";
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath      *)indexPath;
{
    /// Here you can set also height according to your section and row
    
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
