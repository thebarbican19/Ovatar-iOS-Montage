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
    if (self.title == nil) self.title = @"Button Text";

    if (![self.subviews containsObject:self.viewButton]) {
        self.viewButton = [[UIButton alloc] initWithFrame:CGRectMake(self.padding, self.padding, self.bounds.size.width - (self.padding * 2), self.bounds.size.height - (self.padding * 2))];
        self.viewButton.backgroundColor = UIColorFromRGB(0x7490FD);
        self.viewButton.layer.cornerRadius = 8.0;
        self.viewButton.clipsToBounds = true;
        [self.viewButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.viewButton];
        
        self.viewGradient = [CAGradientLayer layer];
        self.viewGradient.frame = self.viewButton.bounds;
        self.viewGradient.colors = @[(id)UIColorFromRGB(0x938DEF).CGColor, (id)UIColorFromRGB(0x7096F0).CGColor];
        self.viewGradient.startPoint = CGPointMake(0.0, 1.0);
        self.viewGradient.endPoint = CGPointMake(1.0, 0.0);
        [self.viewButton.layer addSublayer:self.viewGradient];
        
        self.viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.padding, 0.0, self.viewButton.bounds.size.width - (self.padding * 2), self.viewButton.bounds.size.height)];
        self.viewLabel.text = self.title.uppercaseString;
        self.viewLabel.numberOfLines = 2;
        self.viewLabel.textAlignment = NSTextAlignmentCenter;
        self.viewLabel.textColor = [UIColor whiteColor];
        self.viewLabel.userInteractionEnabled = false;
        self.viewLabel.font = [UIFont fontWithName:@"Avenir-Black" size:12];
        [self.viewButton addSubview:self.viewLabel];
        
        self.viewShadow = [[UIView alloc] initWithFrame:CGRectMake(self.viewButton.frame.origin.x + 4.0, self.viewButton.frame.origin.y + 8.0, self.viewButton.bounds.size.width - 12.0, self.viewButton.bounds.size.height - 16.0)];
        self.viewShadow.alpha = 0.6;
        self.viewShadow.backgroundColor = UIColorFromRGB(0x938DEF);
        self.viewShadow.layer.masksToBounds = false;
        self.viewShadow.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        self.viewShadow.layer.shadowRadius = 8.0;
        self.viewShadow.layer.shadowOpacity = 1.0;
        self.viewShadow.layer.shadowColor = UIColorFromRGB(0x36393F).CGColor;
        self.viewShadow.layer.cornerRadius = self.viewButton.bounds.size.height / 2;
        [self addSubview:self.viewShadow];
        [self sendSubviewToBack:self.viewShadow];

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
            [self.viewLabel setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.viewLabel setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

            } completion:nil];
            
        }];
        
    }
    
}

@end
