//
//  AppDelegate.m
//  StudioBooth
//
//  Created by Bhupinder Verma on 06/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
@interface AppDelegate ()
{
    NSString * filePath;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[Fabric sharedSDK] setDebug: YES];
    [Fabric with:@[CrashlyticsKit]];
    // TODO: Move this to where you establish a user session
    [self logUser];

    self.isStaging = NO;
    // staging  - url - http://staging.studiobooth.us
    // live - url - https://studiobooth.us
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // Override point for customization after application launch.

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"offlineData"] == nil) {
        self.offlineData = [[NSMutableArray alloc]init];
    }
    else{
        self.offlineData = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"offlineData"]];
    }
   
    [self setupNavigation];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self.window makeKeyAndVisible];
    sleep(3.);
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
        [[NSUserDefaults standardUserDefaults] setObject:self.offlineData forKey:@"offlineData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark- Void Method- Navigation and HUD

- (void)setupNavigation {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.mainVC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    self.nvc = [[UINavigationController alloc] initWithRootViewController:self.mainVC];
    [self.window setRootViewController:self.nvc];
    self.nvc.navigationBarHidden = YES;
    
    _hud = [[MBProgressHUD alloc] initWithWindow:self.window];
    _hud.color = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5f];
    _hud.frame = CGRectMake(334, 462, 100, 100);
    _hud.minSize = CGSizeMake(120, 120);
    _hud.cornerRadius = 0.f;
    _hud.bounds = CGRectMake(334, 462, 120, 120);
    _hud.square = YES;
    _hud.labelFont = [UIFont fontWithName:@"Helvetica-light" size:10.0];
    _hud.detailsLabelFont = [UIFont fontWithName:@"Helvetica-light" size:10.0];
   // _hud.labelColor = [UIColor blackColor];
   // _hud.activityIndicatorColor = [UIColor blackColor];
    _hud.margin = 2;
    _hud.labelText = @"  ";
    _hud.detailsLabelText = @"P L E A S E  W A I T";
    [self.window addSubview:_hud];
    [_hud setHidden:YES];
    [_hud show:YES];
}

- (void) logUser {
    // TODO: Use the current user's information
    // You can call any combination of these three methods
    [CrashlyticsKit setUserIdentifier:@"12345"];
    [CrashlyticsKit setUserEmail:@"user@fabric.io"];
    [CrashlyticsKit setUserName:@"Test User"];
}

@end
