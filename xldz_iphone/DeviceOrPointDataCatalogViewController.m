//
//  DeviceOrPointDataCatalogViewController.m
//  XLApp
//
//  Created by ttonway on 14-2-26.
//  Copyright (c) 2014年 Pixel-in-Gene. All rights reserved.
//

#import "DeviceOrPointDataCatalogViewController.h"

#import "XLUtils.h"
#import "Navbar.h"
#import "UIButton+Bootstrap.h"
#import "MJRefresh.h"
#import "CommonPowerPlotViewController.h"
#import "TestPointRateDetialViewController.h"
#import "SwitchDataCatalog2ViewController.h"
#import "DeviceParamStatusViewController.h"
#import "DeviceStatusFlagViewController.h"


@interface CatalogCell ()
{
    UIImageView *divider;
    UIImageView *padView;
}
@end
@implementation CatalogCell
@synthesize catalog = _catalog;
@synthesize titleLabel = _titleLabel;
@synthesize valueLabel = _valueLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        UIView* bgview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        bgview.opaque = YES;
        bgview.backgroundColor = [UIColor listItemBgColor];
        self.backgroundView = bgview;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor textWhiteColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)valueLabel
{
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _valueLabel.textColor = [UIColor textGreenColor];
        _valueLabel.backgroundColor = [UIColor clearColor];
        _valueLabel.numberOfLines = 0;
        [self.contentView addSubview:_valueLabel];
    }
    return _valueLabel;
}

- (void)setCatalog:(CatalogBean *)catalog
{
    _catalog = catalog;
    
    self.titleLabel.text = catalog.title;
    self.valueLabel.text = catalog.value;
    self.accessoryType = catalog.hasMoreAction ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    CGFloat padLeft = catalog.hasIndent ? 20 : 0;
    
    CGRect titleFrame = CGRectMake(padLeft + 20, 10, 0, 0);
    titleFrame.size.width = 320 - padLeft - 20;
    if (catalog.hasValue) {
        titleFrame.size.width -= 100;
    } else if (catalog.hasMoreAction) {
        titleFrame.size.width -= 50;
    }
    CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(titleFrame.size.width, MAXFLOAT) lineBreakMode:self.titleLabel.lineBreakMode];
    titleFrame.size.height = size.height + 5;
    
    
    CGRect valueFrame = CGRectZero;
    if (catalog.hasValue) {
        valueFrame = CGRectMake(240, 0, 60, 30);
        size = [self.valueLabel.text sizeWithFont:self.valueLabel.font constrainedToSize:CGSizeMake(valueFrame.size.width, MAXFLOAT) lineBreakMode:self.valueLabel.lineBreakMode];
        valueFrame.size.height = size.height + 5;
    }
    
    CGRect selfFrame = self.frame;
    selfFrame.size.height = MAX(titleFrame.size.height, valueFrame.size.height) + 20;
    titleFrame.origin.y = (selfFrame.size.height - titleFrame.size.height) / 2;
    valueFrame.origin.y = (selfFrame.size.height - valueFrame.size.height) / 2;
    
    self.frame = selfFrame;
    self.titleLabel.frame = titleFrame;
    self.valueLabel.frame = valueFrame;
    
    if (!padView) {
        padView = [[UIImageView alloc] initWithFrame:CGRectZero];
        padView.image = [XLUtils imageFromColor:[UIColor listItemBgColor]];
        [self addSubview:padView];
    }
    padView.frame = CGRectMake(0, 0, padLeft, self.frame.size.height);
    if (!divider) {
        divider = [[UIImageView alloc] initWithFrame:CGRectZero];
        divider.image = [XLUtils imageFromColor:[UIColor listDividerColor]];
        [self addSubview:divider];
    }
    divider.frame = CGRectMake(padLeft, self.frame.size.height - 1, 320 - padLeft, 1);
}

@end

@implementation CatalogBean
@end



@interface DeviceOrPointDataCatalogViewController ()
{
    MJRefreshHeaderView *refreshHeader;
    NSDictionary *bundle;
    NSString *notifKey;
    
    NSDate *initTime;
}

@property (nonatomic) NSMutableArray *sectionInfoArray;
@property (nonatomic) NSInteger openSectionIndex;

@end

@implementation DeviceOrPointDataCatalogViewController
@synthesize deviceOrPoint = _deviceOrPoint;

- (id)initWithDeviceOrPoint:(id)deviceOrPoint;
{
    self = [super init];
    if (self) {
        _deviceOrPoint = deviceOrPoint;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self initData];
    
//    if (!self.realtime) {
//        self.bottomView.hidden = YES;
//        self.tableView.frame = CGRectUnion(self.tableView.frame, self.bottomView.frame);
//    } else {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addHeader];
    
    self.button1.frame = CGRectMake(117.5, 10, 85, 30);
    [self.button1 setTitle:@"召测" forState:UIControlStateNormal];
    [self.button1 normalStyle];
    [self.button1 addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventTouchUpInside];
    self.button2.hidden = YES;
    self.button3.hidden = YES;
    self.button4.hidden = YES;
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:XLViewDataNotification object:nil];
    notifKey = [NSString stringWithFormat:@"%@-%@", [self.deviceOrPoint description], (self.realtime ? @"实时数据" : @"历史数据")];
    
    //[self queryDataForDate:[NSDate date]];
}

- (void)queryDataForDate:(NSDate *)date
{
    self.refreshDate = date;
    if (refreshHeader.isRefreshing) {
        [refreshHeader endRefreshing];
    }
    [refreshHeader beginRefreshing];
}

- (void)initData
{
    if ([self.deviceOrPoint isKindOfClass:[XLViewDataDevice class]]) {
        [self initDataWithDevice:self.deviceOrPoint];
    } else if ([self.deviceOrPoint isKindOfClass:[XLViewDataTestPoint class]]) {
        [self initDataWithPoint:self.deviceOrPoint];
    }
}

- (CatalogBean *)newCatalogBeanFrom:(XL_VIEW_DATA_TYPE)dataType
{
    NSString *nsTitle= [[NSString alloc] initWithCString:dataType.title encoding:NSUTF8StringEncoding];
    CatalogBean *bean = [[CatalogBean alloc] init];
    bean.title = nsTitle;
    bean.hasValue = NO;
    bean.hasMoreAction = YES;
    bean.hasIndent = YES;
    bean.plotType = dataType.plot_type;
    bean.catalog =[[NSString alloc] initWithCString:dataType.category encoding:NSUTF8StringEncoding];
    
    if (bean.plotType == ONE_DATA) {
        bean.hasValue = YES;
        bean.hasMoreAction = NO;
        bean.value = @"";
    } else if (bean.plotType == ONE_DATA_LIST) {
        bean.hasValue = YES;
        bean.hasMoreAction = YES;
        bean.value = @"";
    }
    
    return bean;
}

- (void)initDataWithDevice:(XLViewDataDevice *)device
{
    self.openSectionIndex = NSNotFound;
    
    if (device.deviceType == DeviceTypeSwitch) {
        APLSectionInfo *sectionInfo = [[APLSectionInfo alloc] init];
        NSMutableArray *childs = [[NSMutableArray alloc] init];
        NSArray *titles;
        if (self.realtime) {
            titles = [NSArray arrayWithObjects:@"回线数据", @"运行状态数据", @"实时遥信类数据", @"实时遥控类数据", @"实时遥测类数据", nil];
        } else {
            titles = [NSArray arrayWithObjects:@"历史遥测类数据", nil];
        }
        [titles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CatalogBean *bean = [[CatalogBean alloc] init];
            bean.title = obj;
            bean.hasValue = NO;
            bean.hasMoreAction = YES;
            bean.hasIndent = NO;
            bean.plotType = SWITCH_DATA;
            
            [childs addObject:bean];
        }];
        
        sectionInfo.childTitles = childs;
        sectionInfo.open = YES;
        self.sectionInfoArray = [NSMutableArray arrayWithObject:sectionInfo];
    } else if (device.deviceType == DeviceTypeFMR) {
        XL_VIEW_DATA_TYPE *data_defines = getTestPointDataDefines(self.realtime);
        
        NSMutableArray *sectionInfoArray = [NSMutableArray array];
        [[NSArray arrayWithObjects:@"变压器特有数据", @"其他数据", nil] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *category = obj;
            NSMutableArray *childs = [[NSMutableArray alloc] init];
            APLSectionInfo *sectionInfo = [[APLSectionInfo alloc] init];
            sectionInfo.title = category;
 
            int i = 0;
            while(data_defines[i].title!=0){
                NSString *nsCategroy= [[NSString alloc] initWithCString:data_defines[i].category encoding:NSUTF8StringEncoding];
                
                if([nsCategroy isEqualToString:category]){
                    CatalogBean *bean = [self newCatalogBeanFrom:data_defines[i]];
                    bean.idxDefine = i;
                    
                    [childs addObject:bean];
                }
                
                i++;
                
            }
            
            sectionInfo.childTitles = childs;
            [sectionInfoArray addObject:sectionInfo];
        }];
        
        self.sectionInfoArray = sectionInfoArray;
    }
    
//    [self.tableView reloadData];
}

- (void)initDataWithPoint:(XLViewDataTestPoint *)point
{
    self.openSectionIndex = NSNotFound;
    
    XL_VIEW_DATA_TYPE *data_defines = getTestPointDataDefines(self.realtime);
    
    NSMutableArray *sectionInfoArray = [NSMutableArray array];
    NSMutableArray *sections = [NSMutableArray arrayWithObjects:@"电能量类数据", @"需量类数据", @"电压电流类数据",  @"功率类数据", nil];
    if ([point isKindOfClass:[XLViewDataUserSumGroup class]]) {
        [sections removeObject:@"需量类数据"];
        [sections removeObject:@"电压电流类数据"];
    }
    [sections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *category = obj;
        NSMutableArray *childs = [[NSMutableArray alloc]init];
        APLSectionInfo *sectionInfo = [[APLSectionInfo alloc] init];

        sectionInfo.title = category;
        
        
        int i = 0;
        while(data_defines[i].title!=0){
            NSString *nsCategroy= [[NSString alloc] initWithCString:data_defines[i].category encoding:NSUTF8StringEncoding];
            
            if([nsCategroy isEqualToString:category]){
                CatalogBean *bean = [self newCatalogBeanFrom:data_defines[i]];
                bean.idxDefine = i;
                
                [childs addObject:bean];
            }
            
            i++;
            
        }

        sectionInfo.childTitles = childs;
        [sectionInfoArray addObject:sectionInfo];
    }];
    
    self.sectionInfoArray = sectionInfoArray;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleNotification:(NSNotification *)aNotification
{
    NSDictionary *dic = (NSDictionary *)aNotification.userInfo;
    if ([NotificationName(dic) isEqualToString:notifKey]) {
        NSDictionary *result = NotificationResult(dic);
        dispatch_async(dispatch_get_main_queue(), ^{
            [refreshHeader endRefreshing];
            
            bundle = result;
            for (APLSectionInfo *section in self.sectionInfoArray) {
                for (CatalogBean *bean in section.childTitles) {
                    if (bean.plotType == ONE_DATA || bean.plotType == ONE_DATA_LIST) {
                        NSString *val = [bundle objectForKey:bean.title];
                        if (val) {
                            bean.value = val;
                        }
                    }
                }
            }
            [self.tableView reloadData];
        });
    }
}

- (void)addHeader
{
    __unsafe_unretained UIViewController *vc = self;
    refreshHeader = [MJRefreshHeaderView header];
    refreshHeader.scrollView = self.tableView;
    refreshHeader.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [vc performSelector:@selector(quertCatalogData) withObject:nil];
    };
}

- (void)quertCatalogData
{
    if ([self.deviceOrPoint isKindOfClass:[XLViewDataDevice class]]) {
        XLViewDataDevice *device = self.deviceOrPoint;
        if (device.deviceType == DeviceTypeSwitch) {
            [refreshHeader endRefreshing];
            return;
        }
    }
    NSString *catalog;
    if (self.openSectionIndex != NSNotFound) {
        APLSectionInfo *sectionInfo = (self.sectionInfoArray)[self.openSectionIndex];
        catalog = sectionInfo.title;
    }
    if (!catalog.length) {
        [refreshHeader endRefreshing];
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         notifKey, @"xl-name",
                         [NSNumber numberWithBool:self.realtime], @"realtime",
                         self.refreshDate, @"time",
                         catalog, @"catalog",
                         nil];
    if ([self.deviceOrPoint isKindOfClass:[XLViewDataDevice class]]) {
        [((XLViewDataDevice *)self.deviceOrPoint) queryCatalogData:dic];
    } else if ([self.deviceOrPoint isKindOfClass:[XLViewDataTestPoint class]]) {
        [((XLViewDataTestPoint *)self.deviceOrPoint) queryCatalogData:dic];
    }
}
//- (void)doneWithView:(MJRefreshBaseView *)refreshView
//{
//    [self refreshData:nil];
//    [refreshView endRefreshing];
//}

- (void)dealloc
{
    [refreshHeader free];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sectionInfoArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	APLSectionInfo *sectionInfo = (self.sectionInfoArray)[section];
	NSInteger numStoriesInSection = sectionInfo.childTitles.count;
    
    return sectionInfo.open ? numStoriesInSection : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    CatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[CatalogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[indexPath.section];
    CatalogBean *bean = [sectionInfo.childTitles objectAtIndex:indexPath.row];
    cell.catalog = bean;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self tableView:tableView cellForRowAtIndexPath:indexPath].frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    APLSectionHeaderView *sectionHeaderView;
    
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[section];
    if (sectionInfo.headerView) {
        sectionHeaderView = sectionInfo.headerView;
    } else {
        sectionHeaderView = [[NSBundle mainBundle] loadNibNamed:@"SectionHeaderView" owner:self options:nil][0];
        sectionInfo.headerView = sectionHeaderView;
    }
    
    sectionHeaderView.disclosureButton.selected = sectionInfo.open;
    sectionHeaderView.titleLabel.text = sectionInfo.title;
    sectionHeaderView.section = section;
    sectionHeaderView.delegate = self;
    
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.deviceOrPoint isKindOfClass:[XLViewDataDevice class]]
        && ((XLViewDataDevice *)self.deviceOrPoint).deviceType == DeviceTypeSwitch) {
        return 0;
    }
    return 48;
}

#pragma mark - SectionHeaderViewDelegate

- (void)sectionHeaderView:(APLSectionHeaderView *)sectionHeaderView sectionOpened:(NSInteger)sectionOpened {
    
	APLSectionInfo *sectionInfo = (self.sectionInfoArray)[sectionOpened];
    
	sectionInfo.open = YES;
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = [sectionInfo.childTitles count];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
    
    NSInteger previousOpenSectionIndex = self.openSectionIndex;
    if (previousOpenSectionIndex != NSNotFound) {
        
		APLSectionInfo *previousOpenSection = (self.sectionInfoArray)[previousOpenSectionIndex];
        previousOpenSection.open = NO;
        [previousOpenSection.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = [previousOpenSection.childTitles count];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenSectionIndex]];
        }
    }
    
    // style the animation so that there's a smooth flow in either direction
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenSectionIndex == NSNotFound || sectionOpened < previousOpenSectionIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // apply the updates
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [self.tableView endUpdates];
    
    self.openSectionIndex = sectionOpened;
    
    [self quertCatalogData];
}

- (void)sectionHeaderView:(APLSectionHeaderView *)sectionHeaderView sectionClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	APLSectionInfo *sectionInfo = (self.sectionInfoArray)[sectionClosed];
    
    sectionInfo.open = NO;
    NSInteger countOfRowsToDelete = [self.tableView numberOfRowsInSection:sectionClosed];
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
    }
    self.openSectionIndex = NSNotFound;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    APLSectionInfo *sectionInfo = (self.sectionInfoArray)[indexPath.section];
    CatalogBean *bean = [sectionInfo.childTitles objectAtIndex:indexPath.row];
    
    //处理非图表数据
    switch (bean.plotType) {
        case SWITCH_DATA: {
            SwitchDataCatalog2ViewController *controller = [[SwitchDataCatalog2ViewController alloc] init];
            controller.device = self.deviceOrPoint;
            controller.realtime = self.realtime;
            controller.category = bean.title;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        case DEVICE_PARAM_STATUS: {
            DeviceParamStatusViewController *controller = [[DeviceParamStatusViewController alloc] init];
            controller.device = self.deviceOrPoint;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        case DEVICE_STATUS_FLAG: {
            DeviceStatusFlagViewController *controller = [[DeviceStatusFlagViewController alloc] init];
            controller.device = self.deviceOrPoint;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        case LIST_DATA:
        case ONE_DATA_LIST: {
            TestPointRateDetialViewController *controller = [[TestPointRateDetialViewController alloc] init];
            controller.testPoint = self.deviceOrPoint;
            controller.realtime = self.realtime;
            controller.category = bean.title;
            controller.refreshDate = self.refreshDate;
            [self.navigationController pushViewController:controller animated:YES];
            return;
        }
        default:
            break;
    }
    

    [self tableView:tableView didSelectPointCatalog:bean];

}

- (void)tableView:(UITableView *)tableView didSelectPointCatalog:(CatalogBean *)catalog
{
    NSString *title = catalog.title;
    
    
    
    
    
    if ([self.deviceOrPoint isKindOfClass:[XLViewDataDevice class]]) {
            //todo 获取测量点或设备ID
    } else if ([self.deviceOrPoint isKindOfClass:[XLViewDataTestPoint class]]) {
         //todo 获取测量点或设备ID
    }
    
    
    XL_VIEW_DATA_TYPE* data_defines=getTestPointDataDefines(self.realtime);
    XLViewPlotType plot_type = data_defines[catalog.idxDefine].plot_type;
    
    if (plot_type == ONE_DATA) {
        //nothing to do
    } else {
        NSLog(@"plot data");
        
        CommonPowerPlotViewController *controller = [[CommonPowerPlotViewController alloc] initWithNibName:@"CommonPowerPlotViewController" bundle:nil];
        controller.plotType=data_defines[catalog.idxDefine].plot_type;
        
        
        char* plot_num_and_times=data_defines[catalog.idxDefine].valueProperty;
        
        
        
        
        NSMutableArray* plot_tags = [[NSMutableArray alloc]init];
        
        
        char *c = plot_num_and_times;
        
        controller.plotNum = *c-'0';
        
        //skip the plot num and first ","
        if(controller.plotNum==1)
            c+=2;
        else{
            //parse the plot tag
            
            char tagdef[128];
            //skip the plot num and first '['
            c+=2;
            
            int j=0;
            while(true){
                if(*c==',' || *(c)==']'){
                    tagdef[j]=0;
                    j=0;
                    NSString *tag= [[NSString alloc] initWithCString:tagdef encoding:NSUTF8StringEncoding];
                    [plot_tags addObject:tag];
                    
                    if(*c==']') break;
                    
                }else{
                    tagdef[j]=*c;
                    j++;
                }
                c++;
            }
            
            //skip ']' and ','
            c+=2;                                    
            controller.plotTags = plot_tags;
            
            
            
            
            
            
        }
        
        NSMutableArray* array = [[NSMutableArray alloc]init];
        
        
        
        char value[6];

        //解析日期类型
        
        int j=0;
        while(true){
            if(*c==',' || *c=='\0'){
                value[j]=0;
                j=0;
                NSString *tag= [[NSString alloc] initWithCString:value encoding:NSUTF8StringEncoding];
                [array addObject:tag];
                
                if(*c=='\0') break;
                
            }else{
                value[j]=*c;
                j++;
            }
            c++;
        }

 
        
        controller.timeTypes=array;
        
        
        NSMutableArray* arrayForKeys = [[NSMutableArray alloc]init];
        
        int k=0;
        while(data_defines[catalog.idxDefine].keys[k]!=0){
            NSString *key = [[NSString alloc] initWithCString:data_defines[catalog.idxDefine].keys[k] encoding:NSUTF8StringEncoding];
            [arrayForKeys addObject:key];
            k++;
        }
        
        controller.dataMapKeys=arrayForKeys;
        
        
        

        controller.plotDataTitle=title;
        
        controller.plotCatalog = catalog.catalog;
        
        
        
        controller.plotDataType=XLViewPlotDataByName;
        
        controller.refDate=[NSDate date];
        

        
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didSelectDeviceCatalog:(CatalogBean *)catalog
{
    XLViewDataDevice *device = self.deviceOrPoint;
    //TODO
}

- (IBAction)refreshData:(id)sender
{
    [self quertCatalogData];
    //[self.tableView reloadData];
}

@end
