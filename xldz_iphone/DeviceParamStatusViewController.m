//
//  DeviceParamStatusViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-20.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceParamStatusViewController.h"

#import "Navbar.h"
#import "SSCheckBoxView.h"

@interface DeviceParamStatusViewController ()
{
    NSString *notifKey;
    
    CGFloat gridWidth, gridHeight;
}
@property (nonatomic) NSArray *statusArray;
@end

@implementation DeviceParamStatusViewController

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

	[self.navigationItem setNewTitle:@"终端参数状态"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    gridWidth = 50;
    gridHeight = 80;
    self.gridView = [[NRGridView alloc] initWithLayoutStyle:NRGridViewLayoutStyleVertical];
    self.gridView.frame = self.view.bounds;
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.gridView.backgroundColor = [UIColor blackColor];
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    [self.gridView setCellSize:CGSizeMake(gridWidth, gridHeight)];
    [self.view addSubview:self.gridView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"设备%@-终端参数状态", self.device.deviceId];
    [self initData];
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

- (void)initData
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         notifKey, @"xl-name",
                         nil];
    [self.device queryParamStatus:dic];
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSArray *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
//            [refreshHeader endRefreshing];
            
            self.statusArray = result;
            [self.gridView reloadData];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NRGridView Data Source
- (NSInteger)numberOfSectionsInGridView:(NRGridView *)gridView
{
    return 1;
}

- (NSInteger)gridView:(NRGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return self.statusArray.count;
}

- (NRGridViewCell*)gridView:(NRGridView *)gridView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *GridCellIdentifier = @"GridCellIdentifier";
    
    NRGridViewCell* cell = [gridView dequeueReusableCellWithIdentifier:GridCellIdentifier];
    
    UILabel *titleLabel;
    SSCheckBoxView *checkBox;
    if(cell == nil){
        cell = [[NRGridViewCell alloc] initWithReuseIdentifier:GridCellIdentifier];
        cell.selectionBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, gridWidth - 10, 30)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor textWhiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(9, 39, 32, 32)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
//        titleLabel.backgroundColor = [UIColor blueColor];
//        checkBox.backgroundColor = [UIColor redColor];
        checkBox.userInteractionEnabled = NO;

        
        titleLabel.tag = 551;
        checkBox.tag = 552;
        [cell.contentView addSubview:titleLabel];
        [cell.contentView addSubview:checkBox];
    } else {
        titleLabel = (UILabel *)[cell.contentView viewWithTag:551];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:552];
    }
    
    NSDictionary *item = [self.statusArray objectAtIndex:indexPath.row];
    titleLabel.text = [item objectForKey:@"title"];
    BOOL on = [[item objectForKey:@"status"] boolValue];
    checkBox.checked = on;
    
    return cell;
}

@end
