//
//  ONoticeView.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 11/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ONotificationDelegate;
@interface ONotificationView : UIView <UIGestureRecognizerDelegate> {
    UIView *container;
    UILabel *label;
    UIImageView *image;
    UITapGestureRecognizer *gesture;
    CAGradientLayer *gradient;

}

typedef NS_ENUM(NSInteger, ONotificationType) {
    ONotificationTypeNotice,
    ONotificationTypeRate,
    ONotificationTypeError
    
};

@property (nonatomic, strong) id <ONotificationDelegate> delegate;
@property (nonatomic, strong) id icon;
@property (nonatomic, assign) int timeout;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) bool action;
@property (nonatomic, assign) float padding;
@property (nonatomic, assign) bool exists;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSDictionary *userobj;
@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;

-(void)notificationPresentWithTitle:(NSString *)title type:(ONotificationType)type;
-(void)notificationDismiss:(BOOL)unamiated;

@end

@protocol ONotificationDelegate <NSObject>

@optional

-(void)notificationViewTapped:(ONotificationView *)alert;

@end

