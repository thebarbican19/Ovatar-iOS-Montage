//
//  OFeedbackController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 28/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITextView+Placeholder.h"

#import "OActionButton.h"
#import "OTitleView.h"

@protocol OFeedbackDelegate;
@interface OFeedbackController : UIView <UITextViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, OActionDelegate, OTitleViewDelegate>

@property (nonatomic, strong) id <OFeedbackDelegate> delegate;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) CAShapeLayer *viewRounded;
@property (nonatomic, strong) UITapGestureRecognizer *viewGesture;
@property (nonatomic, strong) UITextView *viewInput;
@property (nonatomic, strong) UITextField *viewEmail;
@property (nonatomic, strong) OActionButton *viewAction;
@property (nonatomic, strong) OTitleView *viewHeader;

@property (nonatomic, strong) NSString *attachement;
@property (nonatomic, assign) CGRect keyboard;

@property (nonatomic, strong) NSUserDefaults *data;

-(void)present;

@end

@protocol OFeedbackDelegate <NSObject>

@optional

-(void)viewSendFeedback:(NSString *)email message:(NSString *)message;

-(void)titleNavigationButtonTapped:(OTitleButtonType)button;
-(void)titleNavigationHeaderTapped:(OTitleView *)view;

@end
