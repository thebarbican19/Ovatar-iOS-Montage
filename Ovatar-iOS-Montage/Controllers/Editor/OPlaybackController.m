//
//  OPlaybackController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 28/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OPlaybackController.h"
#import "OConstants.h"

@implementation OPlaybackController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.dataobj = [[ODataObject alloc] init];
    
    self.viewPlayer = [[AVPlayerViewController alloc] init];
    self.viewPlayer.view.frame = CGRectMake(36.0, 14.0, self.view.bounds.size.width - 72, 200.0);
    self.viewPlayer.view.backgroundColor = [UIColor blackColor];
    self.viewPlayer.view.clipsToBounds = true;
    self.viewPlayer.view.layer.cornerRadius = 8.0;
    self.viewPlayer.view.alpha = 0.0;
    self.viewPlayer.showsPlaybackControls = false;
    self.viewPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.viewPlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.viewPlayer.player = nil;
    self.viewPlayer.player.allowsExternalPlayback = false;
    self.viewPlayer.allowsPictureInPicturePlayback = false;
    self.viewPlayer.view.userInteractionEnabled = false;
    [self.view addSubview:self.viewPlayer.view];
    
    self.viewControls = [[OPlayerControls alloc] initWithFrame:CGRectMake(0.0, self.viewPlayer.view.bounds.size.height +  28.0, self.view.bounds.size.width, MAIN_PLAYBACK_CONTROLS_HEIGHT)];
    self.viewControls.delegate = self;
    self.viewControls.backgroundColor = [UIColor clearColor];
    self.viewControls.alpha = 0.0;
    [self.view addSubview:self.viewControls];
    
}

-(void)setup:(NSURL *)file {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(elapsed) userInfo:nil repeats:true];

    float videoscale = (self.view.bounds.size.width - 72.0) / self.videosize.width;
    float videoheight = self.videosize.height * videoscale;
    float videowidth = self.videosize.width * videoscale;
    CGSize videoplayersize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - (MAIN_PLAYBACK_NAVIGATION_HEIGHT + 42.0));

    if (videoheight >= videoplayersize.height) videoheight = videoplayersize.height;
    
    [self.viewPlayer.view setFrame:CGRectMake(36.0, 14.0, videowidth, videoheight)];
    [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
    [self.viewControls setFrame:CGRectMake(0.0, self.viewPlayer.view.bounds.size.height +  28.0, self.view.bounds.size.width, MAIN_PLAYBACK_CONTROLS_HEIGHT)];
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.viewPlayer.view setAlpha:1.0];
        [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [self.viewControls setAlpha:1.0];

    } completion:^(BOOL finished) {
        [self.viewPlayer setPlayer:[AVPlayer playerWithURL:file]];
        [self.viewPlayer.player play];
        
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loop:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.viewPlayer.player.currentItem];

    }];
    
}

-(void)destroy:(void (^)(BOOL dismissed))completion {
    [UIView animateWithDuration:0.1 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewPlayer.view setAlpha:0.0];
        [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        [self.viewControls setAlpha:0.0];

    } completion:^(BOOL finished) {
        [self.viewPlayer setPlayer:nil];
        [self.viewPlayer.player play];
        [self.timer invalidate];
        
        [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];

        [[NSNotificationCenter defaultCenter] removeObserver:AVPlayerItemDidPlayToEndTimeNotification];
        
        completion(true);
        
    }];
    
}

-(void)loop:(NSNotification *)notification {
    [self.viewPlayer.player seekToTime:kCMTimeZero];
    [self.viewPlayer.player play];
    
}

-(void)elapsed {
    if (CMTimeGetSeconds(self.viewPlayer.player.currentItem.currentTime) > 0 && CMTimeGetSeconds(self.viewPlayer.player.currentItem.duration)) {
        float currentminutes = rintf(CMTimeGetSeconds(self.viewPlayer.player.currentItem.currentTime) / 60.f);
        float currentseconds = rintf(fmodf(CMTimeGetSeconds(self.viewPlayer.player.currentItem.currentTime), 60.f));
        float durationminutes = rintf(CMTimeGetSeconds(self.viewPlayer.player.currentItem.duration) / 60.f);
        float durationseconds = rintf(fmodf(CMTimeGetSeconds(self.viewPlayer.player.currentItem.duration), 60.f));
        
        [self.viewControls.playerElapsed setHidden:false];
        [self.viewControls.playerElapsed setText:[NSString stringWithFormat:@"%2.0f:%02.0f  | %2.0f:%02.0f", currentminutes, currentseconds, durationminutes, durationseconds]];
        
    }
    else {
        [self.viewControls.playerElapsed setHidden:true];
        [self.viewControls.playerElapsed setText:nil];
        
    }

}

-(void)playbackToggle {
    if (self.viewPlayer.player.rate != 0) [self.viewPlayer.player pause];
    else [self.viewPlayer.player play];
   
}

-(void)playbackRewind {
    [self.viewPlayer.player seekToTime:CMTimeSubtract(self.viewPlayer.player.currentItem.currentTime, CMTimeMakeWithSeconds(1.0, 29.8))];
    [self elapsed];
    
}

-(void)playbackForward {
    [self.viewPlayer.player seekToTime:CMTimeAdd(self.viewPlayer.player.currentItem.currentTime, CMTimeMakeWithSeconds(1.0, 29.8))];
    [self elapsed];
    
}

@end
