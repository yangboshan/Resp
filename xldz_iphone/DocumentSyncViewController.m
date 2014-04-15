//
//  DocumentSyncViewController.m
//  XLApp
//
//  Created by sureone on 4/1/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "DocumentSyncViewController.h"

#import "Navbar.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressTheme.h"
#import "MDRadialProgressLabel.h"

@interface DocumentSyncViewController ()

@end

@implementation DocumentSyncViewController

- (MDRadialProgressView *)progressViewWithFrame:(CGRect)frame
{
	MDRadialProgressView *view = [[MDRadialProgressView alloc] initWithFrame:frame];
    
	// Only required in this demo to align vertically the progress views.
//	view.center = CGPointMake(self.view.center.x + 80, view.center.y);
	
	return view;
}

- (UILabel *)labelAtY:(CGFloat)y andText:(NSString *)text
{
	CGRect frame = CGRectMake(5, y, 180, 50);
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.text = text;
	label.numberOfLines = 0;
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [label.font fontWithSize:14];
	
	return label;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    [self.navigationItem setNewTitle:@"档案同步"];
    
    float width = 120;
    float height = 120;
    
    float x= (self.view.frame.size.width-width)/2;
    float y= 80;
    
    CGRect frame = CGRectMake(x, y, width, height);
    MDRadialProgressView *progressView = [self progressViewWithFrame:frame];
//	
//	progressView.progressTotal = 12;
//    progressView.progressCounter = 4;
//	progressView.theme.completedColor = [UIColor blueColor];
//	progressView.theme.incompletedColor = [UIColor whiteColor];
//    progressView.theme.thickness = 12;
//    progressView.theme.sliceDividerHidden = NO;
//	progressView.theme.centerColor = [UIColor whiteColor];
//    
    
    progressView.progressTotal = 10;
    progressView.progressCounter = 3;
	progressView.startingSlice = 1;
    progressView.theme.sliceDividerHidden = YES;
    progressView.theme.sliceDividerThickness = 1;
	progressView.label.textColor = [UIColor whiteColor];
	progressView.label.shadowColor = [UIColor clearColor];
    progressView.theme.completedColor = [UIColor orangeColor];
    
    
	[self.view addSubview:progressView];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
