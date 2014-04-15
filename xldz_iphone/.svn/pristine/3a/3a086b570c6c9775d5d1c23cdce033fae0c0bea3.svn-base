//
//  CCComboBox.h
//  XLApp
//
//  Created by ttonway on 14-3-27.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import <UIKit/UIKit.h>
#define ROW_HEIGHT 30
#define ROWLINE 6

@protocol CCComboBoxDelegate;
@interface CCComboBox : UIView<UITableViewDataSource, UITableViewDelegate>
{
@private
    UIButton *_button;
    UITableView *_tableView;
    NSInteger _currentRow;
    NSUInteger _rowMaxLines;
    BOOL isHidden;
    UIView *_overlayView;
    
    NSMutableArray *_dataArray;
    UILabel *myLabel;
}
@property (nonatomic) UILabel *titleLabel;
@property (assign, nonatomic) id<CCComboBoxDelegate> delegate;
//@property (strong, nonatomic, setter = setDataArray:) NSMutableArray *dataArray;

- (id)initWithFrame:(CGRect)frame;
- (void)setDataArray:(NSMutableArray *)dataArray selected:(NSUInteger)index;
@end

@interface CCComboBox (UIButton)
- (void)setComboBoxBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)setComboBoxFrame:(CGRect)frame;
- (id)getComboBoxSelectedItem;

@end

@interface CCComboBox (UITableView)
- (void)setComboBoxShowMaxLine:(NSUInteger)count;

@end

/*ComboBox的代理*/

#import <Foundation/Foundation.h>
@class CCComboBox;
@protocol CCComboBoxDelegate <NSObject>

- (void)selected:(CCComboBox *)comboBox atIndex:(NSUInteger)index;

@end
