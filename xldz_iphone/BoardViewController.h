//
//  BoardViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBoard : NSObject
@property (nonatomic) NSString *title;
@property (nonatomic) NSUInteger newPostNum;
@end

@interface BoardViewController : UITableViewController

@property (nonatomic) FBoard *board;

@end
