//
//  ODocumentController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 04/10/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "ODocumentController.h"
#import "OConstants.h"

@implementation ODocumentController

#define MODAL_HEIGHT ([UIApplication sharedApplication].delegate.window.bounds.size.height - 240.0)

-(instancetype)init {
    self = [super init];
    if (self) {
        self.mixpanel = [Mixpanel sharedInstance];
        
        self.payment = [[OPaymentObject alloc] init];
        self.payment.delegate = self;
        
        self.dataobj = [[ODataObject alloc] init];
        
        self.generator = [[UINotificationFeedbackGenerator alloc] init];
        
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
        
        self.viewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        self.viewGesture.delegate = self;
        self.viewGesture.enabled = true;
        [self.viewOverlay addGestureRecognizer:self.viewGesture];
        
        self.viewHeader = [[OTitleView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.viewContainer.bounds.size.width, MAIN_HEADER_MODAL_HEIGHT)];
        self.viewHeader.backgroundColor = [UIColor clearColor];
        self.viewHeader.delegate = self;
        self.viewHeader.title = self.header;
        self.viewHeader.backbutton = true;
        [self.viewContainer addSubview:self.viewHeader];
        
        self.viewContent = [[UITextView alloc] initWithFrame:CGRectMake(32.0, MAIN_HEADER_MODAL_HEIGHT, self.viewContainer.bounds.size.width - 64.0, self.viewContainer.bounds.size.height - MAIN_HEADER_MODAL_HEIGHT)];
        self.viewContent.font =  [UIFont fontWithName:@"Avenir-Medium" size:13.0];
        self.viewContent.textColor = UIColorFromRGB(0x757585);
        self.viewContent.attributedText = self.format;
        self.viewContent.editable = false;
        self.viewContent.backgroundColor = [UIColor clearColor];
        self.viewContent.dataDetectorTypes = UIDataDetectorTypeLink;
        self.viewContent.linkTextAttributes = @{NSForegroundColorAttributeName:UIColorFromRGB(0x7490FD)};
        [self.viewContainer addSubview:self.viewContent];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewOverlay setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            [self.generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            [self.generator prepare];
            
        }];
        
        [UIView animateWithDuration:0.7 delay:0.25 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT + 80.0)];
            
        } completion:^(BOOL finished) {
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
            
        }];
        
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewHeader shadow:self.viewContent.contentOffset.y];
    
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
        
        [self.delegate modalAlertDismissed:self];
        
        [[UIApplication sharedApplication].delegate.window removeFromSuperview];
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        
        completion(true);
        
    }];
    
}

-(NSMutableAttributedString *)format {
    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:self.content];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
    NSArray *matches = [regex matchesInString:self.content options:0 range:NSMakeRange(0.0, self.content.length)];
    
    [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Medium" size:13.0] range:NSMakeRange(0, self.content.length)];
    [formatted addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x757585)range:NSMakeRange(0, self.content.length)];
    
    for (NSTextCheckingResult *match in matches) {
        [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:13.0] range:NSMakeRange(match.range.location, match.range.length)];
        [formatted addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x464655)range:NSMakeRange(match.range.location, match.range.length)];
        
    }
    
    [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
    [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
    
    return formatted;
    
}

-(void)titleNavigationBackTapped:(UIButton *)button {
    [self dismiss:^(BOOL dismissed) {
        [self.delegate modalAlertCallPurchaseSubview:0];

    }];
    
}

@end
