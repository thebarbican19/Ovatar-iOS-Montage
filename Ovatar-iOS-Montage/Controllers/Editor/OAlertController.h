//
//  OAlertController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OAlertPlaceholder.h"
#import "OActionButton.h"
#import "OPaymentObject.h"
#import "ODataObject.h"
#import "ODocumentController.h"

#import "Mixpanel.h"

typedef enum {
    OAlertControllerTypeError,
    OAlertControllerTypePush,
    OAlertControllerTypeComplete,
    OAlertControllerTypeLoading,
    OAlertControllerTypeSubscribe,
    OAlertControllerTypeRender,
    OAlertControllerTypeImporting
    
} OAlertControllerType;

@protocol OAlertDelegate;
@interface OAlertController : UIView <UIGestureRecognizerDelegate, UIScrollViewDelegate, OActionDelegate, OPaymentDelegate>

@property (nonatomic, strong) id <OAlertDelegate> delegate;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) CAShapeLayer *viewRounded;
@property (nonatomic, strong) UITapGestureRecognizer *viewGesture;
@property (nonatomic, strong) OAlertPlaceholder *viewPlaceholder;
@property (nonatomic, strong) UIScrollView *viewPages;
@property (nonatomic, strong) UIPageControl *viewPaging;
@property (nonatomic, strong) UIButton *viewTerms;
@property (nonatomic, strong) UIView *viewButtons;

@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) OPaymentObject *payment;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, assign) BOOL candismiss;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, assign) OAlertControllerType type;
@property (nonatomic, assign) float padding;
@property (nonatomic, assign) float height;

-(void)present;
-(void)dismiss:(void (^)(BOOL dismissed))completion;

@end

@protocol OAlertDelegate <NSObject>

@optional

-(void)modalAlertPresented:(id)view;
-(void)modalAlertDismissed:(id)view;
-(void)modalAlertDismissedWithAction:(id)view action:(OActionButton *)action;
-(void)modalAlertActionCountdownComplete:(id)view action:(OActionButton *)action;
-(void)modalAlertCallDocumentController:(ODocumentType)type;

-(void)viewPurchaseInitialiseWithIdentifyer;

@end
