//
//  WebSVGViewController.m
//  XLApp
//
//  Created by sureone on 3/6/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#import "WebSVGViewController.h"
#import "DDFileReader.h"

@interface WebSVGViewController () <UIWebViewDelegate>

@property (nonatomic) UIWebView* webView;

@end

@implementation WebSVGViewController

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
    // Do any additional setup after loading the view from its nib.
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
                                   initWithTitle:@"测试"
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(refreshSvg)];
    self.navigationItem.rightBarButtonItem = refreshButton;

    
    self.webView = [UIWebView new];
    self.webView.opaque = YES;
    self.webView.frame = CGRectMake(0, 0, 320, 567);

    self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.webView.userInteractionEnabled = YES;
    
    self.webView.delegate=self;
    
    
//  http://stackoverflow.com/questions/747407/using-html-and-local-images-within-uiwebview
    

    
    //load from string
    NSMutableString* content = [[NSMutableString alloc]init];
    [content appendString:@"<!Doctype html><html xmlns=http://www.w3.org/1999/xhtml><head><meta http-equiv=Content-Type content=\"text/html;charset=utf-8\"></head><body>"];
    
    NSString *svgFile = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"svg"];
    NSString* svgContent = [NSString stringWithContentsOfFile:svgFile encoding:NSUTF8StringEncoding error:nil];
    
    [content appendString:svgContent];
    
    [content appendString:@"</body></html>"];
    
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:content baseURL:baseURL];
    
    

    
//    [self removeImage:@"svgload.html"];
    [self copyFileToLocal:@"test" ofType:@"svg"];
    [self copyFileToLocal:@"svgload" ofType:@"html"];
    

    
    //http://stackoverflow.com/questions/7063276/how-to-load-local-html-file-into-uiwebview-iphone
    
//    load from file
//    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"svgload" ofType:@"html"];
//    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadHTMLString:htmlString baseURL:baseURL];
    
    [self.view addSubview:self.webView];

    
    
    //UIWebview manipulating SVG 'on the fly'
    //http://stackoverflow.com/questions/6991828/uiwebview-manipulating-svg-on-the-fly
    
//    NSString *string =
//    @"var path=document.getElementById('cdimg').getSVGDocument().getElementById('line_title'); \
//    path.node.textContent = '进线2'; \
//    ";
//    
////    string=@"alert('hello world');";
//    [self.webView stringByEvaluatingJavaScriptFromString:string];
    
    
//    [self loadSvgDocument];
    
//    [self exeuteJS];
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(testTimer:) userInfo:nil repeats:YES];
    
    
    
}

-(void)testTimer:(id)sender{
    [self requestSvgData];
}


-(void)requestSvgData{
    
    NSArray* arrayColor = [NSArray arrayWithObjects:@"#00FFFF",@"#FFFF00",@"#00FF00",@"#0000FF", nil];
    NSArray* arrayString = [NSArray arrayWithObjects:@"开关分",@"开关合",@"开关分",@"开关合", nil];
    NSArray* arrayX = [NSArray arrayWithObjects:@"46.454529",@"57.454529",@"46.454529",@"57.454529", nil];
    
    NSArray* arrayA = [NSArray arrayWithObjects:@"A: 220V",@"A: 230V",@"A: 224V",@"A: 225V", nil];
    
    
        NSArray* arrayVisibility = [NSArray arrayWithObjects:@"hidden",@"visible",@"hidden",@"visible", nil];
    
    
    
    
    
    
    static int i=0;
    i++;
    
    int k=i%4;
    
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:@"svg_37",@"node-id",@"fill",@"property",[arrayColor objectAtIndex:k],@"value", nil];
    
    NSArray* dictAry = [NSArray arrayWithObjects:dict,
                        [NSDictionary dictionaryWithObjectsAndKeys:@"line_title",@"node-id",[arrayString objectAtIndex:k],@"value", nil],
                        [NSDictionary dictionaryWithObjectsAndKeys:@"svg_5",@"node-id",@"x2",@"property",[arrayX objectAtIndex:k],@"value", nil],
                        
                        [NSDictionary dictionaryWithObjectsAndKeys:@"svg_33",@"node-id",[arrayA objectAtIndex:k],@"value", nil],
                        
                        [NSDictionary dictionaryWithObjectsAndKeys:@"svg_38",@"node-id",@"visibility",@"property",[arrayVisibility objectAtIndex:k],@"value", nil],
                        nil];
    
    [self updateSvgByDict:dictAry];
    
    
    
}

-(void)updateSvgByDict:(NSArray*)dictAry {
    
    NSMutableString *theJS = [[NSMutableString alloc]init];
    for(NSDictionary* dict in dictAry){
        NSString* nodeId = [dict objectForKey:@"node-id"];
        NSString* property = [dict objectForKey:@"property"];
        NSString* value = [dict objectForKey:@"value"];
        
        
        
        if(property!=nil && !([property isEqual:[NSNull null]])){
            
            NSString *js = [NSString stringWithFormat:@"document.getElementById('%@').setAttribute('%@','%@');",nodeId,property,value];
            [theJS appendString:js];
            
        }else{
            NSString *js = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';",nodeId,value];
            [theJS appendString:js];
        }
        
        
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:theJS];
    
}

- (BOOL) getFileExistence: (NSString *) filename
{
    BOOL IsFileExists = NO;
    
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    NSString *favsFilePath = [documentsDir stringByAppendingPathComponent:filename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Check if the database has already been created in the users filesystem
    if ([fileManager fileExistsAtPath:favsFilePath])
    {
        IsFileExists = YES;
    }
    return IsFileExists;
}

- (NSString *)dataFilePath:(NSString *)filename {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    return [docDirectory stringByAppendingPathComponent:filename];
}

- (void)copyFileToLocal:(NSString *)filename ofType:(NSString*)ftype
{
    
    if (![self getFileExistence:filename])
    {
        NSError *error;
        NSString *file = [[NSBundle mainBundle] pathForResource:filename ofType:ftype];
        
        if (file)
        {
            if(ftype!=nil) filename=[NSString stringWithFormat:@"%@.%@",filename,ftype];
            if([[NSFileManager defaultManager] copyItemAtPath:file toPath:[self dataFilePath:filename] error:&error]){
                NSLog(@"File successfully copied");
            } else {

                NSLog(@"Error description-%@ \n", [error localizedDescription]);
                NSLog(@"Error reason-%@", [error localizedFailureReason]);
            }
            file = nil;
        }
    }
}

- (void)removeImage:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:fileName];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (!success)
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

//Method writes a string to a text file
-(void) writeToTextFile:(NSString*) fname withContent:(NSString*)content{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
//    NSString *fileName = [NSString stringWithFormat:@"%@/%@",
//                          documentsDirectory,fname];
    
    
    NSString *fileName = [documentsDirectory stringByAppendingPathComponent:fname];
    
    //create content - four lines of text
    //save content to the documents directory
    NSError *error;
    
    
    if(![content writeToFile:fileName
              atomically:NO
                encoding:NSUTF8StringEncoding
                       error:&error]){
        
        NSLog(@"Could not write file -:%@ ",[error description]);
    }
    
}


-(void) changeSVGAttribute:(NSString*)fileName byDictArray:(NSArray*)dictAry{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSMutableString *svgContent = [[NSMutableString alloc]init];
    
    DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:filePath];
    NSString * line = nil;
    while ((line = [reader readLine])) {
        
        for(NSDictionary* dict in dictAry){
            
            
            NSString* theId = [dict objectForKey:@"id"];
            NSString* attr = [dict objectForKey:@"attr"];
            NSString* value = [dict objectForKey:@"value"];
            
            
            NSString *find = [NSString stringWithFormat:@"id=\"%@\"",theId];
            
//            NSLog(@"before update:%@",line);
            
            if ([line rangeOfString:find].location != NSNotFound){
                NSError *error = nil;
                
                NSString *replacedStr;
                
                NSString *regualStr ;
                if(attr!=nil && !([attr isEqual:[NSNull null]])){
                    replacedStr=[NSString stringWithFormat:@"%@=\"%@\"",attr,value];
                    regualStr = [NSString stringWithFormat:@"%@=\"[^\"]*\"",attr];
                }else{
                    
                    replacedStr=[NSString stringWithFormat:@">%@<",value];
                    regualStr =@">[^<>]*<";

                    
                }
                
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regualStr options:NSRegularExpressionCaseInsensitive error:&error];
                NSString *modifiedString = [regex stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:replacedStr];
//                NSLog(@"%@", modifiedString);
                line = modifiedString;
            }
            
//            NSLog(@"after update:%@",line);
        
        }
        

        
        [svgContent appendString:line];
    }
    
    [self writeToTextFile:@"test.svg" withContent:svgContent];
    
    
    
    
    
}

-(IBAction)refreshSvg{

    [self requestSvgData];
//    [self changeSVGAttribute:@"test.svg" byDictArray:dictAry];
//    [self.webView reload];

    
    
    
}
- (void)loadSvgDocument{
    
    NSArray *all_paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([all_paths count] > 0)
    {
        NSLog(@"Path: %@", [all_paths objectAtIndex:0]);
        
        NSString* docPath =[all_paths objectAtIndex:0];
        
        
        NSLog(@"LISTING ALL FILES FOUND");
        
        int count;
        
        NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:docPath error:NULL];
        for (count = 0; count < (int)[directoryContent count]; count++)
        {
            NSLog(@"File %d: %@", (count + 1), [directoryContent objectAtIndex:count]);
        }

        
    }
    
    

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"svgload.html"];

    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
