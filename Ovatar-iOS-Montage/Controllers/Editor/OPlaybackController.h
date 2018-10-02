//
//  OPlaybackController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 28/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

#import "OPlayerControls.h"
#import "OTitleView.h"
#import "ODataObject.h"

#import "Mixpanel.h"

@protocol OPlaybackDelegate;
@interface OPlaybackController : UIViewController <OControlsDelegate, OTitleViewDelegate>

@property (nonatomic, strong) id <OPlaybackDelegate> delegate;
@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGSize videosize;
@property (nonatomic, strong) ODataObject *dataobj;

@property (nonatomic, assign) float paddingtop;
@property (nonatomic, assign) float paddingbottom;

@property (nonatomic, strong) AVPlayerViewController *viewPlayer;
@property (nonatomic, strong) OPlayerControls *viewControls;

-(void)setup:(NSURL *)file;
-(void)destroy:(void (^)(BOOL dismissed))completion;

@end

@protocol OPlaybackDelegate <NSObject>

@optional

@end
