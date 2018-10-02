//
//  OActionButton.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 02/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OActionButton.h"
#import "OConstants.h"

@implementation OActionButton

-(void)drawRect:(CGRect)rect {
    self.generator = [[UINotificationFeedbackGenerator alloc] init];
    if (self.padding == 0) self.padding = 16.0;
    if (self.fontsize == 0) self.fontsize = 11.0;
    if (self.title == nil) self.title = @"Button Text";
    if (self.title == nil) self.title = @"Button Text";
    if (self.countdown > 0) {
        self.disabled = true;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countdown:) userInfo:nil repeats:true];
        
    }

    if (![self.subviews containsObject:self.viewButton]) {
        self.viewButton = [[UIButton alloc] initWithFrame:CGRectMake(self.padding, self.padding, self.bounds.size.width - (self.padding * 2), self.bounds.size.height - (self.padding * 2))];
        self.viewButton.backgroundColor = self.grayscale?[UIColor clearColor]:UIColorFromRGB(0x7490FD);
        self.viewButton.layer.cornerRadius = 8.0;
        self.viewButton.layer.borderColor = UIColorFromRGB(0xD3D3DB).CGColor;
        self.viewButton.layer.borderWidth = self.grayscale?2.0:0.0;
        self.viewButton.clipsToBounds = true;
        [self.viewButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.viewButton];
        
        self.viewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 14.0, self.viewButton.bounds.size.height - 28.0, self.viewButton.bounds.size.height - 28.0)];
        self.viewIcon.backgroundColor = [UIColor clearColor];
        self.viewIcon.contentMode = UIViewContentModeScaleAspectFit;
        self.viewIcon.clipsToBounds = true;
        self.viewIcon.image = self.icon;
        [self.viewButton addSubview:self.viewIcon];
        
        self.viewGradient = [CAGradientLayer layer];
        self.viewGradient.frame = self.viewButton.bounds;
        self.viewGradient.colors = @[(id)UIColorFromRGB(0x938DEF).CGColor, (id)UIColorFromRGB(0x7096F0).CGColor];
        self.viewGradient.startPoint = CGPointMake(0.0, 1.0);
        self.viewGradient.endPoint = CGPointMake(1.0, 0.0);
        self.viewGradient.hidden = self.grayscale;
        [self.viewButton.layer addSublayer:self.viewGradient];
        
        self.viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.padding + (self.icon==nil?0.0:(self.viewIcon.bounds.size.width / 2)), 0.0, self.viewButton.bounds.size.width - (self.padding * 2), self.viewButton.bounds.size.height)];
        if (self.countdown > 0) self.viewLabel.attributedText = [self format:[NSString stringWithFormat:@"%@ (%d)" ,self.title ,self.countdown]];
        else self.viewLabel.attributedText = [self format:self.title];
        self.viewLabel.numberOfLines = 2;
        self.viewLabel.textAlignment = NSTextAlignmentCenter;
        self.viewLabel.textColor = self.grayscale?UIColorFromRGB(0x757585):[UIColor whiteColor];
        self.viewLabel.userInteractionEnabled = false;
        self.viewLabel.font = [UIFont fontWithName:@"Avenir-Black" size:self.fontsize];
        [self.viewButton addSubview:self.viewLabel];
        
        self.viewShadow = [[UIView alloc] initWithFrame:CGRectMake(self.viewButton.frame.origin.x + 6.0, self.viewButton.frame.origin.y + 8.0, self.viewButton.bounds.size.width - 12.0, self.viewButton.bounds.size.height - 16.0)];
        self.viewShadow.hidden = self.grayscale;
        self.viewShadow.alpha = 0.9;
        self.viewShadow.backgroundColor = self.viewButton.backgroundColor;
        self.viewShadow.layer.masksToBounds = false;
        self.viewShadow.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        self.viewShadow.layer.shadowRadius = 8.0;
        self.viewShadow.layer.shadowOpacity = 1.0;
        self.viewShadow.layer.shadowColor = self.viewButton.backgroundColor.CGColor;
        self.viewShadow.layer.cornerRadius = self.viewButton.bounds.size.height / 2;
        [self addSubview:self.viewShadow];
        [self sendSubviewToBack:self.viewShadow];

    }
    
}

-(NSMutableAttributedString *)format:(NSString *)title {
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:title.uppercaseString];
    [attributed addAttribute:NSKernAttributeName value:@1.2 range:NSMakeRange(0, title.length)];
    
    return attributed;
    
}
                      
-(void)countdown:(NSTimer *)timer {
    if (self.countdown > 1) {
        self.disabled = true;
        self.countdown -= 1;
        self.viewLabel.attributedText = [self format:[NSString stringWithFormat:@"%@ (%d)" ,self.title ,self.countdown]];

    }
    else {
        self.disabled = false;
        self.viewLabel.attributedText = [self format:self.title];

        if ([self.delegate respondsToSelector:@selector(viewActionCountdownComplete:)]) {
            [self.delegate viewActionCountdownComplete:self];
            
        }
        
    }

}

-(void)action:(UIButton *)button {
    if (button) {
        [self.generator notificationOccurred:UINotificationFeedbackTypeSuccess];
        [self.generator prepare];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(viewActionTapped:)]) {
        [self.delegate viewActionTapped:self];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewButton setTransform:CGAffineTransformMakeScale(0.98, 0.98)];
            [self.viewShadow setAlpha:0.2];

        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.viewButton setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                [self.viewShadow setAlpha:1.0];

            } completion:nil];
            
        }];
        
    }
    
}

@end
