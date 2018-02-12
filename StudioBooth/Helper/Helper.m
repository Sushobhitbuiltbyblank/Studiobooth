
#import "Helper.h"
#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@implementation Helper

#pragma mark -
#pragma mark Check Whether Internet is active or not 

+(void)showAlert:(NSString *)title andMessage:(NSString *)msg {
    UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alrt show];
}

+ (BOOL)validateEmail:(NSString *)email
{
    NSString * emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,4}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

+ (NSString *)getUserInfoValueForKey:(NSString *)mkeyStr {
    
    NSString *mstr = [NSString new];
    NSDictionary *minfoDict = (NSDictionary *)[USER_DEFAULTS objectForKey:@"user_information"];
    if ([minfoDict valueForKey:mkeyStr]){
        mstr = [NSString stringWithFormat:@"%@", [minfoDict valueForKey:mkeyStr]];
        if (mstr){
            return mstr;
        }
    }
    return nil;
}

+ (NSString *)createAnimatedGif_testing:(NSMutableArray *) imagesArray {

    UIImage *shacho = [UIImage imageNamed:@"icon_100.png"];
    UIImage *bucho = [UIImage imageNamed:@"icon_144.png"];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"studiobooth_animatedfile.gif"];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], kUTTypeGIF, 2, NULL);
    
    NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:(NSString *)kCGImagePropertyGIFDelayTime] forKey:(NSString *)kCGImagePropertyGIFDictionary];
    NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount] forKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    CGImageDestinationAddImage(destination, shacho.CGImage, (CFDictionaryRef)frameProperties);
    CGImageDestinationAddImage(destination, bucho.CGImage, (CFDictionaryRef)frameProperties);
    CGImageDestinationSetProperties(destination, (CFDictionaryRef)gifProperties);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    NSLog(@"animated GIF file created at %@", path);
    return path;
}


//static UIImage *frameImage(CGSize size, CGFloat radians) {
//    UIGraphicsBeginImageContextWithOptions(size, YES, 1); {
//        [[UIColor whiteColor] setFill];
//        UIRectFill(CGRectInfinite);
//        CGContextRef gc = UIGraphicsGetCurrentContext();
//        CGContextTranslateCTM(gc, size.width / 2, size.height / 2);
//        CGContextRotateCTM(gc, radians);
//        CGContextTranslateCTM(gc, size.width / 4, 0);
//        [[UIColor redColor] setFill];
//        CGFloat w = size.width / 10;
//        CGContextFillEllipseInRect(gc, CGRectMake(-w / 2, -w / 2, w, w));
//    }
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

+ (NSURL *)createAnimatedGif:(NSMutableArray *) imagesArray {
    NSString *frameRate = [NSString stringWithFormat:@"%@",[USER_DEFAULTS valueForKey:@"frame_rate"]];
    float ff = [frameRate floatValue];
    NSNumber *frame = @(ff);
    NSUInteger kFrameCount = [imagesArray count];

    NSDictionary *fileProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{
                                             (__bridge id)kCGImagePropertyGIFLoopCount: @0, // 0 means loop forever
                                             }
                                     };
    
    NSDictionary *frameProperties = @{ (__bridge id)kCGImagePropertyGIFDictionary: @{
                                               (__bridge id)kCGImagePropertyGIFDelayTime: frame, // a float (not double!) in seconds, rounded to centiseconds in the GIF data
                                              }
                                      };
    
    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:kGIFfileName];
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)fileURL, kUTTypeGIF, kFrameCount, NULL);
    CGImageDestinationSetProperties(destination, (__bridge CFDictionaryRef)fileProperties);
    
    for (NSUInteger i = 0; i < kFrameCount; i++) {
        @autoreleasepool {
//            UIImage *image = frameImage(CGSizeMake(300, 300), M_PI * 2 * i / kFrameCount);
            UIImage *image = [imagesArray objectAtIndex:i];
            CGImageDestinationAddImage(destination, image.CGImage, (__bridge CFDictionaryRef)frameProperties);
        }
    }
    
    if (!CGImageDestinationFinalize(destination)) {
        NSLog(@"failed to finalize image destination");
    }
    CFRelease(destination);
    
    NSLog(@"url=%@", fileURL);
    return fileURL;
}

+ (NSString *)getDirectoryFilePath:(NSString *) fileName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *myFilePath = [documentsDirectoryPath stringByAppendingPathComponent:fileName];
    return myFilePath;
}

+ (void)deleteDocumentDirectoryFile:(NSString *)fileName {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathString = [self getDirectoryFilePath:fileName];
    if ([fileManager fileExistsAtPath:pathString])
    {
        NSError *error;
        if (![fileManager removeItemAtPath:pathString error:&error])
        {
            NSLog(@"Error removing file: %@", error);
        };
    }
//    [fileManager removeItemAtPath:[self getDirectoryFilePath:fileName] error:NULL];
}

+ (void)saveImageToDocumentsDirectory:(UIImage *)mimage withFileName:(NSString *)fileName {
    NSData *dataForJPEGFile = UIImageJPEGRepresentation(mimage, 0.80f);
    NSError *error2 = nil;
    if (![dataForJPEGFile writeToFile:[self getDirectoryFilePath:fileName] options:NSAtomicWrite error:&error2])
    {
        return;
    }

//    NSData *imageData = UIImagePNGRepresentation(mimage);
//    [imageData writeToFile:[self getDirectoryFilePath:fileName] atomically:NO];
}

#pragma mark- CORE-DB Methods

+ (NSArray*) getCoreDataReturnObjectArray:(NSString*)typeStr
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [[PersistenceController sharedInstance] managedObjectContext];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[NSString stringWithFormat:@"%@", typeStr] inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    if ([fetchedObjects count])
        return fetchedObjects;
    else
        return nil;
}

+ (BOOL)checkForNullValues:(NSDictionary*) mDict withKeyValue:(NSString *)keyStr
{
    if ([mDict valueForKey:keyStr]!=nil && ![[mDict valueForKey:keyStr] isKindOfClass:[NSNull class]])
        return NO;
    else
        return YES;
}

+(NSString *)stringByStrippingHTML:(NSString *) mTextStr
{
    NSRange r;
    while ((r = [mTextStr rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        mTextStr = [mTextStr stringByReplacingCharactersInRange:r withString:@"\n"];
    
    mTextStr = [mTextStr stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    mTextStr = [mTextStr stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    // BN14
    mTextStr = [mTextStr stringByReplacingOccurrencesOfString:@"&nbsp" withString:@" "];
    mTextStr = [mTextStr stringByReplacingOccurrencesOfString:@"<p>;" withString:@""];
    mTextStr = [mTextStr stringByReplacingOccurrencesOfString:@"&eacute;" withString:@"e"];
    
    return mTextStr;
}

+ (NSString *)timeFormatted:(int)totalSeconds {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    NSString *str = @"";
    if (hours>0) {
        str = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,seconds];
    }
    if (minutes>0) {
        str = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    }
    if (seconds>=0) {
        str = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    }
    return str;
}
+ (NSString *)getCurrentTime
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *est = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    [dateFormatter setTimeZone:est];
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    return time;
}
@end
