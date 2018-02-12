//
//  NSBundle+LibraryExtension.m
//  PrecisoControls
//
//  Created by MacMini on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSBundle+LibraryExtension.h"

@implementation NSBundle (LibraryExtension)

+ (NSBundle*)libraryResourcesBundle {
    static dispatch_once_t onceToken;
    static NSBundle *libraryResourcesBundle = nil;
    dispatch_once(&onceToken, ^{
        NSURL * bundleURL = [[NSBundle mainBundle] URLForResource:@"PrecisoControlsResources" withExtension:@"bundle"];
        if(bundleURL)
        libraryResourcesBundle = [NSBundle bundleWithURL:bundleURL];
    });
    return libraryResourcesBundle;
}
@end
