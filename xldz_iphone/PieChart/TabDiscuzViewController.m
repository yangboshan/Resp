//
//  TabDiscuzViewController.m
//  XLApp
//
//  Created by sureone on 2/16/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "TabDiscuzViewController.h"

#import "NRGridView.h"
#import "UIButton+Bootstrap.h"

@interface TabDiscuzViewController () <NRGridViewDataSource, NRGridViewDelegate>
{
    NSArray *boards;
}

@property (nonatomic, retain) IBOutlet NRGridView *gridView;

@end

@implementation TabDiscuzViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"论坛";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"discuz_icon";
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.bounds;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    frame = view.bounds;
    frame.origin.x = 10;
    frame.origin.y = 10;
    frame.size.width -= 20;
    frame.size.height -= 20;
    self.gridView = [[NRGridView alloc] initWithLayoutStyle:NRGridViewLayoutStyleVertical];
    self.gridView.frame = frame;
    self.gridView.backgroundColor = [UIColor clearColor];
    self.gridView.dataSource = self;
    self.gridView.delegate = self;
    [self.gridView setCellSize:CGSizeMake(150, 150)];
    [view addSubview:self.gridView];
    
    FBoard *board1 = [[FBoard alloc] init];
    board1.title = @"运维交流版块";
    board1.newPostNum = 100;
    FBoard *board2 = [[FBoard alloc] init];
    board2.title = @"安装交流版块";
    board2.newPostNum = 100;
    FBoard *board3 = [[FBoard alloc] init];
    board3.title = @"直通厂家版块";
    board3.newPostNum = 100;
    boards = [NSArray arrayWithObjects:board1, board2, board3, nil];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = NO;
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NRGridView Data Source
- (NSInteger)numberOfSectionsInGridView:(NRGridView *)gridView
{
    return 1;
}

- (NSInteger)gridView:(NRGridView *)gridView numberOfItemsInSection:(NSInteger)section
{
    return boards.count;
}

- (NRGridViewCell*)gridView:(NRGridView *)gridView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *GridCellIdentifier = @"GridCellIdentifier";
    
    NRGridViewCell* cell = [gridView dequeueReusableCellWithIdentifier:GridCellIdentifier];

    UILabel *titleLabel, *descLabel;
    UIButton *btn;
    if(cell == nil){
        cell = [[NRGridViewCell alloc] initWithReuseIdentifier:GridCellIdentifier];
        cell.selectionBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 120, 90)];
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.font = [UIFont systemFontOfSize:30];
        titleLabel.backgroundColor = [UIColor clearColor];
        descLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 100, 120, 30)];
        descLabel.textAlignment = NSTextAlignmentRight;
        descLabel.font = [UIFont systemFontOfSize:18];
        descLabel.textColor = [UIColor lightGrayColor];
        descLabel.backgroundColor = [UIColor clearColor];
        
        btn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 130, 130)];
        btn.userInteractionEnabled = NO;
        [btn primaryStyle];
        titleLabel.tag = 551;
        descLabel.tag = 552;
        [btn addSubview:titleLabel];
        [btn addSubview:descLabel];
        
        btn.tag = 500;
        [cell.contentView addSubview:btn];
    } else {
        btn = (UIButton *)[cell.contentView viewWithTag:500];
        titleLabel = (UILabel *)[btn viewWithTag:551];
        descLabel = (UILabel *)[btn viewWithTag:552];
    }
    
    FBoard *board = [boards objectAtIndex:indexPath.row];
    titleLabel.text = board.title;
    descLabel.text = [NSString stringWithFormat:@"今日新帖%d", board.newPostNum];
    
    return cell;
}

#pragma mark - NRGridView Delegate

- (void)gridView:(NRGridView *)gridView didSelectCellAtIndexPath:(NSIndexPath *)indexPath
{
    [gridView deselectCellAtIndexPath:indexPath animated:YES];
    
    BoardViewController *controller = [[BoardViewController alloc] initWithStyle:UITableViewStylePlain];
    controller.board = [boards objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];

}

@end
