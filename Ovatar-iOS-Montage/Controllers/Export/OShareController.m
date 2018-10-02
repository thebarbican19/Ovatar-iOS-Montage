//
//  OShareController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 01/10/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OShareController.h"
#import "OConstants.h"

@implementation OShareController

#define MODAL_HEIGHT 460.0

-(instancetype)init {
    self = [super init];
    if (self) {
        self.mixpanel = [Mixpanel sharedInstance];
        
        self.dataobj = [[ODataObject alloc] init];
        self.dataobj.delegate = self;
        
        self.imageobj = [OImageObject sharedInstance];
        
        self.payment = [[OPaymentObject alloc] init];
        
    }
    
    return self;
    
}

-(void)present {
    if (![[UIApplication sharedApplication].delegate.window.subviews containsObject:self.viewOverlay]) {
        self.viewOverlay = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
        self.viewOverlay.backgroundColor = MAIN_MODAL_BACKGROUND;
        self.viewOverlay.alpha = 0.0;
        self.viewOverlay.userInteractionEnabled = true;
        
        self.viewRounded = [CAShapeLayer layer];
        self.viewRounded.path = [UIBezierPath bezierPathWithRoundedRect:self.viewOverlay.bounds byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight cornerRadii:CGSizeMake(MAIN_CORNER_EDGES, MAIN_CORNER_EDGES)].CGPath;
        
        self.viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height, self.viewOverlay.bounds.size.width, MODAL_HEIGHT - self.padding)];
        self.viewContainer.backgroundColor = [UIColor lightGrayColor];
        self.viewContainer.backgroundColor = UIColorFromRGB(0xF4F6F8);
        self.viewContainer.layer.mask = self.viewRounded;
        
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        [[UIApplication sharedApplication].delegate.window addSubview:self.viewOverlay];
        [[UIApplication sharedApplication].delegate.window addSubview:self.viewContainer];
        
        self.viewTick = [[OAnimatedIcon alloc] initWithFrame:CGRectMake((self.viewContainer.bounds.size.width * 0.5) - 50.0, 40.0, 100.0, 100.0)];
        self.viewTick.backgroundColor = [UIColor clearColor];
        self.viewTick.transform = CGAffineTransformMakeScale(0.9, 0.9);
        self.viewTick.alpha = 1.0;
        self.viewTick.loopvid = true;
        self.viewTick.type = OAnimatedIconTypeComplete;
        [self.viewContainer addSubview:self.viewTick];
        
        self.viewStatus = [[SAMLabel alloc] initWithFrame:CGRectMake(50.0, self.viewTick.frame.origin.y + 130.0, self.viewContainer.bounds.size.width - 100.0, 105.0)];
        self.viewStatus.textColor = UIColorFromRGB(0xAAAAB8);
        self.viewStatus.attributedText = [self format:NSLocalizedString(@"Export_Saved_Description", nil)];
        self.viewStatus.font = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
        self.viewStatus.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
        self.viewStatus.textAlignment = NSTextAlignmentCenter;
        self.viewStatus.numberOfLines = 9;
        self.viewStatus.alpha = 1.0;
        [self.viewContainer addSubview:self.viewStatus];
        
        self.viewShare = [[OActionButton alloc] initWithFrame:CGRectMake(90.0, self.viewContainer.bounds.size.height - (200.0 + self.padding), self.viewContainer.bounds.size.width - 180.0, 90.0)];
        self.viewShare.backgroundColor = [UIColor clearColor];
        self.viewShare.clipsToBounds = false;
        self.viewShare.delegate = self;
        self.viewShare.title = NSLocalizedString(@"Export_Share_Action", nil);
        self.viewShare.key = @"share";
        self.viewShare.alpha = 0.0;
        [self.viewContainer addSubview:self.viewShare];
        
        self.viewRestart = [[OActionButton alloc] initWithFrame:CGRectMake(100.0, self.viewContainer.bounds.size.height - (120.0), self.viewContainer.bounds.size.width - 200.0, 90.0)];
        self.viewRestart.backgroundColor = [UIColor clearColor];
        self.viewRestart.clipsToBounds = false;
        self.viewRestart.delegate = self;
        self.viewRestart.title = NSLocalizedString(@"Export_Restart_Action", nil);
        self.viewRestart.key = @"restart";
        self.viewRestart.grayscale = true;
        self.viewRestart.alpha = 0.0;
        if (![self.payment paymentPurchasedItemWithProducts:@[@"montage.monthly", @"montage.yearly"]]) self.viewRestart.countdown = 10.0;
        else self.viewRestart.countdown = 0.0;
        [self.viewContainer addSubview:self.viewRestart];
        
        self.viewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        self.viewGesture.delegate = self;
        self.viewGesture.enabled = true;
        [self.viewOverlay addGestureRecognizer:self.viewGesture];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewOverlay setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            [self.generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            [self.generator prepare];
            
            if ([self.delegate respondsToSelector:@selector(modalAlertPresented:)]) {
                [self.delegate modalAlertPresented:self];
                
            }
            
            NSURL *sfx = [[NSBundle mainBundle] URLForResource:@"complete_sfx" withExtension:@"wav"];
            SystemSoundID audioid;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)sfx, &audioid);
            if (error == kAudioServicesNoError) {
                self.complete = audioid;
                AudioServicesPlaySystemSound(self.complete);
                
            }
            
        }];
        
        [UIView animateWithDuration:0.3 delay:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewShare setAlpha:1.0];
            [self.viewRestart setAlpha:1.0];
            
        } completion:nil];
        
        [UIView animateWithDuration:0.7 delay:0.25 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT + 80.0)];
            
        } completion:^(BOOL finished) {
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
            
        }];
        
    }
    
}

-(void)viewActionTapped:(OActionButton *)action {
    if ([action.key isEqualToString:@"share"]) {
        if (self.exported != nil) {
            if ([self.delegate respondsToSelector:@selector(modalAlertCallActivityController:)]) {
                [self dismiss:^(BOOL dismissed) {
                    [self.delegate modalAlertCallActivityController:@[self.exported]];
                    
                }];
                
            }
            
        }
        
    }
    else {
        if (action.disabled) {
            if ([self.delegate respondsToSelector:@selector(viewPurchaseInitialiseWithIdentifyer)]) {
                [self dismiss:^(BOOL dismissed) {
                    [self.delegate viewPurchaseInitialiseWithIdentifyer];
                    
                }];
                
            }

        }
        else {
            if ([self.delegate respondsToSelector:@selector(viewCreateNewStory:)]) {
                [self dismiss:^(BOOL dismissed) {
                    [self.delegate viewCreateNewStory:[NSString stringWithFormat:NSLocalizedString(@"Default_Project_Name", nil) ,self.dataobj.storyExports + 1]];
                    
                }];
                
            }
            
        }
        
    }
    
}

-(void)gesture:(UITapGestureRecognizer *)gesture {
    [self dismiss:^(BOOL dismissed) {
        
    }];
    
}

-(void)dismiss:(void (^)(BOOL dismissed))completion {
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewOverlay setAlpha:0.0];
        [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
        
    } completion:^(BOOL finished) {
        [self.viewOverlay removeFromSuperview];
        [self.viewContainer removeFromSuperview];
        
        [[UIApplication sharedApplication].delegate.window removeFromSuperview];
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        
        completion(true);
        
    }];
    
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
