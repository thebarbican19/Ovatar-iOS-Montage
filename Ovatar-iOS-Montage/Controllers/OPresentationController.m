//
//  OPresentationController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 26/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OPresentationController.h"
#import "OConstants.h"

@interface OPresentationController ()

@end

@implementation OPresentationController

-(void)viewWillLayoutSubviews {
    CGSize videosize = CGSizeMake(1080.0, 1920.0);
    float videoscale = (self.view.bounds.size.width - 72.0) / videosize.width;
    float videoheight = videosize.height * videoscale;
    float videowidth = videosize.width * videoscale;
    
    [self.viewPlayer.view setFrame:CGRectMake((self.view.bounds.size.width / 2) - (videowidth / 2), 26.0, videowidth, videoheight)];
    [self.viewLoader setFrame:CGRectMake((self.view.bounds.size.width / 2) - 100.0, (self.view.bounds.size.height / 2) - 100.0, 200.0, 200.0)];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.viewPlayer = [[AVPlayerViewController alloc] init];
    self.viewPlayer.view.frame = CGRectMake(36.0, 26.0, self.view.bounds.size.width - 72.0, self.view.bounds.size.height - 128.0);
    self.viewPlayer.view.backgroundColor = [UIColor blackColor];
    self.viewPlayer.view.clipsToBounds = true;
    self.viewPlayer.view.layer.cornerRadius = 12.0;
    self.viewPlayer.showsPlaybackControls = false;
    self.viewPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.viewPlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.viewPlayer.player = nil;
    self.viewPlayer.player.allowsExternalPlayback = false;
    self.viewPlayer.allowsPictureInPicturePlayback = false;
    self.viewPlayer.view.userInteractionEnabled = false;
    self.viewPlayer.view.alpha = 0.0;
    [self.view addSubview:self.viewPlayer.view];
    
    self.viewStatus = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.viewPlayer.view.bounds.size.height - 34.0, self.view.bounds.size.width - 40.0, 26.0)];
    self.viewStatus.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    self.viewStatus.textColor = UIColorFromRGB(0x7490FD);
    self.viewStatus.font = [UIFont fontWithName:@"Avenir-Heavy" size:13.0];
    self.viewStatus.textAlignment = NSTextAlignmentCenter;
    self.viewStatus.backgroundColor = [UIColor redColor];
    [self.viewPlayer.view addSubview:self.viewStatus];
    
    self.viewLoader = [[OLoaderView alloc] initWithFrame:CGRectMake(0.0, 26.0, 200.0, 200.0)];
    self.viewLoader.scale = 100.0;
    self.viewLoader.speed = 0.2;
    self.viewLoader.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewLoader];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReset:)  name:AVPlayerItemDidPlayToEndTimeNotification object:self.viewPlayer.player.currentItem];

    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(videoElapsed) userInfo:nil repeats:true];
    
}

-(void)viewPresentLoader:(NSArray *)assets {
    [self.viewLoader loaderPresentWithImages:assets animated:false];
    
}

-(void)viewPresentOutput:(NSURL *)file {
    [self.viewLoader.timer invalidate];
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.viewLoader setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        [self.viewPlayer setPlayer:[AVPlayer playerWithURL:file]];
        [self.viewPlayer.player play];
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewPlayer.view setAlpha:1.0];
            [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            
        } completion:nil];
        
    }];
    
    
}

-(void)videoReset:(NSNotification *)notification {
    [self.viewPlayer.player seekToTime:kCMTimeZero];
    [self.viewPlayer.player play];
    
}

-(void)videoElapsed {
    NSInteger currentseconds = ((NSInteger)CMTimeGetSeconds(self.viewPlayer.player.currentItem.currentTime)) % 60;
    NSInteger currentminutes = (currentseconds / 60) % 60;
    NSInteger durationseconds = ((NSInteger)CMTimeGetSeconds(self.viewPlayer.player.currentItem.duration)) % 60;
    NSInteger durationminutes = (durationseconds / 60) % 60;
    
    [self.viewStatus setText:[NSString stringWithFormat:@"%02ld:%02ld/%02ld:%02ld" ,(long)currentminutes, (long)currentseconds, (long)durationminutes, (long)durationseconds]];
    
}

@end
