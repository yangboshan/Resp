//
//  DeviceHelpViewController.m
//  XLApp
//
//  Created by ttonway on 14-3-18.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceHelpViewController.h"

#import "UIButton+Bootstrap.h"
#import "Navbar.h"
#import "QRCodeViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface DeviceHelpViewController () <ZXingDelegate, UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSString *scanResult;
    BOOL oneDMode;
}

@end

@implementation DeviceHelpViewController

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
    
    [self.navigationItem setNewTitle:@"辅助工具"];
    [self.navigationItem setBackItemWithTarget:self action:@selector(back:)];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSArray *titles = [NSArray arrayWithObjects:@"设备升级", @"摄像档案", @"二维码", @"条形码", @"帮助文档", @"设备调试", nil];
    self.button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button5 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button6 = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button7 = [UIButton buttonWithType:UIButtonTypeSystem];
    NSArray *btns = [NSArray arrayWithObjects:self.button1, self.button2, self.button4, self.button5, self.button6, self.button7, nil];
    
    [btns enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *button = obj;
        [button setTitle:[titles objectAtIndex:idx] forState:UIControlStateNormal];
        NSUInteger x = idx % 2;
        NSUInteger y = idx / 2;
        button.frame = CGRectMake(30 + (115 + 30) * x, 30 + (30 + 20) * y, 115, 30);
        [button blueBorderStyle];
        
        [self.view addSubview:button];
    }];
//    
//    [self.view addSubview:self.button1];
//    [self.view addSubview:self.button2];
//    [self.view addSubview:self.button3];
//    [self.view addSubview:self.button4];
//    [self.view addSubview:self.button5];
//    [self.view addSubview:self.button6];
//    [self.view addSubview:self.button7];
    
    [self.button4 addTarget:self action:@selector(gotoQRCodeScanner:) forControlEvents:UIControlEventTouchUpInside];
    [self.button5 addTarget:self action:@selector(gotoOneCodeScanner:) forControlEvents:UIControlEventTouchUpInside];
    
        [self.button2 addTarget:self action:@selector(launchCameraApp:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)launchCameraApp:(id)sender{
    UIImagePickerController * cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.delegate = self;
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO))
        return;
    
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    
    [self presentModalViewController: cameraUI animated: YES];

    

}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self dismissModalViewControllerAnimated: YES];

}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    }
    
    // Handle a movie capture
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (
                                                 moviePath, nil, nil, nil);
        }
    }
    
    [self dismissModalViewControllerAnimated: YES];

}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gotoOneCodeScanner:(id)sender
{
//    QRCodeViewController *controller = [[QRCodeViewController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:YES];
    NSMutableSet *readers = [[NSMutableSet alloc] init];
    MultiFormatOneDReader *oneReaders=[[MultiFormatOneDReader alloc]init];
    //QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:oneReaders];
    //[readers addObject:qrcodeReader];
    widController.readers = readers;
    oneDMode = YES;
    [self presentViewController:widController animated:YES completion:^{}];
}

- (IBAction)gotoQRCodeScanner:(id)sender
{
//    QRCodeViewController *controller = [[QRCodeViewController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];
    ZXingWidgetController *widController = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:YES];
    NSMutableSet *readers = [[NSMutableSet alloc] init];
    //MultiFormatOneDReader *oneReaders=[[MultiFormatOneDReader alloc]init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    //[readers addObject:oneReaders];
    [readers addObject:qrcodeReader];
    widController.readers = readers;
    oneDMode = NO;
    [self presentViewController:widController animated:YES completion:^{}];
}

#pragma mark - ZXingDelegate

- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"didScanResult %@", result);}];
    
    UIAlertView *alert;
    if (oneDMode) {
        alert = [[UIAlertView alloc]initWithTitle:@"扫描结果为"
                                          message:result
                                         delegate:nil
                                cancelButtonTitle:@"确定"
                                otherButtonTitles:nil];
    } else {
        alert = [[UIAlertView alloc]initWithTitle:@"打开"
                                          message:result
                                         delegate:self
                                cancelButtonTitle:@"取消"
                                otherButtonTitles:@"确定", nil];
    }
    scanResult = result;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:scanResult]];
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller
{
    [self dismissViewControllerAnimated:YES completion:^{NSLog(@"cancel!");}];
}


@end
