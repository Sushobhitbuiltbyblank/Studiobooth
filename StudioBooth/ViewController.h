//
//  ViewController.h
//  StudioBooth
//
//  Created by Bhupinder Verma on 06/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImageView.h"
#import "GPUImage.h"
#import "Helper.h"
#import "ImageClickedVC.h"
#import "AppDelegate.h"
#import "CameraSettings.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
@class AppDelegate;

@interface ViewController : UIViewController<GPUImageVideoCameraDelegate> {
    GPUImageView *cameraView;
    GPUImageStillCamera *videoCamera;
    GPUImageFilterGroup *filterGroup;
    GPUImageMovieWriter *movieWriter;
    GPUImageUIElement *uiElementInput;
    AppDelegate *delegateObj;
    CIDetector *faceDetector;
    UIView *faceView;
    BOOL faceThinking;
    UIVisualEffectView *blurEffectView;
    NSTimer *myTimer, *videoTimer, *gifTimer, *countdowntimer;
}
@property(nonatomic,retain) CIDetector*faceDetector;

@property (strong, nonatomic) IBOutlet FLAnimatedImageView *loaderImgView;

// Start Studio
@property (weak, nonatomic) IBOutlet UIImageView *mSingleMediaImg;

@property (weak, nonatomic) IBOutlet UIView *blackView;
@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;
@property (nonatomic, strong) GPUImageGrayscaleFilter *grayScaleFilter;
@property (nonatomic, strong) GPUImageSharpenFilter *sharpenFilter;

@property (nonatomic, strong) NSString *isImgMediaActive;
@property (nonatomic, strong) NSString *isGifMediaActive;
@property (nonatomic, strong) NSString *isVdoMediaActive;
@property (nonatomic, strong) NSString *choosenMediaType;
@property (nonatomic, strong) NSString *mwhitebalanceTagStr;
@property (nonatomic, strong) NSString *mcamerazoomStr;

@property (nonatomic, strong) NSMutableArray *frameImgsArray;

@property (nonatomic, weak)IBOutlet UIView *mLoginBGView;
@property (nonatomic, weak)IBOutlet UIView *mLoginPopupView;
@property (nonatomic, weak)IBOutlet UIView *mTopBarView;
@property (nonatomic, weak)IBOutlet UIView *mControlBottomView;
@property (nonatomic, weak)IBOutlet UIView *mControlColorChangeView;
@property (nonatomic, weak)IBOutlet UIView *controlView;
@property (nonatomic, weak)IBOutlet UIView *mBottomBarView;
@property (nonatomic, weak)IBOutlet UIView *mTimerView;
@property (nonatomic, weak)IBOutlet UIView *gifFramesView;
@property (nonatomic, weak)IBOutlet UIView *mVideoRecordingView;
@property (nonatomic, weak)IBOutlet UIView *mGifStrip1View;
@property (nonatomic, weak)IBOutlet UIView *mGifStrip2View;
@property (nonatomic, weak)IBOutlet UIView *mGifStrip3View;
@property (nonatomic, weak)IBOutlet UIView *mGifStrip4View;
@property (nonatomic, weak)IBOutlet UIView *multiLineView;

@property (nonatomic, weak)IBOutlet UIView *mGifView1_1;
@property (nonatomic, weak)IBOutlet UIView *mGifView1_2;
@property (nonatomic, weak)IBOutlet UIView *mGifView1_3;
@property (nonatomic, weak)IBOutlet UIView *mGifView2_1;
@property (nonatomic, weak)IBOutlet UIView *mGifView2_2;
@property (nonatomic, weak)IBOutlet UIView *mGifView2_3;
@property (nonatomic, weak)IBOutlet UIView *mGifView3_1;
@property (nonatomic, weak)IBOutlet UIView *mGifView3_2;
@property (nonatomic, weak)IBOutlet UIView *mGifView3_3;
@property (nonatomic, weak)IBOutlet UIView *mGifView4_1;
@property (nonatomic, weak)IBOutlet UIView *mGifView4_2;
@property (nonatomic, weak)IBOutlet UIView *mGifView4_3;

@property (nonatomic, weak)IBOutlet UILabel *mediaStartTitleLbl;
@property (nonatomic, weak)IBOutlet UILabel *mediaStartSingleTitleLbl;
@property (nonatomic, weak)IBOutlet UILabel *mgifFrameCountLbl1;
@property (nonatomic, weak)IBOutlet UILabel *mgifFrameCountLbl2;
@property (nonatomic, weak)IBOutlet UILabel *mgifFrameCountLbl3;
@property (nonatomic, weak)IBOutlet UILabel *mgifFrameCountLbl4;
@property (nonatomic, weak)IBOutlet UILabel *mTimerLbl;
@property (nonatomic, weak)IBOutlet UILabel *mExposureMaxLable;

@property (nonatomic, weak)IBOutlet UISlider *mZoomSlider;
@property (nonatomic, weak)IBOutlet UISlider *mExposureSlider;
@property (weak, nonatomic) IBOutlet UISlider *mSharpningSlider;
@property (weak, nonatomic) IBOutlet UISlider *mContrastSlider;

@property (nonatomic, weak)IBOutlet UITextField *mUserNameTextField;
@property (nonatomic, weak)IBOutlet UITextField *mPasswordTextField;

@property (nonatomic, weak)IBOutlet UIImageView *mCameraBtnBGV;
@property (nonatomic, weak)IBOutlet UIImageView *LoginBlurImageView;
@property (nonatomic, weak)IBOutlet UIImageView *mgifFrame1ImgV;
@property (nonatomic, weak)IBOutlet UIImageView *mgifFrame2ImgV;
@property (nonatomic, weak)IBOutlet UIImageView *mgifFrame3ImgV;
@property (nonatomic, weak)IBOutlet UIImageView *mgifFrame4ImgV;
@property (nonatomic, weak)IBOutlet UIImageView *vdoRecordImgV;
@property (nonatomic, weak)IBOutlet UIButton *mediaTypeImgBtn;
@property (nonatomic, weak)IBOutlet UIButton *mediaTypeGifBtn;
@property (nonatomic, weak)IBOutlet UIButton *mediaTypeVideoBtn;
@property (nonatomic, weak)IBOutlet UIButton *mediaStartBtn;
@property (nonatomic, weak)IBOutlet UIButton *mCount3Btn;
@property (nonatomic, weak)IBOutlet UIButton *mCount2Btn;
@property (nonatomic, weak)IBOutlet UIButton *mCount1Btn;
@property (nonatomic, weak)IBOutlet UIButton *mCountCameraBtn;

@property (nonatomic, weak)IBOutlet UIProgressView *mProgressV;
@property (nonatomic, weak)IBOutlet UISwitch *mRemeberSwitch;
@property (nonatomic, weak)IBOutlet UILabel *msingleStartLbl;
@property (nonatomic, weak)IBOutlet UIButton *mVideoTimerBtn;
@property (weak, nonatomic) IBOutlet UIButton *serverCountBtn;
@property (weak, nonatomic) IBOutlet UIButton *queueCountBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBnt;

@property (nonatomic, assign) int optionsCount;
@property (nonatomic, assign) int timerCount;
@property (nonatomic, assign) int cameraPosition;
@property (nonatomic,assign) int isAudioActive;
@property (nonatomic, assign) float videoRecordingTime;
@property (nonatomic, assign) float showTimerFrameVal;

@property (nonatomic, assign) NSString *frontCam;
@property (nonatomic, assign) NSString *cameraColor;

@property (nonatomic, retain)IBOutlet GPUImageView *cameraView;
@property (weak, nonatomic) IBOutlet UILabel *exposureDurationValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *ISOValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *exposureDurationSlider;
@property (weak, nonatomic) IBOutlet UISlider *ISOSlider;
@property (weak, nonatomic) IBOutlet UISlider *tempratureSlider;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLable;

-(IBAction)zoomSliderChanged:(id)sender; 
-(IBAction)exposureSliderChanged:(id)sender;
-(IBAction)cameraPositionActionMethods:(id)sender;
-(IBAction)logInButtonAction:(id)sender;
-(IBAction)cancelButtonAction:(id)sender;
-(IBAction)colorChangeActionMethods:(id)sender;
-(IBAction)topBarButtonActionMethods:(id)sender;
-(IBAction)mediaOptionsButtonAction:(id)sender;
- (IBAction)pushButtonAction:(id)sender;
- (IBAction)sharpeningSliderChanged:(id)sender;
- (IBAction)contrastSliderChanged:(id)sender;
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)GPUVCWillOutputFeatures:(NSArray*)featureArray forClap:(CGRect)clap
                 andOrientation:(UIDeviceOrientation)curDeviceOrientation;
@end

