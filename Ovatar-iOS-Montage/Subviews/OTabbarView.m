//
//  OTabbarView.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 30/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OTabbarView.h"
#import "OConstants.h"

@implementation OTabbarView

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:self.container]) {
        self.container = [[UIView alloc] initWithFrame:self.bounds];
        self.container.backgroundColor = [UIColor clearColor];
        self.container.alpha = 1.0;
        [self addSubview:self.container];
        
        for (int i = 0; i < self.buttons.count; i++) {
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.bounds.size.width / self.buttons.count) * i, 0.0, self.bounds.size.width / self.buttons.count, self.bounds.size.height)];
            [button setBackgroundColor:[UIColor clearColor]];
            [button addTarget:self action:@selector(tabbarAction:)forControlEvents:UIControlEventTouchDown];
            [button setTag:i];
            [button setAlpha:1.0];
            [button setIsAccessibilityElement:true];
            [button setAccessibilityLabel:[[self.buttons objectAtIndex:i] objectForKey:@"text"]];
            [self.container addSubview:button];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, button.bounds.size.height - 30.0, button.bounds.size.width - 20.0, 20.0)];
            [label setText:[[[self.buttons objectAtIndex:i] objectForKey:@"text"] uppercaseString]];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setTextColor:UIColorFromRGB(0x9BA0A1)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont fontWithName:@"Avenir-Heavy" size:8]];
            [button addSubview:label];
            
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((button.bounds.size.width / 2) - ((button.bounds.size.height - 30.0) / 2), 8.0, button.bounds.size.height - 30.0, button.bounds.size.height - 30.0)];
            [icon setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@" ,[[self.buttons objectAtIndex:i] objectForKey:@"image"]]]];
            [icon setContentMode:UIViewContentModeCenter];
            [icon setBackgroundColor:[UIColor clearColor]];
            [icon setClipsToBounds:true];
            [button addSubview:icon];
            
        }
        
    }
    
}
                            
-(void)tabbarAction:(UIButton *)button {
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.duration = 0.1;
    scale.toValue = [NSNumber numberWithFloat:0.92];
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    scale.autoreverses = true;
    scale.repeatCount = 1;
    
    for (UIView *item in button.subviews) {
        if ([item isKindOfClass:[UIImageView class]]) {
            UIImageView *icon = (UIImageView *)[item viewWithTag:item.tag];
            [icon.layer addAnimation:scale forKey:nil];
            
        }
        
    }
    
    [self.delegate tabbarAction:button];
    
}



@end
