//
//  ViewController.m
//  StudioBooth
//
//  Created by Bhupinder Verma on 06/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Additions.h"
#import "WebserviceHelper.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "CEMovieMaker.h"

#define kBtnTagGrayScale 1000
#define kBtnTagRGB       1001
#define kBtnTagStartEvent 134
#define kBtnTagLogOut 135

#define kBtnTagFront 2001
#define kBtnTagBack 2002
#define kBtnTagBW 2003
#define kBtnTagColor 2004

#define kBtnTagAuto 151
#define kBtnTagCloudy 152
#define kBtnTagDayLight 153
#define kBtnTagInCan 154
#define kBtnTagFlour 155

#define kMediaStartBtnTag 500
#define kMediaImgBtnTag 501
#define kMediaGifBtnTag 502
#define kMediaVdoBtnTag 503

#define kSingleMediaViewTag 111
#define kSingleMediaActiveBtnTag 112
#define kSingleMediaIconTag 113

#define kDoubleMediaViewTag 222
#define kDoubleMediaBtnTag1 223
#define kDoubleMediaIconTag1 224
#define kDoubleMediaBtnTag2 225
#define kDoubleMediaIconTag2 226
#define kDoubleMediaLblTag1 227
#define kDoubleMediaLblTag2 228

#define kAllMediaViewTag 333

#define kReadyTextStr @"READY FOR YOUR"

#define kBtnColor [UIColor colorWithRed:73/255.0f green:73/255.0f blue:73/255.0f alpha:0.9]
#define kBtnImage [UIImage imageNamed:@"Untitled-1.png"]
#define FBOX(x) [NSNumber numberWithFloat:x]
static void * ExposureDurationContext = &ExposureDurationContext;
static void * ISOContext = &ISOContext;
static const float kExposureDurationPower = 5; // Higher numbers will give the slider more sensitivity at shorter durations
static void *ExposureTargetOffsetContext = &ExposureTargetOffsetContext;
static void * DeviceWhiteBalanceGainsContext = &DeviceWhiteBalanceGainsContext;
@interface ViewController ()<GPUImageVideoCameraDelegate, MyCustomDelegate>{
    
    __weak IBOutlet UILabel *lableMedium;
    __weak IBOutlet UILabel *lableLow;
    __weak IBOutlet UILabel *lableHigh;
    __weak IBOutlet UILabel *lableEight;
    
    __weak IBOutlet UILabel *lableNegitiveEight;
    __weak IBOutlet UIView *leftSliderView;
    
    __weak IBOutlet UIView *midSliderView;
    
    __weak IBOutlet UIView *rightSliderView;
    CGRect frame;
    CGPoint startLocation;
    GPUImageExposureFilter *exposureFilter;
    __weak IBOutlet UISwitch *autoExposureSwitch;
    __weak IBOutlet UISwitch *autoWhiteBalanceSwitch;
    
    __weak IBOutlet UISwitch *autoISOSwitch;
   
    __weak IBOutlet UIView *autoWhiteBalanceBack;
    
    BOOL recorVdo;
    __weak IBOutlet UIView *autoExposureBack;
    
    __weak IBOutlet UISegmentedControl *segementView;
    
    NSString *currentUser;
    BOOL isPushButtonClicked;
    NSMutableArray * offlineData;
    UIView *touchView;
    int fail;
    WebserviceHelper *help;
    int sharpeningValue;
    int contrastValue;
    //    UIView *touchView;
    UIImage *imageCaptured;
    bool isChangeShutter;
    float newExposureTargetOffset;
    float temperature;
    NSArray *temperatureArray;
    NSMutableArray *isoArray;
    NSMutableArray *exposureDurationArray;
    NSString *gifType;
    NSTimer *photoTimer;
    NSMutableArray *gifImage;
    int count;
    __weak IBOutlet UIButton *gifButton;
}
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (nonatomic, strong) CEMovieMaker *movieMaker;
@end

@implementation ViewController
@synthesize cameraView,mLoginBGView,exposureDurationSlider;
@synthesize faceDetector,exposureDurationValueLabel,tempratureSlider;
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

-(void)showLoginScreen {
    
    self.mLoginPopupView.center = self.view.center;
    self.mLoginBGView.hidden = NO;
    self.mUserNameTextField.text = @"";
    self.mPasswordTextField.text = @"";
}

#pragma mark - Notification methods

- (void)showOnlySingleMediaOptionActive {
    self.mTopBarView.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.mTopBarView.frame.size.width,self.mTopBarView.frame.size.height);
    self.controlView.hidden = NO;
    self.mTimerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.mTimerView.frame.size.width, self.mTimerView.frame.size.height);
}

- (void)showMultiMediaOptionsActive {
    self.mTimerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.mTimerView.frame.size.width, self.mTimerView.frame.size.height);
    [self.view bringSubviewToFront:self.mTimerView];
    self.mBottomBarView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height-self.mBottomBarView.frame.size.height, self.mBottomBarView.frame.size.width,self.mBottomBarView.frame.size.height);
}

- (void)viewDidLoad {
    gifButton.layer.cornerRadius = gifButton.frame.size.height/2;
    [gifButton setImage:[UIImage imageNamed:@"gifbutton"] forState:UIControlStateNormal];
    [gifButton setImage:[UIImage imageNamed:@"gifbutton_selected"] forState:UIControlStateDisabled];
    isChangeShutter = NO;
    gifImage = [[NSMutableArray alloc]init];
    if ([GPUImageContext supportsFastTextureUpload])
    {
        NSDictionary *detectorOptions = [[NSDictionary alloc] initWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
        self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
        faceThinking = NO;
    }
    sharpeningValue = 0;
    contrastValue = 1;
    help = [[WebserviceHelper alloc] init];
    fail = 0;
    FLAnimatedImage *loadingImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"2" ofType:@"gif"]]];
    self.loaderImgView.animatedImage = loadingImage;
    [super viewDidLoad];
//    autoExposureSwitch.transform = CGAffineTransformMakeScale(0.60, 0.60);
    autoWhiteBalanceSwitch.transform = CGAffineTransformMakeScale(0.60, 0.60);
    autoExposureBack.transform = CGAffineTransformMakeScale(0.60, 0.60);
    autoWhiteBalanceBack.transform = CGAffineTransformMakeScale(0.60, 0.60);
    self.controlView.hidden = YES;
    delegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMultiMediaOptionsActive) name:@"MultiMediaActive" object:nil];
    
    [self setUpCamera:1];
    self.frontCam = @"yes";
    self.cameraColor = @"yes";
    self.mExposureMaxLable.text = [NSString stringWithFormat:@"0"];
    [self layoutControls];
    filterGroup = [[GPUImageFilterGroup alloc] init];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.mUserNameTextField.leftView = paddingView;
    self.mUserNameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.mUserNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    UIView *paddingPwd = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.mPasswordTextField.leftView = paddingPwd;
    self.mPasswordTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [self.mExposureSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
    [self.mExposureSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateSelected];
    [self.mExposureSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateHighlighted];
    [self.mExposureSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateDisabled];
    [self.mExposureSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    [self.mExposureSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateDisabled];
    [self.mExposureSlider setMaximumTrackImage:[UIImage imageNamed:@"Slider_Black_2.png"] forState:UIControlStateNormal];
    
    // set value for sharpening slider
    [self.mSharpningSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
    [self.mSharpningSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateSelected];
    [self.mSharpningSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateHighlighted];
    [self.mSharpningSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateDisabled];
    [self.mSharpningSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    [self.mSharpningSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateDisabled];
    [self.mSharpningSlider setMaximumTrackImage:[UIImage imageNamed:@"Slider_Black_2.png"] forState:UIControlStateNormal];
    // These number values represent each slider position
    NSArray *numberss = @[@(0), @(2), @(4)];
    // slider values go from 0 to the number of values in your numbers array
    NSInteger numberOfSteps = ((float)[numberss count] - 1);
    self.mSharpningSlider.maximumValue = numberOfSteps;
    self.mSharpningSlider.minimumValue = 0;
    
    // As the slider moves it will continously call the -valueChanged:
    self.mSharpningSlider.continuous = NO; // NO makes it call only once you let go
    
    
    // set value for contrast slider
    [self.mContrastSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
    [self.mContrastSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateSelected];
    [self.mContrastSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateHighlighted];
    [self.mContrastSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateDisabled];
    [self.mContrastSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    [self.mContrastSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateDisabled];
    [self.mContrastSlider setMaximumTrackImage:[UIImage imageNamed:@"Slider_Black_2.png"] forState:UIControlStateNormal];
    self.mContrastSlider.maximumValue = numberOfSteps;
    self.mContrastSlider.minimumValue = 0;
    
    // As the slider moves it will continously call the -valueChanged:
    self.mContrastSlider.continuous = NO; // NO makes it call only once you let go
    //set value for iso slider
    [self.ISOSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
    [self.ISOSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateSelected];
    [self.ISOSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateHighlighted];
    [self.ISOSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateDisabled];
    [self.ISOSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    [self.ISOSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateDisabled];
    [self.ISOSlider setMaximumTrackImage:[UIImage imageNamed:@"Slider_Black_2.png"] forState:UIControlStateNormal];
    
    //set the value for shutter speed slider
    [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
    [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateSelected];
    [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateHighlighted];
    [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateDisabled];
    [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateDisabled];
    [self.exposureDurationSlider setMaximumTrackImage:[UIImage imageNamed:@"Slider_Black_2.png"] forState:UIControlStateNormal];
    
    //set the value for whiteBalance/temperature slider
    [self.tempratureSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
    [self.tempratureSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateSelected];
    [self.tempratureSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateHighlighted];
    [self.tempratureSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateDisabled];
    [self.tempratureSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    [self.tempratureSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateDisabled];
    [self.tempratureSlider setMaximumTrackImage:[UIImage imageNamed:@"Slider_Black_2.png"] forState:UIControlStateNormal];
    [self configureSlider];
}
- (void)viewWillAppear:(BOOL)animated {
    
//        self.mUserNameTextField.text = @"1";
//        self.mPasswordTextField.text = @"1";
    [super viewWillAppear:YES];
    [self hideGifFrameView:NO];
    [Helper deleteDocumentDirectoryFile:kGIFfileName];  // Delete GIF
    [Helper deleteDocumentDirectoryFile:kVideofileName];  // Delete Video
    self.mVideoRecordingView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.mVideoRecordingView.frame.size.width, self.mVideoRecordingView.frame.size.height);
    
    [videoCamera.inputCamera lockForConfiguration:nil];
    videoCamera.captureSessionPreset = AVCaptureSessionPresetPhoto;
    [videoCamera.inputCamera unlockForConfiguration];
    if(segementView.selectedSegmentIndex == 0){
        [videoCamera.inputCamera lockForConfiguration:nil];
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [videoCamera.inputCamera unlockForConfiguration];
    }
    
    [self setupActiveMediaButtons];
    
    //    [self fetchSavedCameraSettings];
}

#pragma mark- Orientation Methods

- (void)orientationChanged:(NSNotification *)notification {
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    
    if (deviceOrientation == UIDeviceOrientationPortrait){
        videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    }
    else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
        videoCamera.outputImageOrientation = UIDeviceOrientationPortrait;
    }
}

#pragma mark- Void methods

-(void)layoutControls {
    
    self.mTopBarView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-self.mTopBarView.frame.size.height, self.mTopBarView.frame.size.width, self.mTopBarView.frame.size.height);
    self.mBottomBarView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.mBottomBarView.frame.size.width, self.mBottomBarView.frame.size.height);
    
    for (UIView *vw in self.mControlColorChangeView.subviews) {
        if ([vw isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)vw;
            [btn setBackgroundColor:[UIColor clearColor]];
            NSString *string = btn.currentTitle;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            
            float spacing = 2.0f;
            [attributedString addAttribute:NSKernAttributeName
                                     value:@(spacing)
                                     range:NSMakeRange(0, [string length])];
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:168/255.0f green:168/255.0f blue:168/255.0f alpha:1.0] range:NSMakeRange(0, [string length])];
            
            [btn setAttributedTitle:attributedString forState:UIControlStateNormal];
            
        }
    }
    
    for (UIView *vw in self.mControlBottomView.subviews) {
        if ([vw isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)vw;
            [btn setBackgroundColor:[UIColor clearColor]];
            NSString *string = btn.currentTitle;
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            
            float spacing = 3.0f;
            [attributedString addAttribute:NSKernAttributeName
                                     value:@(spacing)
                                     range:NSMakeRange(0, [string length])];
            
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:168/255.0f green:168/255.0f blue:168/255.0f alpha:1.0] range:NSMakeRange(0, [string length])];
            
            [btn setAttributedTitle:attributedString forState:UIControlStateNormal];
            
        }
    }
    
    UIButton *btn1 = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagFront];
    [btn1 setBackgroundColor:kBtnColor];
    
    UIButton *btn2 = (UIButton *) [self.mControlBottomView viewWithTag:kBtnTagColor];
    [btn2 setBackgroundColor:kBtnColor];
    
    UIButton *btn3 = (UIButton *)[self.mControlColorChangeView viewWithTag:kBtnTagAuto];
    [btn3 setBackgroundColor:kBtnColor];
    
    self.mLoginPopupView.center = self.view.center;
    self.mLoginBGView.center = self.view.center;
    self.mLoginPopupView.layer.cornerRadius = 15;
    self.mLoginBGView.hidden = NO;
    self.mRemeberSwitch.on = NO;
}

-(void)setUpCamera:(NSInteger)camPosition {
    [self.view addSubview:delegateObj.hud];
    [delegateObj.hud show:YES];
    delegateObj.hud.hidden = NO;
//    videoCamera = nil;
    if (camPosition == 2) {
        [self removeObserver:self forKeyPath:@"videoCamera.inputCamera.exposureDuration" context:ExposureDurationContext];
        [self removeObserver:self forKeyPath:@"videoCamera.inputCamera.ISO" context:ISOContext];
        [self removeObserver:self forKeyPath:@"videoCamera.inputCamera.exposureTargetOffset" context:ExposureTargetOffsetContext];
        [self removeObserver:self forKeyPath:@"videoCamera.inputCamera.deviceWhiteBalanceGains" context:DeviceWhiteBalanceGainsContext];

        videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        self.cameraPosition = 2;
        [self setAutoMode];
//         [videoCamera setDelegate:self];
    }
    else {
        if (isChangeShutter) {
            [self removeObserver:self forKeyPath:@"videoCamera.inputCamera.exposureDuration" context:ExposureDurationContext];
            [self removeObserver:self forKeyPath:@"videoCamera.inputCamera.ISO" context:ISOContext];
            [self removeObserver:self forKeyPath:@"videoCamera.inputCamera.exposureTargetOffset" context:ExposureTargetOffsetContext];
            [self removeObserver:self forKeyPath:@"videoCamera.inputCamera.deviceWhiteBalanceGains" context:DeviceWhiteBalanceGainsContext];
        }
        videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
        self.cameraPosition = 1;
        [self setAutoMode];
//         [videoCamera setDelegate:self];
    }
    
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    GPUImageView *filterView = (GPUImageView *)self.cameraView;
    filterView.fillMode = kGPUImageFillModePreserveAspectRatio;
    
    [self setUpFilter:filterView];
    [delegateObj.hud removeFromSuperview];
    [videoCamera startCameraCapture];
    [self addObserver:self forKeyPath:@"videoCamera.inputCamera.exposureDuration" options:NSKeyValueObservingOptionNew context:ExposureDurationContext];
    [self addObserver:self forKeyPath:@"videoCamera.inputCamera.ISO" options:NSKeyValueObservingOptionNew context:ISOContext];
    [self addObserver:self forKeyPath:@"videoCamera.inputCamera.exposureTargetOffset" options:NSKeyValueObservingOptionNew context:ExposureTargetOffsetContext];
    [self addObserver:self forKeyPath:@"videoCamera.inputCamera.deviceWhiteBalanceGains" options:NSKeyValueObservingOptionNew context:DeviceWhiteBalanceGainsContext];
//    [self setShutterSpeed:60];
    [self configureSlider];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches]anyObject];
    if([touch view] == self.controlView)
    {
        CGPoint pt = [[touches anyObject] locationInView:self.controlView];
        startLocation = pt;
    }
}

//Use same thing with touch move methods...
- (void) touchesMoved:(NSSet *)touches withEvent: (UIEvent *)event {
    
    UITouch *touch = [[event allTouches]anyObject];
    if([touch view] == self.controlView) {
        CGPoint pt = [[touches anyObject] previousLocationInView:self.controlView];
        CGFloat dx = pt.x - startLocation.x;
        CGFloat dy = pt.y - startLocation.y;
        CGPoint newCenter = CGPointMake(self.controlView.center.x + dx,self.controlView.center.y + dy);
        self.controlView.center = newCenter;
    }
}

- (AVCaptureWhiteBalanceGains)normalizedGains:(AVCaptureWhiteBalanceGains) gains {
    
    //    Incandescent WB: 245, 247, 242
    //   Auto WB: 248, 246, 232
    //  Cloudy WB: 250, 244, 208
    
    AVCaptureWhiteBalanceGains g = gains;
    
    g.redGain = MAX(1.0, g.redGain);
    g.greenGain = MAX(1.0, g.greenGain);
    g.blueGain = MAX(1.0, g.blueGain);
    
    g.redGain = MIN(videoCamera.inputCamera.maxWhiteBalanceGain, g.redGain);
    g.greenGain = MIN(videoCamera.inputCamera.maxWhiteBalanceGain, g.greenGain);
    g.blueGain = MIN(videoCamera.inputCamera.maxWhiteBalanceGain, g.blueGain);
    
    return g;
}

- (void)setWhiteBalanceGains:(AVCaptureWhiteBalanceGains)gains {
    
    NSError *error = nil;
    
    if ([videoCamera.inputCamera lockForConfiguration:&error])
    {
        AVCaptureWhiteBalanceGains normalizedGains = [self normalizedGains:gains]; // Conversion can yield out-of-bound values, cap to limits
        
        // [VideoDevice setWhiteBalanceMode:avcapturew];
        [videoCamera.inputCamera setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains:normalizedGains completionHandler:nil];
        [videoCamera.inputCamera unlockForConfiguration];
    }
    else {
        NSLog(@"%@", error);
    }
}

-(void)setUpFilter:(GPUImageView *)filterView {
    
    _filter = nil;
    _filter = [[GPUImageWhiteBalanceFilter alloc] init];
    [(GPUImageWhiteBalanceFilter *)_filter setTemperature:5000];
    [_filter addTarget:filterView];
    
    //============== EXPOSURE FILTER ==============================
    
    [self.mExposureSlider setMinimumValue:videoCamera.inputCamera.minExposureTargetBias];
    [self.mExposureSlider setMaximumValue:videoCamera.inputCamera.maxExposureTargetBias];
    [self.mExposureSlider setValue:videoCamera.inputCamera.exposureTargetBias];
    
    self.mZoomSlider.hidden = YES;
    [self.mZoomSlider setMinimumValue:1];
    [self.mZoomSlider setMaximumValue:5];
    [self.mZoomSlider setValue:5/2.];
    
    exposureFilter = nil;
    exposureFilter = [[GPUImageExposureFilter alloc] init];
    [exposureFilter addTarget:filterView];
    
    //================ GRAYSCALE FILTER =========================
    _grayScaleFilter = nil;
    _grayScaleFilter = [[GPUImageGrayscaleFilter alloc] init];
    [_grayScaleFilter addTarget:filterView];
    
    // [videoCamera addTarget:exposureFilter];
    [videoCamera addTarget:_filter];
    
    
    //    //============= sharpFilter ===========
    //    _sharpenFilter = nil;
    //    _sharpenFilter = [[GPUImageSharpenFilter alloc] init];
    //    [(GPUImageSharpenFilter *)_sharpenFilter setSharpness:3];
    //    [_sharpenFilter addTarget:filterView];
    //    [videoCamera addTarget:_filter];
    
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

-(void)showHideTopBarButtonView:(BOOL)isShowing{
    
    [UIView animateWithDuration:0.5 animations:^{
        if (isShowing == YES) {
            self.mTopBarView.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y,self.mTopBarView.frame.size.width,self.mTopBarView.frame.size.height);
            self.controlView.hidden = NO;
        }
        else{
            self.mTopBarView.frame = CGRectMake(self.view.frame.origin.x,self.view.frame.origin.y-self.mTopBarView.frame.size.height,self.mTopBarView.frame.size.width,self.mTopBarView.frame.size.height);
            self.controlView.hidden = YES;
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES; // Support all orientations.
}

-(void)fetchLoginInfo {
    
    NSMutableDictionary *dct = [[NSMutableDictionary alloc] init];
    [dct setValue:kAppAuthValue forKey:kAppAuthKey];
    [dct setValue:self.mUserNameTextField.text forKey:kAppUsernameKey];
    [dct setValue:self.mPasswordTextField.text forKey:kAppPasswordKey];
    
    //    help = [[WebserviceHelper alloc] init];
    help.mydelegate = self;
    [help sendServerRequest:dct andAPI:kLoginAPI];
}
-(void) checkEventOnline {
    NSMutableDictionary *dct = [[NSMutableDictionary alloc] init];
    [dct setValue:kAppAuthValue forKey:kAppAuthKey];
    [dct setValue:[[offlineData objectAtIndex:0] valueForKey:kAppUsernameKey] forKey:kAppUsernameKey];
    [dct setValue:[[offlineData objectAtIndex:0] valueForKey:kAppPasswordKey] forKey:kAppPasswordKey];
    //    WebserviceHelper *help = [[WebserviceHelper alloc] init];
    help.mydelegate = self;
    [help sendServerRequest:dct andAPI:kLoginAPI];
}

- (void) callMyCustomDelegateMethod: (NSDictionary *) mdict {
    
    NSLog(@"%@", mdict);
    if ([[mdict valueForKey:@"msg"] isEqualToString:@"Email Sent Successfully"]) {
        if (offlineData.count>0) {
            [offlineData removeObjectAtIndex:0];
            NSString *value = [@(offlineData.count) stringValue];
            [self.queueCountBtn setTitle: [NSString stringWithFormat:@"Q U E U E D :  %@",[self addSpace:value]]forState:UIControlStateNormal];
            [self.serverCountBtn setTitle:[NSString stringWithFormat:@"S E R V E R :  %@",[self addSpace:[mdict valueForKey:@"total_media"]]]forState:UIControlStateNormal];
            [USER_DEFAULTS setObject:[mdict valueForKey:@"total_media"] forKey:@"total_media"];
            [self uploadData];
        }
    }
    else if ([[mdict valueForKey:@"msg"] isEqualToString:@"SMS Sent Successfully"]) {
        if (offlineData.count>0) {
            [offlineData removeObjectAtIndex:0];
            NSString *value = [@(offlineData.count) stringValue];
            [self.queueCountBtn setTitle: [NSString stringWithFormat:@"Q U E U E D :  %@",[self addSpace:value]]forState:UIControlStateNormal];
            [self.serverCountBtn setTitle:[NSString stringWithFormat:@"S E R V E R :  %@",[self addSpace:[mdict valueForKey:@"total_media"]]]forState:UIControlStateNormal];
            [USER_DEFAULTS setObject:[mdict valueForKey:@"total_media"] forKey:@"total_media"];
            [self uploadData];
        }
    }
    else if (offlineData.count != 0 && [[[mdict valueForKey:@"status"] lowercaseString] isEqualToString:@"success"]&&isPushButtonClicked)
    {
        if([[mdict valueForKey:@"internet_connection"]  isEqualToString:@"Offline"])
        {
            UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Offline Event" message:@"Currently event is in offline mode. Please make it online to start sync media." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alrt show];
            alrt = nil;
            [self.loaderImgView setHidden:YES];
            [self.sendBnt setEnabled:YES];
            isPushButtonClicked = NO;
        }
        else
        {
            [self uploadData];
        }
    }
    else if ([[[mdict valueForKey:@"status"] lowercaseString] isEqualToString:@"success"]){
        isPushButtonClicked = NO;
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.mUserNameTextField.text forKey:kAppUsernameKey];
        [defaults setObject:self.mPasswordTextField.text forKey:kAppPasswordKey];
        [defaults setObject:[mdict valueForKey:@"frame_rate"] forKey:@"frame_rate"];
        self.mLoginBGView.hidden = YES;
        [self showHideTopBarButtonView:YES];
        [USER_DEFAULTS setObject:mdict forKey:@"user_information"];
        [USER_DEFAULTS synchronize];
        NSString *URLstr = [Helper getUserInfoValueForKey:@"overlay"];
        if ([[URLstr lowercaseString]hasSuffix:@".png"])
        {
            [USER_DEFAULTS setObject:@"png" forKey:@"overlay_image_type"];
            [USER_DEFAULTS synchronize];
        }
        else{
            [USER_DEFAULTS setObject:@"gif" forKey:@"overlay_image_type"];
            [USER_DEFAULTS synchronize];
        }
        NSURL *url = [NSURL URLWithString:URLstr];
        NSData *data = [[NSData alloc]initWithContentsOfURL:url ];
        [USER_DEFAULTS setObject:data forKey:@"overlay_image_data"];
        [USER_DEFAULTS synchronize];
        
        
        NSString *logoOverlayUrlString = [Helper getUserInfoValueForKey:kLogoOverlay];
        NSURL *logoOverlayUrl = [NSURL URLWithString:logoOverlayUrlString];
        NSData *logoOverlayData = [[NSData alloc] initWithContentsOfURL:logoOverlayUrl];
        
        // save the logo png to document directory
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"sb%@", @"logoOverlay.png"]];
        NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
        BOOL isdone = [logoOverlayData writeToURL:outputFileUrl atomically:true];
        if(isdone)
        {
            NSLog(@"save png");
        }
        
        NSString *audioURLStr = [Helper getUserInfoValueForKey:@"music"];
        NSString *music_enabled = [Helper getUserInfoValueForKey:@"music_enabled"];
        if([music_enabled isEqualToString:@"1"] && ![audioURLStr isEqualToString:@""])
        {
            NSURL *audioURL = [NSURL URLWithString:audioURLStr];
            NSData *audioData = [[NSData alloc]initWithContentsOfURL:audioURL];
            NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *docsDir = [dirPaths objectAtIndex:0];
            NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"sb%@", @"audio.mp3"]];
            NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
            BOOL isdone = [audioData writeToURL:outputFileUrl atomically:true];
            if(isdone)
            {
                NSLog(@"save audio");
            }
        }
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [delegateObj.hud removeFromSuperview];
        [USER_DEFAULTS setObject:[mdict valueForKey:@"total_media"] forKey:@"total_media"];
        [self.serverCountBtn setTitle:[NSString stringWithFormat:@"S E R V E R :  %@",[self addSpace:[mdict valueForKey:@"total_media"]]]forState:UIControlStateNormal];
        [self getQueueCount];
        if (offlineData.count !=0) {
            self.sendBnt.enabled = YES;
        }
        else{
            self.sendBnt.enabled = NO;
            [self.sendBnt setTitle:@"S E N D  Q U E U E D  I M A G E S" forState:UIControlStateDisabled];
        }
        
        //      self.mTimerView.hidden = YES;
        gifType = [mdict valueForKey:@"gif_type"];
    }
    else if([[[mdict valueForKey:@"status"] lowercaseString] isEqualToString:@"error"]){
        if (isPushButtonClicked) {
            [Helper showAlert:nil andMessage:[mdict valueForKey:@"msg"]];
            if (offlineData.count>0) {
                [offlineData removeObjectAtIndex:0];
                [self uploadData];
            }
        }
        else{
            [Helper showAlert:nil andMessage:@"Error, please check the username/password and try again"];
            [delegateObj.hud removeFromSuperview];
        }
    }
    else if (mdict==nil)
    {
        [self fetchLoginInfo];
        [delegateObj.hud removeFromSuperview];
    }
    
}

- (void) callMyCustomDelegateError:(NSString *)errorStr {
    //      NSLog(@"%@", [USER_DEFAULTS objectForKey:kAppUsernameKey]);
    if (isPushButtonClicked) {
        [self.sendBnt setEnabled:YES];
        [Helper showAlert:nil andMessage:@"Please connect to the internet and try again."];
        [self.loaderImgView setHidden:YES];
    }
    else{
        if ([USER_DEFAULTS objectForKey:kAppUsernameKey] != nil && [[USER_DEFAULTS objectForKey:kAppUsernameKey] isEqualToString:self.mUserNameTextField.text] && [[USER_DEFAULTS objectForKey:kAppPasswordKey] isEqualToString: self.mPasswordTextField.text]) {
            self.mLoginBGView.hidden = YES;
            [self showHideTopBarButtonView:YES];
            [self.serverCountBtn setTitle:[NSString stringWithFormat:@"S E R V E R :  %@",[self addSpace:[USER_DEFAULTS valueForKey:@"total_media"]]]forState:UIControlStateNormal];
            [self getQueueCount];
            if (offlineData.count !=0) {
                self.sendBnt.enabled = YES;
            }
            else{
                self.sendBnt.enabled = NO;
                [self.sendBnt setTitle:@"S E N D  Q U E U E D  I M A G E S" forState:UIControlStateDisabled];
            }
        }
        else{
            NSLog(@"%@", errorStr);
            [Helper showAlert:nil andMessage:@"Error,Login fail and try again later"];
        }
    }
    isPushButtonClicked = NO;
    [delegateObj.hud removeFromSuperview];
}

#pragma mark- Video Media Methods

- (void)startVideoRecording{
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    videoCamera.horizontallyMirrorRearFacingCamera = NO;
    
    GPUImageView *filterView = (GPUImageView *)self.cameraView;
    
    NSString *pathToMovie = [Helper getDirectoryFilePath:kVideofileName];
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    movieWriter.encodingLiveVideo = YES;
    movieWriter.shouldPassthroughAudio = YES;
    if ([[videoCamera.targets objectAtIndex:0] isKindOfClass:[GPUImageGrayscaleFilter class]]) {
        [_grayScaleFilter addTarget:movieWriter];
    } else {
        [_filter addTarget:movieWriter];
    }
    
    [_filter addTarget:filterView];
    
    //    [videoCamera startCameraCapture];
    double delayInSeconds = 0.4f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self showVideoProgressView:YES];
        //        NSLog(@"Do some work");
        [delegateObj.hud removeFromSuperview];
    });
    //    [self showVideoProgressView:YES];
    
    double delayToStartRecording = 0;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, delayToStartRecording * NSEC_PER_SEC);
    dispatch_after(startTime, dispatch_get_main_queue(), ^(void){
        //        NSLog(@"Start recording");
        if (self.isAudioActive == 1) {
            videoCamera.audioEncodingTarget = movieWriter;
        } else {
            videoCamera.audioEncodingTarget = nil;
        }
        if ([[self.frontCam lowercaseString] isEqualToString:@"yes"]) {
            
            //            CGAffineTransform transform = CGAffineTransformMakeScale(-1.0, 1.0);
            //            [movieWriter startRecordingInOrientation:transform];
            [movieWriter startRecording];
        } else {
            [movieWriter startRecording];
        }
        
        [self startVideoProgressTimer];
        
        double delayInSeconds = [[Helper getUserInfoValueForKey:kAppMaxVdoRecordTime] doubleValue];//20.0;
        if (!delayInSeconds || delayInSeconds == 0){
            delayInSeconds = 10;
        }
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
            
            [_filter removeTarget:movieWriter];
            videoCamera.audioEncodingTarget = nil;
            [movieWriter finishRecording];
            //            NSLog(@"Movie completed");
            [self showVideoProgressView:NO];
            
            ImageClickedVC *vcObj = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageClickedVC"];
            vcObj.activeMediaCount = self.optionsCount;
            vcObj.mediaType = self.choosenMediaType;
            [UIView animateWithDuration:0.75
                             animations:^{
                                 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                                 [self.navigationController pushViewController:vcObj animated:NO];
                             }];
        });
    });
}

- (void)stopVideoRecording {
    
    [videoCamera stopCameraCapture];
    [_filter removeTarget:movieWriter];
    videoCamera.audioEncodingTarget = nil;
    [movieWriter finishRecording];
    ImageClickedVC *vcObj = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageClickedVC"];
    vcObj.activeMediaCount = self.optionsCount;
    vcObj.mediaType = self.choosenMediaType;
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:vcObj animated:NO];
                     }];
}

- (void)showVideoProgressView:(BOOL) mshow {
    
    [UIView animateWithDuration:0.5 animations:^{
        
        if (mshow == YES) {
            self.mVideoRecordingView.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.size.height-self.mVideoRecordingView.frame.size.height), self.mVideoRecordingView.frame.size.width, self.mVideoRecordingView.frame.size.height);
        }
        else{
            self.mVideoRecordingView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.mVideoRecordingView.frame.size.width, self.mVideoRecordingView.frame.size.height);
        }
    }];
}

- (void)startVideoProgressTimer {
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    self.mProgressV.transform = transform;
    self.mProgressV.progress = 0;
    self.videoRecordingTime = 0;
    recorVdo = YES;
    self.vdoRecordImgV.image = [UIImage imageNamed:@"video_recorder.png"];
    gifTimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector (changeVideoRecordingBtnImage) userInfo:nil repeats:YES];
    self.mTimerLbl.text = [Helper timeFormatted:(int)self.videoRecordingTime];
    videoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector (setupVideoProgressAndTime) userInfo:nil repeats:YES];
}

- (void)setupVideoProgressAndTime {
    
    self.videoRecordingTime = self.videoRecordingTime+.1;
    self.mTimerLbl.text = [Helper timeFormatted:(int)self.videoRecordingTime];
    int recordtime = [[Helper getUserInfoValueForKey:kAppMaxVdoRecordTime] intValue];
    if (!recordtime || recordtime == 0){
        recordtime = 10;
    }
    float mprogressValue = (float)self.videoRecordingTime/recordtime;
    self.mProgressV.progress = mprogressValue;
    if ((int)self.videoRecordingTime == recordtime){
        [videoTimer invalidate];
        [gifTimer invalidate];
    }
}

- (void)changeVideoRecordingBtnImage {
    
    if (recorVdo){
        [self.mVideoTimerBtn setImage:[UIImage imageNamed:@"Rec"] forState:UIControlStateNormal];
        recorVdo = NO;
    }
    else{
        [self.mVideoTimerBtn setImage:[UIImage imageNamed:@"recording-button"] forState:UIControlStateNormal];
        recorVdo = YES;
    }
}

#pragma mark- GIF frame methods

- (void)hideGifFrameView:(BOOL) mshow {
    
    self.mGifStrip4View.hidden = YES;
    self.mGifStrip3View.hidden = YES;
    self.mGifStrip2View.hidden = YES;
    self.mGifStrip1View.hidden = YES;
    self.gifFramesView.hidden = YES;
    self.mGifView1_1.hidden = YES;
    self.mGifView1_2.hidden = YES;
    self.mGifView1_3.hidden = YES;
    self.mGifView2_1.hidden = YES;
    self.mGifView2_2.hidden = YES;
    self.mGifView2_3.hidden = YES;
    self.mGifView3_1.hidden = YES;
    self.mGifView3_2.hidden = YES;
    self.mGifView3_3.hidden = YES;
    self.mGifView4_1.hidden = YES;
    self.mGifView4_2.hidden = YES;
    self.gifFramesView.frame = CGRectMake(self.view.frame.size.width, self.gifFramesView.frame.origin.y, self.gifFramesView.frame.size.width, self.gifFramesView.frame.size.height);
}

- (void)showGifFrameView:(BOOL) mshow {
    
    self.mgifFrame1ImgV.image = [UIImage imageNamed:@""];
    self.mgifFrame2ImgV.image = [UIImage imageNamed:@""];
    self.mgifFrame3ImgV.image = [UIImage imageNamed:@""];
    self.mgifFrame4ImgV.image = [UIImage imageNamed:@""];
    self.mgifFrame1ImgV.backgroundColor = self.mgifFrame2ImgV.backgroundColor = self.mgifFrame3ImgV.backgroundColor = self.mgifFrame4ImgV.backgroundColor = [UIColor clearColor];
    self.mgifFrameCountLbl1.textColor = self.mgifFrameCountLbl2.textColor = self.mgifFrameCountLbl3.textColor = self.mgifFrameCountLbl4.textColor = [UIColor clearColor];
    self.gifFramesView.hidden = NO;
    self.gifFramesView.frame = CGRectMake((self.view.frame.size.width-self.gifFramesView.frame.size.width), self.gifFramesView.frame.origin.y, self.gifFramesView.frame.size.width, self.gifFramesView.frame.size.height);
}


#pragma mark-  Count Timer Methods

- (void) startCountTimerForClickImage:(NSString *) titleStr {
    
    NSDictionary *muserDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@", titleStr],@"ButtonTitle", nil];
    myTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector (startClickImagesTimer:) userInfo:muserDict repeats:YES];
}

- (void)startClickImagesTimer:(NSTimer *)timer {
    
    NSDictionary *mSenderDict = [timer userInfo];
    NSString *senderBtnTitle = [mSenderDict objectForKey:@"ButtonTitle"];
    self.timerCount = self.timerCount+1;
    if (self.timerCount == 1) {
        self.mCount1Btn.titleLabel.textColor = kAppTextColor;
        self.mCount2Btn.titleLabel.textColor = [UIColor whiteColor];
        self.mCount3Btn.titleLabel.textColor = [UIColor clearColor];
    }
    else if (self.timerCount == 2) {
        self.mCount3Btn.titleLabel.textColor = [UIColor clearColor];
        self.mCount2Btn.titleLabel.textColor = [UIColor clearColor];
        self.mCount1Btn.titleLabel.textColor = [UIColor whiteColor];
    }
    else if (self.timerCount == 3){
        [myTimer invalidate];
        self.mCount1Btn.titleLabel.textColor = [UIColor clearColor];
        self.mCountCameraBtn.titleLabel.textColor = [UIColor whiteColor];
        if ([[senderBtnTitle lowercaseString] isEqualToString:@"video"]) {
            [self performSelector:@selector(startVideoRecording) withObject:nil afterDelay:0.1f];
            double delayInSeconds = 0.1f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self showHideCountTimerView:YES];
                
            });
            [self showHideCountTimerView:YES];
        }
        else if ([[senderBtnTitle lowercaseString] isEqualToString:@"gif"]){
            if ([gifType isEqualToString:@"Boomerang"])
            {
                gifButton.enabled = NO;
                self.mBottomBarView.hidden = YES;
                NSLog(@"button clicked");
                if (_cameraPosition == 2) {
                    NSError *error;
                    
                    if ([videoCamera.inputCamera lockForConfiguration:&error]) {
                        [videoCamera.inputCamera setFocusMode:AVCaptureFocusModeLocked];
                        [videoCamera.inputCamera unlockForConfiguration];
                    }
                }
                [self gifMaker];
                [self performSelector:@selector(makeVideo) withObject:nil afterDelay:2.2];
                NSLog(@"button end");
   
            }
            else{
                    [self performSelector:@selector(popupImage) withObject:nil afterDelay:0.0f];
                    if (!self.frameImgsArray){
                        self.frameImgsArray = [[NSMutableArray alloc] init];
                    }
                    [self.frameImgsArray removeAllObjects];
                    self.videoRecordingTime = 0;
                    [NSTimer scheduledTimerWithTimeInterval:0.4f target:self selector:@selector (timerForGifImageClick) userInfo:nil repeats:NO];
                // make white balance same for every gif image.
                    [videoCamera.inputCamera lockForConfiguration:nil];
                    [videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
                    [videoCamera.inputCamera unlockForConfiguration];

            }
          
        }
        else {
            if ([[senderBtnTitle lowercaseString] isEqualToString:@"photo"]){
                [self performSelector:@selector(popupImage) withObject:nil afterDelay:0.0f];
                if ([videoCamera.targets count]){
                    if ([[videoCamera.targets objectAtIndex:0] isKindOfClass:[GPUImageGrayscaleFilter class]]) {
                        [_grayScaleFilter useNextFrameForImageCapture];
                    }
                    else {
                        [_filter useNextFrameForImageCapture];
                    }
                }
                [self performSelector:@selector(clickImageItself) withObject:nil afterDelay:0.4f];
            }
        }
    }
}

- (void)timerForGifImageClick {
    
    self.videoRecordingTime = self.videoRecordingTime+1;
    if ([videoCamera.targets count]){
        if ([[videoCamera.targets objectAtIndex:0] isKindOfClass:[GPUImageGrayscaleFilter class]]) {
            [_grayScaleFilter useNextFrameForImageCapture];
        }
        else {
            [_filter useNextFrameForImageCapture];
        }
    }
    if (![gifTimer isValid]) {
        gifTimer = [NSTimer scheduledTimerWithTimeInterval:1.8 target:self selector:@selector (timerForGifImageClick) userInfo:nil repeats:YES];
    }
    
    [self performSelector:@selector(setFrameImages:) withObject:[NSString stringWithFormat:@"%d", (int)self.videoRecordingTime] afterDelay:0.1f];
}
- (UIImage*)imageWithImage:(UIImage*)image
              scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (void)setFrameImages:(NSString *) str {
    
    int timeCount = [str intValue];
    UIImage *mFrameImg = [self getCurrentClickedImage];
    UIImage *captureImage = mFrameImg;
    if (captureImage){
        UIImage *image480x640 =  [self imageWithImage:captureImage scaledToSize:CGSizeMake(480.0,640.0)];
        [self.frameImgsArray addObject:image480x640];
    }
    CameraSettings *settingsobj = [CameraSettings fetchMatchingUser];
    if (timeCount == 1){
        self.mgifFrame1ImgV.image = [self.frameImgsArray objectAtIndex:0];
        self.mgifFrame1ImgV.backgroundColor = [UIColor blackColor];
        self.mgifFrameCountLbl1.textColor = [UIColor whiteColor];
        if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
            self.mgifFrame1ImgV.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        
        self.showTimerFrameVal = 0;
        if (![countdowntimer isValid]){
            [self setCounterButtonColor];
            //                    [self performSelector:@selector(setCounterButtonColor) withObject:nil afterDelay:0.1];
            countdowntimer = [NSTimer scheduledTimerWithTimeInterval:0.6 target:self selector:@selector (showOnlyClickImageTimer) userInfo:nil repeats:YES];
        }
        self.mGifStrip1View.hidden = NO;
        self.mGifView1_1.hidden = NO;
        self.mGifView1_2.hidden = NO;
        self.mGifView1_3.hidden = NO;
    }
    else if (timeCount == 2){
        [self popupImage];
        self.mgifFrame2ImgV.image = [self.frameImgsArray objectAtIndex:1];
        self.mgifFrame2ImgV.backgroundColor = [UIColor blackColor];
        self.mgifFrameCountLbl2.textColor = [UIColor whiteColor];
        if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
            self.mgifFrame2ImgV.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        self.mGifStrip2View.hidden = NO;
        self.mGifView2_1.hidden = NO;
        self.mGifView2_2.hidden = NO;
        self.mGifView2_3.hidden = NO;
    }
    else if ( timeCount == 3){
        [self popupImage];
        self.mgifFrame3ImgV.image = [self.frameImgsArray objectAtIndex:2];
        self.mgifFrame3ImgV.backgroundColor = [UIColor blackColor];
        self.mgifFrameCountLbl3.textColor = [UIColor whiteColor];
        if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
            self.mgifFrame3ImgV.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        self.mGifStrip3View.hidden = NO;
        self.mGifView3_1.hidden = NO;
        self.mGifView3_2.hidden = NO;
        self.mGifView3_3.hidden = NO;
    }
    else if (timeCount == 4){
        [self popupImage];
        self.mgifFrame4ImgV.image = [self.frameImgsArray objectAtIndex:3];
        self.mgifFrame4ImgV.backgroundColor = [UIColor blackColor];
        self.mgifFrameCountLbl4.textColor = [UIColor whiteColor];
        if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
            self.mgifFrame4ImgV.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        self.mCount1Btn.titleLabel.textColor = [UIColor clearColor];
        self.mGifStrip4View.hidden = NO;
        self.mGifView4_1.hidden = NO;
        self.mGifView4_2.hidden = NO;
        [countdowntimer invalidate];
        if ([[self.choosenMediaType lowercaseString] isEqualToString:@"gif"]) {
            
            [self.view addSubview:delegateObj.hud];
            [delegateObj.hud show:YES];
            delegateObj.hud.hidden = NO;
            delegateObj.hud.detailsLabelText = @"P R E P A R I N G  G I F";
        }
        
        [gifTimer invalidate];
        [self performSelector:@selector(clickImageItself) withObject:nil afterDelay:0.4f];
    }
}

-(void)showHideCountTimerView:(BOOL)isShowing{
    [UIView animateWithDuration:0.5 animations:^{
        
        if (isShowing == YES) {
            //            self.mTimerView.hidden = YES;
            self.mTimerView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.mTimerView.frame.size.width,self.mTimerView.frame.size.height);
        }
        else{
            //          self.mTimerView.hidden = NO;
            self.mTimerView.frame = CGRectMake(self.view.frame.origin.x, (self.view.frame.size.height-self.mTimerView.frame.size.height), self.mTimerView.frame.size.width,self.mTimerView.frame.size.height);
        }
    }];
}

- (void)clickImageItself {
    
    ImageClickedVC *vcObj = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageClickedVC"];
    if ([[self.choosenMediaType lowercaseString] isEqualToString:@"photo"]){
//        [self popupImage];
        vcObj.clickedImage = [self getCurrentClickedImage];
        vcObj.sharpeningValue = [@(sharpeningValue) stringValue];
        vcObj.contrastValue = [@(contrastValue) stringValue];
    }
    else if ([[self.choosenMediaType lowercaseString] isEqualToString:@"gif"]) {
        vcObj.gifImgsArray = self.frameImgsArray;
        //   NSLog( @"%lu", self.frameImgsArray.count);
        //[vcObj.gifImgsArray addObjectsFromArray:self.frameImgsArray];
        delegateObj.hud.detailsLabelText = @"P L E A S E  W A I T";
        [delegateObj.hud removeFromSuperview];
    }
    else if ([[self.choosenMediaType lowercaseString] isEqualToString:@"video"]) {
        
    }
    vcObj.activeMediaCount = self.optionsCount;
    vcObj.mediaType = self.choosenMediaType;
    [UIView animateWithDuration:0.75
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         [self.navigationController pushViewController:vcObj animated:NO];
                         
                     }];
}

- (UIImage *)getCurrentClickedImage {
    //    [cameraView setInputRotation:kGPUImageFlipHorizonal atIndex:0];
    UIImage *capturedImage = [[UIImage alloc] init];
    //    UIImage* flippedImage = [[UIImage alloc] init];
    [videoCamera pauseCameraCapture];
    if ([videoCamera.targets count]){
        if ([[videoCamera.targets objectAtIndex:0] isKindOfClass:[GPUImageGrayscaleFilter class]]) {
            [_grayScaleFilter useNextFrameForImageCapture];
            capturedImage = [_grayScaleFilter imageFromCurrentFramebuffer];
        }
        else {
            [_filter useNextFrameForImageCapture];
            capturedImage = [_filter imageFromCurrentFramebuffer];
        }
    }
    
    [videoCamera resumeCameraCapture];
    return capturedImage;
}

- (void)setCounterButtonColor {
    self.timerCount = 0;
    self.showTimerFrameVal = 0;
    self.mCount3Btn.titleLabel.textColor = [UIColor whiteColor];
    self.mCount2Btn.titleLabel.textColor = kAppTextColor;
    self.mCount1Btn.titleLabel.textColor = kAppTextColor;
}

- (void)showOnlyClickImageTimer {
    
    self.timerCount = self.timerCount+1;
    //    if (self.timerCount == 1){
    //        self.mCount3Btn.titleLabel.textColor = [UIColor whiteColor];
    //    }
    if (self.timerCount == 1){
        self.mCount1Btn.titleLabel.textColor = kAppTextColor;
        self.mCount2Btn.titleLabel.textColor = [UIColor whiteColor];
        self.mCount3Btn.titleLabel.textColor = [UIColor clearColor];
    }
    else if (self.timerCount == 2){
        self.mCount3Btn.titleLabel.textColor = [UIColor clearColor];
        self.mCount2Btn.titleLabel.textColor = [UIColor clearColor];
        self.mCount1Btn.titleLabel.textColor = [UIColor whiteColor];
    }
    else if (self.timerCount == 3){
        self.mCount3Btn.titleLabel.textColor = [UIColor clearColor];
        self.mCount2Btn.titleLabel.textColor = [UIColor clearColor];
        self.mCount1Btn.titleLabel.textColor = [UIColor clearColor];
        [self setCounterButtonColor];
        //        [self performSelector:@selector(setCounterButtonColor) withObject:nil afterDelay:0.1];
    }
}

#pragma mark-  Media Options Methods

-(void)mediaOptionSelector:(id)sender{
    
    
    [self showHideBottomBarButtonView:YES];
    [self setCounterButtonColor];
    [self performSelector:@selector(showHideCountTimerView:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.4f];
    double delayInSeconds = 0.4f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self showHideCountTimerView:NO];
        //        NSLog(@"Do some work");
    });
    //    [self showHideCountTimerView:NO];
    [self performSelector:@selector(startCountTimerForClickImage:) withObject:self.choosenMediaType afterDelay:0.8f];
    
    if ([self.choosenMediaType isEqualToString:@"gif"]){
        if ([gifType isEqualToString: @"Boomerang"])
        {
             videoCamera.captureSessionPreset = AVCaptureSessionPreset640x480;
        }
        else
        {
            [self performSelector:@selector(showGifFrameView:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.8f];
        }
    }
    else {
        [self hideGifFrameView:NO];
    }
}

-(IBAction)mediaOptionsButtonAction:(id)sender {
    UIButton *btn25 = (UIButton *)[self.view viewWithTag:1125];
    if (kSingleMediaActiveBtnTag == [sender tag] || kMediaStartBtnTag == [sender tag]) {
        [btn25 setBackgroundImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
    }
    
    UIButton *mbtn = (UIButton *)sender;
    NSString *mtitleStr = [mbtn titleForState:UIControlStateNormal];
    NSInteger mtagStr = mbtn.tag;
    
    if ([[mtitleStr lowercaseString] isEqualToString:@"photo"] ||  mtagStr == 501){
        self.choosenMediaType = @"photo";
        self.mCameraBtnBGV.image = [UIImage imageNamed:@"Camera_Icon_Small.png"];
    }
    else if ([[mtitleStr lowercaseString] isEqualToString:@"gif"] ||  mtagStr == 502) {
        //        [self setUpCameraForVideo];
        self.choosenMediaType = @"gif";
        self.mCameraBtnBGV.image = [UIImage imageNamed:@"Gif_Icon_Small.png"];
    }
    else if ([[mtitleStr lowercaseString] isEqualToString:@"video"] ||  mtagStr == 503) {
        [self setUpCameraForVideo];
        self.choosenMediaType = @"video";
        self.mCameraBtnBGV.image = [UIImage imageNamed:@"Video_Icon_Small.png"];
    }
    
    if ([sender tag] != kMediaStartBtnTag){
        [self setSelectMediaBtnForBottomView];
    }
     mbtn.enabled = false;
    [self performSelector:@selector(mediaOptionSelector:) withObject:sender afterDelay:0.3];
}

- (IBAction)pushButtonAction:(id)sender {
    isPushButtonClicked = YES;
    if (offlineData.count != 0) {
        [self.sendBnt setEnabled:NO];
        [self.loaderImgView setHidden:NO];
        [self checkEventOnline];
    }
    else{
        
    }
}

- (IBAction)sharpeningSliderChanged:(id)sender {
    NSUInteger index = (NSUInteger)(self.mSharpningSlider.value + 0.5);
    [self.mSharpningSlider setValue:index animated:YES];
    //    NSLog(@"%f", [(UISlider *)sender value]);
    sharpeningValue = [(UISlider *)sender value];
    [USER_DEFAULTS setInteger:[(UISlider *)sender value] forKey:@"sharpeningValue"];
}

- (IBAction)contrastSliderChanged:(id)sender {
    NSUInteger index = (NSUInteger)(self.mContrastSlider.value + 0.5);
    [self.mContrastSlider setValue:index animated:YES];
    //    NSLog(@"%f", [(UISlider *)sender value]);
    contrastValue = [(UISlider *)sender value]+1;
    if (contrastValue == 0) {
        contrastValue = 1;
        [USER_DEFAULTS setInteger:contrastValue forKey:@"contrastValue"];
    }
    else{
        [USER_DEFAULTS setInteger:contrastValue forKey:@"contrastValue"];
    }
    
}
-(void)uploadData
{
    if (offlineData.count == 0) {
        [self.loaderImgView setHidden:YES];
        [self.sendBnt setEnabled:NO];
        [self.sendBnt setTitle:@"I M A G E S  S E N T" forState:UIControlStateDisabled];
        [self.sendBnt setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        NSString *value = [@(offlineData.count) stringValue];
        [self.queueCountBtn setTitle: [NSString stringWithFormat:@"Q U E U E D :  %@",[self addSpace:value]]forState:UIControlStateNormal];
        isPushButtonClicked = NO;
    }
    else
    {
        //    WebserviceHelper *help = [[WebserviceHelper alloc] init];
        NSDictionary *data = [offlineData objectAtIndex:0];
        if ([[data valueForKey:@"sharedAgain"] isEqualToString:@"yes"]) {
            if ([[data valueForKey:@"shareValue"] isEqualToString:@""]) {
                [Helper deleteDocumentDirectoryFile:[data valueForKey:@"path"]];
                [offlineData removeObjectAtIndex:0];
                [self uploadData];
            }
            else
            {
                [self sendEmailAndTextWithInfoWith:data];
            }
        }
        else{
            if ([data valueForKey:@"shareValue"] == nil) {
                [Helper deleteDocumentDirectoryFile:[data valueForKey:@"path"]];
                [offlineData removeObjectAtIndex:0];
                [self uploadData];
            }
            else
            {
                NSString *file;
                NSLog(@"%@",[data valueForKey:@"path"]);
                file = [Helper getDirectoryFilePath:[data valueForKey:@"path"]];
                NSURL *urlStr = [NSURL fileURLWithPath:file isDirectory:NO];
                NSError *err;
                if ([urlStr checkResourceIsReachableAndReturnError:&err] == NO)
                {
                    [offlineData removeObjectAtIndex:0];
                    [self uploadData];
                }
                else{
                    [help UploadOfflineDataWithName:[data valueForKey:@"path"] withType:[data valueForKey:@"fileType"] withCameraType:[data valueForKey:@"camType"] withshareOption:[data valueForKey:@"shareOptionType"] withShareValue:[data valueForKey:@"shareValue"] withEventKey:[data valueForKey:kAppEventIdKey] withTime:[data valueForKey:@"time"] withBlock:^(int statusCode,NSDictionary *responseDic) {
                        NSLog(@"%d",statusCode,@" ",responseDic);
                        if (statusCode == 200) {
                            fail = 0;
                            [USER_DEFAULTS setObject:[responseDic valueForKey:@"media_url"] forKey:@"sharedLink"];
                            [Helper deleteDocumentDirectoryFile:[data valueForKey:@"path"]];
                            if (offlineData.count>0) {
                                [offlineData removeObjectAtIndex:0];
                                NSString *value = [@(offlineData.count) stringValue];
                                if (value != nil) {
                                    [self.queueCountBtn setTitle: [NSString stringWithFormat:@"Q U E U E D :  %@",[self addSpace:value]]forState:UIControlStateNormal];
                                }
                                if ([responseDic valueForKey:@"total_media"] != nil) {
                                    [self.serverCountBtn setTitle:[NSString stringWithFormat:@"S E R V E R :  %@",[self addSpace:[responseDic valueForKey:@"total_media"]]]forState:UIControlStateNormal];
                                }
                                [USER_DEFAULTS setObject:[responseDic valueForKey:@"total_media"] forKey:@"total_media"];
                                [self uploadData];
                            }
                        }
                        else{
                            if (fail==5) {
                                [self.sendBnt setEnabled:YES];
                                [Helper showAlert:nil andMessage:@"Please connect to the internet and try again."];
                                [self.loaderImgView setHidden:YES];
                            }
                            else{
                                fail++;
                                [self uploadData];
                            }
                            
                        }
                        
                    }];
                }
            }
        }
        
    }
    if (offlineData.count == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[[USER_DEFAULTS valueForKey:@"user_information"] valueForKey:@"event_id"]];
        //        delegateObj.offlineData = nil;
        offlineData = nil;
        [self.loaderImgView setHidden:YES];
        [self.sendBnt setEnabled:NO];
        [self.sendBnt setTitle:@"I M A G E S  S E N T" forState:UIControlStateDisabled];
        [self.serverCountBtn setTitle:[NSString stringWithFormat:@"S E R V E R :  %@",[self addSpace:[USER_DEFAULTS valueForKey:@"total_media"]]]forState:UIControlStateNormal];
        [self.sendBnt setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    }
    else{
        [[NSUserDefaults standardUserDefaults] setObject:offlineData forKey:[[USER_DEFAULTS valueForKey:@"user_information"] valueForKey:@"event_id"]];
    }
}
- (void)sendEmailAndTextWithInfoWith:(NSDictionary *)dic{
    
    //    And, please send media_url (only) as a message while sending email/text message request (Meaning, remove default email_message/sms_message and "link" word from message.).
    
    NSMutableDictionary *dct = [[NSMutableDictionary alloc] init];
    [dct setValue:kAppAuthValue forKey:kAppAuthKey];
    [dct setValue:[dic valueForKey:kAppEventIdKey]forKey:kAppEventIdKey];
    if ([[dic valueForKey:@"shareOptionType"] isEqualToString:@"email_id"]){
        [dct setValue:[dic valueForKey:@"shareValue"] forKey:kAppEmailIdKey];
        [dct setValue:@"" forKey:kAppMessageKey];
        if ([[dic valueForKey:@"sharedLink"] isEqualToString:@""]) {
            [dct setValue:[USER_DEFAULTS valueForKey:@"sharedLink"] forKey:kAppLinkKey];
        }
        else{
            [dct setValue:[dic valueForKey:@"sharedLink"] forKey:kAppLinkKey];
        }
    }
    else {
        [dct setValue:[dic valueForKey:@"shareValue"] forKey:kAppMobileNumKey];
        if ([[dic valueForKey:@"sharedLink"] isEqualToString:@""]) {
            [dct setValue:[USER_DEFAULTS valueForKey:@"sharedLink"] forKey:kAppMessageKey];
        }
        else{
            [dct setValue:[dic valueForKey:@"sharedLink"] forKey:kAppMessageKey];
        }
    }
    //    WebserviceHelper *help = [[WebserviceHelper alloc] init];
    help.mydelegate = self;
    if ([[dic valueForKey:@"shareOptionType"] isEqualToString:@"email_id"]){
        [help sendServerRequest:dct andAPI:kSendMailAPI];
    }
    else {
        [help sendServerRequest:dct andAPI:kSendMobileAPI];
    }
}

- (void)setupActiveMediaButtons {
    
    self.isImgMediaActive = [Helper getUserInfoValueForKey:@"photo"];
    self.isGifMediaActive = [Helper getUserInfoValueForKey:@"gif"];
    self.isVdoMediaActive = [Helper getUserInfoValueForKey:@"video"];
    self.isAudioActive =    [[Helper getUserInfoValueForKey:@"audio"] intValue];
    self.mediaTypeGifBtn.backgroundColor = [UIColor clearColor];
    self.mediaTypeVideoBtn.backgroundColor = [UIColor clearColor];
    self.mediaTypeImgBtn.backgroundColor = [UIColor clearColor];
    self.msingleStartLbl.backgroundColor = [UIColor clearColor];
    
    self.optionsCount = 0;
    
    if ([self.isImgMediaActive isEqualToString:@""] && [self.isGifMediaActive isEqualToString:@""] && [self.isVdoMediaActive isEqualToString:@""]){
        
        self.mBottomBarView.hidden = YES;
    }
    else {
        if ([self.isImgMediaActive isEqualToString:@"1"]){
            self.mediaTypeImgBtn.enabled = YES;
            self.optionsCount = self.optionsCount+1;
        }
        else {
            self.mediaTypeImgBtn.enabled = NO;
        }
        if ([self.isGifMediaActive isEqualToString:@"1"]){
            self.mediaTypeGifBtn.enabled = YES;
            self.optionsCount = self.optionsCount+1;
        }
        else {
            self.mediaTypeGifBtn.enabled = NO;
        }
        if ([self.isVdoMediaActive isEqualToString:@"1"]){
            self.mediaTypeVideoBtn.enabled = YES;
            self.optionsCount = self.optionsCount+1;
        }
        else {
            self.mediaTypeVideoBtn.enabled = NO;
        }
        
        UIView *singleMediaViewTemp = (UIView *)[self.mBottomBarView viewWithTag:kSingleMediaViewTag];
        UIView *doubleMediaViewTemp = (UIView *)[self.mBottomBarView viewWithTag:kDoubleMediaViewTag];
        UIView *AllMediaViewTemp = (UIView *)[self.mBottomBarView viewWithTag:kAllMediaViewTag];
        singleMediaViewTemp.hidden = NO;
        doubleMediaViewTemp.hidden = NO;
        AllMediaViewTemp.hidden = NO;
        if (self.optionsCount == 1){
            doubleMediaViewTemp.hidden = YES;
            AllMediaViewTemp.hidden = YES;
            self.multiLineView.hidden = YES;
            self.mediaStartTitleLbl.hidden = YES;
            
            UIButton *btnTemp = (UIButton *)[singleMediaViewTemp viewWithTag:1125];
            btnTemp.enabled = true;
            UIImageView *miconTemp = (UIImageView *)[singleMediaViewTemp viewWithTag:kSingleMediaIconTag];
            
            if ([self.isImgMediaActive isEqualToString:@"1"]){
                self.mediaStartSingleTitleLbl.hidden = NO;
                [btnTemp setTitle:@"PHOTO" forState:UIControlStateNormal];
                miconTemp.image = [UIImage imageNamed:@"Camera_Icon_Small.png"];
            }
            else if ([self.isGifMediaActive isEqualToString:@"1"]) {
                self.mediaStartSingleTitleLbl.hidden = NO;
                [btnTemp setTitle:@"GIF" forState:UIControlStateNormal];
                miconTemp.image = [UIImage imageNamed:@"Gif_Icon_Small.png"];
            }
            else {
                self.mediaStartSingleTitleLbl.hidden = NO;
                [btnTemp setTitle:@"VIDEO" forState:UIControlStateNormal];
                miconTemp.image = [UIImage imageNamed:@"Video_Icon_Small.png"];
            }
            btnTemp.backgroundColor = [UIColor clearColor];
            NSString *string = [NSString stringWithFormat:@"%@ %@?", kReadyTextStr, [btnTemp titleForState:UIControlStateNormal]];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            
            float spacing = 5.0f;
            [attributedString addAttribute:NSKernAttributeName
                                     value:@(spacing)
                                     range:NSMakeRange(0, [string length])];
            
            self.mediaStartSingleTitleLbl.attributedText = attributedString;
            
            [btnTemp addTarget:self action:@selector(mediaOptionsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (self.optionsCount == 2) {
            NSString *string1 = @"";
            NSString *string2 = @"";
            singleMediaViewTemp.hidden = YES;
            AllMediaViewTemp.hidden = YES;
            self.mediaStartTitleLbl.hidden = NO;
            
            UIButton *btnTemp = (UIButton *)[doubleMediaViewTemp viewWithTag:kDoubleMediaBtnTag1];
            btnTemp.enabled = true;
            UIImageView *miconTemp = (UIImageView *)[doubleMediaViewTemp viewWithTag:kDoubleMediaIconTag1];
            UILabel *lblTemp = (UILabel *)[doubleMediaViewTemp viewWithTag:kDoubleMediaLblTag1];
            
            UIButton *btnTemp2 = (UIButton *)[doubleMediaViewTemp viewWithTag:kDoubleMediaBtnTag2];
            btnTemp2.enabled = true;
            UIImageView *miconTemp2 = (UIImageView *)[doubleMediaViewTemp viewWithTag:kDoubleMediaIconTag2];
            UILabel *lblTemp2 = (UILabel *)[doubleMediaViewTemp viewWithTag:kDoubleMediaLblTag2];
            
            
            btnTemp.backgroundColor = [UIColor clearColor];
            btnTemp2.backgroundColor = [UIColor clearColor];
            
            miconTemp.contentMode = UIViewContentModeScaleAspectFit;
            miconTemp2.contentMode = UIViewContentModeScaleAspectFit;
            if ([self.isImgMediaActive isEqualToString:@"1"] && [self.isGifMediaActive isEqualToString:@"1"]){
                [btnTemp setTitle:@"PHOTO" forState:UIControlStateNormal];
                [btnTemp2 setTitle:@"GIF" forState:UIControlStateNormal];
                
                string1 = @"PHOTO";
                string2 = @"GIF";
                
                miconTemp.image = [UIImage imageNamed:@"camera-large.png"];
                miconTemp2.image = [UIImage imageNamed:@"gif-large.png"];
                lblTemp.text = @"P H O T O G R A P H";
                lblTemp2.text = @"A N I M A T E D  G I F";
            }
            else if ([self.isGifMediaActive isEqualToString:@"1"] && [self.isVdoMediaActive isEqualToString:@"1"]) {
                [btnTemp setTitle:@"GIF" forState:UIControlStateNormal];
                [btnTemp2 setTitle:@"VIDEO" forState:UIControlStateNormal];
                
                string1 = @"GIF";
                string2 = @"VIDEO";
                
                miconTemp.image = [UIImage imageNamed:@"gif-large.png"];
                miconTemp2.image = [UIImage imageNamed:@"video-large.png"];
                
                lblTemp.text = @"A N I M A T E D  G I F";
                lblTemp2.text = @"V I D E O";
            }
            else if ([self.isImgMediaActive isEqualToString:@"1"] && [self.isVdoMediaActive isEqualToString:@"1"]){
                [btnTemp setTitle:@"PHOTO" forState:UIControlStateNormal];
                [btnTemp2 setTitle:@"VIDEO" forState:UIControlStateNormal];
                
                string1 = @"PHOTO";
                string2 = @"VIDEO";
                
                miconTemp.image = [UIImage imageNamed:@"camera-large.png"];
                miconTemp2.image = [UIImage imageNamed:@"video-large.png"];
                
                lblTemp.text = @"P H O T O G R A P H";
                lblTemp2.text = @"V I D E O";
            }
            NSString *string = [NSString stringWithFormat:@"%@ %@ / %@ ?", kReadyTextStr, string1,string2];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            
            float spacing = 5.0f;
            [attributedString addAttribute:NSKernAttributeName
                                     value:@(spacing)
                                     range:NSMakeRange(0, [string length])];
            
            self.mediaStartTitleLbl.attributedText = attributedString;
            
            [btnTemp addTarget:self action:@selector(mediaOptionsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [btnTemp2 addTarget:self action:@selector(mediaOptionsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (self.optionsCount == 3) {
            singleMediaViewTemp.hidden = YES;
            doubleMediaViewTemp.hidden = YES;
            self.mediaStartTitleLbl.hidden = NO;
            
            self.mediaStartTitleLbl.text = [NSString stringWithFormat:@"%@ PHOTO / GIF / VIDEO ?", kReadyTextStr];
            NSString *string = [NSString stringWithFormat:@"%@ PHOTO / GIF / VIDEO ?", kReadyTextStr];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
            
            float spacing = 5.0f;
            [attributedString addAttribute:NSKernAttributeName
                                     value:@(spacing)
                                     range:NSMakeRange(0, [string length])];
            
            self.mediaStartTitleLbl.attributedText = attributedString;
        }
    }
}

-(void)showHideBottomBarButtonView:(BOOL)isShowing{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        if (isShowing == YES) {
            self.mBottomBarView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.mBottomBarView.frame.size.width,self.mBottomBarView.frame.size.height);
        }
        else{
            [self setSelectMediaBtnForBottomView];
            self.mBottomBarView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height-self.mBottomBarView.frame.size.height, self.mBottomBarView.frame.size.width,self.mBottomBarView.frame.size.height);
        }
    }];
}

- (void)setSelectMediaBtnForBottomView {
    
    UIView *singleMediaViewTemp = (UIView *)[self.mBottomBarView viewWithTag:kSingleMediaViewTag];
    UIView *doubleMediaViewTemp = (UIView *)[self.mBottomBarView viewWithTag:kDoubleMediaViewTag];
    
    if (self.optionsCount == 1){
        
        UIButton *btnTemp = (UIButton *)[singleMediaViewTemp viewWithTag:kSingleMediaActiveBtnTag];
        btnTemp.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"start_btn_bg"]];
        [btnTemp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if ([[self.choosenMediaType lowercaseString] isEqualToString:@"photo"]
            || [[self.choosenMediaType lowercaseString] isEqualToString:@"gif"]
            || [[self.choosenMediaType lowercaseString] isEqualToString:@"video"]){
            [self.msingleStartLbl setBackgroundColor:kBtnColor ];
        } else {
            [self.msingleStartLbl setBackgroundColor:[UIColor clearColor] ];
        }
    }
    else if (self.optionsCount == 2){
        
        UIButton *btnTemp = (UIButton *)[doubleMediaViewTemp viewWithTag:kDoubleMediaBtnTag1];
        UIImageView *miconTemp = (UIImageView *)[doubleMediaViewTemp viewWithTag:kDoubleMediaIconTag1];
        UIButton *btnTemp2 = (UIButton *)[doubleMediaViewTemp viewWithTag:kDoubleMediaBtnTag2];
        UIImageView *miconTemp2 = (UIImageView *)[doubleMediaViewTemp viewWithTag:kDoubleMediaIconTag2];
        miconTemp.contentMode = UIViewContentModeScaleAspectFit;
        miconTemp2.contentMode = UIViewContentModeScaleAspectFit;
        
        if ([self.isImgMediaActive isEqualToString:@"1"] && [self.isGifMediaActive isEqualToString:@"1"]) {
            if ([[self.choosenMediaType lowercaseString] isEqualToString:@"photo"]){
                
                btnTemp.backgroundColor = kBtnColor;
                btnTemp2.backgroundColor = [UIColor clearColor];
            }
            else if ([[self.choosenMediaType lowercaseString] isEqualToString:@"gif"]) {
                
                btnTemp2.backgroundColor = kBtnColor;
                btnTemp.backgroundColor = [UIColor clearColor];
            }
        }
        else if ([self.isGifMediaActive isEqualToString:@"1"] && [self.isVdoMediaActive isEqualToString:@"1"]){
            
            if ([[self.choosenMediaType lowercaseString] isEqualToString:@"gif"]) {
                
                btnTemp.backgroundColor = kBtnColor;
                btnTemp2.backgroundColor = [UIColor clearColor];
            }
            else if ([[self.choosenMediaType lowercaseString] isEqualToString:@"video"]) {
                
                btnTemp2.backgroundColor = kBtnColor;
                btnTemp.backgroundColor = [UIColor clearColor];
            }
        }
        else if ([self.isImgMediaActive isEqualToString:@"1"] && [self.isVdoMediaActive isEqualToString:@"1"]){
            
            if ([[self.choosenMediaType lowercaseString] isEqualToString:@"photo"]){
                
                btnTemp.backgroundColor = kBtnColor;
                btnTemp2.backgroundColor = [UIColor clearColor];
            }
            else if ([[self.choosenMediaType lowercaseString] isEqualToString:@"video"]) {
                
                btnTemp2.backgroundColor = kBtnColor;
                btnTemp.backgroundColor = [UIColor clearColor];
            }
        }
    }
    else {
        if ([[self.choosenMediaType lowercaseString] isEqualToString:@"photo"]){
            
            [self.mediaTypeImgBtn setBackgroundColor:kBtnColor];
        }
        else if ([[self.choosenMediaType lowercaseString] isEqualToString:@"gif"]) {
            
            [self.mediaTypeGifBtn setBackgroundColor:kBtnColor];
        }
        else if ([[self.choosenMediaType lowercaseString] isEqualToString:@"video"]) {
            
            [self.mediaTypeVideoBtn setBackgroundColor:kBtnColor];
        }
        else {
            self.choosenMediaType = @"photo";
            self.mediaTypeImgBtn.backgroundColor = [UIColor clearColor];
            self.mediaTypeGifBtn.backgroundColor = [UIColor clearColor];
            self.mediaTypeVideoBtn.backgroundColor = [UIColor clearColor];
        }
    }
}

#pragma mark- SaveSettings to Local DB

- (void) saveSettingDataToLocalDB {
    
    CameraSettings *dbObj = [CameraSettings saveDataWithDictionary:[self getCameraSettingsDict]];
    //    NSLog(@"%@", dbObj);
}

- (void) fetchSavedCameraSettings {
    
    CameraSettings *settingsobj = [CameraSettings fetchMatchingUser];
    
    if (settingsobj){
        
        self.mSharpningSlider.value =[[USER_DEFAULTS valueForKey:@"sharpeningValue"] floatValue];
        [self performSelector:@selector(sharpeningSliderChanged:) withObject:self.mSharpningSlider];
        
        self.mContrastSlider.value =[[USER_DEFAULTS valueForKey:@"contrastValue"] floatValue];
        [self performSelector:@selector(contrastSliderChanged:) withObject:self.mContrastSlider];
        
        self.mExposureSlider.value = [settingsobj.mexposure floatValue];
        [self performSelector:@selector(exposureSliderChanged:) withObject:self.mExposureSlider];
        
        UISlider *mtempZoomSlider = [[UISlider alloc] init];
        mtempZoomSlider.value = [settingsobj.mzoom floatValue];
        [self performSelector:@selector(zoomSliderChanged:) withObject:mtempZoomSlider];
        
        UIButton *mtempWhiteBalancingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        mtempWhiteBalancingBtn.tag = [settingsobj.mwhitebalancing intValue];
        [self performSelector:@selector(colorChangeActionMethods:) withObject:mtempWhiteBalancingBtn];
        
        UIButton *mtempfrontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
            mtempfrontBtn.tag = kBtnTagFront;
        }
        else {
            mtempfrontBtn.tag = kBtnTagBack;
        }
        [self performSelector:@selector(cameraPositionActionMethods:) withObject:mtempfrontBtn];
        
        UIButton *mtempColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([[settingsobj.mcolor lowercaseString] isEqualToString:@"yes"]){
            mtempColorBtn.tag = kBtnTagColor;
        }
        else {
            mtempColorBtn.tag = kBtnTagBW;
        }
        [self performSelector:@selector(cameraPositionActionMethods:) withObject:mtempColorBtn];
    }
    return;
}

- (NSMutableDictionary *) getCameraSettingsDict {
    
    NSMutableDictionary *mSettingsDict = [[NSMutableDictionary alloc] init];
    [mSettingsDict setObject:[Helper getUserInfoValueForKey:kAppClientIdKey] forKey:@"kuserid"];
    
    NSString *mtempStr = [self.mExposureMaxLable.text stringByReplacingOccurrencesOfString:@"  %" withString:@""];
    float mexposurevalue = [mtempStr floatValue];
    [mSettingsDict setObject:[NSString stringWithFormat:@"%.02f", mexposurevalue] forKey:@"kexposure"];
    if (!self.mcamerazoomStr){
        self.mcamerazoomStr = @"100";
    }
    [mSettingsDict setObject:self.mcamerazoomStr forKey:@"kzoom"];
    if (!self.mwhitebalanceTagStr) {
        self.mwhitebalanceTagStr = [NSString stringWithFormat:@"%d", kBtnTagAuto];
    }
    [mSettingsDict setObject:self.mwhitebalanceTagStr forKey:@"kwhitebalance"];
    for (NSObject *cameraobj in videoCamera.targets) {
        if ([cameraobj isKindOfClass:[GPUImageWhiteBalanceFilter class]]){
            [mSettingsDict setObject:@"yes" forKey:@"kcolor"];
        }
        else if ([cameraobj isKindOfClass:[GPUImageGrayscaleFilter class]]){
            [mSettingsDict setObject:@"no" forKey:@"kcolor"];
        }
    }
    if (videoCamera.cameraPosition == AVCaptureDevicePositionFront){
        [mSettingsDict setObject:@"yes" forKey:@"kfront"];
    }
    else {
        [mSettingsDict setObject:@"no" forKey:@"kfront"];
    }
    return mSettingsDict;
}

#pragma mark- Action Methods

-(IBAction)cancelButtonAction:(id)sender {
    self.mUserNameTextField.text = @"";
    self.mPasswordTextField.text = @"";
    [self.mUserNameTextField becomeFirstResponder];
}

-(IBAction)topBarButtonActionMethods:(id)sender {
    
    if ([sender tag] == kBtnTagStartEvent) {
        //        NSLog(@"start event");
        [self saveSettingDataToLocalDB]; // Save Setting to local DB
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraViewTapAction:)];
        [self.cameraView addGestureRecognizer:tgr];
        [self showHideTopBarButtonView:NO];
        [self setupActiveMediaButtons];
        [self showHideBottomBarButtonView:NO];
        
    }
    else{
        self.mLoginBGView.hidden = NO;
        self.mUserNameTextField.text = @"";
        self.mPasswordTextField.text = @"";
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self showHideTopBarButtonView:NO];
    }
}

#pragma mark- check Relogin User
-(BOOL)isOldUser
{
    //    NSString *userID = [USER_DEFAULTS valueForKey:@"user_information"];
    
    return YES;
}
-(IBAction)colorChangeActionMethods:(id)sender {
    
    for (UIView *vw in self.mControlColorChangeView.subviews) {
        if ([vw isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)vw;
            [btn setBackgroundColor:[UIColor clearColor]];
        }
    }
    float temp =0.0;
    float tint = 0.0;
    CameraSettings *dbObj = [CameraSettings fetchMatchingUser];
    switch ([sender tag]) {
        case kBtnTagAuto:{
            [videoCamera.inputCamera lockForConfiguration:nil];
            [videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
            [videoCamera.inputCamera unlockForConfiguration];
            UIButton *btn3 = (UIButton *)[self.mControlColorChangeView viewWithTag:kBtnTagAuto];
            [btn3 setBackgroundColor:kBtnColor];
            self.mwhitebalanceTagStr = [NSString stringWithFormat:@"%d", kBtnTagAuto];
            if (dbObj){
                dbObj.mwhitebalancing = self.mwhitebalanceTagStr;
                [[PersistenceController sharedInstance] saveContext];
            }
            return;
        }
            break;
        case kBtnTagCloudy:{
            UIButton *btn3 = (UIButton *)[self.mControlColorChangeView viewWithTag:kBtnTagCloudy];
            [btn3 setBackgroundColor:kBtnColor];
            temp = 3000;
            tint = 0;
            self.mwhitebalanceTagStr = [NSString stringWithFormat:@"%d", kBtnTagCloudy];
        }
            break;
        case kBtnTagDayLight:{
            temp = 6000;
            tint = 0;
            UIButton *btn3 = (UIButton *)[self.mControlColorChangeView viewWithTag:kBtnTagDayLight];
            [btn3 setBackgroundColor:kBtnColor];
            self.mwhitebalanceTagStr = [NSString stringWithFormat:@"%d", kBtnTagDayLight];
        }
            break;
        case kBtnTagInCan:{
            temp = 7500;
            tint = 0;
            UIButton *btn3 = (UIButton *)[self.mControlColorChangeView viewWithTag:kBtnTagInCan];
            [btn3 setBackgroundColor:kBtnColor];
            self.mwhitebalanceTagStr = [NSString stringWithFormat:@"%d", kBtnTagInCan];
        }
            break;
        case kBtnTagFlour:{
            temp = 10000;
            tint = 50;
            UIButton *btn3 = (UIButton *)[self.mControlColorChangeView viewWithTag:kBtnTagFlour];
            [btn3 setBackgroundColor:kBtnColor];
            self.mwhitebalanceTagStr = [NSString stringWithFormat:@"%d", kBtnTagFlour];
        }
            break;
            
        default:
            break;
    }
    if (dbObj){
        dbObj.mwhitebalancing = self.mwhitebalanceTagStr;
        [[PersistenceController sharedInstance] saveContext];
    }
    AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
        .temperature = temp,
        .tint = tint,
    };
    
    [self setWhiteBalanceGains:[videoCamera.inputCamera deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
}

-(IBAction)logInButtonAction:(id)sender {
    
    if ([self.mUserNameTextField.text length] && [self.mPasswordTextField.text length]) {
        [self fetchLoginInfo];
        if (currentUser!= nil && ![currentUser isEqualToString:self.mUserNameTextField.text]) {
            [self setUpCamera:1];
            self.frontCam = @"yes";
            self.cameraColor = @"yes";
            self.mExposureMaxLable.text = [NSString stringWithFormat:@"0"];
            self.mSharpningSlider.value = 0;
            [self performSelector:@selector(sharpeningSliderChanged:) withObject:self.mSharpningSlider];
            
            self.mContrastSlider.value = 1;
            [self performSelector:@selector(contrastSliderChanged:) withObject:self.mContrastSlider];
            
            self.mExposureSlider.value = 0;
            [self performSelector:@selector(exposureSliderChanged:) withObject:self.mExposureSlider];
            UIButton *mtempfrontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            mtempfrontBtn.tag = kBtnTagFront;
            [self performSelector:@selector(cameraPositionActionMethods:) withObject:mtempfrontBtn];
            
            UIButton *mtempColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            mtempColorBtn.tag = kBtnTagColor;
            [self performSelector:@selector(cameraPositionActionMethods:) withObject:mtempColorBtn];
            [self layoutControls];
            filterGroup = [[GPUImageFilterGroup alloc] init];
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
            
            [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
        }
        else if (currentUser!= nil && [currentUser isEqualToString:self.mUserNameTextField.text])
        {
            [self fetchSavedCameraSettings];
        }
        currentUser = self.mUserNameTextField.text;
        [self.view addSubview:delegateObj.hud];
        [delegateObj.hud show:YES];
        delegateObj.hud.hidden = NO;
        [self.mUserNameTextField resignFirstResponder];
        [self.mPasswordTextField resignFirstResponder];
    }
    else{
        UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Invalid Credentials!" message:@"Please enter valid login credentials for login." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alrt show];
        alrt = nil;
    }
}

-(IBAction)zoomSliderChanged:(id)sender {
    
    NSError *error;
    [videoCamera.inputCamera lockForConfiguration:&error];
    UISlider *zoomslider = (UISlider *)sender;
    //    NSLog(@"Zooom %f",[zoomslider value]);
    self.mcamerazoomStr = [NSString stringWithFormat:@"%.02f", [zoomslider value]];
    if ([zoomslider value]<videoCamera.inputCamera.activeFormat.videoMaxZoomFactor) {
        
        videoCamera.inputCamera.videoZoomFactor = [zoomslider value];
    }
    [videoCamera.inputCamera unlockForConfiguration];
}

-(IBAction)exposureSliderChanged:(id)sender {
    
    //    NSLog(@"%f", [(UISlider *)sender value]);
    
    int val = [(UISlider *)sender value];
    float exposureVal = (float) val / 2;
    self.mExposureMaxLable.text = [NSString stringWithFormat:@"%d",val];
    
    [videoCamera.inputCamera lockForConfiguration:nil];
    [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeLocked];
    [videoCamera.inputCamera setExposureTargetBias:exposureVal completionHandler:nil];
    [videoCamera.inputCamera unlockForConfiguration];
    
}

-(IBAction)cameraPositionActionMethods:(id)sender {
    //        NSLog(@"%f",videoCamera.inputCamera.exposureTargetBias);
    //        NSLog(@"%f",[self.mExposureMaxLable.text floatValue]);
    [videoCamera removeAllTargets];
    //        CameraSettings *dbObj = [CameraSettings fetchMatchingUser];
    if ([sender tag] == kBtnTagFront) {
        [self setUpCamera:1];
        UIButton *btn = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagFront];
        [btn setBackgroundColor:kBtnColor];
        
        UIButton *btn1 = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagBack];
        [btn1 setBackgroundColor:[UIColor clearColor]];
        
        [videoCamera.inputCamera lockForConfiguration:nil];
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeLocked];
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [videoCamera.inputCamera setExposureTargetBias:[self.mExposureMaxLable.text floatValue] completionHandler:nil];
        [videoCamera.inputCamera unlockForConfiguration];
//        [self.mExposureSlider setValue:[self.mExposureMaxLable.text floatValue]];
        //            NSLog(@"%f",videoCamera.inputCamera.exposureTargetBias);
        //            NSLog(@"%f",[self.mExposureMaxLable.text floatValue]);
        // if (dbObj){
        self.frontCam = @"yes";
        //   }
        UIButton *mtempColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([[self.cameraColor lowercaseString] isEqualToString:@"yes"]){
            mtempColorBtn.tag = kBtnTagColor;
            [self performSelector:@selector(cameraPositionActionMethods:) withObject:mtempColorBtn];
        }
        else {
            mtempColorBtn.tag = kBtnTagBW;
            [self performSelector:@selector(cameraPositionActionMethods:) withObject:mtempColorBtn];
        }
        
    }
    else if ([sender tag] == kBtnTagBack){
        [self setUpCamera:2];
        UIButton *btn = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagBack];
        [btn setBackgroundColor:kBtnColor];
        
        UIButton *btn1 = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagFront];
        [btn1 setBackgroundColor:[UIColor clearColor]];
        
        [videoCamera.inputCamera lockForConfiguration:nil];
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeLocked];
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
        [videoCamera.inputCamera setExposureTargetBias:[self.mExposureMaxLable.text floatValue] completionHandler:nil];
        [videoCamera.inputCamera unlockForConfiguration];
        [self.mExposureSlider setValue:[self.mExposureMaxLable.text floatValue]];
        //            NSLog(@"%f",videoCamera.inputCamera.exposureTargetBias);
        //            NSLog(@"%f",[self.mExposureMaxLable.text floatValue]);
        // if (dbObj){
        self.frontCam = @"no";
        UIButton *mtempColorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([[self.cameraColor lowercaseString] isEqualToString:@"yes"]){
            mtempColorBtn.tag = kBtnTagColor;
            [self performSelector:@selector(cameraPositionActionMethods:) withObject:mtempColorBtn];
        }
        else {
            mtempColorBtn.tag = kBtnTagBW;
            [self performSelector:@selector(cameraPositionActionMethods:) withObject:mtempColorBtn];
        }
        // }
    }
    else if ([sender tag] == kBtnTagBW){
        UIButton *btn = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagBW];
        [btn setBackgroundColor:kBtnColor];
        UIButton *btn1 = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagColor];
        [btn1 setBackgroundColor:[UIColor clearColor]];
        [videoCamera addTarget:_grayScaleFilter];
        //  if (dbObj){
        self.cameraColor = @"no";
        //  }
    }
    else if ([sender tag] == kBtnTagColor){
        UIButton *btn = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagColor];
        [btn setBackgroundColor:kBtnColor];
        UIButton *btn1 = (UIButton *)[self.mControlBottomView viewWithTag:kBtnTagBW];
        [btn1 setBackgroundColor:[UIColor clearColor]];
        [videoCamera addTarget:_filter];
        //            [videoCamera addTarget:_sharpenFilter];
        //            if (dbObj){
        self.cameraColor = @"yes";
        //          }
    }
    //   [[PersistenceController sharedInstance] saveContext];
}

#pragma mark- Blurr View

- (UIView *)applyBlurToView:(UIView *)view withEffectStyle:(UIBlurEffectStyle)style andConstraints:(BOOL)addConstraints
{
    //only apply the blur if the user hasn't disabled transparency effects
    if(!UIAccessibilityIsReduceTransparencyEnabled())
    {
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
        blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = view.bounds;
        [view addSubview:blurEffectView];
        if(addConstraints) {
            
            //add auto layout constraints so that the blur fills the screen upon rotating device
            [blurEffectView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
            
            [view addConstraint:[NSLayoutConstraint constraintWithItem:blurEffectView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
        }
    }
    
    return view;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField {
    
    if (textField == self.mUserNameTextField) {
        [self.mPasswordTextField becomeFirstResponder];
    }
    else if (textField == self.mPasswordTextField){
        [self performSelector:@selector(logInButtonAction:) withObject:nil];
    }
    return YES;
}

- (void)removeBlurrEffect:(UIView *)mview {
    
    [blurEffectView removeFromSuperview];
}

- (void)captureImageSession {
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];
    if ([session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    else {
        session.sessionPreset = AVCaptureSessionPresetPhoto;
    }
    [session commitConfiguration];
    
    //    AVCaptureDevice *device = [self frontFacingCamera];
    //
    //    NSError *error;
    //    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    
}

- (AVCaptureDevice *)frontFacingCamera
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

- (AVCaptureDevice *)backCamera
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}
//- (IBAction)autoSharpeningAction:(id)sender {
//    if ([sender isOn]) {
//        lableMedium.textColor = [UIColor darkGrayColor];
//        lableLow.textColor = [UIColor darkGrayColor];
//        lableHigh.textColor = [UIColor darkGrayColor];
//        self.mSharpningSlider.userInteractionEnabled = NO;
//        [self.mSharpningSlider setValue:0.0];
//        [self.mSharpningSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
//        [self.mSharpningSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        lableMedium.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
//        lableLow.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
//        lableHigh.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
//        self.mSharpningSlider.userInteractionEnabled = YES;
//        [self.mSharpningSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
//        [self.mSharpningSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
//
//    }
//}
- (IBAction)autoExposureAction:(id)sender {
    if ([sender isOn]) {
        autoISOSwitch.userInteractionEnabled = NO;
        [autoISOSwitch setOn:NO];
        self.exposureDurationSlider.userInteractionEnabled = NO;
        self.ISOSlider.userInteractionEnabled = NO;
//        [self.exposureDurationSlider setValue:0.0];
//        [self.mExposureMaxLable setText: @"0"];
        [videoCamera.inputCamera lockForConfiguration:nil];
//        [videoCamera.inputCamera setExposureTargetBias:[self.mExposureMaxLable.text floatValue] completionHandler:nil];
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeLocked];
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeAutoExpose];
        [videoCamera.inputCamera unlockForConfiguration];
//        self.mExposureMaxLable.textColor = [UIColor darkGrayColor];
//        lableEight.textColor = [UIColor darkGrayColor];
//        lableNegitiveEight.textColor = [UIColor darkGrayColor];
        [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
        [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
        
        [self.ISOSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
        [self.ISOSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
    }
    else{
        autoISOSwitch.userInteractionEnabled = YES;
        self.exposureDurationSlider.userInteractionEnabled = YES;
         self.ISOSlider.userInteractionEnabled = YES;
        [videoCamera.inputCamera lockForConfiguration:nil];
        [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeCustom];
//        [videoCamera.inputCamera setExposureTargetBias:[self.mExposureMaxLable.text floatValue] completionHandler:nil];
        [videoCamera.inputCamera unlockForConfiguration];
//        self.mExposureMaxLable.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
//        lableEight.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
//        lableNegitiveEight.textColor = [UIColor colorWithRed:154/255.0 green:154/255.0 blue:154/255.0 alpha:1];
        [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
        [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
        [self.ISOSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
        [self.ISOSlider  setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)autoWhiteBalanceAction:(id)sender {
    if ([sender isOn]) {
        [tempratureSlider setUserInteractionEnabled:NO];
        [videoCamera.inputCamera lockForConfiguration:nil];
        [videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
        [videoCamera.inputCamera unlockForConfiguration];
        [tempratureSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
        [tempratureSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
    }
    else
    {
        [tempratureSlider setUserInteractionEnabled:YES];
        [videoCamera.inputCamera lockForConfiguration:nil];
        [videoCamera.inputCamera setWhiteBalanceMode:AVCaptureWhiteBalanceModeLocked];
        [videoCamera.inputCamera unlockForConfiguration];
        [tempratureSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
        [tempratureSlider  setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)autoISOSwitchChanged:(id)sender {
    if (autoISOSwitch.isOn) {
        self.exposureDurationSlider.userInteractionEnabled = NO;
        self.ISOSlider.userInteractionEnabled = NO;
        [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
        [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
        
        [self.ISOSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
        [self.ISOSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
    }
    else{
        self.exposureDurationSlider.userInteractionEnabled = YES;
        self.ISOSlider.userInteractionEnabled = YES;
        [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
        [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
        [self.ISOSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
        [self.ISOSlider  setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
    }
}

-(void)setUpCameraForVideo{
    [videoCamera.inputCamera lockForConfiguration:nil];
    videoCamera.captureSessionPreset = AVCaptureSessionPreset640x480;
    videoCamera.captureSession.usesApplicationAudioSession = true;
    videoCamera.captureSession.automaticallyConfiguresApplicationAudioSession = true;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [videoCamera.inputCamera unlockForConfiguration];
    [videoCamera startCameraCapture];
}
//- (void)cameraViewTapAction:(UITapGestureRecognizer *)tgr
//{
//    if (tgr.state == UIGestureRecognizerStateRecognized) {
//        CGPoint location = [tgr locationInView:self.cameraView];
//        if ([videoCamera.inputCamera isFocusPointOfInterestSupported] && [videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
//            NSError *error;
//            if ([videoCamera.inputCamera lockForConfiguration:&error]) {
//                [videoCamera.inputCamera setFocusPointOfInterest:location];
//                [videoCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
//                [videoCamera.inputCamera setExposurePointOfInterest:location];
//                [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeAutoExpose];
//                [videoCamera.inputCamera unlockForConfiguration];
//            }
//        }
////        if ([videoCamera.inputCamera isFocusPointOfInterestSupported] && [videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus])
////        {
////            NSError *error;
////            if ([videoCamera.inputCamera lockForConfiguration:&error]) {
////                [videoCamera.inputCamera setFocusPointOfInterest:location];
////                [videoCamera.inputCamera setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
////                [videoCamera.inputCamera setExposurePointOfInterest:location];
////                [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
////                [videoCamera.inputCamera unlockForConfiguration];
////            }
////        }
//    }
//}

-(void)cameraViewTapAction:(UITapGestureRecognizer *)tgr
{
    if([gifButton isEnabled])
    {
    if (tgr.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [tgr locationInView:self.cameraView];
        
        AVCaptureDevice *device = videoCamera.inputCamera;
        CGPoint pointOfInterest = CGPointMake(.5f, .5f);
        //        NSLog(@"taplocation x = %f y = %f", location.x, location.y);
        CGSize frameSize = [[self cameraView] frame].size;
        
        if ([videoCamera cameraPosition] == AVCaptureDevicePositionFront) {
            location.x = frameSize.width - location.x;
        }
        
        pointOfInterest = CGPointMake(location.y / frameSize.height, 1.f - (location.x / frameSize.width));
        
        
        if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                [device setFocusPointOfInterest:pointOfInterest];
                [device setFocusMode:AVCaptureFocusModeAutoFocus];
                touchView.hidden = YES;
                //                    [touchView removeFromSuperview];
                //                    [UIView beginAnimations:nil context:NULL];
                //                    [UIView setAnimationBeginsFromCurrentState:YES];
                //                    [UIView setAnimationDuration:0.1];
                //                    [UIView setAnimationCurve: UIViewAnimationCurveLinear];
                //                    [self.view.layer removeAllAnimations];
                //                    [UIView commitAnimations];
                touchView = [[UIView alloc] init];
                [touchView setBackgroundColor:[UIColor clearColor]];
                touchView.frame = CGRectMake(location.x-75, location.y-75, 150, 150);
                touchView.layer.borderColor = [UIColor yellowColor].CGColor;
                touchView.layer.borderWidth = 1.0f;
                [self.view addSubview:touchView];
                [UIView animateWithDuration:0.1 delay:0.2 options:0 animations:^{
                    touchView.frame = CGRectMake(location.x-50, location.y-50, 100, 100);
                }completion:^(BOOL finished) {
                    touchView.frame = CGRectMake(location.x-50, location.y-50, 100, 100);
                    //                    touchView.hidden = YES;
                    //                    [touchView removeFromSuperview];
                }];
                [UIView animateWithDuration:0.3 delay:1 options:0 animations:^{
                    touchView.alpha = 0;
                } completion:^(BOOL finished) {
                    touchView.hidden = YES;
                    //                        [touchView removeFromSuperview];
                }];
                
                if([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure])
                {
                    [device setExposurePointOfInterest:pointOfInterest];
                     if(segementView.selectedSegmentIndex == 0){
                         [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                     }
                }
                
                [device unlockForConfiguration];
                
                //                NSLog(@"FOCUS OK");
            } else {
                NSLog(@"ERROR = %@", error);
            }
        }
    }
    }
}

#pragma mark- Util Method

-(void)getQueueCount{
    offlineData = [[NSMutableArray alloc]initWithArray:[USER_DEFAULTS  valueForKey:[[USER_DEFAULTS valueForKey:@"user_information"] valueForKey:@"event_id"]] copyItems:YES];
    NSMutableArray * temp = [delegateObj.offlineData copy];
    for (int index = 0; index< temp.count; index++) {
        if ([[[temp objectAtIndex:index] valueForKey:@"event_id"] isEqualToString:[[USER_DEFAULTS valueForKey:@"user_information"] valueForKey:@"event_id"]]) {
            [offlineData addObject:[temp objectAtIndex:index]];
        }
    }
    [delegateObj.offlineData removeObjectsInArray:offlineData];
    [USER_DEFAULTS setValue:offlineData forKey:[[USER_DEFAULTS valueForKey:@"user_information"] valueForKey:@"event_id"]];
    [USER_DEFAULTS setValue:delegateObj.offlineData forKey:@"offlineData"];
    NSString *value = [@(offlineData.count) stringValue];
    [self.queueCountBtn setTitle: [NSString stringWithFormat:@"Q U E U E D :  %@",[self addSpace:value]]forState:UIControlStateNormal];
    
}
-(NSString *) addSpace:(NSString *)value
{
    NSMutableString *spacedString = [[NSMutableString alloc]init];
    for (int i = 0; i<[value length]; i++)
    {
        NSString *val = [NSString stringWithFormat:@"%c ",[value characterAtIndex:i]];
        [spacedString appendString:val];
    }
    return (NSString *)spacedString;
}

-(void)popupImage
{
        self.mTimerView.hidden = YES;
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height )];
        self.blackView.backgroundColor = [UIColor whiteColor];
    //    [[[UIApplication sharedApplication] keyWindow] addSubview:self.blackView];
        self.blackView.hidden = NO;
        self.blackView.alpha = 1.0f;
        // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
        [UIView animateWithDuration:0.5 delay:0.1 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.blackView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
    //        [[[UIApplication sharedApplication] keyWindow]removeFromSuperview];
            self.blackView.hidden = NO;
        }];
    self.mTimerView.hidden = NO;
}

-(void)popupWhiteImage{
    self.mTimerView.hidden = YES;
    //        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height )];
    self.blackView.backgroundColor = [UIColor whiteColor];
    //    [[[UIApplication sharedApplication] keyWindow] addSubview:self.blackView];
    self.blackView.hidden = NO;
    self.blackView.alpha = 0.5f;
    // Then fades it away after 2 seconds (the cross-fade animation will take 0.5s)
    [UIView animateWithDuration:0.1 delay:0.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        self.blackView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        //        [[[UIApplication sharedApplication] keyWindow]removeFromSuperview];
        self.blackView.hidden = NO;
    }];
    self.mTimerView.hidden = NO;

}
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    if (!faceThinking) {
        CFAllocatorRef allocator = CFAllocatorGetDefault();
        CMSampleBufferRef sbufCopyOut;
        CMSampleBufferCreateCopy(allocator,sampleBuffer,&sbufCopyOut);
        [self performSelectorInBackground:@selector(grepFacesForSampleBuffer:) withObject:CFBridgingRelease(sbufCopyOut)];
    }
}

- (void)grepFacesForSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    faceThinking = TRUE;
    NSLog(@"Faces thinking");
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    
    if (attachments)
        CFRelease(attachments);
    NSDictionary *imageOptions = nil;
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    int exifOrientation;
    
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    BOOL isUsingFrontFacingCamera = FALSE;
    AVCaptureDevicePosition currentCameraPosition = [videoCamera cameraPosition];
    if (currentCameraPosition != AVCaptureDevicePositionBack)
    {
        isUsingFrontFacingCamera = TRUE;
    }
    
    switch (curDeviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
            exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
            break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
            if (isUsingFrontFacingCamera)
                exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
            else
                exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
            break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
            exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
            break;
    }
    
    imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
    
    NSLog(@"Face Detector %@", [self.faceDetector description]);
    NSLog(@"converted Image %@", [convertedImage description]);
//    convertedImage = [convertedImage imageByApplyingTransform:CGAffineTransformTranslate(CGAffineTransformMakeScale(1, -1), 0, convertedImage.extent.size.height)];
    NSArray *features = [self.faceDetector featuresInImage:convertedImage options:imageOptions];
    
    
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
    
    
    [self GPUVCWillOutputFeatures:features forClap:clap andOrientation:curDeviceOrientation];
    faceThinking = FALSE;
    
}

- (void)GPUVCWillOutputFeatures:(NSArray*)featureArray forClap:(CGRect)clap
                 andOrientation:(UIDeviceOrientation)curDeviceOrientation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Did receive array");
//        [cameraView setTransform:CGAffineTransformMakeScale(-1, 1)];
        CGRect previewBox = self.view.frame;
        
        if (featureArray == nil && faceView) {
            [faceView removeFromSuperview];
            faceView = nil;
        }
        
        
        for ( CIFaceFeature *faceFeature in featureArray) {
            
            // find the correct position for the square layer within the previewLayer
            // the feature box originates in the bottom left of the video frame.
            // (Bottom right if mirroring is turned on)
            NSLog(@"%@", NSStringFromCGRect([faceFeature bounds]));
            
            //Update face bounds for iOS Coordinate System
            CGRect faceRect;
            if (self.cameraPosition == 1){
                
                CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
                transform = CGAffineTransformTranslate(transform,
                                                       0, -self.cameraView.bounds.size.width-180);
                faceRect = CGRectApplyAffineTransform(faceFeature.bounds, transform);

            }
            else
            {
                faceRect = [faceFeature bounds];
            }
            
            // flip preview width and height
            CGFloat temp;
            temp = faceRect.size.width;
            faceRect.size.width = faceRect.size.height;
            faceRect.size.height = temp;
            temp = faceRect.origin.x;
            faceRect.origin.x = faceRect.origin.y;
            faceRect.origin.y = temp;
            // scale coordinates so they fit in the preview box, which may be scaled
            CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
            CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
            faceRect.size.width *= widthScaleBy;
            faceRect.size.height *= heightScaleBy;
            faceRect.origin.x *= widthScaleBy;
//            faceRect.origin.x = (previewBox.size.width*widthScaleBy - faceRect.origin.x);
            faceRect.origin.y *= heightScaleBy;
            faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
            if (faceView) {
                [faceView removeFromSuperview];
                faceView =  nil;
            }
            
            // create a UIView using the bounds of the face
            faceView = [[UIView alloc] initWithFrame:faceRect];
            
            // add a border around the newly created UIView
            faceView.layer.borderWidth = 1;
            faceView.layer.borderColor = [[UIColor redColor] CGColor];
            
            // add the new view to create a box around the face
            [self.view addSubview:faceView];
            
        }
    });
    
}
- (IBAction)shutterSpeedButton:(id)sender {
    [self setShutterSpeed:60];
}

static const float kExposureMinimumDuration = 1.0/1000; // Limit exposure duration to a useful range

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    isChangeShutter = YES;
//    id oldValue = change[NSKeyValueChangeOldKey];
    id newValue = change[NSKeyValueChangeNewKey];
    if ( context == ExposureDurationContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            double newDurationSeconds = CMTimeGetSeconds( [newValue CMTimeValue] );
            if ( segementView.selectedSegmentIndex == 0) {
                double minDurationSeconds = MAX( CMTimeGetSeconds( videoCamera.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
                double maxDurationSeconds = CMTimeGetSeconds( videoCamera.inputCamera.activeFormat.maxExposureDuration );
                // Map from duration to non-linear UI range 0-1
                double p = ( newDurationSeconds - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds ); // Scale to 0-1
                self.exposureDurationSlider.value = pow( p, 1 / kExposureDurationPower ); // Apply inverse power
                
                if ( newDurationSeconds < 1 ) {
                    int digits = MAX( 0, 2 + floor( log10( newDurationSeconds ) ) );
                    self.exposureDurationValueLabel.text = [ NSString stringWithFormat:@"1/%.*f", digits, 1/newDurationSeconds];
                   
                }
                else {
                    self.exposureDurationValueLabel.text = [NSString stringWithFormat:@"%.2f", newDurationSeconds];
                }
            }
        }
    }
    else if ( context == ISOContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            float newISO = [newValue floatValue];
            
            if ( videoCamera.inputCamera.exposureMode != AVCaptureExposureModeCustom ) {
                self.ISOSlider.value = newISO;
            }
            self.ISOValueLabel.text = [NSString stringWithFormat:@"%i", (int)newISO];
        }
    }
    else if ( context == DeviceWhiteBalanceGainsContext ) {
        if ( newValue && newValue != [NSNull null] ) {
            AVCaptureWhiteBalanceGains newGains;
            [newValue getValue:&newGains];
            AVCaptureWhiteBalanceTemperatureAndTintValues newTemperatureAndTint = [videoCamera.inputCamera temperatureAndTintValuesForDeviceWhiteBalanceGains:newGains];
            
            if ( videoCamera.inputCamera.whiteBalanceMode != AVCaptureExposureModeLocked ) {
                for (int i = 0; i<temperatureArray.count; i++) {
                    if([temperatureArray[i] floatValue] > newTemperatureAndTint.temperature)
                    {
                        self.tempratureSlider.value = i;
                        break;
                    }
                }
//                self.tempratureSlider.value = newTemperatureAndTint.temperature;
                temperature = newTemperatureAndTint.tint;
            }
            float temp = newTemperatureAndTint.temperature/10;
            self.temperatureLable.text = [NSString stringWithFormat:@"%i", (int)round(temp)*10];
//            self.tintValueLabel.text = [NSString stringWithFormat:@"%i", (int)newTemperatureAndTint.tint];
        }
    }
    else if (context == ExposureTargetOffsetContext){
//        NSLog(@"%@, %@",_ISOValueLabel.text,exposureDurationValueLabel.text);
        newExposureTargetOffset = [change[NSKeyValueChangeNewKey] floatValue];
        if(segementView.selectedSegmentIndex == 1)
        {
        if(!videoCamera.inputCamera) return;
            double p = pow( exposureDurationSlider.value, kExposureDurationPower ); // Apply power function to expand slider's low-end range
            
            double minDurationSeconds = MAX( CMTimeGetSeconds( videoCamera.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
            
            double maxDurationSeconds = CMTimeGetSeconds( videoCamera.inputCamera.activeFormat.maxExposureDuration );
            
            double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds; // Scale from 0-1 slider range to actual duration
            
            
            
            if ( videoCamera.inputCamera.exposureMode == AVCaptureExposureModeCustom ) {
                
                if ( newDurationSeconds < 1 ) {
                    
                    int digits = MAX( 0, 2 + floor( log10( newDurationSeconds ) ) );
                    
                    self.exposureDurationValueLabel.text = [NSString stringWithFormat:@"1/%.*f", digits, 1/newDurationSeconds];
                    
                }
                
                else {
                    
                    self.exposureDurationValueLabel.text = [NSString stringWithFormat:@"%.2f", newDurationSeconds];
                    
                }
                
            }
            CGFloat currentISO = videoCamera.inputCamera.ISO;
        CGFloat biasISO = 0;
        
        //Assume 0,3 as our limit to correct the ISO
        if (newExposureTargetOffset > 0.7f)
        {
            biasISO = -50;
            CGFloat newISO = currentISO+biasISO;
            newISO = newISO > videoCamera.inputCamera.activeFormat.maxISO? videoCamera.inputCamera.activeFormat.maxISO : newISO;
            newISO = newISO < videoCamera.inputCamera.activeFormat.minISO? videoCamera.inputCamera.activeFormat.minISO : newISO;
            NSError *error = nil;
            if ( [videoCamera.inputCamera lockForConfiguration:&error] ) {
                [videoCamera.inputCamera setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:newISO completionHandler:nil];
                [videoCamera.inputCamera unlockForConfiguration];
                self.ISOSlider.value = newISO;
            }
            else {
                NSLog( @"Could not lock device for configuration: %@", error );
            }

        }
//        else if(newExposureTargetOffset > 0.1f) //decrease ISO
//            biasISO = -1;
        else if(newExposureTargetOffset < -0.7f)
        {
            biasISO = 50;
            CGFloat newISO = currentISO+biasISO;
            newISO = newISO > videoCamera.inputCamera.activeFormat.maxISO? videoCamera.inputCamera.activeFormat.maxISO : newISO;
            newISO = newISO < videoCamera.inputCamera.activeFormat.minISO? videoCamera.inputCamera.activeFormat.minISO : newISO;
            NSError *error = nil;
            if ( [videoCamera.inputCamera lockForConfiguration:&error] ) {
                [videoCamera.inputCamera setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:newISO completionHandler:nil];
                [videoCamera.inputCamera unlockForConfiguration];
                self.ISOSlider.value = newISO;
            }
            else {
                NSLog( @"Could not lock device for configuration: %@", error );
            }
        }
//        else if(newExposureTargetOffset < -0.1f) //increase ISO
//            biasISO = 1;
        
        //    if(biasISO){
        //Normalize ISO level for the current device
        }
    }

}
- (IBAction)changeExposureDuration:(id)sender
{
    
//    float newExposureTargetOffset = [change[NSKeyValueChangeNewKey] floatValue];
//    NSLog(@"Offset is : %f",newExposureTargetOffset);
    
    if(!videoCamera.inputCamera) return;
    
    CGFloat currentISO = videoCamera.inputCamera.ISO;
    CGFloat biasISO = 0;
    
    //Assume 0,3 as our limit to correct the ISO
    if(newExposureTargetOffset > 0.3f) //decrease ISO
        biasISO = -50;
    else if(newExposureTargetOffset < -0.3f) //increase ISO
        biasISO = 50;
    
//    if(biasISO){
        //Normalize ISO level for the current device
        CGFloat newISO = currentISO+biasISO;
        newISO = newISO > videoCamera.inputCamera.activeFormat.maxISO? videoCamera.inputCamera.activeFormat.maxISO : newISO;
        newISO = newISO < videoCamera.inputCamera.activeFormat.minISO? videoCamera.inputCamera.activeFormat.minISO : newISO;
    UISlider *control = sender;
    NSError *error = nil;
    
    double p = pow( control.value, kExposureDurationPower ); // Apply power function to expand slider's low-end range
    double minDurationSeconds = MAX( CMTimeGetSeconds( videoCamera.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
    double maxDurationSeconds = CMTimeGetSeconds( videoCamera.inputCamera.activeFormat.maxExposureDuration );
    double newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds; // Scale from 0-1 slider range to actual duration
    
    if ( videoCamera.inputCamera.exposureMode == AVCaptureExposureModeCustom ) {
        if ( newDurationSeconds < 1 ) {
            int digits = MAX( 0, 2 + floor( log10( newDurationSeconds ) ) );
            self.exposureDurationValueLabel.text = [NSString stringWithFormat:@"1/%.*f", digits, 1/newDurationSeconds];
        }
        else {
            self.exposureDurationValueLabel.text = [NSString stringWithFormat:@"%.2f", newDurationSeconds];
        }
    }
    
    if ( [videoCamera.inputCamera lockForConfiguration:&error] ) {
        if (segementView.selectedSegmentIndex == 2) {
             [videoCamera.inputCamera setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:currentISO completionHandler:nil];
            [videoCamera.inputCamera unlockForConfiguration];
        }
        else{
        [videoCamera.inputCamera setExposureModeCustomWithDuration:CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )  ISO:newISO completionHandler:nil];
            self.ISOSlider.value = newISO;
        }
           }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
//}
}
- (IBAction)changeISO:(id)sender {
    UISlider *control = sender;
    NSError *error = nil;
    
    if ( [videoCamera.inputCamera lockForConfiguration:&error] ) {
        [videoCamera.inputCamera setExposureModeCustomWithDuration:AVCaptureExposureDurationCurrent ISO:control.value completionHandler:nil];
        [videoCamera.inputCamera unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }
}
- (IBAction)changeTemperature:(id)sender {
    NSUInteger index = (NSUInteger)(tempratureSlider.value + 0.5);
    [tempratureSlider setValue:index animated:NO];
    float number = [temperatureArray[index] floatValue]; // <-- This numeric value you want
    NSLog(@"sliderIndex: %f", (float)index);
    NSLog(@"number: %f", number);
      NSError *error = nil;
    if ( [videoCamera.inputCamera lockForConfiguration:&error] ) {
            AVCaptureWhiteBalanceTemperatureAndTintValues temperatureAndTint = {
            .temperature = number,
            .tint = temperature,
        };
        
        [self setWhiteBalanceGains:[videoCamera.inputCamera deviceWhiteBalanceGainsForTemperatureAndTintValues:temperatureAndTint]];
        [videoCamera.inputCamera unlockForConfiguration];
    }
    else {
        NSLog( @"Could not lock device for configuration: %@", error );
    }

}


- (void)configureSlider{
//    self.temperatureSlider.enabled = ( self.videoDevice && self.videoDevice.whiteBalanceMode == AVCaptureWhiteBalanceModeLocked );
    self.exposureDurationSlider.minimumValue = 0;
    self.exposureDurationSlider.maximumValue = 0.579;
//    self.exposureDurationSlider.enabled = ( videoCamera.inputCamera && videoCamera.inputCamera.exposureMode == AVCaptureExposureModeCustom );
    
    self.ISOSlider.minimumValue = videoCamera.inputCamera.activeFormat.minISO;
    self.ISOSlider.maximumValue = videoCamera.inputCamera.activeFormat.maxISO;
//    self.ISOSlider.enabled = ( videoCamera.inputCamera.exposureMode == AVCaptureExposureModeCustom );
//    self.tempratureSlider.minimumValue = 2013;
//    self.tempratureSlider.maximumValue = 8000;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 2010; i<=8000; i+=10) {
        [array addObject:FBOX(i)];
    }
    temperatureArray = array;
    
    // slider values go from 0 to the number of values in your numbers array
    NSInteger numberOfSteps = ((float)[temperatureArray count] - 1);
    tempratureSlider.maximumValue = numberOfSteps;
    tempratureSlider.minimumValue = 0;
    
    // As the slider moves it will continously call the -valueChanged:
    tempratureSlider.continuous = YES; // NO makes it call only once you let go
    [tempratureSlider addTarget:self
               action:@selector(changeTemperature:)
     forControlEvents:UIControlEventValueChanged];
    [self setAutoMode];
}

- (void) setAutoMode {
    [segementView setSelectedSegmentIndex:1];
    [self performSelector:@selector(segementValueChanged:) withObject:segementView];
//    [autoExposureSwitch setOn:YES];
    [autoWhiteBalanceSwitch setOn:YES];
    [autoISOSwitch setOn:NO];
//    [self performSelector:@selector(autoExposureAction:) withObject:autoExposureSwitch];
    [self performSelector:@selector(autoWhiteBalanceAction:) withObject:autoWhiteBalanceSwitch];
}

- (IBAction)segementValueChanged:(id)sender {
    
    switch (segementView.selectedSegmentIndex) {
            
        case 0:
//            autoISOSwitch.userInteractionEnabled = NO;
//            [autoISOSwitch setOn:NO];
            self.exposureDurationSlider.userInteractionEnabled = NO;
            self.ISOSlider.userInteractionEnabled = NO;
            [videoCamera.inputCamera lockForConfiguration:nil];
            [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeLocked];
            [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
            [videoCamera.inputCamera unlockForConfiguration];
            [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
            [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
            [self.ISOSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
            [self.ISOSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
            break;
            
            
        case 1:
            [self setShutterSpeed:60];
            self.exposureDurationSlider.userInteractionEnabled = YES;
            self.ISOSlider.userInteractionEnabled = NO;
            [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
             [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
            [self.ISOSlider setThumbImage:[UIImage imageNamed:@"thumDisable.png"] forState:UIControlStateNormal];
            [self.ISOSlider setMinimumTrackImage:[UIImage imageNamed:@"sliderDisable.png"] forState:UIControlStateNormal];
            break;
            
            
        case 2:
            autoISOSwitch.userInteractionEnabled = YES;
            self.exposureDurationSlider.userInteractionEnabled = YES;
            self.ISOSlider.userInteractionEnabled = YES;
            [videoCamera.inputCamera lockForConfiguration:nil];
            [videoCamera.inputCamera setExposureMode:AVCaptureExposureModeCustom];
            [videoCamera.inputCamera unlockForConfiguration];
            [self.exposureDurationSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
            [self.exposureDurationSlider setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
            [self.ISOSlider setThumbImage:[UIImage imageNamed:@"Eclipse.png"] forState:UIControlStateNormal];
            [self.ISOSlider  setMinimumTrackImage:[UIImage imageNamed:@"Slider_3.png"] forState:UIControlStateNormal];
            break;
        default:

            break;
    }

}

-(void)setShutterSpeed:(int)value{
    exposureDurationValueLabel.text = @"1/60";
    NSMutableString *dsata = [[NSMutableString alloc]initWithString:@"1/60"];
    [dsata insertString:@".0" atIndex:1];
    [dsata insertString:@".0" atIndex:dsata.length];
    double newDurationSeconds = [[dsata substringToIndex:3] floatValue]/[[dsata substringFromIndex:4] floatValue];
    double minDurationSeconds = MAX( CMTimeGetSeconds( videoCamera.inputCamera.activeFormat.minExposureDuration ), kExposureMinimumDuration );
    double maxDurationSeconds = CMTimeGetSeconds( videoCamera.inputCamera.activeFormat.maxExposureDuration );
    // Map from duration to non-linear UI range 0-1
    double p = ( newDurationSeconds - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds ); // Scale to 0-1
    self.exposureDurationSlider.value = pow( p, 1 / kExposureDurationPower ); // Apply inverse power
    
    if ( newDurationSeconds < 1 ) {
        int digits = MAX( 0, 2 + floor( log10( newDurationSeconds ) ) );
        self.exposureDurationValueLabel.text = [NSString stringWithFormat:@"1/%.*f", digits, 1/newDurationSeconds];
    }
}
#pragma marks - GifMaker

 
-(void)gifMaker{
    NSLog(@"gifmaker called");
    count = 0;

    photoTimer = [NSTimer scheduledTimerWithTimeInterval:0.115 target:self selector:@selector (getClickedImage) userInfo:nil repeats:YES];
    
}

-(void )getClickedImage{
    NSLog(@"getclickedImageCalled");
    if ([[videoCamera.targets objectAtIndex:0] isKindOfClass:[GPUImageGrayscaleFilter class]]) {
        [videoCamera capturePhotoAsImageProcessedUpToFilter:_grayScaleFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            [self performSelector:@selector(popupWhiteImage) withObject:nil afterDelay:0.0f];
            [gifImage addObject:processedImage];
            count ++;
            if (count > 10) {
                NSLog(@"phototimerover");
                [photoTimer invalidate];
            }
            
        }];

    }
    else{
        [videoCamera capturePhotoAsImageProcessedUpToFilter:_filter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
            [self performSelector:@selector(popupWhiteImage) withObject:nil afterDelay:0.0f];
            [gifImage addObject:processedImage];
            count ++;
            if (count > 10) {
                NSLog(@"phototimerover");
                [photoTimer invalidate];
            }
            
        }];

    }
}

- (IBAction)gifButtonAction:(id)sender {
    gifButton.enabled = NO;
    self.mBottomBarView.hidden = YES;
    NSLog(@"button clicked");
        if (_cameraPosition == 2) {
    NSError *error;
                videoCamera.captureSessionPreset = AVCaptureSessionPreset640x480;
                if ([videoCamera.inputCamera lockForConfiguration:&error]) {
                    [videoCamera.inputCamera setFocusMode:AVCaptureFocusModeLocked];
                    [videoCamera.inputCamera unlockForConfiguration];
                }
        }
    [self performSelector:@selector(gifMaker) withObject:nil afterDelay:0.7];
//    [self gifMaker];
    [self performSelector:@selector(makeVideo) withObject:nil afterDelay:2.3];
   NSLog(@"button end");
}
-(void)makeVideo
{
    gifButton.enabled = YES;
    self.mBottomBarView.hidden = NO;
    NSLog(@"makeVideoCalled");
    UIImage *image = [gifImage objectAtIndex:0];
    NSDictionary *settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:image.size.width andHeight:image.size.height];
    self.movieMaker = [[CEMovieMaker alloc] initWithSettings:settings];
    NSMutableArray *reverseArray = [[NSMutableArray alloc]init];
    for (int i = (int)gifImage.count-1; i>=0; i--) {
        [reverseArray addObject:[gifImage objectAtIndex:i]];
    }
    [gifImage addObjectsFromArray:reverseArray];
    [gifImage addObjectsFromArray:gifImage];
    [gifImage addObjectsFromArray:gifImage];
    //    [gifImage addObjectsFromArray:gifImage];
    [self.movieMaker createMovieFromImages:[gifImage copy] withCompletion:^(NSURL *fileURL){
        NSString *music_enabled = [Helper getUserInfoValueForKey:@"music_enabled"];
        NSString *audioStr = [Helper getUserInfoValueForKey:@"music"];
        if([music_enabled isEqualToString:@"1"]&&![audioStr isEqualToString:@""])
        {
            NSString *audio = [Helper getDirectoryFilePath:@"sbaudio.mp3"];
            NSString *video = [Helper getDirectoryFilePath:kBoomerangGifName];
            [self mergeAudio:audio toVideo:video savetoPath:kBoomerangGifName withCompletionHandler:^(BOOL finished) {
                ImageClickedVC *vcObj = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageClickedVC"];
                vcObj.gifUrl = fileURL;
                vcObj.activeMediaCount = self.optionsCount;
                vcObj.mediaType = self.choosenMediaType;
                [UIView animateWithDuration:0.75
                                 animations:^{
                                     [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                                     [self.navigationController pushViewController:vcObj animated:NO];
                                     
                                 }];
                //        [self viewMovieAtUrl:fileURL];
                [gifImage removeAllObjects];
            }];
        }
        else{
            ImageClickedVC *vcObj = [self.storyboard instantiateViewControllerWithIdentifier:@"ImageClickedVC"];
            vcObj.gifUrl = fileURL;
            vcObj.activeMediaCount = self.optionsCount;
            vcObj.mediaType = self.choosenMediaType;
            [UIView animateWithDuration:0.75
                             animations:^{
                                 [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                                 [self.navigationController pushViewController:vcObj animated:NO];
                                 
                             }];
            //        [self viewMovieAtUrl:fileURL];
            [gifImage removeAllObjects];
        }
    }];
}
     
- (void)viewMovieAtUrl:(NSURL *)fileURL
{
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [playerController.view setFrame:self.view.bounds];
    [self presentMoviePlayerViewControllerAnimated:playerController];
    [playerController.moviePlayer prepareToPlay];
    [playerController.moviePlayer play];
    playerController.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    [self.view addSubview:playerController.view];
}

-(void)mergeAudio:(NSString *)audioPath toVideo:(NSString *)videoPath savetoPath:(NSString *)filePath withCompletionHandler:(void (^)(BOOL finished))completion
{
    AVURLAsset* videoAsset;
    AVURLAsset* audioAsset;
    
    AVMutableComposition* mixComposition = [AVMutableComposition composition];
    
    NSURL *video_url = [NSURL fileURLWithPath:videoPath];
    videoAsset = [[AVURLAsset alloc]initWithURL:video_url options:nil];
    CMTimeRange video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    
    AVMutableCompositionTrack *a_compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [a_compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    NSURL *audio_url = [NSURL fileURLWithPath:audioPath];
    audioAsset = [[AVURLAsset alloc]initWithURL:audio_url options:nil];
    CMTimeRange audio_timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    
    AVMutableCompositionTrack *b_compositionAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [b_compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", filePath]];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath]){
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    }
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         dispatch_async(dispatch_get_main_queue(), ^{
             // Do export finish stuff
             NSLog(@"done");
             completion(YES);
         });
     }];
}
@end
