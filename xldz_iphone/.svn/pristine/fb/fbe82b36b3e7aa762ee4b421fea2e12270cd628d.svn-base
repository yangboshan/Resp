//
//  LHDropDownControlView.m
//  DropDownControl
//
//  Created by Lukas Heiniger on 06.12.12.
//  Copyright (c) 2012 cyclus.ch, L. Heiniger. All rights reserved.
//

#import "LHDropDownControlView.h"
#import <QuartzCore/QuartzCore.h>

#define kOptionHeight 30
#define kOptionSpacing 1
#define kAnimationDuration 0.2

@implementation LHDropDownControlView {
    CGRect mBaseFrame;
    
    // Configuration
    NSArray *mSelectionOptions, *mSelectionTitles;

    // Subviews
    UILabel *mTitleLabel;
    UIImage *mBgImage;
    NSMutableArray *mSelectionCells;
    
    // Control state
    BOOL mControlIsActive;
    NSInteger mSelectionIndex;
    NSInteger mPreviousSelectionIndex;
}

@synthesize titleLabel = mTitleLabel;

#pragma mark - Object Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        mBaseFrame = frame;
        
        // Background
        mBgImage = [[UIImage imageNamed:@"dropdown_bg2"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        UIImage *tfImg = [[UIImage imageNamed:@"textfield"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        UIImageView *backGroundView = [[UIImageView alloc] initWithImage:tfImg];
        backGroundView.frame = self.bounds;
        [self addSubview:backGroundView];
        
        // Title
        mTitleLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 5, 0)];
        //mTitleLabel.textAlignment = NSTextAlignmentCenter;
        mTitleLabel.textColor = [UIColor blackColor];
        mTitleLabel.backgroundColor = [UIColor clearColor];
        mTitleLabel.font = [UIFont systemFontOfSize:17.0];
        [self addSubview:mTitleLabel];
    }
    return self;
}


#pragma mark - Accessors

- (void)setTitle:(NSString *)title {
    _title = title;
    mTitleLabel.text = title;
}


#pragma mark - Configuration

- (void)setSelectionOptions:(NSArray *)selectionOptions withTitles:(NSArray *)selectionOptionTitles {
    if ([selectionOptions count] != [selectionOptionTitles count]) {
        [NSException raise:NSInternalInconsistencyException format:@"selectionOptions and selectionOptionTitles must contain the same number of objects"];
    }
    mSelectionOptions = selectionOptions;
    mSelectionTitles = selectionOptionTitles;
    mSelectionCells = nil;
}


#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] != 1)
        return;
    
    UITouch *touch = [touches anyObject];
    if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        [self activateControl];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count] != 1)
        return;
    
    UITouch *touch = [touches anyObject];
    
    // Calculate the selection index
    CGPoint location = [touch locationInView:self];
    if ((CGRectContainsPoint(self.bounds, location)) && (location.y > mBaseFrame.size.height)) {
        mSelectionIndex = (location.y - mBaseFrame.size.height - kOptionSpacing) / (kOptionHeight + kOptionSpacing);
    } else {
        mSelectionIndex = NSNotFound;
    }
    
    if (mSelectionIndex == mPreviousSelectionIndex) 
        return;
    
    // Selection animation
    if (mSelectionIndex != NSNotFound) {
        UIView *cell = [mSelectionCells objectAtIndex:mSelectionIndex];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            cell.frame = CGRectInset(cell.frame, -6, 0);
        }];
    }
    if (mPreviousSelectionIndex != NSNotFound) {
        UIView *cell = [mSelectionCells objectAtIndex:mPreviousSelectionIndex];
        [UIView animateWithDuration:kAnimationDuration animations:^{
            cell.frame = CGRectInset(cell.frame, 6, 0);
        }];
    }
    mPreviousSelectionIndex = mSelectionIndex;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (mControlIsActive) {
        [self inactivateControl];
        if (mSelectionIndex < [mSelectionOptions count]) {
            [self.delegate dropDownControlView:self didFinishWithSelection:[mSelectionOptions objectAtIndex:mSelectionIndex]];
        } else {
            [self.delegate dropDownControlView:self didFinishWithSelection:nil];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    if (mControlIsActive) {
        [self inactivateControl];
    }
}

#pragma mark - View Transformation

- (CATransform3D)contractedTransorm {
    CATransform3D t = CATransform3DIdentity;
    t = CATransform3DRotate(t, M_PI / 2, 1, 0, 0);
    t.m34 = -1.0/50;
    return t;
}

#pragma mark - Control Activation / Deactivation

- (void)activateControl {
    
    if ([self.delegate respondsToSelector:@selector(dropDownControlViewWillBecomeActive:)]) {
        BOOL b = [self.delegate dropDownControlViewWillBecomeActive:self];
        if (!b) {
            return;
        }
    }
    
    mControlIsActive = YES;
    
    mSelectionIndex = NSNotFound;
    mPreviousSelectionIndex = NSNotFound;

    
    // Prepare the selection cells
    if (mSelectionCells == nil) {
        mSelectionCells = [NSMutableArray arrayWithCapacity:0];
        for (int i=0; i < [mSelectionTitles count]; i++) {
            UIImageView *newCell = [[UIImageView alloc] initWithImage:mBgImage];
            newCell.frame = CGRectMake(0, mBaseFrame.size.height + (i * kOptionHeight + kOptionSpacing) + kOptionSpacing, mBaseFrame.size.width, kOptionHeight);
            newCell.layer.anchorPoint = CGPointMake(0.5, 0.0);
            newCell.layer.transform = [self contractedTransorm];
            //newCell.alpha = 0;
            
            UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectInset(newCell.bounds, 10, 0)];
            newLabel.font = [UIFont systemFontOfSize:17.0];
            newLabel.backgroundColor = [UIColor clearColor];
            newLabel.textColor = [UIColor blackColor];
            newLabel.text = [mSelectionTitles objectAtIndex:i];
            [newCell addSubview:newLabel];
            
            //[self addSubview:newCell];
            [mSelectionCells addObject:newCell];
        }
    }
    
    // Expand our frame
    CGRect newFrame = mBaseFrame;
    newFrame.size.height += [mSelectionOptions count] * (kOptionHeight + kOptionSpacing);
    self.frame = newFrame;
    
    //转换坐标
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    CGRect mapFrame = [self convertRect:self.bounds toView:rootView];

    // Show selection cells animated
    int count = [mSelectionCells count];
    for (int i = 0; i < count; i++) {
        UIView *cell = [mSelectionCells objectAtIndex:i];
        
        cell.frame = CGRectMake(mapFrame.origin.x, mapFrame.origin.y + (i + 1) * (kOptionHeight + kOptionSpacing), mapFrame.size.width, kOptionHeight);
        [rootView addSubview:cell];
        
        cell.alpha = 1.0;
        [UIView animateWithDuration:kAnimationDuration delay:(i * kAnimationDuration / count) options:0 animations:^{
//            CGRect destinationFrame = CGRectMake(0, mBaseFrame.size.height + i * (kOptionHeight + kOptionSpacing) + kOptionSpacing, mBaseFrame.size.width, kOptionHeight);
            CGRect destinationFrame = CGRectMake(mapFrame.origin.x, mapFrame.origin.y + (i + 1) * (kOptionHeight + kOptionSpacing), mapFrame.size.width, kOptionHeight);
            cell.frame = destinationFrame;
            cell.layer.transform = CATransform3DIdentity;
        } completion:nil];
    }
}

- (void)inactivateControl {
    mControlIsActive = NO;
    
    [self.delegate dropDownControlView:self didFinishWithSelection:nil];
    
    UIView *rootView = [[UIApplication sharedApplication] keyWindow];
    CGRect mapFrame = [self convertRect:self.bounds toView:rootView];
    
    int count = [mSelectionCells count];
    for (int i = count - 1; i >= 0; i--) {
        UIView *cell = [mSelectionCells objectAtIndex:i];
        [UIView animateWithDuration:kAnimationDuration delay:((count - 1 - i) * kAnimationDuration / count) options:0 animations:^{
            CGRect destinationFrame = CGRectMake(mapFrame.origin.x, mapFrame.origin.y + (i + 1) * (kOptionHeight + kOptionSpacing), mapFrame.size.width, kOptionHeight);
            cell.frame = destinationFrame;//CGRectMake(0, mBaseFrame.size.height + (i * kOptionHeight + kOptionSpacing) + kOptionSpacing, mBaseFrame.size.width, mBaseFrame.size.height);
            cell.layer.transform = [self contractedTransorm];
        } completion:^(BOOL completed){
            //cell.alpha = 0;
            [cell removeFromSuperview];
            if (i == 0) {
                self.frame = mBaseFrame;
            }
        }];
    }
}

@end
