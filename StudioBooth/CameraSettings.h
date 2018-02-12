//
//  CameraSettings.h
//  StudioBooth
//
//  Created by Bhupinder Verma on 29/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "PersistenceController.h"
#import "Singleton.h"
#import "Helper.h"

@interface CameraSettings : NSManagedObject

@property (nonatomic, retain) NSString * mexposure;
@property (nonatomic, retain) NSString * mzoom;
@property (nonatomic, retain) NSString * mwhitebalancing;
@property (nonatomic, retain) NSString * mfront;
@property (nonatomic, retain) NSString * mcolor;
@property (nonatomic, retain) NSNumber * muserid;

+ (CameraSettings *)saveDataWithDictionary:(NSDictionary *)dictObj;
+ (CameraSettings *)fetchMatchingUser;

@end
