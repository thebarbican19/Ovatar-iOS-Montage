//
//  OShareController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 01/10/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OActionButton.h"
#import "OPaymentObject.h"
#import "ODataObject.h"
#import "OImageObject.h"
#import "OAnimatedIcon.h"

#import "Mixpanel.h"

#import "SAMLabel.h"

@protocol OShareDelegate;
@interface OShareController : UIView <ODataDelegate, OActionDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id <OShareDelegate> delegate;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) CAShapeLayer *viewRounded;
@property (nonatomic, strong) OAnimatedIcon *viewTick;
@property (nonatomic, strong) OActionButton *viewShare;
@property (nonatomic, strong) OActionButton *viewRestart;
@property (nonatomic, strong) SAMLabel *viewStatus;
@property (nonatomic, strong) UITapGestureRecognizer *viewGesture;

@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) OPaymentObject *payment;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, strong) OImageObject *imageobj;

@property (nonatomic, strong) NSURL *exported;
@property (nonatomic) SystemSoundID complete;
@property (nonatomic, assign) CGSize videosize;

@property (nonatomic, assign) float padding;

-(void)present;
-(void)dismiss:(void (^)(BOOL dismissed))completion;

@end

@protocol OShareDelegate <NSObject>

@optional

-(void)modalAlertPresented:(id)view;
-(void)modalAlertDismissed:(id)view;
-(void)modalAlertDismissedWithAction:(id)view action:(OActionButton *)action;
-(void)modalAlertCallActivityController:(NSArray *)items;

-(void)viewPurchaseInitialiseWithIdentifyer;
-(void)viewCreateNewStory:(NSString *)name;

@end
