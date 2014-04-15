//
//  QRCodeViewController.m
//  ZXingDemo
//
//  Created by Wei on 13-3-27.
//  Copyright (c) 2013年 Wei. All rights reserved.
//

#import "QRCodeViewController.h"

//自定义需要用到
#import <Decoder.h>
#import <TwoDDecoderResult.h>


@interface QRCodeViewController ()

@end

@implementation QRCodeViewController
@synthesize textView = _textView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 10.f, 300.f, 200.f)];
    self.textView.returnKeyType = UIReturnKeyDone;
    self.textView.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:self.textView];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"ZXing扫描器" forState:UIControlStateNormal];
    [button1 setFrame:CGRectMake(10.f, 240.f, 140.f, 50.f)];
    [button1 addTarget:self action:@selector(pressButton1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];

    
}

- (void)pressButton1:(UIButton *)button
{
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:YES];
    NSMutableSet *readers = [[NSMutableSet alloc] init];
    MultiFormatOneDReader *oneReaders=[[MultiFormatOneDReader alloc]init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:oneReaders];
    [readers addObject:qrcodeReader];
    widController.readers = readers;
    [self presentViewController:widController animated:YES completion:^{}];
}

- (void)outPutResult:(NSString *)result
{
    NSLog(@"result:%@", result);
    self.textView.text = result;
}

#pragma mark - ZXingDelegate

- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{[self outPutResult:result];}];    
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"cancel!");}];
}


@end
