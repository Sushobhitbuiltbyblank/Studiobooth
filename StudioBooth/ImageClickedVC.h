//
//  StartStudioVC.h
//  StudioBooth
//
//  Created by Bhupinder Verma on 08/06/15.
//  Copyright (c) 2015 PopulaceInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Helper.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "WebserviceHelper.h"
#import <MediaPlayer/MediaPlayer.h>
#import "FLAnimatedImage.h"
@class AppDelegate;

@interface ImageClickedVC : UIViewController
{
    AppDelegate *delegateObj;
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
}
@property (nonatomic) BOOL isServiceActive;
@property (nonatomic, strong) NSString *sharpeningValue;
@property (nonatomic, strong) NSString *contrastValue;
@property (nonatomic, strong)IBOutlet UIImageView *mImgview;
@property (nonatomic, strong) UIImage *clickedImage;
@property (weak, nonatomic) IBOutlet UIImageView *thankYouImageView;

@property (nonatomic, assign) int activeMediaCount;
@property (nonatomic, strong) NSString *mediaType;
@property (nonatomic, strong) NSMutableArray *gifImgsArray;
//@property (nonatomic, weak) IBOutlet UIImageView *overlayImg;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *overlayImg;

@property (weak, nonatomic) IBOutlet UIImageView *overlayPNGImg;
@property (nonatomic, weak) NSURL *gifUrl;

@property(nonatomic,weak) IBOutlet UIView *mTopBarView;
@property(nonatomic,weak) IBOutlet UIView *shareOptionView;
@property(nonatomic,weak) IBOutlet UIView *shareFillView;
@property (nonatomic,weak) IBOutlet UIButton *memailBtn;
@property (nonatomic,weak) IBOutlet UIButton *mSmsBtn;
@property (nonatomic,weak) IBOutlet UIButton *mShareBtn;
@property (nonatomic,weak) IBOutlet UIButton *mCancelBtn;

@property (nonatomic,weak) IBOutlet UIView *mShareView;
@property(nonatomic,weak) IBOutlet UIView *magreementView;
@property (weak, nonatomic) IBOutlet UIView *mAgreementLineAfterLable;
@property(nonatomic,weak) IBOutlet UITextView *magreementTV;
@property (weak, nonatomic) IBOutlet UIButton *magreementCBBtn;
@property (weak, nonatomic) IBOutlet UILabel *msharedAgreementLable;
@property (weak, nonatomic) IBOutlet UIView *mAgreementLine;


@property (nonatomic,weak) IBOutlet UIButton *acceptBtn;
@property(nonatomic,weak) IBOutlet UIView *sendEmailView;
@property (nonatomic,weak) IBOutlet UIButton *sendBtn;
@property (nonatomic,weak) IBOutlet UITextField *emailTF;

@property(nonatomic,weak) IBOutlet UIView *thanksView;
@property(nonatomic,weak) IBOutlet UITextView *thankyouTextV;
//@property(nonatomic,weak) IBOutlet UIWebView *mwebV;

@property(nonatomic,weak) IBOutlet UIView *keyboardView;
@property (nonatomic,weak) IBOutlet UITextField *numberTF;

@property (nonatomic, strong) NSString *muploadedLinkStr;
@property (nonatomic, strong) NSString *msendingViaEmail;
@property (nonatomic,weak) IBOutlet UIImageView *ShareBGImageView;
@property (nonatomic,strong)MPMoviePlayerController *player;
//@property (nonatomic,retain) AVPlayer *avPlayer;
//@property (nonatomic, retain)AVPlayerLayer *avPlayerLayer;
@property (nonatomic,weak)IBOutlet UIView *mMovieView;

@property (nonatomic,weak)IBOutlet UIView *mTopViewCenter;
@property (nonatomic,weak)IBOutlet UIView *mTopViewShare;
@property (nonatomic,weak)IBOutlet UIView *mTopViewCancel;


@property (weak, nonatomic) IBOutlet UIImageView *smsBtnImage;
@property (weak, nonatomic) IBOutlet UILabel *smsBtnText;
@property (weak, nonatomic) IBOutlet UIImageView *emailBtnImage;
@property (weak, nonatomic) IBOutlet UILabel *emailBtnText;
@property (weak, nonatomic) IBOutlet UIView *verticleLastWhiteLine;
@property (weak, nonatomic) IBOutlet UIView *horizontalEmailBtnBottomBoarder;
@property (weak, nonatomic) IBOutlet UIView *horizontalSmsBtnBottomBoarder;


- (IBAction)cancelButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;
- (IBAction)emailButtonAction:(id)sender;
- (IBAction)smsTextButtonAction:(id)sender;
- (IBAction)acceptAgreementButtonAction:(id)sender;
- (IBAction)sendEmailButtonAction:(id)sender;
- (IBAction)cancelEmailViewAction:(id)sender;
- (IBAction)finishButtonAction:(id)sender;
- (IBAction)shareAgainButtonAction:(id)sender;
- (IBAction)keyboardButtonAction:(id)sender;
- (IBAction)smsSendButtonAction:(id)sender;
- (IBAction)keyboardCancelButtonAction:(id)sender;


@end
