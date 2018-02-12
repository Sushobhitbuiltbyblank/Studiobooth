//
//  Constants.h
//  StudioBooth
//
//  Created by Bhupinder Verma on 07/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#ifndef StudioBooth_Constants_h
#define StudioBooth_Constants_h
#define KAPIURLStaging @"http://staging.studiobooth.us"
#define kAPIURL @"https://studiobooth.us" //https://demo.builtbyblank.com/studiobooth"
#define kLoginAPI @"/API/POST/eventinfo.php"
#define kUserDataAPI @"/API/POST/userdata.php"
#define kSendMediaAPI @"/API/POST/media.php"
#define kSendMailAPI @"/API/POST/event_email.php"
#define kSendMobileAPI @"/API/POST/event_sms.php"


#define kAppEmailIdKey @"email_id"
#define kAppLinkKey @"link"
#define kAppMobileNumKey @"mobile_number"
#define kAppUsernameKey @"username"
#define kAppPasswordKey @"password"
#define kAppClientIdKey @"client_id"
#define kAppEventIdKey @"event_id"
#define kAppAuthKey @"auth_key"
#define kAppMessageKey @"message"
#define kAppMediaTypeKey @"media_type"
#define kAppMediaKey @"media"
#define kAppMediaUploadKey @"upload_path"
#define kAppSMSMessageKey @"sms_messages"
#define kAppSMSAllowedKey @"email"
#define kAppEmailAllowedKey @"sms"
#define kAppMaxVdoRecordTime @"max_record_time"
#define kAPIkey @"API"

#define kAutoStr @"auto"
#define kCloudyStr @"cloudy"
#define kDayLightStr @"daylight"
#define kIncandescentStr @"incandescent"
#define kflourescentStr @"flourescent"

#define kAcceptAgreement @"agreement_accepted"
#define kAppHaveShareLink @"HaveShareLink"
#define kAppAuthValue @"03c017f682085142f3b60f56673e22dc"

#define kImagefileName @"studiobooth_imagefile.jpeg"
#define kGIFfileName @"studiobooth_animatedfile.gif"
#define kVideofileName @"studiobooth_video.mp4"
#define kBoomerangGifName @"studiobooth_gifVideo.mp4"

#define kMediaUploadNotification @"MediaFileUploadNotification"
#define kUploadResponseKey @"upload_response"
#define kUploadErrorKey @"internal_error"

#define kRememberLogin @"login_remeber"
#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]
#define USERDEFAULTS(arg)[[NSUserDefaults standardUserDefaults] objectForKey:arg]

#define kAppTextColor [UIColor colorWithRed:67.0/255.0 green:67.0/255.0 blue:67.0/255.0 alpha:1.0]

#define kLogoOverlay @"overlay_logo"
#endif
