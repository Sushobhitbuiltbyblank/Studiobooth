//
//  CameraSettings.m
//  StudioBooth
//
//  Created by Bhupinder Verma on 29/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import "CameraSettings.h"


@implementation CameraSettings

@dynamic mexposure;
@dynamic mzoom;
@dynamic mwhitebalancing;
@dynamic mfront;
@dynamic mcolor;
@dynamic muserid;

+ (CameraSettings *)saveDataWithDictionary:(NSDictionary *)dictObj
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [[PersistenceController sharedInstance] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CameraSettings" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    CameraSettings *mCameraSettingsData = nil;//*mWeatherData = nil;
    BOOL exists = NO;
    for(CameraSettings *cameraSettingsDataObj in fetchedObjects)
    {
        if ([[NSString stringWithFormat:@"%@", [dictObj valueForKey:@"kuserid"]] intValue] == [cameraSettingsDataObj.muserid intValue]){
            mCameraSettingsData = cameraSettingsDataObj;
            exists = YES;
            break;
        }
    }
    if (!exists)
        mCameraSettingsData = (CameraSettings *)[NSEntityDescription insertNewObjectForEntityForName:@"CameraSettings" inManagedObjectContext:[[PersistenceController sharedInstance] managedObjectContext]];
    if (![Helper checkForNullValues:dictObj withKeyValue:@"kexposure"]){
        mCameraSettingsData.mexposure = [Helper stringByStrippingHTML:[NSString stringWithFormat:@"%@", [dictObj valueForKey:@"kexposure"]]];
    }
    if (![Helper checkForNullValues:dictObj withKeyValue:@"kuserid"]){
        mCameraSettingsData.muserid = [NSNumber numberWithInt:[[NSString stringWithFormat:@"%@", [dictObj valueForKey:@"kuserid"]] intValue]];
    }
    if (![Helper checkForNullValues:dictObj withKeyValue:@"kzoom"]){
        mCameraSettingsData.mzoom = [NSString stringWithFormat:@"%@", [dictObj valueForKey:@"kzoom"]];
    }
    if (![Helper checkForNullValues:dictObj withKeyValue:@"kwhitebalance"]){
        mCameraSettingsData.mwhitebalancing = [NSString stringWithFormat:@"%@", [dictObj valueForKey:@"kwhitebalance"]];
    }
    if (![Helper checkForNullValues:dictObj withKeyValue:@"kfront"]){
        mCameraSettingsData.mfront = [NSString stringWithFormat:@"%@", [dictObj valueForKey:@"kfront"]];
    }
    if (![Helper checkForNullValues:dictObj withKeyValue:@"kcolor"]){
        mCameraSettingsData.mcolor = [NSString stringWithFormat:@"%@", [dictObj valueForKey:@"kcolor"]];
    }
    [[PersistenceController sharedInstance] saveContext];
    return mCameraSettingsData;
}

+ (CameraSettings *)fetchMatchingUser {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [[PersistenceController sharedInstance] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"CameraSettings" inManagedObjectContext:context];

    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"muserid == %@", [Helper getUserInfoValueForKey:kAppClientIdKey]]];
    
    NSArray* results = [context executeFetchRequest:fetchRequest error:nil];
    
    if(results.count>0)
    {
        for(CameraSettings* cameraObj in results)
        {
            NSLog(@"found obj: %@", [cameraObj description ]);
        }
        return [results lastObject];
    }else{
        NSLog(@"Creating obj" );
    }
    return nil;
}

@end
