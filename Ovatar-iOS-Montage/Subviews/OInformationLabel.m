//
//  OInformationLabel.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 16/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OInformationLabel.h"
#import "OConstants.h"

@implementation OInformationLabel

- (void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:self.labelTimestamp]) {
        self.labelTimestamp = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.bounds.size.width,  self.bounds.size.height / 2)];
        self.labelTimestamp.font = [UIFont fontWithName:@"Avenir-Heavy" size:11.0];
        self.labelTimestamp.textColor = UIColorFromRGB(0xAAAAB8);
        self.labelTimestamp.text = nil;
        self.labelTimestamp.backgroundColor = [UIColor clearColor];
        self.labelTimestamp.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.labelTimestamp];
        
        self.labelLocation = [[UILabel alloc] initWithFrame:CGRectMake(0.0, self.bounds.size.height / 2, self.bounds.size.width,  self.bounds.size.height / 2)];
        self.labelLocation.font = [UIFont fontWithName:@"Avenir-Heavy" size:11.0];
        self.labelLocation.textColor = UIColorFromRGB(0xAAAAB8);
        self.labelLocation.text = nil;
        self.labelLocation.backgroundColor = [UIColor clearColor];
        self.labelLocation.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.labelLocation];
        
    }
    
}

-(void)content:(NSString *)timestamp location:(NSString *)location {
    NSLog(@"content timestamp %@ location %@" ,timestamp, location);
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (![self.labelTimestamp.text isEqualToString:timestamp] || timestamp == nil) [self.labelTimestamp setAlpha:0.0];
        if (![self.labelLocation.text isEqualToString:location] || location == nil) [self.labelLocation setAlpha:0.0];

    } completion:^(BOOL finished) {
        if (self.labelTimestamp.alpha == 0.0) {
            [self.labelTimestamp setText:timestamp];
            [self.labelTimestamp setFrame:CGRectMake(0.0, self.labelTimestamp.frame.origin.y + 10.0, self.bounds.size.width,  self.bounds.size.height / 2)];
            [UIView animateWithDuration:0.2 delay:0.15 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.labelTimestamp setFrame:CGRectMake(0.0, self.labelTimestamp.frame.origin.y - 10.0, self.bounds.size.width,  self.bounds.size.height / 2)];
                [self.labelTimestamp setAlpha:1.0];
                
            } completion:nil];
            
        }
        else {
            [UIView transitionWithView:self.labelTimestamp duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.labelTimestamp setTextColor:[UIColorFromRGB(0x464655) colorWithAlphaComponent:0.8]];
                
            } completion:^(BOOL finished) {
                [UIView transitionWithView:self.labelTimestamp duration:0.45 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    [self.labelTimestamp setTextColor:UIColorFromRGB(0xAAAAB8)];
                    
                } completion:nil];
                
            }];
            
        }
        
        if (self.labelLocation.alpha == 0.0) {
            [self.labelLocation setText:location];
            [self.labelLocation setFrame:CGRectMake(0.0, self.labelLocation.frame.origin.y + 10.0, self.bounds.size.width,  self.bounds.size.height / 2)];
            [UIView animateWithDuration:0.2 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.labelLocation setFrame:CGRectMake(0.0, self.labelLocation.frame.origin.y - 10.0, self.bounds.size.width,  self.bounds.size.height / 2)];
                [self.labelLocation setAlpha:1.0];
                
            } completion:nil];
        
        }
        else {
            [UIView transitionWithView:self.labelLocation duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.labelLocation setTextColor:[UIColorFromRGB(0x464655) colorWithAlphaComponent:0.8]];

            } completion:^(BOOL finished) {
                [UIView transitionWithView:self.labelLocation duration:0.45 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    [self.labelLocation setTextColor:UIColorFromRGB(0xAAAAB8)];
                    
                } completion:nil];
                
            }];
            
        }

    }];
    
}

@end
