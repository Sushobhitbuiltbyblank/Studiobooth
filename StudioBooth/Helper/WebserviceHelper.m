//
//  WebserviceHelper.m
//  StudioBooth
//
//  Created by Bhupinder Verma on 07/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import "WebserviceHelper.h"
#import "Constants.h"
#import "AFHTTPRequestOperation.h"
#import "AFURLRequestSerialization.h"
#import "AFURLSessionManager.h"
#import "Helper.h"
#import "AFHTTPRequestOperationManager.h"

@implementation WebserviceHelper

-(void)sendServerRequest:(NSDictionary *)dct andAPI:(NSString *)api{
    NSString *requestStr;
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isStaging]) {
        requestStr  = [NSString stringWithFormat:@"%@%@",KAPIURLStaging, api];
    }
    else{
        requestStr = [NSString stringWithFormat:@"%@%@",kAPIURL, api];
    }
//    NSString *requestStr = [NSString stringWithFormat:@"%@%@",kAPIURL, kLoginAPI];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    
    //convert object to data
   // NSString *requestBody = [NSString stringWithFormat:@"Event Login=%@",[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    NSString *post = [NSString stringWithFormat:@"username=tanmay&password=demo&auth_key=03c017f682085142f3b60f56673e22dc"];
    NSString *mPoststr = [NSString new];
    for (NSString *keystr in [dct allKeys]){
        mPoststr = [mPoststr stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", keystr, [dct valueForKey:keystr]]];
    }
    mPoststr = [mPoststr substringToIndex:(mPoststr.length-1)];
    NSLog(@"%@", mPoststr);
    [self establishConnection:request withString:mPoststr];
}

-(void)sendEmailRequest:(NSDictionary *)dct andAPI:(NSString *)api {
    NSString *requestStr;
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isStaging]) {
        requestStr  = [NSString stringWithFormat:@"%@%@",KAPIURLStaging, kSendMailAPI];
    }
    else{
        requestStr = [NSString stringWithFormat:@"%@%@",kAPIURL, kSendMailAPI];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *post = [NSString stringWithFormat:@"message=%@&event_id=%@&email_id=%@&link=%@&auth_key=%@", [dct valueForKey:kAppMessageKey], [dct valueForKey:kAppEventIdKey], [dct valueForKey:kAppEmailIdKey], [dct valueForKey:kAppLinkKey], [dct valueForKey:kAppAuthKey]];
    [self establishConnection:request withString:post];
}

-(void)sendMediaPostRequest:(NSDictionary *)dct andAPI:(NSString *)api {
    
    NSString *requestStr = [NSString stringWithFormat:@"%@",[dct valueForKey:kAppMediaUploadKey]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestStr]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *post = [NSString stringWithFormat:@"media_type=%@&event_id=%@&media=%@&auth_key=%@", [dct valueForKey:kAppMediaTypeKey], [dct valueForKey:kAppEventIdKey], [dct valueForKey:kAppMediaKey], [dct valueForKey:kAppAuthKey]];
    [self establishConnection:request withString:post];
}

- (void)establishConnection:(NSMutableURLRequest *)request withString:(NSString *)post {
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:postData];
    // print json:
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [conn start];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    NSLog(@"%@",response);
    
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    NSLog(@"loans: %@", json);
    [self.mydelegate callMyCustomDelegateMethod:json];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self.mydelegate callMyCustomDelegateError:[NSString stringWithFormat:@"%@", error.description]];
}

#pragma mark- Upload Media

- (void)uploadDataWithImageTypeFile:(NSString *)fileNameStr withtype:(NSString *)imageTypeStr withCameraType: (NSString *)camType withshareOption:(NSString *)shareOption withShareValue:(NSString *)shareOptionvalue{
    // TIME
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *est = [NSTimeZone timeZoneWithAbbreviation:@"EST"];
    [dateFormatter setTimeZone:est];
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    NSString* uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *uniqueName = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    uniqueName = [uniqueName stringByReplacingOccurrencesOfString:@"."
                                                withString:@""];
    // Upload Media
    NSDictionary *dict = @{kAppAuthKey : kAppAuthValue, kAppEventIdKey : [NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],
                           kAppMediaTypeKey : imageTypeStr,
                           @"camera":camType,
                           shareOption:shareOptionvalue,
                           @"time":time
                           };
    NSString *imgStr;
    if ([imageTypeStr isEqualToString:@"image"]){
        imgStr = [Helper getDirectoryFilePath:kImagefileName];
    }
    else if ([imageTypeStr isEqualToString:@"gif"]){
        if ([fileNameStr isEqual: @"studiobooth_gifVideo"]) {
            imgStr = [Helper getDirectoryFilePath:kBoomerangGifName];
        }
        else
        imgStr = [Helper getDirectoryFilePath:kGIFfileName];
    }
    else {
        imgStr = [Helper getDirectoryFilePath:kVideofileName];
    }
    NSURL *urlStr = [NSURL fileURLWithPath:imgStr];
    NSString *urlString;
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isStaging]) {
        urlString = [NSString stringWithFormat:@"%@%@",KAPIURLStaging, kSendMediaAPI];
    }
    else{
        urlString = [NSString stringWithFormat:@"%@%@",kAPIURL, kSendMediaAPI];
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if ([imageTypeStr isEqualToString:@"video"]){
            [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:[NSString stringWithFormat:@"%@_%@.mp4",uniqueIdentifier,uniqueName] mimeType:@"video/mp4" error:nil];
        }
        else {
            if ([imageTypeStr isEqualToString:@"image"]){
                [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:[NSString stringWithFormat:@"%@_%@.jpeg", uniqueIdentifier,uniqueName] mimeType:@"image/jpeg" error:nil];
                NSLog(@"%@",[NSString stringWithFormat:@"%@_%@.jpeg",uniqueIdentifier, uniqueName]);
            }
            else {
                if ([fileNameStr isEqual: @"studiobooth_gifVideo"]) {
                    [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:[NSString stringWithFormat:@"%@_%@.mp4",uniqueIdentifier,uniqueName] mimeType:@"video/mp4" error:nil];
                }
                else
                {
                    [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:[NSString stringWithFormat:@"%@_%@.gif",uniqueIdentifier,uniqueName] mimeType:@"image/gif" error:nil];
                }
            }
        }
    } error:nil];
    [request addValue:@"multipart/form-data" forHTTPHeaderField: @"enctype"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSData *dt = (NSData *) responseObject;
            NSString *myString = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
            NSLog(@"%@",myString);
            
           // id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMediaUploadNotification object:@{kUploadResponseKey :kUploadErrorKey}];
          //  NSLog(@"%@", jsonObject);
        }
        else {                 
            NSLog(@"%@ ", responseObject);
            NSData *dt = (NSData *) responseObject;
            NSString *myString = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
            NSLog(@"%@",myString);
            
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMediaUploadNotification object:@{kUploadResponseKey :jsonObject}];
            NSLog(@"%@", jsonObject);
            NSDictionary *json = @{@"status":@"success"};
            [self.mydelegate callMyCustomDelegateMethod:json];
        }
    }];
    
    [uploadTask resume];
   
}
-(void)UploadOfflineDataWithName:(NSString *)fileNameStr withType:(NSString *)imageTypeStr withCameraType: (NSString *)camType withshareOption:(NSString *)shareOption withShareValue:(NSString *)shareOptionvalue withEventKey:(NSString *)eventId withTime:(NSString *)time withBlock:(resposeCompletionBlock)block
{
    NSDictionary *dict = @{kAppAuthKey : kAppAuthValue, kAppEventIdKey : eventId,
                           kAppMediaTypeKey : imageTypeStr,
                           @"camera":camType,
                           shareOption:shareOptionvalue,
                           @"time":time
                           };
    NSString *imgStr;
    if ([imageTypeStr isEqualToString:@"image"]){
        imgStr = [Helper getDirectoryFilePath:fileNameStr];
    }
    else if ([imageTypeStr isEqualToString:@"gif"]){
        imgStr = [Helper getDirectoryFilePath:fileNameStr];
    }
    else {
        imgStr = [Helper getDirectoryFilePath:fileNameStr];
    }
    NSURL *urlStr = [NSURL fileURLWithPath:imgStr];
    NSString *urlString;
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isStaging]) {
        urlString = [NSString stringWithFormat:@"%@%@",KAPIURLStaging, kSendMediaAPI];
    }
    else{
        urlString = [NSString stringWithFormat:@"%@%@",kAPIURL, kSendMediaAPI];
    }
    //    NSData *dt1 = [NSData dataWithContentsOfURL:urlStr];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if ([imageTypeStr isEqualToString:@"video"]){
//            [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:[NSString stringWithFormat:@"%@.mp4", fileNameStr] mimeType:@"video/mp4" error:nil];
            [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:fileNameStr mimeType:@"video/mp4" error:nil];
        }
        else {
            if ([imageTypeStr isEqualToString:@"image"]){
//                [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:[NSString stringWithFormat:@"%@.png", fileNameStr] mimeType:@"image/png" error:nil];
                 [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:fileNameStr mimeType:@"image/jpeg" error:nil];
//                NSLog(@"%@",[NSString stringWithFormat:@"%@", fileNameStr]);
            }
            else {
//                [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:[NSString stringWithFormat:@"%@.gif", fileNameStr] mimeType:@"image/gif" error:nil];
                [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName: fileNameStr mimeType:@"image/gif" error:nil];

            }
        }
    } error:nil];
    [request addValue:@"multipart/form-data" forHTTPHeaderField: @"enctype"];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSData *dt = (NSData *) responseObject;
            NSString *myString = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
                                                                                             NSLog(@"%@",myString);
            
//             id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            if (block) {
                block(400,@{kUploadResponseKey :kUploadErrorKey});
            }
//            [[NSNotificationCenter defaultCenter] postNotificationName:kMediaUploadNotification object:@{kUploadResponseKey :kUploadErrorKey}];
            //  NSLog(@"%@", jsonObject);
        }
        else {
            NSLog(@"%@ ", responseObject);
            NSData *dt = (NSData *) responseObject;
            NSString *myString = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
            NSLog(@"%@",myString);
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            if (block) {
                block(200,jsonObject);
            }
//            [[NSNotificationCenter defaultCenter] postNotificationName:kMediaUploadNotification object:@{kUploadResponseKey :jsonObject}];
            NSLog(@"%@", jsonObject);
//            NSDictionary *json = @{@"status":@"success"};
//            [self.mydelegate callMyCustomDelegateMethod:json];
        }
    }];
    
    [uploadTask resume];
}


//////////////////--------------------- TEST TEST TEST
- (void)UploadData {
    NSString *post = [NSString stringWithFormat:@"auth_key=%@&event_id=%@&media_type=%@",@"03c017f682085142f3b60f56673e22dc",@"27",@"video"];
    [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // Upload Video
    NSDictionary *dict = @{kAppAuthKey : @"03c017f682085142f3b60f56673e22dc",
                           kAppEventIdKey : @"27",
                           kAppMediaTypeKey : @"image"};
    
    NSString *imgStr = [[NSBundle mainBundle] pathForResource:@"icon_180" ofType:@"png"];
    NSURL *urlStr = [NSURL fileURLWithPath:imgStr];
    NSString *urlString;
    if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] isStaging]) {
        urlString = [NSString stringWithFormat:@"%@%@",KAPIURLStaging, kSendMediaAPI];
    }
    else{
        urlString = [NSString stringWithFormat:@"%@%@",kAPIURL, kSendMediaAPI];
    }
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:urlStr name:kAppMediaKey fileName:@"icon_180" mimeType:@"image/png" error:nil];
    } error:nil];
    
    //    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    //    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    ////    [request setHTTPBody:postData];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSProgress *progress = nil;
    
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            NSData *dt = (NSData *) responseObject;
            NSString *myString = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
            NSLog(@"%@",myString);
            
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", jsonObject);        }
        else {
            NSLog(@"%@ ", responseObject);
            NSData *dt = (NSData *) responseObject;
            NSString *myString = [[NSString alloc] initWithData:dt encoding:NSUTF8StringEncoding];
            NSLog(@"%@",myString);
            
            id jsonObject = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSLog(@"%@", jsonObject);
            
        }
    }];
    
    [uploadTask resume];
}

- (void) testWithNetworking {
    
    NSString *str=[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Archive.zip"];
    NSDictionary *parameters = @{@"foo": @"bar"};
    NSURL *filePath = [NSURL fileURLWithPath:str];
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    
    NSData *imageData=[NSData dataWithContentsOfURL:filePath];
    
    
    NSMutableURLRequest *request =
    [serializer multipartFormRequestWithMethod:@"POST" URLString:@"https://url"
                                    parameters:parameters
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                         [formData appendPartWithFileData:imageData
                                                     name:@"image"
                                                 fileName:@"Archive.zip"
                                                 mimeType:@"application/zip"];
                     } error:nil];
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *operation =
    [manager HTTPRequestOperationWithRequest:request
                                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                         NSLog(@"Success %@", responseObject);
                                     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         NSLog(@"Failure %@", error.description);
                                     }];
    
    
    [operation setUploadProgressBlock:^(NSUInteger __unused bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        NSLog(@"Wrote %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
    }];
}
@end
