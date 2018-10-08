//
//  ODocumentController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 04/10/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OActionButton.h"
#import "OPaymentObject.h"
#import "ODataObject.h"
#import "OTitleView.h"

#import "Mixpanel.h"

typedef enum {
    ODocumentTypeSubscription
    
} ODocumentType;

@protocol ODocumentDelegate;
@interface ODocumentController : UIView <UITextViewDelegate, UIGestureRecognizerDelegate, OPaymentDelegate, OTitleViewDelegate>

-(void)present;

@property (nonatomic, strong) id <ODocumentDelegate> delegate;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) CAShapeLayer *viewRounded;
@property (nonatomic, strong) UITapGestureRecognizer *viewGesture;
@property (nonatomic, strong) UITextView *viewContent;
@property (nonatomic, strong) OTitleView *viewHeader;

@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) OPaymentObject *payment;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, assign) float padding;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *header;

@end

@protocol ODocumentDelegate <NSObject>

@optional

-(void)modalAlertPresented:(id)view;
-(void)modalAlertDismissed:(id)view;
-(void)modalAlertCallPurchaseSubview:(int)delay;

@end
