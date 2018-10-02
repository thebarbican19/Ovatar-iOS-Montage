//
//  OToggleIcon.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 25/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OToggleIcon.h"
#import "OConstants.h"

@implementation OToggleIcon

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:self.toggleContainer]) {
        self.toggleContainer = [[UIView alloc] initWithFrame:self.bounds];
        self.toggleContainer.backgroundColor = UIColorFromRGB(0x7490FD);
        self.toggleContainer.userInteractionEnabled = true;
        self.toggleContainer.clipsToBounds = true;
        self.toggleContainer.layer.cornerRadius = self.bounds.size.height / 2;
        self.toggleContainer.layer.borderWidth = 2.0;
        self.toggleContainer.layer.borderColor = UIColorFromRGB(0x7490FD).CGColor;
        [self addSubview:self.toggleContainer];
        
        self.toggleIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 8.0, self.toggleContainer.bounds.size.width - 16.0, self.toggleContainer.bounds.size.height - 16.0)];
        self.toggleIcon.backgroundColor = [UIColor clearColor];
        self.toggleIcon.userInteractionEnabled = false;
        self.toggleIcon.image = [UIImage imageNamed:@"settings_selected"];
        self.toggleIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.toggleContainer addSubview:self.toggleIcon];
        
        self.toggleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture)];
        self.toggleGesture.enabled = false;
        self.toggleGesture.delegate = self;
        [self.toggleContainer addGestureRecognizer:self.toggleGesture];
        
    }
    
    [self toggled:self.toggled animated:false];
    
}

-(void)gesture {
    [self setToggled:!self.toggled];
    [self toggled:self.toggled animated:false];

}

-(void)toggled:(BOOL)toggled animated:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:0.2 delay:0.1 options:toggled?UIViewAnimationOptionCurveEaseIn:UIViewAnimationOptionCurveEaseIn animations:^{
            if (toggled) {
                [self.toggleContainer setBackgroundColor:UIColorFromRGB(0x7490FD)];
                [self.toggleContainer setAlpha:1.0];
                [self.toggleIcon setAlpha:1.0];
                [self.toggleIcon setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
                
            }
            else {
                [self.toggleContainer setBackgroundColor:[UIColor clearColor]];
                [self.toggleContainer setAlpha:0.2];
                [self.toggleIcon setAlpha:0.0];
                [self.toggleIcon setTransform:CGAffineTransformMakeScale(0.6, 0.6)];
                
            }
            
        } completion:nil];
        
        if (toggled) {
            [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.toggleIcon setAlpha:1.0];
                [self.toggleIcon setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
                
            } completion:nil];
        
        }

    }
    else {
        if (toggled) {
            [self.toggleContainer setBackgroundColor:UIColorFromRGB(0x7490FD)];
            [self.toggleContainer setAlpha:1.0];
            [self.toggleIcon setAlpha:1.0];
            [self.toggleIcon setTransform:CGAffineTransformMakeScale(0.8, 0.8)];

        }
        else {
            [self.toggleContainer setBackgroundColor:[UIColor clearColor]];
            [self.toggleContainer setAlpha:0.2];
            [self.toggleIcon setAlpha:0.0];
            [self.toggleIcon setTransform:CGAffineTransformMakeScale(0.6, 0.6)];

        }
        
    }
    
    [self setToggled:!self.toggled];
    
}

@end
