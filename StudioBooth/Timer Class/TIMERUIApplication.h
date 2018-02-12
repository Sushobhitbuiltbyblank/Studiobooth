//
//  TIMERUIApplication.h
//  StudioBooth
//
//  Created by Sushobhit_BuiltByBlank on 9/21/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

//the length of time before your application "times out". This number actually represents seconds, so we'll have to multiple it by 60 in the .m file
#define kApplicationTimeoutInMinutes 45

//the notification your AppDelegate needs to watch for in order to know that it has indeed "timed out"
#define kApplicationDidTimeoutNotification @"AppTimeOut"

@interface TIMERUIApplication : UIApplication
{
    NSTimer     *myidleTimer;
}

-(void)resetIdleTimer;
-(void)resetIdleTimerAfter:(int) timeout;
@end
