//
//  PostViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "PostViewController.h"

#import "Navbar.h"
#import "JMWhenTapped.h"

@interface PostViewController () <UITextViewDelegate>

@property (nonatomic) UIView *headerView;

@end

static NSString *CellIdentifier = @"Cell";

@implementation PostViewController
@synthesize headerView = _headerView;

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
    
    
    [self.navigationItem setNewTitle:@"详细信息"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorColor = [UIColor listDividerColor];
    self.tableView.backgroundColor = [UIColor blackColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    //去除UITableView中多余的separator
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    
    [self.tableView whenTapped:^{
        [self.inputTextView resignFirstResponder];
    }];
    
    UINib *nib = [UINib nibWithNibName:@"PostTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier];
    
    self.inputTextView.delegate = self;
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

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[NSBundle mainBundle] loadNibNamed:@"PostTableViewHeader" owner:self options:nil][0];
        _headerView.backgroundColor = [UIColor blackColor];
    }
    return _headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.headerView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.backgroundColor = [UIColor listItemBgColor];
    
    return cell;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect cf = [self.view convertRect:self.view.bounds toView:keyWindow];
    CGFloat delta = 216 - CGRectGetHeight(keyWindow.frame) + CGRectGetMaxY(cf);//键盘高度216
    if (delta > 0) {
        CGRect rect1 = self.tableView.frame;
        rect1.size.height -= delta;
        
        CGRect rect2 = self.inputTextView.frame;
        rect2.origin.y -= delta;
        
        CGRect rect3 = self.sendBtn.frame;
        rect3.origin.y -= delta;
        
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.tableView.frame = rect1;
        self.inputTextView.frame = rect2;
        self.sendBtn.frame = rect3;
        [UIView commitAnimations];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CGRect rect2 = self.inputTextView.frame;
    rect2.origin.y = self.view.bounds.size.height - rect2.size.height;
    self.inputTextView.frame = rect2;
    
    CGRect rect3 = self.sendBtn.frame;
    rect3.origin.y = self.view.bounds.size.height - rect3.size.height;;
    self.sendBtn.frame = rect3;
    
    CGRect rect1 = self.tableView.frame;
    rect1.size.height = rect3.origin.y;
    self.tableView.frame = rect1;
}

@end
