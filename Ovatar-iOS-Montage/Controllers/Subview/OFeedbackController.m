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


-(void)viewActionTapped:(OActionButton *)action {
    AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if ([action.key isEqualToString:@"dismiss"]) {
        [self.navigationController popViewControllerAnimated:true];
        
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
            [self.data setObject:self.viewEmail.text forKey:@"ovatar_email"];
            [self.mixpanel.people set:@{@"$email":self.viewEmail.text}];
            [self.delegate viewPresentLoader:true text:NSLocalizedString(@"Feedback_Sending_Title", nil)];
            [self.viewInput resignFirstResponder];
            [self.slack slackSend:self.viewInput.text userdata:[app applicationUserData] type:NFeedbackTypeGeneral completion:^(NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (error == nil || error.code == 200) {
                        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                            [self.viewInput setAlpha:0.0];
                            [self.viewEmail setAlpha:0.0];
                            [self.viewAction setAlpha:0.0];

                        } completion:^(BOOL finished) {
                            [self.viewTick setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
                            [self.viewStatus setFrame:CGRectMake(self.viewStatus.frame.origin.x, self.viewStatus.frame.origin.y - 16.0, self.viewStatus.bounds.size.width, self.viewStatus.bounds.size.height)];
                            [UIView animateWithDuration:0.3 delay:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                [self.viewTick setAlpha:1.0];
                                [self.viewTick setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                                [self.viewStatus setAlpha:1.0];
                                [self.viewStatus setFrame:CGRectMake(self.viewStatus.frame.origin.x, self.viewStatus.frame.origin.y + 16.0, self.viewStatus.bounds.size.width, self.viewStatus.bounds.size.height)];
                                
                            } completion:nil];
                            
                        }];
                        
                    }
                    else [self.viewInput becomeFirstResponder];
                    
                    [self.delegate viewPresentLoader:false text:nil];
                    
                }];
                
            }];
            
        }
        
    }
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];

    self.slack = [[NSlackObject alloc] init];
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.viewEmail = [[UITextField alloc] initWithFrame:CGRectMake(30.0, 4.0, self.view.bounds.size.width - 60.0, 48.0)];
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
    [self.view addSubview:self.viewEmail];

    self.viewInput = [[UITextView alloc] initWithFrame:CGRectMake(25.0, 4.0 + (self.viewEmail.hidden?0.0:self.viewEmail.bounds.size.height), self.view.bounds.size.width - 50.0, self.view.bounds.size.height - self.viewEmail.bounds.size.height + 8.0)];
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
    [self.view addSubview:self.viewInput];
    
    self.viewTick = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 50.0, 60.0, 100.0, 100.0)];
    self.viewTick.backgroundColor = [UIColor clearColor];
    self.viewTick.contentMode = UIViewContentModeScaleAspectFit;
    self.viewTick.image = [UIImage imageNamed:@"export_complete"];
    self.viewTick.transform = CGAffineTransformMakeScale(0.9, 0.9);
    self.viewTick.alpha = 0.0;
    [self.view addSubview:self.viewTick];
    
    self.viewStatus = [[SAMLabel alloc] initWithFrame:CGRectMake(50.0, self.viewTick.frame.origin.y + 180.0, self.view.bounds.size.width - 100.0, 105.0)];
    self.viewStatus.textColor = UIColorFromRGB(0xAAAAB8);
    self.viewStatus.text = NSLocalizedString(@"Feedback_Sent_Placeholder", nil);
    self.viewStatus.font = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
    self.viewStatus.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
    self.viewStatus.textAlignment = NSTextAlignmentCenter;
    self.viewStatus.numberOfLines = 9;
    self.viewStatus.alpha = 0.0;
    [self.view addSubview:self.viewStatus];
    
    self.viewAction = [[OActionButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 220.0, self.view.bounds.size.height - 102.0, 110.0, 90.0)];
    self.viewAction.backgroundColor = [UIColor clearColor];
    self.viewAction.delegate = self;
    self.viewAction.title = NSLocalizedString(@"Feedback_Send_Action", nil);
    [self.view addSubview:self.viewAction];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField tag] == 1) [self viewActionTapped:nil];
    
    return true;
    
}

-(void)textFieldDidShow:(NSNotification*)notification {
    self.keyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewInput setFrame:CGRectMake(self.viewInput.frame.origin.x, self.viewInput.frame.origin.y, self.viewInput.bounds.size.width, self.view.bounds.size.height - (self.viewInput.frame.origin.y + self.viewAction.bounds.size.height + self.keyboard.size.height + 44.0))];
        [self.viewAction setFrame:CGRectMake(self.viewAction.frame.origin.x, (self.view.bounds.size.height - 102.0) - self.keyboard.size.height, 210.0, self.viewAction.bounds.size.height)];

    }];
    
}

-(void)textFieldDidHide:(NSNotification*)notification {
    self.keyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        [self.viewInput setFrame:CGRectMake(self.viewInput.frame.origin.x, self.viewInput.frame.origin.y, self.viewInput.bounds.size.width, self.view.bounds.size.height - (self.viewInput.frame.origin.y + self.viewAction.bounds.size.height + 44.0))];
        [self.viewAction setFrame:CGRectMake(self.viewAction.frame.origin.x, (self.view.bounds.size.height - 102.0), self.viewAction.bounds.size.width, self.viewAction.bounds.size.height)];

    }];
    
}

@end
