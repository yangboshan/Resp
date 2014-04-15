//
//  MenuTableViewController.h
//  XLApp
//
//  Created by ttonway on 14-3-3.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuItem : NSObject
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *iconName;

+ (MenuItem *)itemWithTitle:(NSString *)title image:(NSString *)image;
@end


@interface MenuTableViewController : UITableViewController
{
    NSArray *_menuItems;
}

@property (nonatomic) NSArray *menuItems;

@end
