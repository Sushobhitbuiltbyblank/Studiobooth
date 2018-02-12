//
//  ImageClickedVC.m
//  StudioBooth
//
//  Created by Bhupinder Verma on 08/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import "ImageClickedVC.h"
#import "Base64.h"
#import "UIImage+animatedGIF.h"
#import "TIMERUIApplication.h"
#import "FLAnimatedImage.h"
#define kImgBtnFram [
#define kBtnColor [UIColor colorWithRed:54/255.0f green:54/255.0f blue:54/255.0f alpha:1.0]
#define kBtnOriginalColor [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.75]

@interface ImageClickedVC ()<MyCustomDelegate>
{
    BOOL shwoingShareView, showingEmailView, showingKeyBoardView;
    BOOL sharedAgain;
    NSString *time;
    NSString *uniqueName;
}

@end

@implementation ImageClickedVC


- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
    sharedAgain = false;
    id obj = [TIMERUIApplication sharedApplication];
    [obj resetIdleTimer];
    [super viewDidLoad];
    //add timer notification for logout the app user
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
    self.isServiceActive = NO;
    NSData *data = [USER_DEFAULTS dataForKey:@"overlay_image_data"];
    if ([[USER_DEFAULTS stringForKey:@"overlay_image_type"] isEqual:@"png"])
    {
            UIImage *img = [[UIImage alloc]initWithData:data ];
            self.overlayImg.image=img;
    }
    else
    {
        FLAnimatedImage *animatedImage1 = [FLAnimatedImage animatedImageWithGIFData:data];
        self.overlayImg.animatedImage = animatedImage1;
        NSString *overlayURL = [Helper getDirectoryFilePath:@"sblogoOverlay.png"];
        self.overlayPNGImg.image = [UIImage imageWithContentsOfFile:overlayURL];
    }
    
    self.ShareBGImageView.hidden = YES;
    delegateObj = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.sendEmailView.hidden = YES;
    self.thanksView.hidden = YES;
    self.keyboardView.hidden = YES;
    shwoingShareView = NO;
    showingEmailView = NO;
    showingKeyBoardView = NO;
//    self.mwebV.hidden = YES;
    self.player.view.hidden = YES;
    self.mShareBtn.hidden = NO;
    self.mShareView.hidden = NO;
    self.shareOptionView.hidden = NO;
    self.shareFillView.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self basicSetupForViews];
    
    [USER_DEFAULTS setBool:NO forKey:kAppHaveShareLink];
    [USER_DEFAULTS synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getTheMediaFileUploadResult:) name:kMediaUploadNotification object:nil];
    
    self.emailTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"E M A I L  A D D R E S S"
                                                                          attributes:@{
                                                                                       NSForegroundColorAttributeName : [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f]}];
    
    self.numberTF.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"P H O N E  N U M B E R"
                                                                          attributes:@{
                                                                                       NSForegroundColorAttributeName : [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f]}];
    
//    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(playerItemDidReachEnd:)
//                                                 name:AVPlayerItemDidPlayToEndTimeNotification
//                                               object:[self.avPlayer currentItem]];
    
    
//    
//    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
//    
//    // Setting the swipe direction.
//    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
//    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
//    
//    // Adding the swipe gesture on image view
//    [self.mImgview addGestureRecognizer:swipeLeft];
//    [self.mImgview addGestureRecognizer:swipeRight];
//    
//    [self.mImgview setUserInteractionEnabled:YES];

    
}
//- (void)playerItemDidReachEnd:(NSNotification *)notification {
//    AVPlayerItem *p = [notification object];
//    [p seekToTime:kCMTimeZero];
//}
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:delegateObj.offlineData forKey:@"offlineData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:YES];
    self.sendEmailView.hidden = NO;
    self.keyboardView.hidden = NO;
    double delayInSeconds = 0.4f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:1.0 animations:^{
            self.mTopBarView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.mTopBarView.frame.size.width, self.mTopBarView.frame.size.height);
        }];
    });
}

#pragma mark- Movie play methods

- (void)playMovieInPlayer {
    [self performSelector:@selector(setupMoviePlayer) withObject:self afterDelay:0.2];
 //   [self setupMoviePlayer];
//        self.mwebV.frame = CGRectMake(self.mImgview.frame.origin.x, self.mImgview.frame.origin.y, self.mImgview.frame.size.width, self.mImgview.frame.size.height);
        self.player.view.frame = self.mImgview.frame;

//    NSLog(@"%@", [NSURL URLWithString:[Helper getDirectoryFilePath:kVideofileName]]);
//    self.mwebV.opaque = YES;
//    self.mwebV.backgroundColor = [UIColor clearColor];
//    [self.mwebV loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[Helper getDirectoryFilePath:kVideofileName]]]];
}

-(void)setupMoviePlayer {
    CameraSettings *settingsobj = [CameraSettings fetchMatchingUser];
    if (_gifUrl != nil) {
         self.player = [[MPMoviePlayerController alloc] initWithContentURL:_gifUrl];
    }
   else
   {
        self.player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[Helper getDirectoryFilePath:kVideofileName]]];
   }
    self.player.repeatMode = MPMovieRepeatModeOne;
    if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
        self.player.view.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    self.player.view.frame = self.mImgview.frame;
    [self.view addSubview:self.player.view];
    self.player.controlStyle = MPMovieControlStyleNone;
    [self.player prepareToPlay];
    [self.player play];
    
    [self.view insertSubview:self.player.view aboveSubview:self.mImgview];
    
//    self.avPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[Helper getDirectoryFilePath:kVideofileName]]];
//    self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
//    
//    self.avPlayerLayer.frame = self.mImgview.layer.bounds;
//    [self.mImgview.layer addSublayer:self.avPlayerLayer];
//    if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
//                self.mImgview.transform = CGAffineTransformMakeScale(-1.0, 1.0);
//            }
//    [self.avPlayer play];
    
    
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


#pragma mark- Void methods

- (void)basicSetupForViews {
    if ([[Helper getUserInfoValueForKey:@"agreement_required"]  isEqual: @"0"]) {
        self.magreementCBBtn.hidden = true;
        self.msharedAgreementLable.text = @"T E R M S   &   C O N D I T I O N S";
        self.mAgreementLineAfterLable.hidden = true;
    }
    else{
        self.msharedAgreementLable.text = @"A C C E P T    T E R M S   &   C O N D I T I O N S";
    }
    if ([self.mediaType isEqualToString:@"gif"]){
        if (_gifUrl != nil) {
            self.player.view.hidden = NO;
            [self playMovieInPlayer];
        }
        else
        {
            [self playGIFfile];
        }
    }
    else if ([self.mediaType isEqualToString:@"photo"]) {
         CameraSettings *settingsobj = [CameraSettings fetchMatchingUser];
        if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
            self.mImgview.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
//        self.mImgview.image = self.clickedImage;
        GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:self.clickedImage];
        GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
        float val = [[NSString stringWithFormat:@"0.%@",self.sharpeningValue] floatValue];
        [sharpenFilter setSharpness:val*2];
        [imageSource addTarget:sharpenFilter];
        [imageSource processImage];
        [sharpenFilter useNextFrameForImageCapture];
        UIImage *outputImage = [sharpenFilter imageFromCurrentFramebuffer];
        
        GPUImagePicture *imageSourceforContrast = [[GPUImagePicture alloc] initWithImage:outputImage];
        GPUImageContrastFilter *contrastfilter =[[GPUImageContrastFilter alloc]init];
        if ([self.contrastValue integerValue]>1) {
            float val = [[NSString stringWithFormat:@"0.%@",self.contrastValue] floatValue];
            [contrastfilter setContrast:val+1-0.1];
        }
        else{
        [contrastfilter setContrast:[self.contrastValue integerValue]];
        }
        [imageSourceforContrast addTarget:contrastfilter];
        [imageSourceforContrast processImage];
        [contrastfilter useNextFrameForImageCapture];
        UIImage *outputImageWithContrast = [contrastfilter imageFromCurrentFramebuffer];
        self.mImgview.image = outputImageWithContrast;
        
       
        UIImage *image960x1280 =  [self imageWithImage:outputImageWithContrast scaledToSize:CGSizeMake(960.0,1280.0)];
        //compression Quality value
//        float compressionQuality = 0.8;
//        [Helper saveImageToDocumentsDirectory:image960x1280 withFileName:@"org.jpeg"];
//        CGRect rect = CGRectMake(0.0, 0.0, image960x1280.size.width, image960x1280.size.height);
//        UIGraphicsBeginImageContext(rect.size);
//        [image960x1280 drawInRect:rect];
//        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
//        NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
//        NSData *imageData50 = UIImageJPEGRepresentation(img, 0.5);
//        [Helper saveImageToDocumentsDirectory:[UIImage imageWithData:imageData50] withFileName:@"50percompress.jpeg"];
//        UIGraphicsEndImageContext();
//        image960x1280 = [UIImage imageWithData:imageData];
//        [Helper saveImageToDocumentsDirectory:image960x1280 withFileName:@"80percompress.jpeg"];
        [Helper deleteDocumentDirectoryFile:kImagefileName];
        [Helper saveImageToDocumentsDirectory:image960x1280 withFileName:kImagefileName];
    }
    else if ([self.mediaType isEqualToString:@"video"]) {
        
//        self.mwebV.hidden = YES;
//        if (![[USER_DEFAULTS stringForKey:@"overlay_image_type"] isEqual:@"png"])
//        {
//            self.overlayImg.hidden = YES;
//        }
        self.player.view.hidden = NO;
        [self playMovieInPlayer];
    }
    self.shareOptionView.frame = CGRectMake((self.view.frame.origin.x-self.shareOptionView.frame.size.width), self.shareOptionView.frame.origin.y, self.shareOptionView.frame.size.width, self.shareOptionView.frame.size.height);
    self.sendEmailView.frame = CGRectMake((self.view.frame.origin.x-self.sendEmailView.frame.size.width), (self.shareOptionView.frame.origin.y+self.shareOptionView.frame.size.height), self.sendEmailView.frame.size.width, self.sendEmailView.frame.size.height);
    self.keyboardView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.keyboardView.frame.size.width, self.keyboardView.frame.size.height);
    
    if (USERDEFAULTS(kAcceptAgreement)){
        self.acceptBtn.enabled = NO;
        [self.acceptBtn setTitle:@"✓ Agreement Accepted" forState:UIControlStateNormal];
    }

    NSString *agreementmessagestr = [Helper getUserInfoValueForKey:@"agreements_message"];
    self.magreementTV.text = agreementmessagestr;
    self.magreementTV.font = [UIFont fontWithName:@"Helvetica Light" size:18];
    self.magreementTV.textColor = [UIColor whiteColor];
    self.magreementTV.textAlignment = NSTextAlignmentCenter;
    if ([[Helper getUserInfoValueForKey:kAppEmailAllowedKey] isEqualToString:@"1"]){
        self.memailBtn.enabled = YES;
    }
    else{
        self.memailBtn.enabled = NO;
    }
    if ([[Helper getUserInfoValueForKey:kAppSMSAllowedKey] isEqualToString:@"1"]){
        self.memailBtn.enabled = YES;
    }
    else{
        self.memailBtn.enabled = NO;
    }
    
    if ([self.mediaType isEqualToString:@"photo"]){
        self.mShareBtn.hidden = YES;
        self.mCancelBtn.hidden = YES;
        self.mTopViewCancel.hidden = YES;
        self.mTopViewCenter.hidden = YES;
        self.mShareView.hidden = YES;
        [self performSelector:@selector(showTopView) withObject:nil afterDelay:1.];
    }
}

- (void)showTopView {
    self.mShareBtn.hidden = NO;
    self.mCancelBtn.hidden = NO;
    self.mTopViewCancel.hidden = NO;
    self.mTopViewCenter.hidden = NO;
    self.mShareView.hidden = NO;
}

- (void)playGIFfile {
    CameraSettings *settingsobj = [CameraSettings fetchMatchingUser];
    UIImage *mygifImage = [UIImage animatedImageWithAnimatedGIFURL:[Helper createAnimatedGif:self.gifImgsArray]];
    if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
        self.mImgview.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    self.mImgview.image= mygifImage;
}

-(void)showHideKeyboardView {
    
    [UIView animateWithDuration:0.3 animations:^{
        if (showingKeyBoardView == YES) {
            self.keyboardView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.keyboardView.frame.size.width, self.keyboardView.frame.size.height);
            showingKeyBoardView = NO;
            if ([[Helper getUserInfoValueForKey:@"agreements_enabled"]  isEqual: @"1"]) {
                self.magreementView.hidden = NO;
            }
            else
            {
                self.magreementView.backgroundColor = [UIColor blackColor];
                self.magreementView.alpha = 0.7;
                self.magreementTV.hidden = YES;
                self.magreementView.hidden = NO;
                self.msharedAgreementLable.hidden = YES;
                self.mAgreementLine.hidden = YES;
            }
            self.shareFillView.hidden = YES;
        }
        else{
            self.numberTF.text = @"";
            self.keyboardView.frame = CGRectMake(self.view.frame.origin.x, (self.shareOptionView.frame.origin.y+self.shareOptionView.frame.size.height+1), self.keyboardView.frame.size.width, self.keyboardView.frame.size.height);
            showingKeyBoardView = YES;
            self.shareFillView.hidden = NO;
        }
    }];
}

-(void)showHideShareView {
    
    [UIView animateWithDuration:0.3 animations:^{
        if (shwoingShareView == YES) {
            
            self.shareOptionView.frame = CGRectMake((self.view.frame.origin.x-self.shareOptionView.frame.size.width), self.shareOptionView.frame.origin.y, self.shareOptionView.frame.size.width, self.shareOptionView.frame.size.height);
            shwoingShareView = NO;
        }
        else{
            self.shareOptionView.frame = CGRectMake(self.view.frame.origin.x, self.shareOptionView.frame.origin.y, self.shareOptionView.frame.size.width, self.shareOptionView.frame.size.height);
            shwoingShareView = YES;
        }
    }];
}

-(void)showHideEmailView {
    
    [UIView animateWithDuration:0.3 animations:^{
        if (showingEmailView == YES) {
            self.sendEmailView.frame = CGRectMake((self.view.frame.origin.x-self.sendEmailView.frame.size.width), (self.shareOptionView.frame.origin.y+self.shareOptionView.frame.size.height+1), self.sendEmailView.frame.size.width, self.sendEmailView.frame.size.height);
            showingEmailView = NO;
            self.ShareBGImageView.hidden = YES;
                self.shareFillView.hidden = YES;
            [self.emailTF resignFirstResponder];
        }
        else{
            self.ShareBGImageView.hidden = NO;
            self.emailTF.text = @"";
            self.sendEmailView.frame = CGRectMake(self.view.frame.origin.x, (self.shareOptionView.frame.origin.y+self.shareOptionView.frame.size.height+1), self.sendEmailView.frame.size.width, self.sendEmailView.frame.size.height);
            
            showingEmailView = YES;
            self.shareFillView.hidden = NO;
            [self.emailTF becomeFirstResponder];
        }
    }];
}

- (void) makeTextViewParagraphStyle {
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.hyphenationFactor = 1;
    paragraphStyle.lineHeightMultiple = 1.2f;
    paragraphStyle.alignment = NSTextAlignmentJustified;
    
    NSDictionary *ats = @{NSFontAttributeName:self.magreementTV.font, NSParagraphStyleAttributeName : paragraphStyle,};
    self.magreementTV.textAlignment = NSTextAlignmentJustified;
    self.magreementTV.attributedText = [[NSAttributedString alloc] initWithString:self.magreementTV.text attributes:ats];
}

- (void)hideAndAShowViews:(BOOL) mShowViews {
    
    self.mTopBarView.hidden = mShowViews;
    if (![[Helper getUserInfoValueForKey:@"agreements_enabled"]  isEqual: @"1"]) {
            self.msharedAgreementLable.hidden = YES;
            self.mAgreementLine.hidden = YES;
            self.magreementTV.hidden = YES;
            self.magreementView.backgroundColor = [UIColor blackColor];
            self.magreementView.alpha = 0.7;
    }
    self.magreementView.hidden = mShowViews;
    self.thanksView.hidden = !mShowViews;
    self.shareOptionView.hidden = mShowViews;
}
#pragma mark- Action methods

- (IBAction)cancelButtonAction:(id)sender {
    [self.player stop];
    [self.mCancelBtn setBackgroundColor:kBtnColor];
    [self performSelector:@selector(cancelButtonSelector:) withObject:sender afterDelay:0.3f];
}

- (void)cancelButtonSelector:(id)sender {   
    [self cancelBack];
}

- (IBAction)shareButtonAction:(id)sender {
    [self.mShareBtn setBackgroundColor:kBtnColor];
    [self performSelector:@selector(shareButtonSelector:) withObject:sender afterDelay:0.3f];
}

- (void)shareButtonSelector:(id)sender {
    if ([[Helper getUserInfoValueForKey:@"agreements_enabled"]  isEqual: @"1"]) {
        self.magreementView.hidden = NO;
    }
    else
    {
        self.magreementView.backgroundColor = [UIColor blackColor];
        self.magreementView.alpha = 0.7;
        self.magreementTV.hidden = YES;
        self.msharedAgreementLable.hidden = YES;
        self.mAgreementLine.hidden = YES;
    }
    if([[Helper getUserInfoValueForKey:@"sms"] isEqual:@"0"])
    {
        self.mCancelBtn.frame = CGRectMake(_mCancelBtn.frame.origin.x - _mSmsBtn.frame.size.width, _mCancelBtn.frame.origin.y, _mCancelBtn.frame.size.width + _mSmsBtn.frame.size.width, _mCancelBtn.frame.size.height);
        _mTopViewCancel.frame = CGRectMake(_mTopViewCancel.frame.origin.x - _mSmsBtn.frame.size.width-1, _mTopViewCancel.frame.origin.y, _mTopViewCancel.frame.size.width + _mSmsBtn.frame.size.width, _mTopViewCancel.frame.size.height);
        self.shareFillView.frame = CGRectMake(self.shareFillView.frame.origin.x - _mSmsBtn.frame.size.width-1, self.shareFillView.frame.origin.y, self.shareFillView.frame.size.width + _mSmsBtn.frame.size.width, self.shareFillView.frame.size.height);
        self.mSmsBtn.hidden = YES;
        self.smsBtnText.hidden = YES;
        self.smsBtnImage.hidden = YES;
        self.horizontalSmsBtnBottomBoarder.hidden = YES;
        self.verticleLastWhiteLine.hidden = YES;
    }
    if ([[Helper getUserInfoValueForKey:@"email"] isEqual:@"0"])
    {
        self.mCancelBtn.frame = CGRectMake(_mCancelBtn.frame.origin.x - _mSmsBtn.frame.size.width, _mCancelBtn.frame.origin.y, _mCancelBtn.frame.size.width + _mSmsBtn.frame.size.width, _mCancelBtn.frame.size.height);
        _mTopViewCancel.frame = CGRectMake(_mTopViewCancel.frame.origin.x - _mSmsBtn.frame.size.width-1, _mTopViewCancel.frame.origin.y, _mTopViewCancel.frame.size.width + _mSmsBtn.frame.size.width, _mTopViewCancel.frame.size.height);
        self.shareFillView.frame = CGRectMake(self.shareFillView.frame.origin.x - _mSmsBtn.frame.size.width-1, self.shareFillView.frame.origin.y, self.shareFillView.frame.size.width + _mSmsBtn.frame.size.width, self.shareFillView.frame.size.height);
        self.mSmsBtn.frame = CGRectMake(_memailBtn.frame.origin.x, _mSmsBtn.frame.origin.y, _mSmsBtn.frame.size.width - 1, _mSmsBtn.frame.size.height);
        self.memailBtn.hidden = YES;
        self.emailBtnText.hidden = YES;
        self.emailBtnImage.hidden = YES;
        self.horizontalSmsBtnBottomBoarder.hidden = YES;
        self.verticleLastWhiteLine.hidden = YES;
        self.smsBtnText.frame = CGRectMake(_emailBtnText.frame.origin.x, _smsBtnText.frame.origin.y, _smsBtnText.frame.size.width, _smsBtnText.frame.size.height);
        self.smsBtnImage.frame = CGRectMake(_emailBtnImage.frame.origin.x, _emailBtnImage.frame.origin.y, _emailBtnImage.frame.size.width, _emailBtnImage.frame.size.height);
        }
    self.mShareBtn.hidden = YES;
    self.mShareView.hidden = YES;
    self.mTopViewCenter.hidden = YES;
    [self showHideShareView];
}

- (IBAction)checkBoxBtn:(id)sender {
    if ([self.magreementCBBtn isSelected])
    {
        [self.magreementCBBtn setSelected:false];
    }
    else{
        [self.magreementCBBtn setSelected:true];
    }
}

- (IBAction)emailButtonAction:(id)sender {
    if ([[Helper getUserInfoValueForKey:@"agreements_enabled"]  isEqual: @"1"]) {
        self.magreementView.hidden = NO;
        if ([[Helper getUserInfoValueForKey:@"agreement_required"]  isEqual: @"1"]) {
            if (![self.magreementCBBtn isSelected])
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                         message:@"Please Accept the Terms & Conditions Before Sharing"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                //We add buttons to the alert controller by creating UIAlertActions:
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil]; //You can use a block here to handle a press on this button
                [alertController addAction:actionOk];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                if (showingKeyBoardView == YES){
                    [self showHideKeyboardView];
                }
                
                [self.memailBtn setBackgroundColor:kBtnColor];
                [self.mSmsBtn setBackgroundColor:kBtnOriginalColor];
                [self performSelector:@selector(showHideEmailView) withObject:nil afterDelay:0.3f];

            }
        }
        else{
            if (showingKeyBoardView == YES){
                [self showHideKeyboardView];
            }
            
            [self.memailBtn setBackgroundColor:kBtnColor];
            [self.mSmsBtn setBackgroundColor:kBtnOriginalColor];
            [self performSelector:@selector(showHideEmailView) withObject:nil afterDelay:0.3f];
        }
    }
    else
    {
        self.magreementView.backgroundColor = [UIColor blackColor];
        self.magreementView.alpha = 0.7;
        self.msharedAgreementLable.hidden = YES;
        self.mAgreementLine.hidden = YES;
        self.magreementTV.hidden = YES;
        if (showingKeyBoardView == YES){
            [self showHideKeyboardView];
        }
        
        [self.memailBtn setBackgroundColor:kBtnColor];
        [self.mSmsBtn setBackgroundColor:kBtnOriginalColor];
        [self performSelector:@selector(showHideEmailView) withObject:nil afterDelay:0.3f];
    }
    
}

- (IBAction)cancelEmailViewAction:(id)sender {
    
    [self showHideEmailView];
}

- (IBAction)smsTextButtonAction:(id)sender {
    if ([[Helper getUserInfoValueForKey:@"agreements_enabled"]  isEqual: @"1"]) {
        if ([[Helper getUserInfoValueForKey:@"agreement_required"]  isEqual: @"1"]) {
            if (![self.magreementCBBtn isSelected])
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                         message:@"Please Accept the Terms & Conditions Before Sharing"
                                                                                  preferredStyle:UIAlertControllerStyleAlert];
                //We add buttons to the alert controller by creating UIAlertActions:
                UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:nil]; //You can use a block here to handle a press on this button
                [alertController addAction:actionOk];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            else{
                self.magreementView.hidden = YES;
                
                if (showingEmailView == YES){
                    [self showHideEmailView];
                }
                [self.mSmsBtn setBackgroundColor:kBtnColor];
                [self.memailBtn setBackgroundColor:kBtnOriginalColor];
                [self performSelector:@selector(showHideKeyboardView) withObject:nil afterDelay:0.3f];
            }
        }
        else{
            self.magreementView.hidden = YES;
            
            if (showingEmailView == YES){
                [self showHideEmailView];
            }
            [self.mSmsBtn setBackgroundColor:kBtnColor];
            [self.memailBtn setBackgroundColor:kBtnOriginalColor];
            [self performSelector:@selector(showHideKeyboardView) withObject:nil afterDelay:0.3f];
        }
    }
    else{
        self.magreementView.hidden = YES;
        
        if (showingEmailView == YES){
            [self showHideEmailView];
        }
        [self.mSmsBtn setBackgroundColor:kBtnColor];
        [self.memailBtn setBackgroundColor:kBtnOriginalColor];
        [self performSelector:@selector(showHideKeyboardView) withObject:nil afterDelay:0.3f];
    }
}

- (IBAction)smsSendButtonAction:(id)sender {
    
    if (self.numberTF.text.length == 10 && [self.numberTF.text characterAtIndex:0] != '0' ){
      [self shareMediaWithEmailOrText];
    }
    else {
        [Helper showAlert:@"Invalid Phone Number" andMessage:@"Please enter a valid Phone Number"];
    }
}

- (IBAction)keyboardCancelButtonAction:(id)sender {
    
    [self showHideKeyboardView];
}

- (IBAction)acceptAgreementButtonAction:(id)sender {
    
    if (USERDEFAULTS(kAcceptAgreement)){
        
    }
    else {
        self.acceptBtn.enabled = NO;
        [USER_DEFAULTS setObject:@"No" forKey:kAcceptAgreement];
        [USER_DEFAULTS synchronize];
        [Helper showAlert:@"✓" andMessage:@"Share agreement accepted."];
        [self.acceptBtn setTitle:@"✓ Agreement Accepted" forState:UIControlStateNormal];
    }
}

- (IBAction)sendEmailButtonAction:(id)sender {
    
    [self.emailTF resignFirstResponder];
    if (!self.emailTF.text.length || [self.emailTF.text isEqualToString:@" "]){
        [Helper showAlert:nil andMessage:@"Please enter your email ID."];
        return;
    }
    if (![Helper validateEmail:self.emailTF.text]){
        [Helper showAlert:@"Invalid Email Address" andMessage:@"Please enter a valid email address"];
        return;
    }
    self.magreementView.hidden = NO;
    
    [self shareMediaWithEmailOrText];
}

- (IBAction)shareAgainButtonAction:(id)sender {
    sharedAgain = true;
    self.ShareBGImageView.frame = CGRectMake(0,200,768,554);
    self.ShareBGImageView.hidden = YES;
    [self.memailBtn setBackgroundColor:kBtnOriginalColor];
    [self.mSmsBtn setBackgroundColor:kBtnOriginalColor];
    [self hideAndAShowViews:NO];
    if (![[Helper getUserInfoValueForKey:@"agreements_enabled"]  isEqual: @"1"]) {
        self.magreementView.hidden = YES;
        self.magreementView.backgroundColor = [UIColor blackColor];
        self.magreementView.alpha = 0.7;
    }
}

- (IBAction)finishButtonAction:(id)sender {
    
    self.shareOptionView.hidden = YES;
    self.sendEmailView.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MultiMediaActive" object:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark- Custom Keypad Method

- (IBAction)keyboardButtonAction:(id)sender {
//    UIFont* boldFont = [UIFont boldSystemFontOfSize:[UIFont systemFontSize]];
    [sender setBackgroundColor:kBtnColor];
    [[sender layer] setBorderWidth:1.0f];
    [[sender layer] setBorderColor:[UIColor whiteColor].CGColor];
    UIButton *mNumberBtn = (UIButton *)sender;
    if ([sender tag] == 1011){
        if (self.numberTF.text.length){
            self.numberTF.text = [self.numberTF.text substringToIndex:(self.numberTF.text.length-1)];
        }
    } else {
        if (self.numberTF.text.length <= 10){
            self.numberTF.text = [self.numberTF.text stringByAppendingString:mNumberBtn.titleLabel.text];
        }
    }
    [self performSelector:@selector(keyboardAlternativeState:) withObject:sender afterDelay:.3];
}

- (void)keyboardAlternativeState:(id)sender {
    [[sender layer] setBorderWidth:0.0f];
    [sender setBackgroundColor:[UIColor clearColor]];
}
#pragma mark- WebHelper Methods

- (void)shareMediaWithEmailOrText {
    [self.view addSubview:delegateObj.hud];
    [delegateObj.hud show:YES];
    delegateObj.hud.hidden = NO;
    if ([USER_DEFAULTS boolForKey:kAppHaveShareLink]){
        [self sendEmailAndTextWithInfo];
    }
    else {
        [self checkEventOnline];
    }
}

- (void)sendEmailAndTextWithInfo {
    
    //    And, please send media_url (only) as a message while sending email/text message request (Meaning, remove default email_message/sms_message and "link" word from message.).
    
    NSMutableDictionary *dct = [[NSMutableDictionary alloc] init];
    [dct setValue:kAppAuthValue forKey:kAppAuthKey];
    [dct setValue:[Helper getUserInfoValueForKey:kAppEventIdKey] forKey:kAppEventIdKey];
    if (showingEmailView){
        [dct setValue:self.emailTF.text forKey:kAppEmailIdKey];
        [dct setValue:@"" forKey:kAppMessageKey];
        [dct setValue:self.muploadedLinkStr forKey:kAppLinkKey];
    }
    else {
        [dct setValue:self.numberTF.text forKey:kAppMobileNumKey];
        [dct setValue:self.muploadedLinkStr forKey:kAppMessageKey];
    }
    WebserviceHelper *help = [[WebserviceHelper alloc] init];
    help.mydelegate = self;
    if (showingEmailView){
        [help sendServerRequest:dct andAPI:kSendMailAPI];
    }
    else {
        [help sendServerRequest:dct andAPI:kSendMobileAPI];
    }
}

- (void)sendMediaWithInfo {
    
    NSData *imageData = UIImageJPEGRepresentation(self.clickedImage, 90);
    NSString *encodedString = [imageData base64EncodedString];
    
    NSMutableDictionary *dct = [[NSMutableDictionary alloc] init];
    [dct setValue:kAppAuthValue forKey:kAppAuthKey];
    [dct setValue:[Helper getUserInfoValueForKey:@"email_messages"] forKey:kAppMessageKey];
    [dct setValue:[Helper getUserInfoValueForKey:kAppEventIdKey] forKey:kAppEventIdKey];
    [dct setValue:[Helper getUserInfoValueForKey:kAppMediaUploadKey] forKey:kAppMediaUploadKey];
    if ([self.mediaType isEqualToString:@"video"]){
        [dct setValue:@"video" forKey:kAppMediaTypeKey];
    }
    else {
        [dct setValue:@"photo" forKey:kAppMediaTypeKey];
    }
    [dct setValue:encodedString forKey:kAppMediaKey];
    
    WebserviceHelper *help = [[WebserviceHelper alloc] init];
    help.mydelegate = self;
    [help sendServerRequest:dct andAPI:kSendMailAPI];
    
}

- (void) callMyCustomDelegateMethod: (NSDictionary *) mdict {
    
    NSLog(@"%@", mdict);
    if ([[mdict valueForKey:@"internet_connection"]  isEqualToString:@"Offline"] && [[[mdict valueForKey:@"status"] lowercaseString] isEqualToString:@"success"]) {
//        [[USER_DEFAULTS valueForKey:@"user_information"] setValue:@"internet_connection" forKey:@"Online"];
            [self ActivateOfflineMode];
            [delegateObj.hud removeFromSuperview];
        }
    else if([[[mdict valueForKey:@"status"] lowercaseString] isEqualToString:@"success"] && [[mdict valueForKey:@"internet_connection"]  isEqualToString:@"Online"] )
        {
            [self uploadMediaFileData];
        }
    else if ([[[mdict valueForKey:@"status"] lowercaseString] isEqualToString:@"success"]){
        if (showingKeyBoardView == YES){
            [self showHideKeyboardView];
        }
        if (showingEmailView == YES){
            [self showHideEmailView];
        }
        [self hideAndAShowViews:YES];
        self.ShareBGImageView.hidden = NO;
        self.ShareBGImageView.frame = self.view.frame;
        [delegateObj.hud removeFromSuperview];
    }
     else if (mdict==nil)
    {
        [self checkEventOnline];
    }
    else {
//        [Helper showAlert:nil andMessage:@"Error"];
        [delegateObj.hud removeFromSuperview];
    }
    
}

- (void) callMyCustomDelegateError:(NSString *)errorStr {
    
    NSLog(@"%@", errorStr);
    self.isServiceActive = NO;
    id obj = [TIMERUIApplication sharedApplication];
    [obj resetIdleTimerAfter:10];
//    [Helper showAlert:nil andMessage:@"Error"];
    [self ActivateOfflineMode];
    [delegateObj.hud removeFromSuperview];
}
#pragma mark- check Event Online/Offline
-(void) checkEventOnline {
    NSMutableDictionary *dct = [[NSMutableDictionary alloc] init];
    [dct setValue:kAppAuthValue forKey:kAppAuthKey];
    [dct setValue:[USER_DEFAULTS valueForKey:kAppUsernameKey] forKey:kAppUsernameKey];
    [dct setValue:[USER_DEFAULTS valueForKey:kAppPasswordKey] forKey:kAppPasswordKey];
    
    WebserviceHelper *help = [[WebserviceHelper alloc] init];
    help.mydelegate = self;
    [help sendServerRequest:dct andAPI:kLoginAPI];
    
}



#pragma mark- Upload Data Methods

- (void)uploadMediaFileData {
    self.isServiceActive = YES;
    NSString *camType;
    WebserviceHelper *help = [[WebserviceHelper alloc] init];
    help.mydelegate = self;
    CameraSettings *settingsobj = [CameraSettings fetchMatchingUser];
    if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
        camType = @"front";
    }
    else{
        camType = @"back";
    }
    NSString *shareOptionType = @"";
    NSString *shareValue = @"";
    if (showingEmailView){
        shareOptionType = @"email_id";
        shareValue = self.emailTF.text;
    }
    else {
        shareOptionType = @"mobile_number";
        shareValue = self.numberTF.text;
    }
    NSString *fileNamestr = @"";
    if ([self.mediaType isEqualToString:@"photo"]){
        fileNamestr = @"studiobooth_imagefile";
        [help uploadDataWithImageTypeFile:fileNamestr withtype:@"image" withCameraType:camType withshareOption:shareOptionType withShareValue:shareValue];
    }
    else if ([self.mediaType isEqualToString:@"video"]){
        fileNamestr = @"studiobooth_video";
        [help uploadDataWithImageTypeFile:fileNamestr withtype:@"video" withCameraType:camType withshareOption:shareOptionType withShareValue:shareValue];
    }
    else{
        fileNamestr = @"studiobooth_animatedfile";
        if (_gifUrl != nil) {
            fileNamestr = @"studiobooth_gifVideo";
            [help uploadDataWithImageTypeFile:fileNamestr withtype:self.mediaType withCameraType:camType withshareOption:shareOptionType withShareValue:shareValue];
        }
        else
        {
            [help uploadDataWithImageTypeFile:fileNamestr withtype:self.mediaType withCameraType:camType withshareOption:shareOptionType withShareValue:shareValue];
        }
    }
}


#pragma mark- Notification methods

-(void)applicationDidTimeout:(NSNotification *) notif
{
    if (!self.isServiceActive) {
         [self cancelBack];
    }
}
-(void)cancelBack
{
    self.shareOptionView.hidden = YES;
    self.sendEmailView.hidden = YES;
    self.keyboardView.hidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MultiMediaActive" object:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)getTheMediaFileUploadResult:(NSNotification *) notification {
   
    id obj = [TIMERUIApplication sharedApplication];
    [obj resetIdleTimerAfter:10];
//    NSLog(@"status notify- %@", notification);
    if ([[NSString stringWithFormat:@"%@", [[notification object] valueForKey:kUploadResponseKey]] isEqualToString:kUploadErrorKey]){
        [self ActivateOfflineMode];
//        [Helper showAlert:@"Oops...An error" andMessage:@"Please try again."];
        [delegateObj.hud removeFromSuperview];
         self.isServiceActive = NO;
    }
    else {
        NSDictionary *responseDict = (NSDictionary *)[[notification object] valueForKey:kUploadResponseKey];
        if (responseDict){
            if ([[responseDict valueForKey:@"status"] isEqualToString:@"success"]){
                self.muploadedLinkStr = [responseDict valueForKey:@"media_url"];
                [USER_DEFAULTS setBool:YES forKey:kAppHaveShareLink];
                [USER_DEFAULTS synchronize];
                self.thankYouImageView.image = [UIImage imageNamed:@"Thank_You"];
//                [self sendEmailAndTextWithInfo];
                 self.isServiceActive = NO;
                
            }
            else {
                [delegateObj.hud removeFromSuperview];
                [Helper showAlert:@"Oops...An error" andMessage:[NSString stringWithFormat:@"%@", [responseDict valueForKey:@"msg"]]];
            }
        }
    }
}
- (void) ActivateOfflineMode{
    self.thankYouImageView.image = [UIImage imageNamed:@"thankyou_offline"];
    if ([self.mediaType isEqualToString:@"photo"]){
        [self saveDataOnDeviceWithMediaType:@"image"];
    }
    else if([self.mediaType isEqualToString:@"video"])
    {
        [self saveDataOnDeviceWithMediaType:@"video"];
        
    }
    else{
        [self saveDataOnDeviceWithMediaType:@"gif"];
    }
}
- (void) saveDataOnDeviceWithMediaType:(NSString*)imageTypeStr{
    if (!sharedAgain) {
        time = [Helper getCurrentTime];
        uniqueName = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    }
    uniqueName = [uniqueName stringByReplacingOccurrencesOfString:@"."
                                                       withString:@""];
    NSString *fileName = [uniqueName stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *shareOptionType = @"";
    NSString *shareValue = @"";
    NSString *camType = @"";
    CameraSettings *settingsobj = [CameraSettings fetchMatchingUser];
    if ([[settingsobj.mfront lowercaseString] isEqualToString:@"yes"]){
        camType = @"front";
    }
    else{
        camType = @"back";
    }

    if (showingEmailView){
        shareOptionType = @"email_id";
        shareValue = self.emailTF.text;
    }
    else {
        shareOptionType = @"mobile_number";
        shareValue = self.numberTF.text;
    }
    
    NSString *imgStr;
    if ([imageTypeStr isEqualToString:@"image"]){
        
        imgStr = [Helper getDirectoryFilePath:kImagefileName];
        NSURL *urlStr = [NSURL fileURLWithPath:imgStr];
        NSData *videoData = [NSData dataWithContentsOfURL:urlStr];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *path=[NSString stringWithFormat:@"/%@_%@.jpeg",uniqueIdentifier,fileName];
         NSString *name = [NSString stringWithFormat:@"%@_%@.jpeg",uniqueIdentifier,fileName];
        NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"%@", path];
        BOOL success = [videoData writeToFile:tempPath atomically:NO];
        if (success) {
            if (sharedAgain) {
                sharedAgain = NO;
                if (shareValue == nil) {
                    
                }
                else{
                NSDictionary *data = @{@"camType":camType,@"shareOptionType":shareOptionType,@"shareValue":shareValue,@"fileType":@"image",kAppEventIdKey:[NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],@"time":time,@"sharedAgain":@"yes",@"sharedLink":self.muploadedLinkStr,kAppUsernameKey:[USER_DEFAULTS valueForKey:kAppUsernameKey],kAppPasswordKey:[USER_DEFAULTS valueForKey:kAppPasswordKey]};
                [delegateObj.offlineData addObject:data];
                }
            }
            else{
                if (shareValue == nil) {
                    
                }
                else{
            NSDictionary *data = @{@"camType":camType,@"shareOptionType":shareOptionType,@"shareValue":shareValue,@"fileType":@"image",@"path":name,kAppEventIdKey:[NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],@"time":time,@"sharedAgain":@"no",kAppUsernameKey:[USER_DEFAULTS valueForKey:kAppUsernameKey],kAppPasswordKey:[USER_DEFAULTS valueForKey:kAppPasswordKey]};
                [delegateObj.offlineData addObject:data];
                self.muploadedLinkStr = @"";
                }
            }
            
        }
    }
    else if ([imageTypeStr isEqualToString:@"gif"]){
        if (_gifUrl != nil) {
            imgStr = [Helper getDirectoryFilePath:kBoomerangGifName];
        }
        else
        {
            imgStr = [Helper getDirectoryFilePath:kGIFfileName];
        }
        NSURL *urlStr = [NSURL fileURLWithPath:imgStr];
        NSData *videoData = [NSData dataWithContentsOfURL:urlStr];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *path;
        NSString *name;
        if (_gifUrl != nil) {
            path=[NSString stringWithFormat:@"/%@_%@.mp4",uniqueIdentifier,fileName];
            name = [NSString stringWithFormat:@"%@_%@.mp4",uniqueIdentifier,fileName];
        }
        else
        {
            path=[NSString stringWithFormat:@"/%@_%@.gif",uniqueIdentifier,fileName];
            name = [NSString stringWithFormat:@"%@_%@.gif",uniqueIdentifier,fileName];
        }
        NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"%@", path];
        BOOL success = [videoData writeToFile:tempPath atomically:NO];
        if (success) {
            if (sharedAgain) {
                sharedAgain = NO;
                if (shareValue == nil) {
                    
                }
                else{
                    NSDictionary *data;
                    if (_gifUrl !=nil) {
                          data = @{@"camType":camType,@"shareOptionType":shareOptionType,@"shareValue":shareValue,@"fileType":@"video",kAppEventIdKey:[NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],@"time":time,@"sharedAgain":@"yes",@"sharedLink":self.muploadedLinkStr,kAppUsernameKey:[USER_DEFAULTS valueForKey:kAppUsernameKey],kAppPasswordKey:[USER_DEFAULTS valueForKey:kAppPasswordKey]};
                    }
                    else{
                        data = @{@"camType":camType,@"shareOptionType":shareOptionType,@"shareValue":shareValue,@"fileType":@"gif",kAppEventIdKey:[NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],@"time":time,@"sharedAgain":@"yes",@"sharedLink":self.muploadedLinkStr,kAppUsernameKey:[USER_DEFAULTS valueForKey:kAppUsernameKey],kAppPasswordKey:[USER_DEFAULTS valueForKey:kAppPasswordKey]};
                    }
                [delegateObj.offlineData addObject:data];
                }
            }
            else{
                if (shareValue == nil) {
                    
                }
                else{
                    NSDictionary *data;
                     if (_gifUrl !=nil) {
                         data = @{@"camType":camType,@"shareOptionType":shareOptionType,@"shareValue":shareValue,@"fileType":@"video",@"path":name,kAppEventIdKey:[NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],@"time":time,@"sharedAgain":@"no",kAppUsernameKey:[USER_DEFAULTS valueForKey:kAppUsernameKey],kAppPasswordKey:[USER_DEFAULTS valueForKey:kAppPasswordKey]};
                     }
                     else{
                          data = @{@"camType":camType,@"shareOptionType":shareOptionType,@"shareValue":shareValue,@"fileType":@"gif",@"path":name,kAppEventIdKey:[NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],@"time":time,@"sharedAgain":@"no",kAppUsernameKey:[USER_DEFAULTS valueForKey:kAppUsernameKey],kAppPasswordKey:[USER_DEFAULTS valueForKey:kAppPasswordKey]};
                     }
                [delegateObj.offlineData addObject:data];
                 self.muploadedLinkStr = @"";
                }
            }
        }
    }
    else {
        imgStr = [Helper getDirectoryFilePath:kVideofileName];
        NSURL *urlStr = [NSURL fileURLWithPath:imgStr];
        NSData *videoData = [NSData dataWithContentsOfURL:urlStr];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        NSString *path=[NSString stringWithFormat:@"/%@_%@.mp4",uniqueIdentifier,fileName];
         NSString *name = [NSString stringWithFormat:@"%@_%@.mp4",uniqueIdentifier,fileName];
        NSString *tempPath = [documentsDirectory stringByAppendingFormat:@"%@", path];
        BOOL success = [videoData writeToFile:tempPath atomically:NO];
        if (success) {
            if (sharedAgain) {
                sharedAgain = NO;
                if (shareValue == nil) {
                    
                }
                else{
                NSDictionary *data = @{@"camType":camType,@"shareOptionType":shareOptionType,@"shareValue":shareValue,@"fileType":@"video",kAppEventIdKey:[NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],@"time":time,@"sharedAgain":@"yes",@"sharedLink":self.muploadedLinkStr,kAppUsernameKey:[USER_DEFAULTS valueForKey:kAppUsernameKey],kAppPasswordKey:[USER_DEFAULTS valueForKey:kAppPasswordKey]};
                [delegateObj.offlineData addObject:data];
                }
            }
            else{
                if (shareValue == nil) {
                    
                }
                else{
                NSDictionary *data = @{@"camType":camType,@"shareOptionType":shareOptionType,@"shareValue":shareValue,@"fileType":@"video",@"path":name,kAppEventIdKey:[NSString stringWithFormat:@"%@", [Helper getUserInfoValueForKey:kAppEventIdKey]],@"time":time,@"sharedAgain":@"no",kAppUsernameKey:[USER_DEFAULTS valueForKey:kAppUsernameKey],kAppPasswordKey:[USER_DEFAULTS valueForKey:kAppPasswordKey]};
                [delegateObj.offlineData addObject:data];
                 self.muploadedLinkStr = @"";
                }
            }
        }
    }
    if (showingKeyBoardView == YES){
        [self showHideKeyboardView];
    }
    if (showingEmailView == YES){
        [self showHideEmailView];
    }
    [self hideAndAShowViews:YES];
    self.ShareBGImageView.hidden = NO;
    self.ShareBGImageView.frame = self.view.frame;
    id obj = [TIMERUIApplication sharedApplication];
    [obj resetIdleTimerAfter:10];
}

#pragma mark- Gesture funtions
-(void) handleSwipe:(UISwipeGestureRecognizer *)swipe
{
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft && self.clickedImage != nil ) {
//        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:self.clickedImage];
//        GPUImageSharpenFilter *stillImageFilter = [[GPUImageSharpenFilter alloc] init];
//        [stillImageSource addTarget:stillImageFilter];
//        [stillImageFilter setSharpness:4.0f];
////        [stillImageFilter prepareForImageCapture];
//        [stillImageSource processImage];
//        UIImage *sharpImage = [stillImageFilter imageFromCurrentFramebuffer];
//        self.mImgview.image =sharpImage;
        GPUImagePicture *imageSource = [[GPUImagePicture alloc] initWithImage:self.clickedImage];
        GPUImageContrastFilter *contrastfilter =[[GPUImageContrastFilter alloc]init];
        [contrastfilter setContrast:1];
//        GPUImageAdaptiveThresholdFilter *stillImageFilter = [[GPUImageAdaptiveThresholdFilter alloc] init];
//        stillImageFilter.blurRadiusInPixels = 8.0;
        GPUImageSharpenFilter *sharpenFilter = [[GPUImageSharpenFilter alloc] init];
        [sharpenFilter setSharpness:1];
        [imageSource addTarget:sharpenFilter];
        [sharpenFilter addTarget:contrastfilter];
//        [stillImageFilter addTarget:sharpenFilter];
        
        
        [imageSource processImage];
        [sharpenFilter useNextFrameForImageCapture];
        UIImage *outputImage = [sharpenFilter imageFromCurrentFramebuffer];
        self.mImgview.image = outputImage;
    }
    else{
        self.mImgview.image = self.clickedImage;
    }
}


@end
