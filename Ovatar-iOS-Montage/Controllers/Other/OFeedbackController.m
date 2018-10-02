//
//  OFeedbackController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 28/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OFeedbackController.h"
#import "OConstants.h"

#import "AppDelegate.h"

@interface OFeedbackController ()

@end

@implementation OFeedbackController

#define MODAL_HEIGHT ([UIApplication sharedApplication].delegate.window.bounds.size.height - 120.0)
#define MODAL_BUTTON_HEIGHT 80.0

-(void)viewActionTapped:(OActionButton *)action {
    if ([action.key isEqualToString:@"dismiss"]) {
        [self dismiss:^(BOOL dismissed) {
            
        }];
        
    }
    else {
        if (![[NSPredicate predicateWithFormat:@"SELF MATCHES %@", REGEX_EMAIL] evaluateWithObject:self.viewEmail.text]) {
            CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
            [shake setDuration:0.1];
            [shake setRepeatCount:2];
            [shake setAutoreverses:true];
            [shake setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.viewEmail.center.x - 3,self.viewEmail.center.y)]];
            [shake setToValue:[NSValue valueWithCGPoint:CGPointMake(self.viewEmail.center.x + 3, self.viewEmail.center.y)]];
            
            [self.viewEmail.layer addAnimation:shake forKey:@"position"];
            [self.viewEmail becomeFirstResponder];

        }
        else if ([self.viewInput.text length] < 5) {
            CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"position"];
            [shake setDuration:0.1];
            [shake setRepeatCount:2];
            [shake setAutoreverses:true];
            [shake setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.viewInput.center.x - 3,self.viewInput.center.y)]];
            [shake setToValue:[NSValue valueWithCGPoint:CGPointMake(self.viewInput.center.x + 3, self.viewInput.center.y)]];
            
            [self.viewInput.layer addAnimation:shake forKey:@"position"];
            [self.viewInput becomeFirstResponder];
            
        }
        else {
            [self.viewEmail resignFirstResponder];
            [self.viewInput resignFirstResponder];

            [self dismiss:^(BOOL dismissed) {
                [self.delegate viewSendFeedback:self.viewEmail.text message:self.viewInput.text];
                
            }];
            
        }
        
    }
    
}

-(void)present {
    self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    if (![[UIApplication sharedApplication].delegate.window.subviews containsObject:self.viewOverlay]) {
        self.viewOverlay = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
        self.viewOverlay.backgroundColor = MAIN_MODAL_BACKGROUND;
        self.viewOverlay.alpha = 0.0;
        self.viewOverlay.userInteractionEnabled = true;
        
        self.viewRounded = [CAShapeLayer layer];
        self.viewRounded.path = [UIBezierPath bezierPathWithRoundedRect:self.viewOverlay.bounds byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight cornerRadii:CGSizeMake(MAIN_CORNER_EDGES, MAIN_CORNER_EDGES)].CGPath;
        
        self.viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
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
        self.viewHeader.title = NSLocalizedString(@"Main_Support_Title", nil);
        self.viewHeader.backbutton = true;
        [self.viewContainer addSubview:self.viewHeader];
        
        self.viewEmail = [[UITextField alloc] initWithFrame:CGRectMake(38.0, MAIN_HEADER_MODAL_HEIGHT, self.viewContainer.bounds.size.width - 86.0, 48.0)];
        self.viewEmail.placeholder = NSLocalizedString(@"Feedback_Email_Placeholder", nil);
        self.viewEmail.text = [self.data objectForKey:@"ovatar_email"];
        self.viewEmail.hidden = self.viewEmail.text.length>5?true:false;
        self.viewEmail.keyboardType = UIKeyboardTypeEmailAddress;
        self.viewEmail.returnKeyType = UIReturnKeyNext;
        self.viewEmail.keyboardAppearance = UIKeyboardAppearanceLight;
        self.viewEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.viewEmail.backgroundColor = [UIColor clearColor];
        self.viewEmail.font =  [UIFont fontWithName:@"Avenir-Medium" size:16.0];
        self.viewEmail.textColor = UIColorFromRGB(0xAAAAB8);
        self.viewEmail.delegate = self;
        self.viewEmail.tag = 1;
        [self.viewContainer addSubview:self.viewEmail];

        self.viewInput = [[UITextView alloc] initWithFrame:CGRectMake(32.0, MAIN_HEADER_MODAL_HEIGHT + (self.viewEmail.hidden?0.0:self.viewEmail.bounds.size.height), self.viewContainer.bounds.size.width - 64.0, self.viewContainer.bounds.size.height - self.viewEmail.bounds.size.height + 8.0)];
        self.viewInput.textColor = UIColorFromRGB(0xAAAAB8);
        self.viewInput.delegate = self;
        self.viewInput.text = nil;
        self.viewInput.placeholder = NSLocalizedString(@"Feedback_Default_Placeholder", nil);
        self.viewInput.keyboardAppearance = UIKeyboardAppearanceLight;
        self.viewInput.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        self.viewInput.font =  [UIFont fontWithName:@"Avenir-Medium" size:16.0];
        self.viewInput.backgroundColor = [UIColor clearColor];
        self.viewInput.layer.cornerRadius = 4.0;
        self.viewInput.clipsToBounds = true;
        self.viewInput.tag = 2;
        self.viewInput.returnKeyType = UIReturnKeyDefault;
        self.viewEmail.keyboardType = UIKeyboardTypeDefault;
        [self.viewContainer addSubview:self.viewInput];
        
        self.viewAction = [[OActionButton alloc] initWithFrame:CGRectMake((self.viewContainer.bounds.size.width / 2) - 110.0, self.viewContainer.bounds.size.height - 102.0, 220.0, MODAL_BUTTON_HEIGHT)];
        self.viewAction.backgroundColor = [UIColor clearColor];
        self.viewAction.delegate = self;
        self.viewAction.padding = 10.0;
        self.viewAction.title = NSLocalizedString(@"Feedback_Send_Action", nil);
        [self.viewContainer addSubview:self.viewAction];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewOverlay setAlpha:1.0];
            
        } completion:nil];
        
        [UIView animateWithDuration:0.7 delay:0.25 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT + 80.0)];
            
        } completion:^(BOOL finished) {
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
            
        }];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)titleNavigationBackTapped:(UIButton *)button {
    [self dismiss:^(BOOL dismissed) {
        [self.delegate titleNavigationButtonTapped:OTitleButtonTypeSettings];
        
    }];
    
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

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField tag] == 1) [self viewActionTapped:nil];
    
    return true;
    
}

-(void)textFieldDidShow:(NSNotification*)notification {
    self.keyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewInput setFrame:CGRectMake(self.viewInput.frame.origin.x, self.viewInput.frame.origin.y, self.viewInput.bounds.size.width, self.viewContainer.bounds.size.height - (self.viewInput.frame.origin.y + self.viewAction.bounds.size.height + self.keyboard.size.height + 44.0))];
        [self.viewAction setFrame:CGRectMake(self.viewAction.frame.origin.x, (self.viewContainer.bounds.size.height - 102.0) - self.keyboard.size.height, 210.0, self.viewAction.bounds.size.height)];

    }];
    
}

-(void)textFieldDidHide:(NSNotification*)notification {
    self.keyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewInput setFrame:CGRectMake(self.viewInput.frame.origin.x, self.viewInput.frame.origin.y, self.viewInput.bounds.size.width, self.viewContainer.bounds.size.height - (self.viewInput.frame.origin.y + self.viewAction.bounds.size.height + 44.0))];
        [self.viewAction setFrame:CGRectMake(self.viewAction.frame.origin.x, (self.viewContainer.bounds.size.height - 102.0), self.viewAction.bounds.size.width, self.viewAction.bounds.size.height)];

    }];
    
}

@end
