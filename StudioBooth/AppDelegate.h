//
//  AppDelegate.h
//  StudioBooth
//
//  Created by Bhupinder Verma on 06/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "MBProgressHUD.h"
#import "WebserviceHelper.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *nvc;
@property (strong, nonatomic) ViewController *mainVC;
@property (nonatomic, retain) MBProgressHUD *hud;
@property (nonatomic, strong) NSMutableArray *offlineData;
@property BOOL isStaging;
- (void)setupNavigation;
@end

