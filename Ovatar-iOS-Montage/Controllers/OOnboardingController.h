//
//  OOnboardingController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 21/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

#import "OImageObject.h"
#import "ODataObject.h"
#import "OExportObject.h"

#import "OMainController.h"
#import "OActionButton.h"

#import "SAMLabel.h"

@interface OOnboardingController : UIViewController <OActionDelegate, OMainDelegate>

@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, strong) OPaymentObject *payment;

@property (nonatomic, assign) float paddingtop;
@property (nonatomic, assign) float paddingbottom;
@property (nonatomic) UIStatusBarStyle statusbarstyle;

@property (nonatomic, strong) AVPlayerViewController *viewAnimation;
@property (nonatomic, strong) UIImageView *viewBackground;
@property (nonatomic, strong) UIScrollView *viewContainer;
@property (nonatomic, strong) UIImageView *viewLogo;
@property (nonatomic, strong) SAMLabel *viewLabel;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) CAShapeLayer *viewRounded;
@property (nonatomic, strong) OMainController *viewMain;
@property (nonatomic, strong) OActionButton *viewAction;

-(void)viewAppDelegateCalled:(NSString *)promocode;

@end
