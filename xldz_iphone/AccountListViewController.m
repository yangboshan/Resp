//
//  AccountListViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-17.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "AccountListViewController.h"

#import "Navbar.h"
#import "SSCheckBoxView.h"
#import "MySectionHeaderView.h"

#import "AccountViewController.h"
#import "UIButton+Bootstrap.h"

@interface AccountListViewController () <AccountViewControllerDelegate>
{
    AccountListType accountListType;
    NSMutableArray *selectedAccounts;
}

@end

@implementation AccountListViewController

- (id)initWithType:(AccountListType)type {
    self = [super init];
    if (self) {
        accountListType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setNewTitle:@"用户列表"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];

    if (accountListType == AccountListTypeEdit) {
        self.button1.frame = CGRectMake(60, 10, 85, 30);
        self.button2.frame = CGRectMake(175, 10, 85, 30);
        [self.button1 setTitle:@"新建用户" forState:UIControlStateNormal];
        [self.button2 setTitle:@"编辑" forState:UIControlStateNormal];
        [self.button1 okStyle];
        [self.button2 normalStyle];
        self.button3.hidden = YES;
        self.button4.hidden = YES;
        
        [self.button1 addTarget:self action:@selector(createNewUser:) forControlEvents:UIControlEventTouchUpInside];
        [self.button2 addTarget:self action:@selector(toggleEdit:) forControlEvents:UIControlEventTouchUpInside];
    } else if (accountListType == AccountListTypeSwitch) {
        self.bottomView.hidden = YES;
        self.tableView.frame = CGRectUnion(self.tableView.frame, self.bottomView.frame);
    } else if (accountListType == AccountListTypeSelect) {
        self.button1.frame = CGRectMake(117.5, 10, 85, 30);
        [self.button1 setTitle:@"确认" forState:UIControlStateNormal];
        [self.button1 okStyle];
        [self.button1 addTarget:self action:@selector(onSelectOK:) forControlEvents:UIControlEventTouchUpInside];
        self.button2.hidden = YES;
        self.button3.hidden = YES;
        self.button4.hidden = YES;
        selectedAccounts = [NSMutableArray array];
    }
    
    [self initData];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    [self.tableView reloadData];
    
    [self.button2 setTitle:(editing ? @"取消": @"编辑") forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    
//    [self.tableView reloadData];
//}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initData
{
    NSMutableArray *array;
    if (accountListType == AccountListTypeSelect || !self.line) {
        array = [[[XLModelDataInterface testData] getAllUserBasicInfo] mutableCopy];
    } else {
        array = [[[XLModelDataInterface testData] queryUserForLine:self.line] mutableCopy];
    }
    if (accountListType == AccountListTypeSelect && self.line) {
        [array removeObjectsInArray:[[XLModelDataInterface testData] queryUserForLine:self.line]];
    }
    
    self.userArray = [NSMutableArray array];
    for (XLViewDataUserBaiscInfo *user in array) {
        if (accountListType == AccountListTypeSwitch && !user.attention) {
            continue;
        }
        BOOL online = NO;
        NSArray *devices = [[XLModelDataInterface testData] queryDevicesForUser:user];
        for (XLViewDataDevice *device in devices) {
            if ([[XLModelDataInterface testData] isDeviceOnline:device]) {
                online = YES;
                break;
            }
        }
        user.online = online;
        
        [self.userArray addObject:user];
    }
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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 170, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"用户名";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(190, 0, 70, 30)];
    label2.textColor = [UIColor whiteColor];
    label2.backgroundColor = [UIColor clearColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"状态";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = (accountListType == AccountListTypeSelect) ? @"选择" : @"关注";
    
    MySectionHeaderView *view = [[MySectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor blackColor];
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:label3];
    
    if (self.isEditing) {
        CGRect frame = label1.frame;
        frame.origin.x += 38;
        frame.size.width -= 38;
        label1.frame = frame;
    }
    
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.userArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UIImageView *statusImg;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;

        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 170, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        statusImg = [[UIImageView alloc] initWithFrame:CGRectMake(190, 0, 70, 44)];
        statusImg.contentMode = UIViewContentModeCenter;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        
        nameLabel.tag = 551;
        statusImg.tag = 552;
        checkBox.tag = 553;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:statusImg];
        [cell.contentView addSubview:checkBox];
        
        [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        statusImg = (UIImageView *)[cell.contentView viewWithTag:552];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    }
    
    XLViewDataUserBaiscInfo *user = [self.userArray objectAtIndex:indexPath.row];
    
    nameLabel.text = user.userName;
    statusImg.image = [UIImage imageNamed:(user.online ? @"wifi-icon" : @"wifi-off-icon")];
    checkBox.userInteractionEnabled = !self.isEditing;
    if (accountListType == AccountListTypeSelect) {
        checkBox.checked = [selectedAccounts containsObject:user];
    } else {
        checkBox.checked = user.attention;
    }
    
    CGRect frame = nameLabel.frame;
    frame.size.width = 170;
    if (self.isEditing) {
        frame.size.width -= 38;
    }
    nameLabel.frame = frame;
    
    frame = statusImg.frame;
    frame.origin.x = 190;
    if (self.isEditing) {
        frame.origin.x -= 38;
    }
    statusImg.frame = frame;
    
    frame = checkBox.frame;
    frame.origin.x = 260 + 13;
    if (self.isEditing) {
        frame.origin.x -= 38;
    }
    checkBox.frame = frame;
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isEditing;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        XLViewDataUserBaiscInfo *user = [self.userArray objectAtIndex:indexPath.row];
        [self.userArray removeObject:user];
        [[XLModelDataInterface testData] deleteUserBasicInfo:user.userId];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SSCheckBoxView *checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    checkBox.hidden = YES;
    
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (!indexPath) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    SSCheckBoxView *checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    checkBox.hidden = NO;
}

- (void)checkBoxViewChangedState:(SSCheckBoxView *)cbv
{
    CGRect rect = [cbv convertRect:cbv.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        XLViewDataUserBaiscInfo *user = [self.userArray objectAtIndex:indexPath.row];
        
        if (accountListType == AccountListTypeSelect) {
            if (cbv.checked) {
                [selectedAccounts addObject:user];
            } else {
                [selectedAccounts removeObject:user];
            }
        } else {
            user.attention = cbv.checked;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XLViewDataUserBaiscInfo *user = [self.userArray objectAtIndex:indexPath.row];
    
    if (accountListType == AccountListTypeSwitch) {
        [XLModelDataInterface testData].currentUser = user;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        AccountViewController *controller = [[AccountViewController alloc] init];
        controller.userInfo = user;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)toggleEdit:(id)sender
{
    [self setEditing:!self.isEditing animated:YES];
}

- (IBAction)createNewUser:(id)sender
{
    AccountViewController *controller = [[AccountViewController alloc] init];
    controller.createDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)accountViewController:(AccountViewController *)controller onCreateUser:(XLViewDataUserBaiscInfo *)user
{
    user.line = self.line;
    [[XLModelDataInterface testData] createUserBasicInfo:user];
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self.userArray addObject:user];
    [self.tableView reloadData];
}

- (IBAction)onSelectOK:(id)sender
{
    NSAssert(self.selectDelegate != nil, @"selectDelegate can't be nil");
    [self.selectDelegate accountListViewController:self onSelectUsers:selectedAccounts];
}

@end
