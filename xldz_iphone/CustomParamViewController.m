//
//  CustomParamViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-10.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "CustomParamViewController.h"

#import "MyTextField.h"

@interface CustomParamViewController ()
{
    BOOL inited;
}

@end

@implementation CustomParamViewController

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsSelection = NO;
    [self addHeader];
    
    self.button1.frame = CGRectMake(8, 10, 70, 30);
    self.button2.frame = CGRectMake(86, 10, 70, 30);
    self.button3.frame = CGRectMake(164, 10, 70, 30);
    self.button4.frame = CGRectMake(242, 10, 70, 30);
    [self.button1 setTitle:(self.isEditing ? @"完成" : @"编辑") forState:UIControlStateNormal];
    [self.button2 setTitle:@"保存" forState:UIControlStateNormal];
    [self.button3 setTitle:@"下发" forState:UIControlStateNormal];
    [self.button4 setTitle:@"召测" forState:UIControlStateNormal];
    [self.button1 normalStyle];
    [self.button2 okStyle];
    [self.button3 warningStyle];
    [self.button4 normalStyle];
    [self.button1 addTarget:self action:@selector(toggleEditing:) forControlEvents:UIControlEventTouchUpInside];
    [self.button2 addTarget:self action:@selector(saveParam:) forControlEvents:UIControlEventTouchUpInside];
    [self.button4 addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self initData];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!inited) {
        inited = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader beginRefreshing];
        });
    }
}

- (void)setEditing:(BOOL)editing
{
    [super setEditing:editing];
    
    [self.button1 setTitle:(self.isEditing ? @"完成" : @"编辑") forState:UIControlStateNormal];
}

- (void)initData
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addHeader
{
    __unsafe_unretained UIViewController *vc = self;
    refreshHeader = [MJRefreshHeaderView header];
    refreshHeader.scrollView = self.tableView;
    refreshHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc performSelector:@selector(initData) withObject:nil];
    };
}

//- (void)doneWithView:(MJRefreshBaseView *)refreshView
//{
//    [self refreshData:nil];
//    [refreshView endRefreshing];
//}

- (void)dealloc
{
    [refreshHeader free];
}

#pragma mark - Table view data source
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BasicParamCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UITextField *textField;
    CCComboBox *dropDownView;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        cell.backgroundView = bgview;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 110, 30)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.adjustsFontSizeToFitWidth = YES;
        textField = [[MyTextField alloc] initWithFrame:CGRectMake(150, 7, 150, 30)];
        textField.adjustsFontSizeToFitWidth = YES;
        textField.delegate = self;
        
//        dropDownView = [[LHDropDownControlView alloc] initWithFrame:CGRectMake(150, 7, 150, 30)];
//        dropDownView.delegate = self;
        dropDownView = [[CCComboBox alloc] initWithFrame:CGRectMake(150, 7, 150, 30)];
        dropDownView.delegate = self;
        
        nameLabel.tag = CELL_LABEL_TAG;
        textField.tag = CELL_TEXTFIELD_TAG;
        dropDownView.tag = CELL_DROPDOWNVIEW_TAG;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:textField];
        [cell.contentView addSubview:dropDownView];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:CELL_LABEL_TAG];
        textField = (UITextField *)[cell.contentView viewWithTag:CELL_TEXTFIELD_TAG];
        dropDownView = (CCComboBox *)[cell.contentView viewWithTag:CELL_DROPDOWNVIEW_TAG];
    }
    
    NSMutableDictionary *param = [self tableView:tableView paramForRowAtIndexPath:indexPath];
    BOOL editing = self.isEditing;
    if (editing && !param.editable) {
        editing = NO;
    }
    
    textField.enabled = editing;
    textField.hidden = NO;
    dropDownView.hidden = YES;
    
    nameLabel.text = param.paramName;
    switch (param.paramType) {
        case XLParamTypeString:
        textField.text = param.paramValue;
        textField.keyboardType = UIKeyboardTypeDefault;
        break;
        case XLParamTypeNumber:
        textField.text = param.paramValue;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        break;
        case XLParamTypeSpinner: {
            NSArray *listNames = param.listNames == nil ? param.listValues : param.listNames;
            NSUInteger index = [param.listValues indexOfObject:param.paramValue];
            NSString *str = index == NSNotFound ? @"" : [listNames objectAtIndex:index];
            textField.text = str;
            if (editing) {
                dropDownView.hidden = NO;
                textField.hidden = YES;
                
//                dropDownView.title = str;
//                [dropDownView setSelectionOptions:param.listValues withTitles:listNames];
                
                [dropDownView setDataArray:[listNames mutableCopy] selected:index];
            }
            
            break;
        }
        default:
        textField.text = @"未定义参数类型";
        textField.keyboardType = UIKeyboardTypeDefault;
        break;
    }
    
    return cell;
}

- (NSMutableDictionary *)tableView:(UITableView *)tableView paramForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect rect = [textField convertRect:textField.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSMutableDictionary *param = [self tableView:self.tableView paramForRowAtIndexPath:indexPath];
        param.paramValue = textField.text;
    }
}

#pragma mark - CCComboBoxDelegate

- (void)selected:(CCComboBox *)comboBox atIndex:(NSUInteger)index
{
    CGRect rect = [comboBox convertRect:comboBox.bounds toView:self.tableView];
    NSIndexPath *indexPath = [[self.tableView indexPathsForRowsInRect:rect] objectAtIndex:0];
    if (indexPath) {
        NSMutableDictionary *param = [self tableView:self.tableView paramForRowAtIndexPath:indexPath];
        param.paramValue = [param.listValues objectAtIndex:index];
    }
}

//#pragma mark - Drop Down Selector Delegate
//
//- (BOOL)dropDownControlViewWillBecomeActive:(LHDropDownControlView *)view  {
//    if (refreshHeader.isRefreshing) {
//        return NO;
//    }
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
//        NSMutableDictionary *param = [self tableView:self.tableView paramForRowAtIndexPath:indexPath];
//        param.paramValue = selection;
//        NSArray *listNames = param.listNames == nil ? param.listValues : param.listNames;
//        NSUInteger index = [param.listValues indexOfObject:param.paramValue];
//        NSString *str = index == NSNotFound ? @"" : [listNames objectAtIndex:index];
//        view.title = str;
//    }
//}

- (IBAction)toggleEditing:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    self.editing = !self.isEditing;
    [self.tableView reloadData];
}

- (IBAction)saveParam:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    self.editing = NO;
    [self.tableView reloadData];
}

- (IBAction)refreshData:(id)sender
{
    [self initData];
    //[self.tableView reloadData];
}


@end
