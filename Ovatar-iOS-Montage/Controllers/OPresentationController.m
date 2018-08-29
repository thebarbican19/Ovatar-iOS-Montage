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
    [self.viewShare setFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 100.0, self.view.bounds.size.height - 140.0, 200.0, 90.0)];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.viewPlayer = [[AVPlayerViewController alloc] init];
    self.viewPlayer.view.frame = CGRectMake(36.0, 26.0, self.view.bounds.size.width - 72.0, self.view.bounds.size.height - 128.0);
    self.viewPlayer.view.backgroundColor = [UIColor blackColor];
    self.viewPlayer.view.clipsToBounds = true;
    self.viewPlayer.view.layer.cornerRadius = 8.0;
    self.viewPlayer.showsPlaybackControls = false;
    self.viewPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.viewPlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.viewPlayer.player = nil;
    self.viewPlayer.player.allowsExternalPlayback = false;
    self.viewPlayer.allowsPictureInPicturePlayback = false;
    self.viewPlayer.view.userInteractionEnabled = false;
    self.viewPlayer.view.alpha = 0.0;
    [self.view addSubview:self.viewPlayer.view];
    
    self.viewElapsed = [[UILabel alloc] initWithFrame:CGRectMake(20.0, self.view.bounds.size.height - 34.0, self.view.bounds.size.width - 40.0, 26.0)];
    self.viewElapsed.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    self.viewElapsed.textColor = UIColorFromRGB(0x7490FD);
    self.viewElapsed.font = [UIFont fontWithName:@"Avenir-Heavy" size:13.0];
    self.viewElapsed.textAlignment = NSTextAlignmentCenter;
    self.viewElapsed.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewElapsed];
    
    self.viewTick = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 50.0, self.viewPlayer.view.frame.origin.y + 40.0, 100.0, 100.0)];
    self.viewTick.backgroundColor = [UIColor clearColor];
    self.viewTick.contentMode = UIViewContentModeScaleAspectFit;
    self.viewTick.image = [UIImage imageNamed:@"export_complete"];
    self.viewTick.transform = CGAffineTransformMakeScale(0.9, 0.9);
    self.viewTick.alpha = 0.0;
    [self.view addSubview:self.viewTick];

    self.viewStatus = [[SAMLabel alloc] initWithFrame:CGRectMake(50.0, self.viewTick.frame.origin.y + 180.0, self.view.bounds.size.width - 100.0, 105.0)];
    self.viewStatus.textColor = UIColorFromRGB(0xAAAAB8);
    self.viewStatus.attributedText = [self format:@"Your video has been saved to your *Photo Library*. Would you like to share it?"];
    self.viewStatus.font = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
    self.viewStatus.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
    self.viewStatus.textAlignment = NSTextAlignmentCenter;
    self.viewStatus.numberOfLines = 9;
    self.viewStatus.alpha = 0.0;
    [self.view addSubview:self.viewStatus];
    
    self.viewShare = [[OActionButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 100.0, self.view.bounds.size.height - 240.0, 200.0, 90.0)];
    self.viewShare.backgroundColor = [UIColor clearColor];
    self.viewShare.clipsToBounds = false;
    self.viewShare.delegate = self;
    self.viewShare.title = @"Share";
    self.viewShare.alpha = 0.0;
    [self.view addSubview:self.viewShare];

    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(videoElapsed) userInfo:nil repeats:true];
        
}

-(void)viewPresentOutput:(NSURL *)file {
    float videoscale = (self.view.bounds.size.width - 72.0) / self.videosize.width;
    float videoheight = self.videosize.height * videoscale;
    float videowidth = self.videosize.width * videoscale;
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
    } completion:^(BOOL finished) {
        [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        [self.viewPlayer setPlayer:[AVPlayer playerWithURL:file]];
        [self.viewPlayer.player play];
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewPlayer.view setAlpha:1.0];
            [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [self.viewPlayer.view setFrame:CGRectMake((self.view.bounds.size.width / 2) - (videowidth / 2), 26.0, videowidth, videoheight)];
            
        } completion:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReset:)  name:AVPlayerItemDidPlayToEndTimeNotification object:self.viewPlayer.player.currentItem];

    }];
    
}

-(void)viewReset {
    [self.viewPlayer setPlayer:nil];
    [self.viewPlayer.view setAlpha:0.0];
    [self.viewElapsed setAlpha:0.0];
    [self.viewTick setAlpha:0.0];
    [self.viewShare setAlpha:0.0];
    [self.viewStatus setAlpha:0.0];

    [[NSNotificationCenter defaultCenter] removeObserver:AVPlayerItemDidPlayToEndTimeNotification];
    
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
    
    [self.viewElapsed setText:[NSString stringWithFormat:@"%02ld:%02ld/%02ld:%02ld" ,(long)currentminutes, (long)currentseconds, (long)durationminutes, (long)durationseconds]];
    
}

-(void)viewExportSucsessful {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewPlayer.view setAlpha:0.0];
        [self.viewElapsed setAlpha:0.0];

    } completion:^(BOOL finished) {
        [self.viewTick setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        [self.viewShare setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
        [self.viewStatus setFrame:CGRectMake(self.viewStatus.frame.origin.x, self.viewStatus.frame.origin.y - 16.0, self.viewStatus.bounds.size.width, self.viewStatus.bounds.size.height)];
        [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewTick setAlpha:1.0];
            [self.viewTick setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [self.viewStatus setAlpha:1.0];
            [self.viewStatus setFrame:CGRectMake(self.viewStatus.frame.origin.x, self.viewStatus.frame.origin.y + 16.0, self.viewStatus.bounds.size.width, self.viewStatus.bounds.size.height)];

        } completion:nil];
        
        [UIView animateWithDuration:0.3 delay:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewShare setAlpha:1.0];
            [self.viewShare setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

        } completion:nil];
        
    }];
    
    NSURL *sfx = [[NSBundle mainBundle] URLForResource:@"complete_sfx" withExtension:@"mp3"];
    SystemSoundID audioid;
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)sfx, &audioid);
    if (error == kAudioServicesNoError) {
        self.complete = audioid;
        AudioServicesPlaySystemSound(self.complete);
        
    }
     
}

-(void)viewActionTapped:(OActionButton *)action {
    if (self.exported != nil) {
        UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[self.exported] applicationActivities:nil];
        [super presentViewController:share animated:true completion:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
            
        }];
        
    }
    
}

-(NSMutableAttributedString *)format:(NSString *)text {
    if (text != nil) {
        NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:text];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
        NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0.0, text.length)];
        
        [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Medium" size:15.0] range:NSMakeRange(0, text.length)];
        [formatted addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xAAAAB8)range:NSMakeRange(0, text.length)];
        
        for (NSTextCheckingResult *match in matches) {
            [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:15.0] range:NSMakeRange(match.range.location, match.range.length)];
            [formatted addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x7490FD)range:NSMakeRange(match.range.location, match.range.length)];
            
        }
        
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        
        return formatted;
        
    }
    else return nil;
    
}

@end
