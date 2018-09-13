//
//  AppDelegate.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 10/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <StoreKit/StoreKit.h>

#import "Mixpanel.h"
#import "ODataObject.h"
#import "OPaymentObject.h"
#import "OLoaderView.h"
#import "OTickerLabel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSUserDefaults *data;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) Mixpanel *mixpanel;
@property (strong, nonatomic) ODataObject *model;
@property (strong, nonatomic) OPaymentObject *payment;
@property (strong, nonatomic) UIView *splash;
@property (strong, nonatomic) OLoaderView *loader;
@property (assign) float padding;
@property (strong, nonatomic) NSArray *lassets;
@property (strong, nonatomic) NSString *ltext;
@property (strong, nonatomic) OTickerLabel *ticker;

-(int)applicationTimer;
-(NSString *)applicationTimerFormatted;
-(NSDictionary *)applicationUserData;

-(void)applicationRatePrompt;
-(void)applicationLoadingScreen:(BOOL)loading;

@end

