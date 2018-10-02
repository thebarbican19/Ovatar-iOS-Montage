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

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSUserDefaults *data;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) Mixpanel *mixpanel;
@property (strong, nonatomic) ODataObject *model;
@property (strong, nonatomic) OPaymentObject *payment;
@property (strong, nonatomic) UIView *splash;
@property (assign) float padding;

-(int)applicationTimer;
-(NSString *)applicationTimerFormatted;
-(NSDictionary *)applicationUserData;

-(void)applicationRatePrompt;

@end

