//
//  OPlayerControls.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 30/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OPlayerControls.h"
#import "OConstants.h"

@implementation OPlayerControls

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:self.playerContainer]) {
        self.playerContainer = [[UIView alloc] initWithFrame:CGRectMake(50.0, 8.0, self.bounds.size.width - 100.0,  self.bounds.size.height - 16.0)];
        self.playerContainer.backgroundColor = [UIColor clearColor];
        [self addSubview:self.playerContainer];
        
        self.playerElapsed = [[UILabel alloc] initWithFrame:CGRectMake(10.0, -8.0, self.playerContainer.bounds.size.width - 20.0, 16.0)];
        self.playerElapsed.textAlignment = NSTextAlignmentCenter;
        self.playerElapsed.textColor = UIColorFromRGB(0x7490FD);
        self.playerElapsed.font = [UIFont fontWithName:@"Avenir-Heavy" size:10];
        [self.playerContainer addSubview:self.playerElapsed];
    
        self.playerRewind = [[UIButton alloc] initWithFrame:CGRectMake((self.playerContainer.bounds.size.width / 3) * 0, 16.0, (self.playerContainer.bounds.size.width / 3), self.playerContainer.bounds.size.height - 16.0)];
        self.playerRewind.backgroundColor = [UIColor clearColor];
        self.playerRewind.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.playerRewind.tag = 1;
        self.playerRewind.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [self.playerRewind setImage:[UIImage imageNamed:@"playback_rewind"] forState:UIControlStateNormal];
        [self.playerRewind addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self.playerContainer addSubview:self.playerRewind];
        
        self.playerForward = [[UIButton alloc] initWithFrame:CGRectMake((self.playerContainer.bounds.size.width / 3) * 2, 16.0, (self.playerContainer.bounds.size.width / 3), self.playerContainer.bounds.size.height - 16.0)];
        self.playerForward.backgroundColor = [UIColor clearColor];
        self.playerForward.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.playerForward.tag = 3;
        self.playerForward.transform = CGAffineTransformMakeScale(0.9, 0.9);
        [self.playerForward setImage:[UIImage imageNamed:@"playback_forward"] forState:UIControlStateNormal];
        [self.playerForward addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self.playerContainer addSubview:self.playerForward];
        
        self.playerPlay = [[UIButton alloc] initWithFrame:CGRectMake((self.playerContainer.bounds.size.width / 3) * 1, 16.0, (self.playerContainer.bounds.size.width / 3), self.playerContainer.bounds.size.height - 16.0)];
        self.playerPlay.backgroundColor = [UIColor clearColor];
        self.playerPlay.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.playerPlay.tag = 2;
        [self.playerPlay setImage:[UIImage imageNamed:@"playback_pause"] forState:UIControlStateNormal];
        [self.playerPlay addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self.playerContainer addSubview:self.playerPlay];
        
    }
    
}
         
-(void)action:(UIButton *)button {
    if (button.tag == 2) {
        if ([self.delegate respondsToSelector:@selector(playbackToggle)]) {
            UIImage *image = nil;
            if ([button.currentImage isEqual:[UIImage imageNamed:@"playback_play"]]) image = [UIImage imageNamed:@"playback_pause"];
            else image = [UIImage imageNamed:@"playback_play"];
            
            [button setImage:image forState:UIControlStateNormal];
            [self.delegate playbackToggle];

        }
        
    }
    
    if (button.tag == 1) {
        if ([self.delegate respondsToSelector:@selector(playbackRewind)]) {
            [self.delegate playbackRewind];
            
        }
        
    }
    
    if (button.tag == 3) {
        if ([self.delegate respondsToSelector:@selector(playbackForward)]) {
            [self.delegate playbackForward];
            
        }
        
    }
                
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 0.1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.autoreverses = true;
    animation.repeatCount = 1;
    animation.toValue = [NSNumber numberWithFloat:0.95];
    [button.layer addAnimation:animation forKey:nil];
    
    UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
    [generator notificationOccurred:UINotificationFeedbackTypeWarning];
    [generator prepare];
                
}

@end
