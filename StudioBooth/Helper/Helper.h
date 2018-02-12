

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

typedef void (^completionBlock)(id response, NSError *error);

@interface Helper : NSObject
{

}


+ (BOOL) validateEmail:(NSString *)email;
+(void)showAlert:(NSString *)title andMessage:(NSString *)msg;
+ (NSString *)getUserInfoValueForKey:(NSString *)mkeyStr;
//+ (NSString *)createAnimatedGif:(NSMutableArray *) imagesArray;
+ (NSURL *)createAnimatedGif:(NSMutableArray *) imagesArray;
+ (void)deleteDocumentDirectoryFile:(NSString *)fileName;
+ (NSString *)getDirectoryFilePath:(NSString *) fileName;
+ (void)saveImageToDocumentsDirectory:(UIImage *)mimage withFileName:(NSString *)fileName;
+ (BOOL)checkForNullValues:(NSDictionary*) mDict withKeyValue:(NSString *)keyStr;
+(NSString *)stringByStrippingHTML:(NSString *) mTextStr;
+ (NSArray*) getCoreDataReturnObjectArray:(NSString*)typeStr;
+ (NSString *)timeFormatted:(int)totalSeconds;
+ (NSString *)getCurrentTime;

@end
