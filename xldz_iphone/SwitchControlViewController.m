//
//  SwitchControlViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-14.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "SwitchControlViewController.h"
#import <AudioToolbox/AudioServices.h>

#import "Navbar.h"
#import "UIButton+Bootstrap.h"
#import "MySectionHeaderView.h"
#import "SSCheckBoxView.h"

@interface SwitchControlViewController ()
{
    NSArray *controlArray;
    NSInteger selectedIndex;
    
    NSArray *dropdownOptions;
    
    NSString *notifKey;
}

@property (nonatomic) BOOL hasPreseted;

@end

@implementation SwitchControlViewController
@synthesize hasPreseted = _hasPreseted;

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
    
    [self.navigationItem setNewTitle:@"控制操作"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];

    dropdownOptions = [NSArray arrayWithObjects:@"分", @"合", nil];
	
    self.button1.frame = CGRectMake(20, 10, 80, 30);
    self.button2.frame = CGRectMake(120, 10, 80, 30);
    self.button3.frame = CGRectMake(220, 10, 80, 30);
    self.button4.hidden = YES;
    [self.button1 setTitle:@"遥控预置" forState:UIControlStateNormal];
    [self.button2 setTitle:@"遥控执行" forState:UIControlStateNormal];
    [self.button3 setTitle:@"遥控取消" forState:UIControlStateNormal];
    [self.button1 normalStyle];
    [self.button2 okStyle];
    [self.button3 cancelStyle];
    [self.button1 addTarget:self action:@selector(presetRemoteControls:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(executeRemoteControls:) forControlEvents:UIControlEventTouchUpInside];
    [self.button3 addTarget:self action:@selector(cancelRemoteControls:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.allowsSelection = NO;

    
    selectedIndex = NSNotFound;
    self.hasPreseted = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOperation:) name:XLViewOperationDone object:nil];
    notifKey = [NSString stringWithFormat:@"开关%@-控制操作", self.device.deviceId];
    [self initData];
}

- (void)handleOperation:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:@"遥控执行"] || [NotificationName(dic) isEqualToString:@"遥控取消"]) {
        NSString *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:result
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:notifKey, @"xl-name", nil];
    [self.device queryRemoteControls:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            //[refreshHeader endRefreshing];
            
            selectedIndex = NSNotFound;
            controlArray = result;
            [self.tableView reloadData];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setHasPreseted:(BOOL)hasPreseted
{
    _hasPreseted = hasPreseted;
    
    self.button2.enabled = hasPreseted;
    self.button3.enabled = hasPreseted;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 60, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"遥控号";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(180, 0, 80, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = @"遥控操作";
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label4.textColor = [UIColor whiteColor];
    label4.backgroundColor = [UIColor clearColor];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.text = @"选择";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label3];
    [view addSubview:label4];
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return controlArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ControlCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *noLabel;
    UISwitch *dropDownView;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        noLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 60, 44)];
        noLabel.textColor = [UIColor textWhiteColor];
        noLabel.backgroundColor = [UIColor clearColor];
        noLabel.textAlignment = NSTextAlignmentCenter;
        CGRect rect = CGRectMake(180, 7, 80, 30);
        dropDownView = [[UISwitch alloc] initWithFrame:rect];
        CGPoint center = dropDownView.center;
        center.x = CGRectGetMidX(rect);
        center.y =  CGRectGetMidY(rect);
        dropDownView.center = center;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        
        nameLabel.tag = 551;
        noLabel.tag = 552;
        dropDownView.tag = 553;
        checkBox.tag = 554;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:noLabel];
        [cell.contentView addSubview:dropDownView];
        [cell.contentView addSubview:checkBox];
        
        [dropDownView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        noLabel = (UILabel *)[cell.contentView viewWithTag:552];
        dropDownView = (UISwitch *)[cell.contentView viewWithTag:553];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:554];
    }
    
    NSMutableDictionary *control = [controlArray objectAtIndex:indexPath.row];
    nameLabel.text = [control objectForKey:@"名称"];
    noLabel.text = [control objectForKey:@"遥控号"];
    dropDownView.on = [[control objectForKey:@"遥控操作"] isEqualToString:@"合"];
    dropDownView.enabled = selectedIndex == indexPath.row;
    checkBox.checked = selectedIndex == indexPath.row;
    
    return cell;
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        //NSMutableDictionary *control = [controlArray objectAtIndex:indexPath.row];
        NSInteger oldSelectedIndex = selectedIndex;
        
        if (cbv.checked) {
            selectedIndex = indexPath.row;
        } else {
            selectedIndex = NSNotFound;
        }
        self.hasPreseted = NO;
        
        if (oldSelectedIndex != NSNotFound) {
            NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:oldSelectedIndex inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)switchAction:(id)sender
{
    UISwitch *view = sender;
    CGRect rect = [view convertRect:view.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSMutableDictionary *control = [controlArray objectAtIndex:indexPath.row];
        [control setObject:(view.on ? @"合" : @"分") forKey:@"遥控操作"];
    }
}

//#pragma mark - Drop Down Selector Delegate
//
//- (BOOL)dropDownControlViewWillBecomeActive:(LHDropDownControlView *)view  {
//    self.tableView.scrollEnabled = NO;
//    return YES;
//}
//
//- (void)dropDownControlView:(LHDropDownControlView *)view didFinishWithSelection:(id)selection {
//    self.tableView.scrollEnabled = YES;
//    
//    CGRect rect = [view convertRect:view.bounds toView:self.tableView];
//    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
//    if (indexPath && selection) {
//        NSMutableDictionary *control = [controlArray objectAtIndex:indexPath.row];
//        [control setObject:selection forKey:@"遥控操作"];
//        view.title = selection;
//    }
//}


- (IBAction)presetRemoteControls:(id)sender
{
    if (selectedIndex < controlArray.count) {
        [self.device presetRemoteControls:controlArray[selectedIndex]];
        self.hasPreseted = YES;
    }
}

- (IBAction)executeRemoteControls:(id)sender
{
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    static SystemSoundID soundIDTest = kSystemSoundID_Vibrate;
    NSString * path = [[NSBundle mainBundle] pathForResource:@"alert" ofType:@"wav"];
    if (path) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundIDTest);
    }
    AudioServicesPlaySystemSound(soundIDTest);
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"遥控执行", @"xl-name", nil];
    [self.device executeRemoteControls:dic];
}

- (IBAction)cancelRemoteControls:(id)sender
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"遥控取消", @"xl-name", nil];
    [self.device cancelRemoteControls:dic];
}

@end
