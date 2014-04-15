//
//  CustomParamViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-10.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "CustomInputTableViewController.h"

#import "XLParamInterface.h"
//#import "LHDropDownControlView.h"
#import "UIButton+Bootstrap.h"
#import "MJRefresh.h"
#import "CCComboBox.h"

#define CELL_LABEL_TAG 551
#define CELL_TEXTFIELD_TAG 552
#define CELL_DROPDOWNVIEW_TAG 553

@interface CustomParamViewController : CustomInputTableViewController <CCComboBoxDelegate>
{
    MJRefreshHeaderView *refreshHeader;
}

// to be overwrite
- (void)initData;
- (NSMutableDictionary *)tableView:(UITableView *)tableView paramForRowAtIndexPath:(NSIndexPath *)indexPath;

- (IBAction)toggleEditing:(id)sender;
- (IBAction)refreshData:(id)sender;
- (IBAction)saveParam:(id)sender;

@end
