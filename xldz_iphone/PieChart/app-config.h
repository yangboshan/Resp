//
//  app-config.h
//  XLApp
//
//  Created by sureone on 3/3/14.
//  Copyright (c) 2014 Pixel-in-Gene. All rights reserved.
//

#ifndef XLApp_app_config_h
#define XLApp_app_config_h

#define SCALE_FROM_PARENT

#define MAX_DETAIL_DIALOG_SHOW_TIMER 1

#define DEFAULT_RECORDS_RANGE 30

#define MAJOR_TICK_LENGTH 1.5

#define AXIS_LINE_LENGTH 1.0f

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)

//#define HIDE_EDGL_PLOT

#endif
