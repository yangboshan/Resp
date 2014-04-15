//
//  LineListViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "LineListViewController.h"

#import "Navbar.h"
#import "UIButton+Bootstrap.h"
#import "MySectionHeaderView.h"
#import "SSCheckBoxView.h"
#import "LineViewController.h"

@interface LineListViewController () <LineViewControllerDelegate>
{
    LineListType lineListType;
    NSMutableArray *selecedLines;
}

@end

@implementation LineListViewController

- (id)initWithType:(LineListType)type
{
    self = [super init];
    if (self) {
        lineListType = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.navigationItem setNewTitle:@"线路列表"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    if (lineListType == LineListTypeEdit) {
        self.button1.frame = CGRectMake(60, 10, 85, 30);
        self.button2.frame = CGRectMake(175, 10, 85, 30);
        [self.button1 setTitle:@"新建线路" forState:UIControlStateNormal];
        [self.button2 setTitle:@"编辑" forState:UIControlStateNormal];
        [self.button1 okStyle];
        [self.button2 normalStyle];
        self.button3.hidden = YES;
        self.button4.hidden = YES;
        
        [self.button1 addTarget:self action:@selector(createLine:) forControlEvents:UIControlEventTouchUpInside];
        [self.button2 addTarget:self action:@selector(toggleEdit:) forControlEvents:UIControlEventTouchUpInside];
    } else if (lineListType == LineListTypeeSwitch) {
        self.bottomView.hidden = YES;
        self.tableView.frame = CGRectUnion(self.tableView.frame, self.bottomView.frame);
    } else if (lineListType == LineListTypeSelect) {
        self.button1.frame = CGRectMake(117.5, 10, 85, 30);
        [self.button1 setTitle:@"确认" forState:UIControlStateNormal];
        [self.button1 okStyle];
        [self.button1 addTarget:self action:@selector(onSelectOK:) forControlEvents:UIControlEventTouchUpInside];
        self.button2.hidden = YES;
        self.button3.hidden = YES;
        self.button4.hidden = YES;
        selecedLines = [NSMutableArray array];;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)initData
//{
//    NSArray *array = [[XLModelDataInterface testData] queryAllLines];
//    self.lineArray = [NSMutableArray arrayWithArray:array];
//}

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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 140, 30)];
    label1.textColor = [UIColor whiteColor];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = @"名称";
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 100, 30)];
    label2.backgroundColor = [UIColor clearColor];
    label2.textColor = [UIColor whiteColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"线路ID";
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(260, 0, 60, 30)];
    label3.textColor = [UIColor whiteColor];
    label3.backgroundColor = [UIColor clearColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.text = lineListType == LineListTypeSelect ? @"选择" : @"关注";
    
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
    return self.lineArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    UILabel *nameLabel;
    UILabel *noLabel;
    SSCheckBoxView *checkBox;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor listItemBgColor];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 140, 44)];
        nameLabel.textColor = [UIColor textWhiteColor];
        nameLabel.backgroundColor = [UIColor clearColor];
        noLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 100, 44)];
        noLabel.backgroundColor = [UIColor clearColor];
        noLabel.textColor = [UIColor textWhiteColor];
        noLabel.textAlignment = NSTextAlignmentCenter;
        checkBox = [[SSCheckBoxView alloc] initWithFrame:CGRectMake(260 + 13, 0, 47, 44)
                                                   style:kSSCheckBoxViewStyleCircle
                                                 checked:NO];
        
        nameLabel.tag = 551;
        noLabel.tag = 552;
        checkBox.tag = 553;
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:noLabel];
        [cell.contentView addSubview:checkBox];
        
        [checkBox setStateChangedTarget:self selector:@selector(checkBoxViewChangedState:)];
    } else {
        nameLabel = (UILabel *)[cell.contentView viewWithTag:551];
        noLabel = (UILabel *)[cell.contentView viewWithTag:552];
        checkBox = (SSCheckBoxView *)[cell.contentView viewWithTag:553];
    }
    
    XLViewDataLine *line = [self.lineArray objectAtIndex:indexPath.row];
    
    nameLabel.text = line.lineName;
    noLabel.text = line.lineNo;
    checkBox.userInteractionEnabled = !self.isEditing;
    if (lineListType == LineListTypeSelect) {
        checkBox.checked = [selecedLines containsObject:line];
    } else {
        checkBox.checked = line.attention;
    }
    
    CGRect frame = nameLabel.frame;
    frame.size.width = 140;
    if (self.isEditing) {
        frame.size.width -= 38;
    }
    nameLabel.frame = frame;
    
    frame = noLabel.frame;
    frame.origin.x = 160;
    if (self.isEditing) {
        frame.origin.x -= 38;
    }
    noLabel.frame = frame;
    
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
    XLViewDataLine *line = [self.lineArray objectAtIndex:indexPath.row];
    if (line.isDefault) {
        return UITableViewCellEditingStyleNone;
    }
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        XLViewDataLine *line = [self.lineArray objectAtIndex:indexPath.row];
        [self.lineArray removeObject:line];
        [[XLModelDataInterface testData] deleteLine:line.lineId];
        
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
        XLViewDataLine *line = [self.lineArray objectAtIndex:indexPath.row];
        if (lineListType == LineListTypeSelect) {
            if (cbv.checked) {
                [selecedLines removeObject:line];
            } else {
                [selecedLines addObject:line];
            }
        } else {
            line.attention = cbv.checked;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    XLViewDataLine *line = [self.lineArray objectAtIndex:indexPath.row];
    if (lineListType == LineListTypeeSwitch) {
        [XLModelDataInterface testData].currentLine = line;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        LineViewController *controller = [[LineViewController alloc] init];
        controller.lineInfo = line;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (IBAction)toggleEdit:(id)sender
{
    [self setEditing:!self.isEditing animated:YES];
}

- (IBAction)createLine:(id)sender
{
    LineViewController *controller = [[LineViewController alloc] init];
    controller.createDelegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)lineViewController:(LineViewController *)controller onCreateLine:(XLViewDataLine *)line
{
    line.system = self.system;
    [[XLModelDataInterface testData] createLine:line];
    
    //[self.navigationController popViewControllerAnimated:YES];
    [self.lineArray addObject:line];
    [self.tableView reloadData];
}

- (IBAction)onSelectOK:(id)sender
{
    NSAssert(self.selectDelegate != nil, @"selectDelegate can't be nil");
    [self.selectDelegate lineListViewController:self onSelectLines:selecedLines];
}

@end
