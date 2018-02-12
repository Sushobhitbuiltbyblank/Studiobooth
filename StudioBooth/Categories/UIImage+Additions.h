//
//  UIImage+Additions.h
//  Commons
//
//  Created by Omar Hussain on 5/19/13.
//  Copyright (c) 2013 Populace Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
-(UIImage *)scaledToSize:(CGSize)newSize;
-(UIImage *)scaledToScale:(CGFloat)scale;
-(UIImage *)scaledToHScale:(CGFloat)h andVScale:(CGFloat)v;
-(UIImage *)scaledToWidth:(CGFloat)width;
-(UIImage * )cropWithRect:(CGRect)cropRect;
+ (UIImage*)libraryImageNamed:(NSString*)name;
+ (UIImage*)documentsImageNamed:(NSString*)name;
- (UIImage*)imageCroppedToSize:(CGRect)rect;
- (UIImage*) maskWithMask:(UIImage *)maskImage;
- (UIImage*)combineWithImage:(UIImage *)otherimage;
+ (UIImage*) blur:(UIImage*)theImage withRadius:(float)radius;
+(UIImage *)capture:(UIView *)view;
@end
