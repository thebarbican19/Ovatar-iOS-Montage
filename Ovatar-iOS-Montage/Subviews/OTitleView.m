//
//  OTitleView.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 06/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OTitleView.h"
#import "OConstants.h"

@implementation OTitleView

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:self.viewContainer]) {
        self.viewRounded = [CAShapeLayer layer];
        self.viewRounded.path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerBottomLeft| UIRectCornerBottomRight cornerRadii:CGSizeMake(26.0, 26.0)].CGPath;

        self.viewContainer = [[UIView alloc] initWithFrame:self.bounds];
        self.viewContainer.backgroundColor = UIColorFromRGB(0xF4F6F8);
        self.viewContainer.layer.mask = self.viewRounded;
        [self addSubview:self.viewContainer];
        
        self.viewTitle = [[UILabel alloc] initWithFrame:CGRectMake(36.0, 0.0, self.bounds.size.width - 80.0, self.viewContainer.bounds.size.height)];
        self.viewTitle.font = [UIFont fontWithName:@"Avenir-Heavy" size:28.0];
        self.viewTitle.textColor = UIColorFromRGB(0x464655);
        self.viewTitle.text = self.title;
        self.viewTitle.backgroundColor = [UIColor clearColor];
        [self.viewContainer addSubview:self.viewTitle];
        
        self.viewBack = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, self.viewContainer.bounds.size.height, self.viewContainer.bounds.size.height)];
        self.viewBack.tag = 0;
        self.viewBack.alpha = 1.0;
        self.viewBack.backgroundColor = [UIColor clearColor];
        [self.viewBack setImage:[UIImage imageNamed:@"navigation_back"] forState:UIControlStateNormal];
        [self.viewBack addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewContainer addSubview:self.viewBack];
        
        for (int i = 1; i < 3; i++) {
            UIButton *viewButton = [[UIButton alloc] initWithFrame:CGRectMake(self.viewContainer.bounds.size.width - ((self.viewContainer.bounds.size.height * i) + 10.0), 0.0, self.viewContainer.bounds.size.height, self.viewContainer.bounds.size.height)];
            viewButton.tag = i;
            viewButton.alpha = 0.0;
            viewButton.backgroundColor = [UIColor clearColor];
            viewButton.transform = CGAffineTransformMakeTranslation(0.8, 0.8);
            [viewButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            [viewButton addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewContainer addSubview:viewButton];
            
        }
        
        self.viewShadow = [[UIView alloc] initWithFrame:CGRectMake(self.viewContainer.frame.origin.x + 6.0, self.viewContainer.frame.origin.y + 20.0, self.viewContainer.bounds.size.width - 12.0, self.viewContainer.bounds.size.height - 22.0)];
        self.viewShadow.alpha = 0.0;
        self.viewShadow.backgroundColor = UIColorFromRGB(0xAAAAB8);
        self.viewShadow.layer.masksToBounds = false;
        self.viewShadow.layer.shadowOffset = CGSizeMake(0.0, 3.0);
        self.viewShadow.layer.shadowRadius = 10.0;
        self.viewShadow.layer.shadowOpacity = 1.0;
        self.viewShadow.layer.shadowColor = self.viewShadow.backgroundColor.CGColor;
        self.viewShadow.layer.cornerRadius = self.viewContainer.bounds.size.height / 2;
        [self addSubview:self.viewShadow];
        [self sendSubviewToBack:self.viewShadow];
        
    }

}

-(void)shadow:(float)scrollpos {
    if (scrollpos > 0) [self.viewShadow setAlpha:0.0 + (fabsf(scrollpos) / 50.0)];
    else [self.viewShadow setAlpha:0.0];
    
}

-(void)setup:(NSArray *)actions animate:(BOOL)animate {
    self.buttons = [[NSMutableArray alloc] initWithArray:actions];
    if (animate) {
        for (int i = 1; i < 3; i++) {
            [UIView animateWithDuration:animate?0.2:0.0 delay:animate?(0.4 - (i * 0.2)):0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                if (i <= actions.count) {
                    [(UIButton *)[self.viewContainer viewWithTag:i] setImage:[UIImage imageNamed:[actions objectAtIndex:i - 1]] forState:UIControlStateNormal];
                    [(UIButton *)[self.viewContainer viewWithTag:i] setAlpha:1.0];
                    [(UIButton *)[self.viewContainer viewWithTag:i] setTransform:CGAffineTransformMakeTranslation(1.0, 1.0)];

                }
                else {
                    [(UIButton *)[self.viewContainer viewWithTag:i] setAlpha:0.0];
                    [(UIButton *)[self.viewContainer viewWithTag:i] setTransform:CGAffineTransformMakeTranslation(0.8, 0.8)];

                }

            } completion:nil];
            
        }
        
    }
    
    [UIView animateWithDuration:animate?0.2:0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if (self.backbutton) {
            [self.viewBack setFrame:CGRectMake(0.0, 0.0, self.viewContainer.bounds.size.height, self.viewContainer.bounds.size.height)];
            [self.viewTitle setFrame:CGRectMake(self.viewContainer.bounds.size.height, 0.0, self.bounds.size.width - 80.0, self.viewContainer.bounds.size.height)];
            
        }
        else {
            [self.viewBack setFrame:CGRectMake(0.0 - self.viewContainer.bounds.size.height, 0.0, self.viewContainer.bounds.size.height, self.viewContainer.bounds.size.height)];
            [self.viewTitle setFrame:CGRectMake(36.0, 0.0, self.bounds.size.width - 80.0, self.viewContainer.bounds.size.height)];
        }
        
    } completion:nil];
 
    [self title:self.title animate:animate];
    
}

-(void)title:(NSString *)text animate:(BOOL)animate {
    if (animate) {
        if (![[self.viewTitle text] isEqualToString:text]) {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self.viewTitle setAlpha:0.0];
                [self.viewTitle setFrame:CGRectMake(self.viewTitle.frame.origin.x + 8.0, self.viewTitle.frame.origin.y, self.viewTitle.bounds.size.width, self.viewTitle.bounds.size.height)];
                
                
            } completion:^(BOOL finished) {
                [self.viewTitle setText:text];
                [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self.viewTitle setAlpha:1.0];
                    [self.viewTitle setFrame:CGRectMake(self.viewTitle.frame.origin.x - 8.0, self.viewTitle.frame.origin.y, self.viewTitle.bounds.size.width, self.viewTitle.bounds.size.height)];
                    
                } completion:nil];
                
            }];
            
        }
        
    }
    else [self.viewTitle setText:text];
    
    self.title = text;
    
}

-(void)action:(UIButton *)type {
    if (type.tag == 0) {
        if ([self.delegate respondsToSelector:@selector(titleNavigationBackTapped:)]) {
            [self.delegate titleNavigationBackTapped:type];

        }

    }
    else {
        if ([self.delegate respondsToSelector:@selector(titleNavigationButtonTapped:)]) {
            if ([[self.buttons objectAtIndex:type.tag - 1] isEqualToString:@"navigation_export"]) {
                [self.delegate titleNavigationButtonTapped:OTitleButtonTypeExport];

            }
            else if ([[self.buttons objectAtIndex:type.tag - 1] isEqualToString:@"navigation_preview"]) {
                [self.delegate titleNavigationButtonTapped:OTitleButtonTypePreview];
                
            }
            else if ([[self.buttons objectAtIndex:type.tag - 1] isEqualToString:@"navigation_settings"]) {
                [self.delegate titleNavigationButtonTapped:OTitleButtonTypeSettings];
                
            }
            else if ([[self.buttons objectAtIndex:type.tag - 1] isEqualToString:@"navigation_select"]) {
                [self.delegate titleNavigationButtonTapped:OTitleButtonTypeSelect];
                
            }
            else if ([[self.buttons objectAtIndex:type.tag - 1] isEqualToString:@"navigation_close"]) {
                [self.delegate titleNavigationButtonTapped:OTitleButtonTypeClose];
                
            }
            
        }
        
    }
    
}

@end
