//
//  ActionEventTableViewCell.h
//  XLApp
//
//  Created by ttonway on 14-3-14.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActionEventTableViewCell : UITableViewCell

@property (nonatomic,retain) IBOutlet UILabel *eventNoLabel;
@property (nonatomic,retain) IBOutlet UILabel *eventTimeLabel;
@property (nonatomic,retain) IBOutlet UILabel *eventContentLabel;
@property (nonatomic,retain) IBOutlet UIButton *chartBtn;

@end
