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
#import "NSlackObject.h"
#import "SAMLabel.h"

@protocol OFeedbackDelegate;
@interface OFeedbackController : UIViewController <UITextViewDelegate, OActionDelegate>

@property (nonatomic, strong) id <OFeedbackDelegate> delegate;
@property (nonatomic, strong) UITextView *viewInput;
@property (nonatomic, strong) OActionButton *viewAction;
@property (nonatomic, strong) SAMLabel *viewStatus;
@property (nonatomic, strong) UIImageView *viewTick;

@property (nonatomic, strong) NSString *attachement;
@property (nonatomic, assign) CGRect keyboard;

@property (nonatomic, strong) NSlackObject *slack;

@end

@protocol OFeedbackDelegate <NSObject>

@optional

-(void)viewPresentLoader:(BOOL)present text:(NSString *)text;

@end
