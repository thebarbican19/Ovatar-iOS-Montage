//
//  OPresentationController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 26/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

#import "OLoaderView.h"
#import "OPaymentObject.h"
#import "OActionButton.h"

#import "SAMLabel.h"

@interface OPresentationController : UIViewController <OActionDelegate>

@property (nonatomic, strong) AVPlayerViewController *viewPlayer;
@property (nonatomic, strong) UILabel *viewElapsed;
@property (nonatomic, strong) SAMLabel *viewStatus;
@property (nonatomic, strong) UIImageView *viewTick;
@property (nonatomic, strong) OActionButton *viewShare;

@property (nonatomic, strong) NSURL *exported;
@property (nonatomic) SystemSoundID complete;
@property (nonatomic, assign) CGSize videosize;

-(void)viewReset;
-(void)viewPresentOutput:(NSURL *)file;
-(void)viewExportSucsessful;

@end
