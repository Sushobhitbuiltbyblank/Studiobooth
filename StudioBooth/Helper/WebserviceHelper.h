//
//  WebserviceHelper.h
//  StudioBooth
//
//  Created by Bhupinder Verma on 07/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebserviceHelper;
@protocol MyCustomDelegate <NSObject>   //define delegate protocol
- (void) callMyCustomDelegateMethod: (NSDictionary *) mdict;  //define delegate method to be implemented within another class
- (void) callMyCustomDelegateError:(NSString *)errorStr;  //define delegate method to be implemented within another class
@end //end protocol

@interface WebserviceHelper : NSObject<NSURLConnectionDelegate>{
        NSMutableData *_responseData;
}

-(void)sendServerRequest:(NSDictionary *)dct andAPI:(NSString *)api;
-(void)sendEmailRequest:(NSDictionary *)dct andAPI:(NSString *)api;
-(void)sendMediaPostRequest:(NSDictionary *)dct andAPI:(NSString *)api;
- (void)UploadData;

- (void)uploadDataWithImageTypeFile:(NSString *)fileNameStr withtype:(NSString *)imageTypeStr withCameraType: (NSString *)camType withshareOption:(NSString *)shareOption withShareValue:(NSString *)shareOptionvalue;

typedef void (^resposeCompletionBlock)(int statusCode, NSDictionary *response);
-(void)UploadOfflineDataWithName:(NSString *)fileNameStr withType:(NSString *)imageTypeStr withCameraType: (NSString *)camType withshareOption:(NSString *)shareOption withShareValue:(NSString *)shareOptionvalue withEventKey:(NSString *)eventId withTime:(NSString *)time withBlock:(resposeCompletionBlock)block;
@property (nonatomic, weak) id <MyCustomDelegate> mydelegate; //define MyCustomDelegate as delegate

@end
