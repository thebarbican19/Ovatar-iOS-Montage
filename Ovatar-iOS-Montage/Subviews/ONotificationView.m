//
//  ONoticeView.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 11/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "ONotificationView.h"
#import "OConstants.h"

@implementation ONotificationView

-(void)notificationPresentWithTitle:(NSString *)title type:(ONotificationType)type {
    self.generator = [[UINotificationFeedbackGenerator alloc] init];
    if (type == ONotificationTypeError) {
        [self setTimeout:6];
        [self.generator notificationOccurred:UINotificationFeedbackTypeError];

    }
    else if (type == ONotificationTypeRate) {
        [self.generator notificationOccurred:UINotificationFeedbackTypeSuccess];
        
    }
    
    if (@available(iOS 11, *)) {
        self.padding = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
                        
    }
        
    if (self.timer) [self.timer invalidate];
    for (UIView *subview in [UIApplication sharedApplication].delegate.window.subviews){
        if ([subview isKindOfClass:[UIView class]] && subview.tag == 999) self.exists = true;
        else self.exists = false;
        
    }
    
    if (!self.exists) {
        container = [[UIView alloc] initWithFrame:CGRectMake(15.0, [UIApplication sharedApplication].delegate.window.bounds.size.height - (self.padding + 68.0), [UIApplication sharedApplication].delegate.window.bounds.size.width - 30.0, 65.0)];
        container.backgroundColor = [UIColor whiteColor];
        container.layer.cornerRadius = 8.0;
        container.clipsToBounds = true;
        container.layer.shadowOffset = CGSizeMake(0, 1);
        container.layer.shadowRadius = 4;
        container.layer.shadowOpacity = 0.2;
        container.tag = 999;
        container.layer.borderWidth = 0.5;
        container.layer.borderColor = [UIColor colorWithWhite:0.0 alpha:0.1].CGColor;
        container.alpha = 0.0;
        container.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
        gradient = [CAGradientLayer layer];
        gradient.frame = container.bounds;
        gradient.colors = @[(id)UIColorFromRGB(0x938DEF).CGColor, (id)UIColorFromRGB(0x7096F0).CGColor];
        gradient.startPoint = CGPointMake(0.0, 1.0);
        gradient.endPoint = CGPointMake(1.0, 0.0);
        [container.layer addSublayer:gradient];
        
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        [[UIApplication sharedApplication].delegate.window addSubview:container];
        
        if ([self.icon isKindOfClass:[UIImage class]] || [self.icon isKindOfClass:[NSURL class]]) {
            image = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, container.bounds.size.height, container.bounds.size.height)];
            image.contentMode = UIViewContentModeScaleAspectFill;
            image.alpha = 1.0;
            image.backgroundColor = [UIColor clearColor];
            image.clipsToBounds = true;
            [container addSubview:image];
            
        }
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(28.0, 2.0, container.bounds.size.width - 56.0, container.bounds.size.height - 4.0)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"Avenir-Heavy" size:13.0];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled = false;
        label.numberOfLines = 2;
        label.tag = 1;
        label.attributedText = [self notificationFormat:title];
        [container addSubview:label];
        
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notificationAction:)];
        gesture.enabled = true;
        gesture.delegate = self;
        [container addGestureRecognizer:gesture];
        
        [self.generator prepare];
        [container setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [container setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [container setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            if (self.timeout > 0) self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(notificationDismiss:) userInfo:nil repeats:false];
            
        }];
        
    }
    else {
        for (UIView *subview in [UIApplication sharedApplication].delegate.window.subviews){
            if ([subview isKindOfClass:[UIView class]] && subview.tag == 999) {
                for (UIView *outlet in subview.subviews){
                    if ([outlet isKindOfClass:[UILabel class]] && [outlet tag] == 1) {
                        //[(SAMLabel *)[outlet viewWithTag:0] setText:@"pop"];
                        
                    }
                    
                    if ([outlet isKindOfClass:[UIImageView class]]) {
                        //[(UIImageView *)[outlet viewWithTag:0] setImage:self.icon];
                        
                    }
                    
                }
                
            }
            
            [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:0.65 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [subview setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                [subview setAlpha:1.0];
                
            } completion:nil];
            
        }
        
    }
    
}

-(void)notificationDismiss:(BOOL)unamiated {
    [UIView animateWithDuration:unamiated?0.0:0.2 delay:0.15 options:UIViewAnimationOptionCurveEaseIn animations:^{
        container.transform = CGAffineTransformMakeScale(0.9, 0.9);
        container.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        self.icon = nil;
        self.type = nil;
        self.action = false;
        
        [container removeFromSuperview];
        [self removeFromSuperview];
        
    }];
}

-(void)notificationAction:(UIButton *)gesture {
    [self notificationDismiss:false];
    if (self.timer) [self.timer invalidate];
    if (self.action) {
        if ([self.delegate respondsToSelector:@selector(notificationViewTapped:)] && self.action) {
            [self.delegate notificationViewTapped:self];
            
        }
        
    }
    
}

-(NSAttributedString *)notificationFormat:(NSString *)content {
    if (content != nil) {
        NSMutableAttributedString *formatContent = [[NSMutableAttributedString alloc] initWithString:content];
        NSRegularExpression *formatRegex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
        NSArray *formatMatches = [formatRegex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
        for (NSTextCheckingResult *match in formatMatches) {
            //[formatContent addAttribute:NSFontAttributeName value:[UIFont fontWithName:MAIN_FONT_MEDIUM size:label.font.pointSize] range:NSMakeRange(match.range.location, match.range.length)];
            [formatContent addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x202123) range:NSMakeRange(match.range.location, match.range.length)];
            
        }
        
        [formatContent.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatContent.string.length)];
        [formatContent.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatContent.string.length)];
        
        return formatContent;
        
    }
    else return nil;
    
}



@end
