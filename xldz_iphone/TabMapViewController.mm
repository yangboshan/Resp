//
//  TabMapViewController.mm
//  XLApp
//
//  Created by sureone on 2/16/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

//注:静态库中采用ObjectC++实现，因此需要您保证您工程中至少有一个.mm后缀的源文件(您可以将任意一个.m后缀的文件改名为.mm)，或者在工程属性中指定编译方式，即将XCode的Project -> Edit Active Target -> Build -> GCC4.2 - Language -> Compile Sources As设置为"Objective-C++

#import "TabMapViewController.h"

#import "BMapKit.h"
#import "BMKNavigation.h"
#import "DeviceViewController.h"

@interface TabMapViewController () <BMKMapViewDelegate, UIAlertViewDelegate>
{
    BMKMapView *_mapView;
    
    NSArray *annotations;
}

@property (nonatomic) XLViewDataDevice *selectedDevice;

@end

@implementation TabMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"地图";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"map_icon";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    searchBar.delegate = self;
//    [self.view addSubview:searchBar];
//    UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
//    searchController.delegate = self;
//    searchController.searchResultsDataSource = self;
//    searchController.searchResultsDelegate = self;
//    searchController.displaysSearchBarInNavigationBar = YES;
    
    if (IOS_VERSION_7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
	
    CGFloat height = self.searchDisplayController.searchBar.frame.size.height;
    CGRect rect = self.view.bounds;
    rect.origin.y += height;
    rect.size.height -= height;
    _mapView = [[BMKMapView alloc]initWithFrame:rect];
    _mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_mapView setShowsUserLocation:YES];//显示定位的蓝点儿
    
    [self.view addSubview:_mapView];
    
//    float zoomLevel = 0.02;
//    double lat = 31.867037;
//    double lot = 118.824720;
//    CLLocationCoordinate2D theLocation = CLLocationCoordinate2DMake(lat,lot);
//    NSDictionary *tip = BMKBaiduCoorForWgs84(theLocation);
//    theLocation = BMKCoorDictionaryDecode(tip);
//    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(theLocation, BMKCoordinateSpanMake(zoomLevel, zoomLevel));
//    BMKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
//    [_mapView setRegion:adjustedRegion animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    double centerLat = 31.867037;
    double centerLot = 118.824720;
    double deltaLat = 0.02;
    double deltaLot = 0.02;
    
    self.devices = [[XLModelDataInterface testData] queryDevicesInMap];
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *a = [NSMutableArray array];
    BOOL first = YES;
    for (XLViewDataDevice *device in self.devices) {
        if (device.latitude == 0 && device.longitude == 0) {
            NSLog(@"%@ has no coordinate for map", device);
            [array addObject:[NSNull null]];
        } else {
            BMKPointAnnotation *ann = [self addPointAnnotation:device];
            [array addObject:ann];
            [a addObject:ann];
            
            if (first) {
                first = NO;
                centerLat = device.latitude;
                centerLot = device.longitude;
            } else {
                deltaLat = MAX(deltaLat, ABS(device.latitude - centerLat));
                deltaLot = MAX(deltaLot, ABS(device.longitude - centerLot));
            }
        }
    }
    annotations = array;
    [_mapView addAnnotations:a];
    
    CLLocationCoordinate2D theLocation = CLLocationCoordinate2DMake(centerLat,centerLot);
    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(theLocation, BMKCoordinateSpanMake(deltaLat * 2.5, deltaLot * 2.5));
    [_mapView setRegion:viewRegion animated:YES];
    
    CLLocationCoordinate2D *coors = (CLLocationCoordinate2D *)calloc(a.count, sizeof(CLLocationCoordinate2D));
    int index = 0;
    for (BMKPointAnnotation *ann in a) {
        coors[index++] = ann.coordinate;
    }
    BMKPolyline *polyline = [BMKPolyline polylineWithCoordinates:coors count:a.count];
    [_mapView addOverlay:polyline];
}

- (void)viewWillAppear:(BOOL)animated
{
    static BOOL inited = NO;
    
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    if (!inited) {
        inited = YES;
        [self initData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}

//添加标注
- (BMKPointAnnotation *)addPointAnnotation:(XLViewDataDevice *)device
{
    BMKPointAnnotation *pointAnnotation = [[BMKPointAnnotation alloc] init];
    CLLocationCoordinate2D coor;
    coor.latitude = device.latitude;
    coor.longitude = device.longitude;
    pointAnnotation.coordinate = coor;
    pointAnnotation.title = device.deviceName;
//    pointAnnotation.subtitle = device.
    
    return pointAnnotation;
}

#pragma mark - BMKMapViewDelegate

//根据overlay生成对应的View
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id <BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKCircle class]])
    {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        circleView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        circleView.lineWidth = 5.0;
		return circleView;
    }
    
    if ([overlay isKindOfClass:[BMKPolyline class]])
    {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:1];
        polylineView.lineWidth = 3.0;
		return polylineView;
    }
	
	if ([overlay isKindOfClass:[BMKPolygon class]])
    {
        BMKPolygonView* polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor = [[UIColor purpleColor] colorWithAlphaComponent:1];
        polygonView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        polygonView.lineWidth =2.0;
		return polygonView;
    }
    if ([overlay isKindOfClass:[BMKGroundOverlay class]])
    {
        BMKGroundOverlayView* groundView = [[BMKGroundOverlayView alloc] initWithOverlay:overlay];
		return groundView;
    }
	return nil;
}

// 根据anntation生成对应的View
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    NSString *AnnotationViewID = @"renameMark";
    BMKAnnotationView* newAnnotation = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (!newAnnotation) {
        newAnnotation = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        // 设置颜色
        ((BMKPinAnnotationView*)newAnnotation).pinColor = BMKPinAnnotationColorGreen;
        // 从天上掉下效果
        ((BMKPinAnnotationView*)newAnnotation).animatesDrop = NO;
        // 设置可拖拽
        ((BMKPinAnnotationView*)newAnnotation).draggable = NO;
        
        newAnnotation.canShowCallout = NO;
    }
    
    //可以自己画泡泡框，http://blog.csdn.net/mad1989/article/details/8794762
    NSString *title = ((BMKPointAnnotation *)annotation).title;
    UIFont *font = [UIFont systemFontOfSize:14];
    CGSize size = [title sizeWithFont:font];
    CGFloat width = MAX(size.width + 9*2, 41);
    width = MIN(width, 300);
    CGFloat leftWidth = floor(width * 20 / 41);
    UIView *viewForImage = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 54)];
    UIImageView *leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, leftWidth, 54)];
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(leftWidth, 0, width - leftWidth, 54)];
    UIImage *leftImage = [[UIImage imageNamed:@"icon_paopao_middle_left"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 9, 18, 5)];
    UIImage *rightImage = [[UIImage imageNamed:@"icon_paopao_middle_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(6, 7, 18, 9)];
    leftImageView.image = leftImage;
    rightImageView.image = rightImage;
    [viewForImage addSubview:leftImageView];
    [viewForImage addSubview:rightImageView];
    
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(9, 6, width - 9*2, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = font;
    label.text = title;
    label.backgroundColor = [UIColor clearColor];
    [viewForImage addSubview:label];
    newAnnotation.image = nil;//newAnnotation.image = [self getImageFromView:viewForImage];
    newAnnotation.frame = viewForImage.frame;
    [newAnnotation addSubview:viewForImage];
    newAnnotation.centerOffset = CGPointMake((newAnnotation.frame.size.width / 2 - leftWidth), -(newAnnotation.frame.size.height / 2 - 6));
    
    
    return newAnnotation;
}

//-(UIImage *)getImageFromView:(UIView *)view{
//    UIGraphicsBeginImageContext(view.bounds.size);
//    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    CGRect rect = CGRectMake(6, 0, image.size.width * 2, image.size.height * 2);
//    UIGraphicsBeginImageContext(CGSizeMake(rect.size.width + 6, rect.size.height + 20));
//    [image drawInRect:rect];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    BMKPointAnnotation *annotation = view.annotation;
    NSUInteger index = [annotations indexOfObject:annotation];
    if (index != NSNotFound) {
        XLViewDataDevice *device = [self.devices objectAtIndex:index];
        self.selectedDevice = device;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:[NSString stringWithFormat:@"查看%@的详细信息？", device.deviceName]
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"查看", @"导航", nil];
        [alert show];
    }
}

// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
//    BMKPointAnnotation *annotation = view.annotation;
//    NSUInteger index = [annotations indexOfObject:annotation];
//    if (index != NSNotFound) {
//        XLViewDataDevice *device = [self.devices objectAtIndex:index];
//        self.selectedDevice = device;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
//                                                        message:[NSString stringWithFormat:@"查看%@的详细信息？", device.deviceName]
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                              otherButtonTitles:@"查看", @"导航", nil];
//        [alert show];
//    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        DeviceViewController *controller = [[DeviceViewController alloc] init];
        controller.device = self.selectedDevice;
        [self.navigationController pushViewController:controller animated:YES];
    } else if (buttonIndex == alertView.firstOtherButtonIndex + 1) {
        [self webNavi];
    }
}


- (IBAction)webNavi
{
    if (_mapView.userLocation.updating) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"正在定位当前位置，请稍候。"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //初始化调启导航时的参数管理类
    NaviPara* para = [[NaviPara alloc]init];
    //指定导航类型
    para.naviType = NAVI_TYPE_WEB;
    
    //初始化起点节点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    CLLocationCoordinate2D coor1 = _mapView.userLocation.location.coordinate;
    start.pt = coor1;
    //指定起点名称
    start.name = _mapView.userLocation.title;
    //指定起点
    para.startPoint = start;
    
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    CLLocationCoordinate2D coor2;
	coor2.latitude = self.selectedDevice.latitude;
	coor2.longitude = self.selectedDevice.longitude;
	end.pt = coor2;
    para.endPoint = end;
    //指定终点名称
    end.name = self.selectedDevice.deviceName;
    //指定调启导航的app名称
    para.appName = [NSString stringWithFormat:@"%@", @"XLApp"];
    //调启web导航
    [BMKNavigation openBaiduMapNavigation:para];
}


#pragma mark - UITableView data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
//	if (tableView == self.searchDisplayController.searchResultsTableView) {
//        return [self.searchResults count];
//    } else {
//        return [self.countrys count];
//    }
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceSearchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        cell.backgroundColor=[UIColor clearColor];
//        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
//        bgview.opaque = YES;
//        bgview.backgroundColor = [UIColor listItemBgColor];
//        cell.backgroundView = bgview;
    }

    cell.textLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
//    cell.textLabel.backgroundColor = [UIColor clearColor];
//    cell.textLabel.textColor = [UIColor textWhiteColor];
    
	return cell;
}

#pragma mark - UISearchDisplayController Delegate Methods
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
//    UINib *cellNib = [UINib nibWithNibName:@"CountryCell" bundle:nil];
//    [tableView registerNib:cellNib forCellReuseIdentifier:countryCellIdentifier];
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
//    [self updateFilteredCountrys:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


@end
