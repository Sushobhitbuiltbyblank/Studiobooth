//
//  UIImage+Additions.m
//  Commons
//
//  Created by Omar Hussain on 5/19/13.
//  Copyright (c) 2013 Populace Inc. All rights reserved.
//

#import "UIImage+Additions.h"
#import "NSBundle+LibraryExtension.h"
@implementation UIImage (Additions)

- (UIImage*)imageCroppedToSize:(CGRect)rect
{
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
	CGContextTranslateCTM(currentContext, 0.0, rect.size.height);
	CGContextScaleCTM(currentContext, 1.0, -1.0);
    
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGContextClipToRect( currentContext, clippedRect);
	CGRect drawRect = CGRectMake(rect.origin.x * -1,rect.origin.y * -1,self.size.width,self.size.height);
	CGContextDrawImage(currentContext, drawRect, self.CGImage);
	CGContextScaleCTM(currentContext, 1.0, -1.0);
    
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return cropped;
}
- (UIImage*) maskWithMask:(UIImage *)maskImage {
    
	CGImageRef maskRef = maskImage.CGImage;
    
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
                                        CGImageGetHeight(maskRef),
                                        CGImageGetBitsPerComponent(maskRef),
                                        CGImageGetBitsPerPixel(maskRef),
                                        CGImageGetBytesPerRow(maskRef),
                                        CGImageGetDataProvider(maskRef), NULL, false);
    
	CGImageRef masked = CGImageCreateWithMask([self CGImage], mask);
	return [UIImage imageWithCGImage:masked];
}
- (UIImage*)combineWithImage:(UIImage *)otherimage
{
    UIGraphicsBeginImageContext(self.size);
    [self drawInRect:CGRectMake(0,0,self.size.width,self.size.height)];
    [otherimage drawInRect:CGRectMake(0,0,self.size.width,self.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
-(UIImage *)scaledToWidth:(CGFloat)width{
    CGSize newSize = CGSizeMake(width, (self.size.height/self.size.width) * width);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(UIImage *)scaledToScale:(CGFloat)scale{
    CGSize size = [self size];
    CGSize newSize = CGSizeMake(size.width * scale, size.height * scale);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)scaledToHScale:(CGFloat)h andVScale:(CGFloat)v{
    CGSize size = [self size];
    CGSize newSize = CGSizeMake(size.width * h, size.height * v);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [self drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage * )cropWithRect:(CGRect)cropRect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], cropRect);
    // or use the UIImage wherever you like
    UIImage * croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}
+ (UIImage*)documentsImageNamed:(NSString*)name {
    NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:name];
    UIImage *imageFromDocuments = [UIImage imageWithContentsOfFile:path];
    if (imageFromDocuments) {
        return imageFromDocuments;
    }
    
    NSArray * extensions = @[@"png",@"jpg",@"jpeg",@"JPG",@"bmp",@"BMP"];
    for(NSString * extension in extensions){
        NSString * multiPlatformImageName = name;
        //if([UIDevice de_isRetinaDisplay]){
        //    multiPlatformImageName = [NSString stringWithFormat:@"%@2x.png",multiPlatformImageName];
        //}else{
        multiPlatformImageName = [NSString stringWithFormat:@"%@.%@",path,extension];
        //}
        
        imageFromDocuments = [UIImage imageWithContentsOfFile:multiPlatformImageName];
        if (imageFromDocuments) {
            return imageFromDocuments;
        }
    }
    return nil;
    
    
}
+ (UIImage*)libraryImageNamed:(NSString*)name {
    UIImage *imageFromMainBundle = [UIImage imageNamed:name];
    if (imageFromMainBundle) {
        return imageFromMainBundle;
    }
    
    UIImage *imageFromLibraryBundle = [UIImage imageWithContentsOfFile:[[[NSBundle libraryResourcesBundle] resourcePath] stringByAppendingPathComponent:name]];
    if(imageFromLibraryBundle){
        return imageFromLibraryBundle;
    }
    NSArray * extensions = @[@"png",@"jpg",@"jpeg",@"JPG",@"bmp",@"BMP"];
    for(NSString * extension in extensions){
    NSString * multiPlatformImageName = name;
    //if([UIDevice de_isRetinaDisplay]){
    //    multiPlatformImageName = [NSString stringWithFormat:@"%@2x.png",multiPlatformImageName];
    //}else{
    multiPlatformImageName = [NSString stringWithFormat:@"%@.%@",multiPlatformImageName,extension];
    //}
    
    imageFromMainBundle = [UIImage imageNamed:multiPlatformImageName];
    if (imageFromMainBundle) {
        return imageFromMainBundle;
    }
    
    imageFromLibraryBundle = [UIImage imageWithContentsOfFile:[[[NSBundle libraryResourcesBundle] resourcePath] stringByAppendingPathComponent:multiPlatformImageName]];
        if(imageFromLibraryBundle){
        return imageFromLibraryBundle;
        }
    }
    imageFromLibraryBundle = [UIImage documentsImageNamed:name];
    if(imageFromLibraryBundle){
        return imageFromLibraryBundle;
    }
    return nil;
    
    
}

+ (UIImage*) blur:(UIImage*)theImage withRadius:(float)
radius{
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];

    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:radius] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];

    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    return [UIImage imageWithCGImage:cgImage];
    
    // if you need scaling
    // return [[self class] scaleIfNeeded:cgImage];
}
+(UIImage *)capture:(UIView *)view{
    UIGraphicsBeginImageContext(view.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
