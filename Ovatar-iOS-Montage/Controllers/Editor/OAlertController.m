//
//  OAlertController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OAlertController.h"
#import "OConstants.h"

@interface OAlertController ()

@end

@implementation OAlertController

#define MODAL_HEIGHT 340.0
#define MODAL_HEIGHT_LOADING 210.0
#define MODAL_BUTTON_HEIGHT 80.0

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
    if (self.type != OAlertControllerTypeLoading) self.height = MODAL_HEIGHT;
    else self.height = MODAL_HEIGHT_LOADING;
    
    float bheight = 0.0;
    float bwidth = 0.0;
    if (self.buttons.count == 1) bwidth = 220.0;
    else bwidth = [UIApplication sharedApplication].delegate.window.bounds.size.width - 28.0;
    
    if (self.type == OAlertControllerTypeSubscribe) bheight = MODAL_BUTTON_HEIGHT + 30.0;
    else bheight = MODAL_BUTTON_HEIGHT;

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
        
        self.viewPages = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.viewOverlay.bounds.size.width, MODAL_HEIGHT - (bheight + self.padding))];
        self.viewPages.pagingEnabled = true;
        self.viewPages.scrollEnabled = true;
        self.viewPages.delegate = self;
        self.viewPages.alpha = self.type==OAlertControllerTypeSubscribe?1.0:0.0;
        self.viewPages.showsHorizontalScrollIndicator = false;
        self.viewPages.contentSize = CGSizeMake(self.viewPages.bounds.size.width * 3, self.viewPages.bounds.size.height);
        [self.viewContainer addSubview:self.viewPages];
        
        self.viewPlaceholder = [[OAlertPlaceholder alloc] initWithFrame:self.viewPages.frame];
        self.viewPlaceholder.backgroundColor = [UIColor clearColor];
        self.viewPlaceholder.alpha = self.type==OAlertControllerTypeSubscribe?0.0:1.0;
        [self.viewContainer addSubview:self.viewPlaceholder];
        
        self.viewPaging = [[UIPageControl alloc] initWithFrame:CGRectMake((self.viewContainer.bounds.size.width / 2) - 100.0, self.viewPages.bounds.size.height - 24.0, 200.0, 20.0)];
        self.viewPaging.backgroundColor = [UIColor clearColor];
        self.viewPaging.alpha = self.type==OAlertControllerTypeSubscribe?0.2:0.0;
        self.viewPaging.pageIndicatorTintColor = UIColorFromRGB(0xAAAAB8);
        self.viewPaging.currentPageIndicatorTintColor = UIColorFromRGB(0x464655);
        [self.viewContainer addSubview:self.viewPaging];

        if (self.type == OAlertControllerTypeSubscribe) {
            NSArray *products = [self.payment productsFromIdentifyer:self.payment.paymentProductIdentifyer];
            for (int i = 0; i < [products count]; i++) {
                NSString *summary = [[products objectAtIndex:i] objectForKey:@"summary"];
                NSString *image = [[products objectAtIndex:i] objectForKey:@"icon"];

                UIView *placeholder = [[UIView alloc] initWithFrame:CGRectMake(self.viewPages.bounds.size.width * i, 0.0, self.viewPages.bounds.size.width, self.viewPages.bounds.size.height)];
                placeholder.backgroundColor = [UIColor clearColor];
                [self.viewPages addSubview:placeholder];

                UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake((self.viewPages.bounds.size.width / 2) - 40.0, 30.0, 80.0, 80.0)];
                icon.image = [UIImage imageNamed:image];
                icon.contentMode = UIViewContentModeScaleAspectFit;
                [placeholder addSubview:icon];
                
                SAMLabel *label= [[SAMLabel alloc] initWithFrame:CGRectMake(40.0, 130.0, placeholder.bounds.size.width - 80.0, 130.0)];
                label.backgroundColor = [UIColor clearColor];
                label.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
                label.textAlignment = NSTextAlignmentCenter;
                label.numberOfLines = 3;
                label.text = summary;
                label.font = [UIFont fontWithName:@"Avenir-Heavy" size:14];
                label.textColor = UIColorFromRGB(0x464655);
                [placeholder addSubview:label];
                
            }
            
            [self.viewPaging setNumberOfPages:[products count]];
            [self.viewPaging setCurrentPage:0];
            [self.viewPages setContentSize:CGSizeMake(self.viewPages.bounds.size.width * [products count], self.viewPages.bounds.size.height)];
        
        }
        
        self.viewButtons = [[UIView alloc] initWithFrame:CGRectMake(14.0 + ((self.viewPages.bounds.size.width / 2) - (bwidth / 2)), self.viewPages.bounds.size.height, bwidth - 28.0, bheight)];
        self.viewButtons.backgroundColor = [UIColor clearColor];
        [self.viewContainer addSubview:self.viewButtons];
        
        self.viewTerms = [[UIButton alloc] initWithFrame:CGRectMake(0.0, self.viewButtons.bounds.size.height - 30.0, self.viewButtons.bounds.size.width, 30.0)];
        self.viewTerms.titleLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:10];;
        self.viewTerms.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.viewTerms.backgroundColor = [UIColor clearColor];
        self.viewTerms.tag = 99;
        self.viewTerms.alpha = self.type==OAlertControllerTypeSubscribe?1.0:0.0;
        [self.viewTerms setTitleColor:UIColorFromRGB(0xAAAAB8) forState:UIControlStateNormal];
        [self.viewTerms setTitle:NSLocalizedString(@"Subscription_Terms_Action", nil) forState:UIControlStateNormal];
        [self.viewTerms addTarget:self action:@selector(terms) forControlEvents:UIControlEventTouchUpInside];
        [self.viewButtons addSubview:self.viewTerms];

        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewOverlay setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            if (self.type == OAlertControllerTypeError) [self.generator notificationOccurred:UINotificationFeedbackTypeError];
            else [self.generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            [self.generator prepare];
            
            if ([self.delegate respondsToSelector:@selector(modalAlertPresented:)]) {
                [self.delegate modalAlertPresented:self];
                
            }
            
        }];
        
        [UIView animateWithDuration:0.7 delay:0.25 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - self.height, self.viewOverlay.bounds.size.width, self.height + 80.0)];
            
        } completion:^(BOOL finished) {
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - self.height, self.viewOverlay.bounds.size.width, self.height)];
            
        }];
        
        [self setup:false];

    }
    else {
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - self.height, self.viewOverlay.bounds.size.width, self.height)];
            [self.viewButtons setFrame:CGRectMake(14.0 + ((self.viewOverlay.bounds.size.width / 2) - (bwidth / 2)), self.viewContainer.bounds.size.height - (bheight + self.padding), bwidth - 28.0, bheight)];
            [self.viewPlaceholder setAlpha:self.type==OAlertControllerTypeSubscribe?0.0:1.0];
            [self.viewPages setAlpha:self.type==OAlertControllerTypeSubscribe?1.0:0.0];
            [self.viewPaging setAlpha:self.type==OAlertControllerTypeSubscribe?0.2:0.0];
            [self.viewButtons setAlpha:self.type==OAlertControllerTypeLoading?0.0:1.0];
            [self.viewTerms setAlpha:self.type==OAlertControllerTypeSubscribe?1.0:0.0];

        } completion:^(BOOL finished) {
            [self setup:true];

        }];
    
    }
    
    for (UIView *subview in self.viewButtons.subviews) {
        if (subview.tag != 99) [subview removeFromSuperview];
        
    }
    
    for (int i = 0; i < self.buttons.count; i++) {
        NSDictionary *button = [self.buttons objectAtIndex:i];

        UIView *container = [[UIView alloc] initWithFrame:CGRectMake((self.viewButtons.bounds.size.width / 2) * i, 0.0, (self.viewButtons.bounds.size.width / self.buttons.count), MODAL_BUTTON_HEIGHT)];
        container.backgroundColor = [UIColor clearColor];
        [self.viewButtons addSubview:container];
        
        OActionButton *action = [[OActionButton alloc] initWithFrame:container.bounds];
        action.backgroundColor = [UIColor clearColor];
        action.clipsToBounds = false;
        action.delegate = self;
        action.title = [button objectForKey:@"title"];
        action.key = [button objectForKey:@"key"];
        action.grayscale = ![[button objectForKey:@"primary"] boolValue];
        action.modaldismiss = [[button objectForKey:@"dismiss"] boolValue];
        action.padding = 10.0;
        action.countdown = [[button objectForKey:@"delay"] intValue];
        [container addSubview:action];
        
    }
    
}

-(void)setup:(BOOL)exists {
    if (self.type == OAlertControllerTypeError) {
        if (self.error.code == 200 || self.error == nil) {
            [self setType:OAlertControllerTypeComplete];
            [self setup:true];
            
        }
        
        NSString *errosubtitle = NSLocalizedString(@"Error_Description_Unknown", nil);
        if ([self.error.domain containsString:@" "] && [self.error.domain length] > 1)
            errosubtitle = self.error.domain;
        else if ([self.error.localizedFailureReason containsString:@" "] && [self.error.localizedFailureReason length] > 1)
            errosubtitle = self.error.localizedFailureReason;
        else if ([self.error.localizedDescription containsString:@" "] && [self.error.localizedDescription length] > 1)
            errosubtitle = self.error.localizedDescription;
        
        NSString *errortitle = [NSString stringWithFormat:@"Error_Title_%d" ,arc4random_uniform(3) + 1];
        errortitle = NSLocalizedString(errortitle, nil);
        
        [self setCandismiss:true];
        [self.viewPlaceholder setup:errortitle subtitle:errosubtitle icon:OAnimatedIconTypeError animate:exists];
        [self.mixpanel track:@"App Error Presented" properties:@{@"Text":errosubtitle}];

    }
    else if (self.type == OAlertControllerTypePush) {
        NSString *errortitle = NSLocalizedString(@"Permissions_Title_Notifications", nil);
        NSString *errosubtitle = NSLocalizedString(@"Permissions_Description_Notifications", nil);

        [self.viewPlaceholder setup:errortitle subtitle:errosubtitle icon:OAnimatedIconTypePush animate:false];
        
    }
    else if (self.type == OAlertControllerTypeComplete) {
        NSString *errortitle = [NSString stringWithFormat:@"Subscription_Complete_Title_%d" ,arc4random_uniform(3) + 1];
        errortitle = NSLocalizedString(errortitle, nil);
        
        if (self.subtitle == nil) self.subtitle = NSLocalizedString(@"Error_Description_Unknown", nil);
        
        [self.viewPlaceholder setup:errortitle subtitle:self.subtitle icon:OAnimatedIconTypeComplete animate:false];

    }
    else if (self.type == OAlertControllerTypeLoading) {
        NSString *errortitle = NSLocalizedString(@"Subscription_Loading_Title", nil);
        NSString *errorsubtitle = NSLocalizedString(@"Subscription_Loading_Description", nil);
        
        [self.viewPlaceholder setup:errortitle subtitle:errorsubtitle icon:OAnimatedIconTypeLoading animate:false];
        
    }
    else if (self.type == OAlertControllerTypeRender) {
        NSString *errortitle = NSLocalizedString(@"Export_Rendering_Title", nil);
        NSString *errorsubtitle = [NSString stringWithFormat:NSLocalizedString(@"Export_Rendering_Description", nil), self.dataobj.storyActiveName, 0];;

        [self.viewPlaceholder setup:errortitle subtitle:errorsubtitle icon:OAnimatedIconTypeRender animate:false];
        
    }
    else if (self.type == OAlertControllerTypeImporting) {
        NSString *errortitle = NSLocalizedString(@"Export_Importing_Title", nil);
        NSString *errorsubtitle = [NSString stringWithFormat:NSLocalizedString(@"Export_Importing_Description", nil), self.dataobj.storyActiveName, 0];;
        
        [self.viewPlaceholder setup:errortitle subtitle:errorsubtitle icon:OAnimatedIconTypeRender animate:false];
        
    }
    
}

-(void)gesture:(UITapGestureRecognizer *)gesture {
    if (self.candismiss) {
        [self dismiss:^(BOOL dismissed) {
            
        }];
        
    }
    
}

-(void)dismiss:(void (^)(BOOL dismissed))completion {
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewOverlay setAlpha:0.0];
        [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height, self.viewOverlay.bounds.size.width, self.height)];

    } completion:^(BOOL finished) {
        [self.viewOverlay removeFromSuperview];
        [self.viewContainer removeFromSuperview];
        
        if ([self.delegate respondsToSelector:@selector(modalAlertDismissed:)]) {
            [self.delegate modalAlertDismissed:self];
            
        }
        
        [[UIApplication sharedApplication].delegate.window removeFromSuperview];
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        
        [[NSNotificationCenter defaultCenter] removeObserver:@"LoaderExportStatus"];
        
        completion(true);
        
        self.type = 0;
        self.error = nil;
        self.key = nil;
        self.buttons = nil;
        self.subtitle = nil;
        
    }];

}

-(void)terms {
    [self dismiss:^(BOOL dismissed) {
        if (![self.payment paymentPurchasedItemWithProducts:@[@"montage.monthly", @"montage.yearly"]]) {
            [self.delegate modalAlertCallDocumentController:ODocumentTypeSubscription];
            
        }
        
    }];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewPaging setCurrentPage:(scrollView.contentOffset.x + (0.5f * self.viewPages.bounds.size.width)) / self.viewPages.bounds.size.width];
    
}

-(void)viewActionTapped:(OActionButton *)action {
    if ([action.key isEqualToString:@"purchase"]) {
        [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewPages setAlpha:0.0];
            [self.viewButtons setAlpha:0.0];
            
        } completion:^(BOOL finished) {
            [self setCandismiss:false];
            [self.delegate viewPurchaseInitialiseWithIdentifyer];
            
        }];
        
    }
    else {
        if ([self.delegate respondsToSelector:@selector(modalAlertDismissedWithAction:action:)]) {
            if (action.modaldismiss) {
                [self dismiss:^(BOOL dismissed) {
                    [self.delegate modalAlertDismissedWithAction:self action:action];
                    
                }];
                
            }
            else [self.delegate modalAlertDismissedWithAction:self action:action];
            
        }
        
    }
    
}

-(void)viewActionCountdownComplete:(OActionButton *)action {
    if ([self.delegate respondsToSelector:@selector(viewActionCountdownComplete:)]) {
        [self.delegate modalAlertActionCountdownComplete:self action:action];
        
    }
    
}

@end
