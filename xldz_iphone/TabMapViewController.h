//
//  TabMapViewController.h
//  XLApp
//
//  Created by sureone on 2/16/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "ContentViewController.h"

#import "XLModelDataInterface.h"


@interface TabMapViewController : ContentViewController <UITableViewDataSource, UITableViewDelegate,UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic) NSArray *devices;

@end