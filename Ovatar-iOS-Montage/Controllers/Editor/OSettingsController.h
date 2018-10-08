//
//  ODocumentController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 22/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ODataObject.h"
#import "OTitleView.h"
#import "OActionButton.h"
#import "OSettingsFooter.h"
#import "OPaymentObject.h"
#import "OImageObject.h"
#import "ODataObject.h"

#import "GDActionSheet.h"

#import "Mixpanel.h"

typedef enum {
    OSettingsSubviewTypeMusic,
    OSettingsSubviewTypeWatermark,
    OSettingsSubviewTypeMain
    
} OSettingsSubviewType;

@protocol OSettingsDelegate;
@interface OSettingsController : UIView <OTitleViewDelegate, ODataDelegate, GDActionSheetDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) id <OSettingsDelegate> delegate;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) CAShapeLayer *viewRounded;
@property (nonatomic, strong) OTitleView *viewHeader;
@property (nonatomic, strong) UITableView *viewTable;
@property (nonatomic, strong) UITapGestureRecognizer *viewGesture;
@property (nonatomic, retain) GDActionSheet *viewSheet;
@property (nonatomic, retain) OSettingsFooter *viewFooter;

@property (nonatomic, strong) OPaymentObject *payment;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableArray *settings;
@property (nonatomic, strong) NSMutableArray *document;
@property (nonatomic, strong) NSDictionary *selected;
@property (nonatomic, assign) OSettingsSubviewType type;

@property (nonatomic, strong) NSMutableArray *music;
@property (nonatomic, strong) NSMutableArray *imported;
@property (nonatomic, strong) NSMutableArray *watermarks;
@property (nonatomic, assign) float padding;
@property (nonatomic, assign) CGRect keyboard;

-(void)present:(OSettingsSubviewType)type;
-(void)dismiss:(void (^)(BOOL dismissed))completion;

@end

@protocol OSettingsDelegate <NSObject>

@optional

-(void)modalAlertPresented:(id)view;
-(void)modalAlertDismissed:(id)view;
-(void)modalAlertDismissedWithAction:(id)view action:(OActionButton *)action;
-(void)modalAlertCallPurchaseSubview:(int)delay;
-(void)modalAlertCallFeedbackSubview;
-(void)modalAlertCallSafariController:(NSURL *)url;
-(void)modalAlertCallActivityController:(NSArray *)items;
-(void)modalAlertCallMusicController;
-(void)modalAlertCallActionSheet:(NSArray *)buttons key:(NSString *)key;

-(void)viewRestorePurchases;

@end

