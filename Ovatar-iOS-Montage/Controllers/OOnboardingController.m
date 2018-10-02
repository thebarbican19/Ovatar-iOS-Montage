//
//  OOnboardingController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 21/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OOnboardingController.h"
#import "OConstants.h"

@interface OOnboardingController ()

@end

@implementation OOnboardingController

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (@available(iOS 11, *)) {
        self.paddingtop = self.view.safeAreaInsets.top;
        self.paddingbottom = self.view.safeAreaInsets.bottom;
        self.viewMain.paddingtop = self.view.safeAreaInsets.top;
        self.viewMain.paddingbottom = self.view.safeAreaInsets.bottom;

    }
    
    [self.imageobj imageAuthorization:false completion:^(PHAuthorizationStatus status) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (status == PHAuthorizationStatusAuthorized) {
                [self.viewMain viewAuthorize];
                [UIView animateWithDuration:0.2 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.viewLogo setTransform:CGAffineTransformMakeScale(0.4, 0.4)];
                    [self.viewLogo setAlpha:0.0];
                    [self.viewContainer scrollRectToVisible:CGRectMake(0.0, self.viewContainer.bounds.size.height, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height) animated:false];
                    
                } completion:^(BOOL finished) {
                    [self viewStatusStyle:UIStatusBarStyleDefault];

                }];
               
            }
            else {
                [UIView animateWithDuration:0.4 delay:1.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.viewLogo setFrame:CGRectMake((self.viewContainer.bounds.size.width * 0.5) - 100.0, ((self.viewContainer.bounds.size.height - 150.0) * 0.3) - 100.0, 200.0, 200.0)];
                    [self.viewLabel setFrame:CGRectMake(30.0, ((self.viewContainer.bounds.size.height - 50.0) * 0.6) - 50.0, self.view.bounds.size.width - 60.0, 100)];

                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        [self.viewLabel setFrame:CGRectMake(30.0, ((self.viewContainer.bounds.size.height - 50.0) * 0.6) - 60.0, self.view.bounds.size.width - 60.0, 100)];
                        [self.viewLabel setAlpha:1.0];
                        
                    } completion:nil];
                    
                    [UIView animateWithDuration:0.7 delay:1.25 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
                       
                        [self.viewOverlay setFrame:CGRectMake(0.0, self.viewContainer.bounds.size.height - 150.0, self.viewContainer.bounds.size.width, 150.0 + 80.0)];
                        
                    } completion:^(BOOL finished) {
                        [self.viewOverlay setFrame:CGRectMake(0.0, self.viewContainer.bounds.size.height - 150.0, self.viewContainer.bounds.size.width, 150.0)];

                    }];

                }];
                
                [self.viewAnimation.player play];
                [self viewStatusStyle:UIStatusBarStyleLightContent];

            }
            
        }];
        
    }];
    
    [self.viewContainer setContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 2)];
    [self.viewBackground setFrame:CGRectMake(0.0, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height)];
    [self.viewAnimation.view setFrame:self.viewBackground.bounds];
    [self.viewMain.view setFrame:CGRectMake(0.0, self.viewContainer.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.paddingbottom)];
    [self.viewMain.view setBackgroundColor:[UIColor clearColor]];
    [self.viewMain.viewPlayer.view setFrame:CGRectMake(self.viewContainer.bounds.size.width, self.paddingtop + MAIN_HEADER_HEIGHT, self.viewContainer.bounds.size.width, self.viewMain.view.bounds.size.height)];
    [self.viewMain.viewAlert setPadding:self.paddingbottom];
    [self.viewMain.viewSettings setPadding:self.paddingbottom];
    
    [self viewStatusStyle:UIStatusBarStyleLightContent];
    
}

-(void)viewStatusStyle:(UIStatusBarStyle)style {
    [self setStatusbarstyle:style];
    [self setNeedsStatusBarAppearanceUpdate];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.payment = [[OPaymentObject alloc] init];

    self.imageobj = [OImageObject sharedInstance];
    
    self.view.backgroundColor = UIColorFromRGB(0xF4F6F8);

    self.viewContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.viewContainer.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height * 2);
    self.viewContainer.showsVerticalScrollIndicator = false;
    self.viewContainer.pagingEnabled = true;
    self.viewContainer.backgroundColor = [UIColor clearColor];
    self.viewContainer.scrollEnabled = false;
    [self.view addSubview:self.viewContainer];

    self.viewBackground = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.viewBackground.contentMode = UIViewContentModeScaleAspectFill;
    self.viewBackground.image = [UIImage imageNamed:@"splash_background"];
    [self.viewContainer addSubview:self.viewBackground];

    self.viewAnimation = [[AVPlayerViewController alloc] init];
    self.viewAnimation.view.frame = self.view.bounds;
    self.viewAnimation.view.backgroundColor = [UIColor clearColor];
    self.viewAnimation.showsPlaybackControls = false;
    self.viewAnimation.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]  pathForResource:@"Montage-Onboarding" ofType:@"mov"]]];
    self.viewAnimation.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.viewAnimation.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.viewAnimation.player.allowsExternalPlayback = false;
    self.viewAnimation.allowsPictureInPicturePlayback = false;
    self.viewAnimation.view.userInteractionEnabled = false;
    [self.viewBackground addSubview:self.viewAnimation.view];
    
    self.viewLogo = [[UIImageView alloc] initWithFrame:CGRectMake((self.viewBackground.bounds.size.width * 0.5) - 100.0, (self.viewBackground.bounds.size.height * 0.5) - 100.0, 200.0, 200.0)];
    self.viewLogo.image = [UIImage imageNamed:@"splash_icon"];
    self.viewLogo.contentMode = UIViewContentModeCenter;
    [self.viewBackground addSubview:self.viewLogo];
    
    self.viewLabel = [[SAMLabel alloc] initWithFrame:CGRectMake(30.0, ((self.viewContainer.bounds.size.height - 50.0) * 0.6) - 100.0, self.view.bounds.size.width - 60.0, 100)];
    self.viewLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.viewLabel.backgroundColor = [UIColor clearColor];
    self.viewLabel.alpha = 0.0;
    self.viewLabel.textAlignment = NSTextAlignmentCenter;
    self.viewLabel.numberOfLines = 5;
    self.viewLabel.font = [UIFont fontWithName:@"Avenir-Black" size:10.0];
    self.viewLabel.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
    self.viewLabel.attributedText = self.viewFormatText;
    self.viewLabel.layer.shadowOffset = CGSizeMake(0.0, 1.5);
    self.viewLabel.layer.shadowRadius = 2.0;
    self.viewLabel.layer.shadowOpacity = 0.1;
    [self.viewBackground addSubview:self.viewLabel];

    self.viewRounded = [CAShapeLayer layer];
    self.viewRounded.path = [UIBezierPath bezierPathWithRoundedRect:self.viewContainer.bounds byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight cornerRadii:CGSizeMake(MAIN_CORNER_EDGES, MAIN_CORNER_EDGES)].CGPath;
    
    self.viewOverlay = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.viewContainer.bounds.size.height, self.viewContainer.bounds.size.width, 150.0)];
    self.viewOverlay.backgroundColor = UIColorFromRGB(0xF4F6F8);
    self.viewOverlay.layer.mask = self.viewRounded;
    [self.viewContainer addSubview:self.viewOverlay];
    
    self.viewAction = [[OActionButton alloc] initWithFrame:CGRectMake(30.0, 30.0, self.viewOverlay.bounds.size.width - 60.0, self.viewOverlay.bounds.size.height - 60.0)];
    self.viewAction.backgroundColor = [UIColor clearColor];
    self.viewAction.clipsToBounds = false;
    self.viewAction.delegate = self;
    self.viewAction.title = NSLocalizedString(@"Permissions_Action_Begin", nil);
    self.viewAction.key = @"authorize";
    self.viewAction.grayscale = false;
    self.viewAction.padding = 20.0;
    [self.viewOverlay addSubview:self.viewAction];

    self.viewMain = [[OMainController alloc] init];
    self.viewMain.delegate = self;
    self.viewMain.view.clipsToBounds = true;
    self.viewMain.view.frame = CGRectMake(0.0, self.viewContainer.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
    self.viewMain.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:self.viewMain];
    [self.viewContainer addSubview:self.viewMain.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewVideoLoop:)  name:AVPlayerItemDidPlayToEndTimeNotification object:self.viewAnimation.player.currentItem];
    
}

-(void)viewAppDelegateCalled:(NSString *)promocode {
    [self.viewMain paymentApplyPromoCode:promocode];
    
}

-(void)viewVideoLoop:(NSNotification *)notification {
    [self.viewAnimation.player seekToTime:kCMTimeZero];
    [self.viewAnimation.player play];
    
}

-(void)viewActionTapped:(OActionButton *)action {
    [self.imageobj imageAuthorization:true completion:^(PHAuthorizationStatus status) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (status == PHAuthorizationStatusAuthorized) {
                [self.payment paymentRetriveCurrentPricing];
                [self viewDidLayoutSubviews];
                [self.viewMain viewAuthorize];
                
            }
            else {
                NSLog(@"not authorized");
            }
            
        }];
        
    }];
    
}

-(NSMutableAttributedString *)viewFormatText {
    NSString *name = NSLocalizedString(@"Onboarding_Title", nil);
    NSString *subtitle = NSLocalizedString(@"Onboarding_Subtitle", nil);
    NSString *content = [NSString stringWithFormat:@"%@\n%@" ,name, subtitle];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:content];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
    NSArray *formatMatches = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1.0 alpha:0.6] range:NSMakeRange(name.length + 1, subtitle.length)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Medium" size:11] range:NSMakeRange(name.length + 1, subtitle.length)];
    
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, name.length)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Black" size:23] range:NSMakeRange(0, name.length)];
    
    for (NSTextCheckingResult *match in formatMatches) {
        [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:11] range:NSMakeRange(match.range.location, match.range.length)];
        [attributed addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1.0 alpha:0.8] range:NSMakeRange(match.range.location, match.range.length)];

    }
    
    [attributed.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributed.string.length)];
    [attributed.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributed.string.length)];
    
    return attributed;
    
}

-(UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
    
}

-(BOOL)prefersStatusBarHidden {
    return false;
    
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusbarstyle;
    
}

@end
