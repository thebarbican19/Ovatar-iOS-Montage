//
//  AppDelegate.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 10/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "AppDelegate.h"
#import "OConstants.h"
#import "OOnboardingController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.payment = [[OPaymentObject alloc] init];
    self.mixpanel = [Mixpanel sharedInstance];
    self.statsobj = [OStatsObject sharedInstance];

    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        [self.data setBool:true forKey:@"app_inactive"];
        [self.data synchronize];
        
    }
    
    [Mixpanel sharedInstanceWithToken:@"432df9ded107b072fd653eece3749fc0"];

    [self.payment paymentRetriveCurrentPricing];
    
    [self applicationSetupShortcuts];
    [self applicationVersionCheck];
    [self applicationCheckCrashes];
    [self applicationSetActiveTimer:true];
    
    if (![self.data boolForKey:@"app_installed"]) {
        [self.data setBool:true forKey:@"app_installed"];
        [self.mixpanel track:@"App Installed" properties:nil];
        if ([self applicationUserData]) {
            NSString *name = [NSString stringWithFormat:@"%@" ,[[self applicationUserData] objectForKey:@"name"]];
            NSString *sex = [NSString stringWithFormat:@"%@" ,[[self applicationUserData] objectForKey:@"sex"]];

            [self.mixpanel identify:self.mixpanel.distinctId];
            [self.mixpanel.people set:@{@"$first_name":name,
                                        @"Gender":sex,
                                        @"Installed On":[NSDate date],
                                        @"Installed Version":APP_VERSION}];
            
            NSLog(@"Set Name in Mixpanel %@" ,[self applicationUserData]);
            
        }
    
    }
    else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MMMM YYYY";
        
        NSMutableDictionary *stats = [[NSMutableDictionary alloc] init];
        if (self.statsobj.capturesTotal > 5) {
            [stats setObject:@(self.statsobj.capturesTotal) forKey:@"Photos Total"];
            [stats setObject:@(self.statsobj.capturesThisMonth) forKey:[NSString stringWithFormat:@"Photos %@" ,[formatter stringFromDate:[NSDate date]]]];

        }
        
        if (self.statsobj.visitedCountries.count > 0) {
            [stats setObject:self.statsobj.visitedCountries forKey:@"Visited Countries"];
            [stats setObject:self.statsobj.vistedUnescoSites forKey:@"Visited Unesco Sites"];
            [stats setObject:self.statsobj.favoritePlace forKey:@"Favorite Place"];

        }
        
        [self.mixpanel identify:self.mixpanel.distinctId];
        [self.mixpanel.people set:stats];
        
        NSLog(@"Set Mixpanel Stats: %@" ,stats);
                                
        [self.mixpanel track:@"App Opened" properties:@{@"version":APP_VERSION, @"build":APP_BUILD}];
    
    }
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    
    return true;
    
}

-(void)applicationStatsInitialize {
    [[OStatsObject sharedInstance] initiate];

}

-(BOOL)applicationInstalled {
    return [[self.data objectForKey:@"app_installed"] boolValue];
    
}

-(BOOL)applicationRated {
    return [[self.data objectForKey:@"app_rated"] boolValue];
    
}

-(int)applicationTimer {
    int duration = [[self.data objectForKey:@"app_timer"] intValue];
    return duration;
    
}

-(NSString *)applicationTimerFormatted {
    int duration = [[self.data objectForKey:@"app_timer"] intValue];
    return [NSString stringWithFormat:@"%02d mins %02d secs" ,duration / 60, duration % 60];
    
}

-(void)applicationCheckCrashes {
    if ([[self.data objectForKey:@"app_installed"] boolValue] && ![[self.data objectForKey:@"app_killed"] boolValue]) {
        if (!APP_DEBUG_MODE) {
            //[self.api cacheDestroy:nil];
            
        }
        
    }
    
    [self.data setBool:false forKey:@"app_killed"];
    [self.data synchronize];
    
}

-(void)applicationVersionCheck {
    self.mixpanel = [Mixpanel sharedInstance];
    if ([[self.data objectForKey:@"app_installed"] boolValue] && ([[self.data objectForKey:@"app_version"] floatValue] != APP_VERSION_FLOAT || [[self.data objectForKey:@"app_build"] floatValue] != APP_BUILD_FLOAT || [[self.data objectForKey:@"app_version"] floatValue] == 0)) {
        [self.data setFloat:APP_VERSION_FLOAT forKey:@"app_version"];
        [self.data setFloat:APP_BUILD_FLOAT forKey:@"app_build"];
        [self.mixpanel track:@"App Updated" properties:@{@"version":APP_VERSION, @"build":APP_BUILD}];
        
    }
    
}

-(void)applicationSetActiveTimer:(BOOL)initiate  {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    
    if (!self.timer.isValid && initiate) self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(applicationSetActiveTimer:) userInfo:nil repeats:true];
    
    int active = [[self.data objectForKey:@"app_timer"] intValue] + 1;
    
    [self.data setInteger:active forKey:@"app_timer"];
    [self.data synchronize];
    
}

-(void)applicationRatePrompt {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.mixpanel = [Mixpanel sharedInstance];
    self.dataobj = [[ODataObject alloc] init];
    if (self.applicationTimer > 60 * 3 && self.applicationRated == false && self.dataobj.storyExports > 0) {
        if (@available(iOS 10.3, *)) {
            [SKStoreReviewController requestReview];
            
            [self.data setObject:@(true) forKey:@"app_rated"];
            [self.mixpanel track:@"App Rated"];
            
        }
        
    }
    
}

-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    [self applicationOpenFromURL:url];
    
    return true;

}

-(void)applicationOpenFromURL:(NSURL *)url {
    self.mixpanel = [Mixpanel sharedInstance];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for (NSString *components in [url.query componentsSeparatedByString:@"&"]) {
        [parameters setObject:[[components componentsSeparatedByString:@"="] lastObject] forKey:[[components componentsSeparatedByString:@"="] firstObject]];
        
    }
    
    if (parameters) {
        [self.mixpanel track:@"App Opened from URL" properties:@{@"URL":[NSString stringWithFormat:@"%@" ,url]}];
        
        if ([url.host isEqualToString:@"promo"]) {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            OOnboardingController *viewMain = (OOnboardingController *)window.rootViewController;
            [viewMain viewAppDelegateCallback:OOOnboardingControllerCallbackTypePromo data:[parameters objectForKey:@"code"]];

        }
        
    }
    
    if ([parameters objectForKey:@"email"] != nil) {
        [self.mixpanel identify:self.mixpanel.distinctId];
        [self.mixpanel.people set:@{@"$email":[parameters objectForKey:@"email"]}];
                                    
        [self.data setObject:[parameters objectForKey:@"email"] forKey:@"ovatar_email"];
        [self.data synchronize];
        
    }
    
    if ([parameters objectForKey:@"name"] != nil) {
        [self.mixpanel identify:self.mixpanel.distinctId];
        [self.mixpanel.people set:@{@"$name":[parameters objectForKey:@"name"]}];
        
        [self.data setObject:[parameters objectForKey:@"name"] forKey:@"ovatar_name"];
        [self.data synchronize];
        
    }
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    [[OStatsObject sharedInstance] initiate];
    
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    [[OStatsObject sharedInstance] suspend];

}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];

    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(applicationRatePrompt) userInfo:nil repeats:false];
    
    [self.data setBool:false forKey:@"app_inactive"];
    [self.data synchronize];
    
    [self applicationSetActiveTimer:true];
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    for (int i = 0; i < 300; i++) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = NSLocalizedString(@"Notification_Title_Reminder", nil);
        content.body = NSLocalizedString(@"Notification_Body_Reminder", nil);
        content.sound = [UNNotificationSound soundNamed:@"complete_sfx"];
        content.badge = 0;
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60*60*24*i];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *triggerdate = [calendar components:NSCalendarUnitYear|
                                         NSCalendarUnitMonth|NSCalendarUnitDay|
                                         NSCalendarUnitHour|NSCalendarUnitMinute|
                                         NSCalendarUnitSecond|NSCalendarUnitTimeZone fromDate:date];
        triggerdate.hour = 19;
        triggerdate.minute = 30;
        triggerdate.second = 0;
        triggerdate.timeZone = triggerdate.timeZone;
        
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:triggerdate repeats:false];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"reminder_notification"
                                                                              content:content
                                                                              trigger:trigger];
        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"\nAdded Recent Notification '%@' on %@" ,date ,content.title);
                
            }
            
        }];
        
    }
    
    [[Mixpanel sharedInstance].people addPushDeviceToken:deviceToken];

    
}

-(void)applicationSetupShortcuts {
    NSMutableArray *shortcuts = [[NSMutableArray alloc] init];
//    UIApplicationShortcutItem *capture = [[UIApplicationShortcutItem alloc]
//                                           initWithType:@"com.ovatar.montage.quickaction.capture"
//                                           localizedTitle:NSLocalizedString(@"Extension_Shortcut_Capture", nil)
//                                           localizedSubtitle:nil
//                                           icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeCaptureVideo]
//                                           userInfo:nil];
    
    UIApplicationShortcutItem *todays = [[UIApplicationShortcutItem alloc]
                                           initWithType:@"com.ovatar.montage.quickaction.importtoday"
                                           localizedTitle:NSLocalizedString(@"Extension_Shortcut_Todays", nil)
                                           localizedSubtitle:nil
                                           icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeTime]
                                           userInfo:nil];
    
    //[shortcuts addObject:capture];
    [shortcuts addObject:todays];
    
    [[UIApplication sharedApplication] setShortcutItems:shortcuts];
    
    
}

-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    self.dataobj = [[ODataObject alloc] init];
    self.imageobj = [OImageObject sharedInstance];
    if ([shortcutItem.type isEqualToString:@"com.ovatar.montage.quickaction.importtoday"]) {
        [self.imageobj imageReturnFromDay:[NSDate date] completion:^(NSArray *images) {
            NSMutableArray *append = [[NSMutableArray alloc] initWithArray:images];
            NSString *story = self.dataobj.storyActiveKey;
            for (PHAsset *asset in append) {
                if ([self.dataobj storyContainsAssets:story asset:asset.localIdentifier]) {
                    [append removeObject:asset];
                    
                }
                
            }
            
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            OOnboardingController *viewMain = (OOnboardingController *)window.rootViewController;
            [viewMain viewAppDelegateCallback:OOOnboardingControllerCallbackTypeShortcut data:append];
            
        }];
        
    }
    
}

-(void)applicationWillResignActive:(UIApplication *)application {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.payment = [[OPaymentObject alloc] init];
    
    [self.payment paymentDestroyCurrentPricing];

    [self.data setObject:[NSDate date] forKey:@"app_lastopened"];
    [self.data setBool:true forKey:@"app_killed"];
    [self.data synchronize];
    
    [self.timer invalidate];
    
}

-(void)applicationWillTerminate:(UIApplication *)application {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.payment = [[OPaymentObject alloc] init];

    [self.payment paymentDestroyCurrentPricing];

    [self.data setObject:[NSDate date] forKey:@"app_lastopened"];
    [self.data setBool:true forKey:@"app_killed"];
    [self.data synchronize];
    
    [self.timer invalidate];
        
}

-(NSDictionary *)applicationUserData {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];

    NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
    NSString *device = [UIDevice currentDevice].name;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"NamesDetect" ofType:@"json"];
    NSArray *content = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
    for (NSString *word in [device componentsSeparatedByString:@" "]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE[c] %@" ,word.capitalizedString];
        NSDictionary *output = [[content filteredArrayUsingPredicate:predicate] firstObject];
        if (output != nil) {
            if ([output objectForKey:@"name"] != nil) {
                [user setObject:[output objectForKey:@"name"] forKey:@"name"];
                
            }
            if ([self.data objectForKey:@"ovatar_email"] != nil) {
                [user setObject:[self.data objectForKey:@"ovatar_email"] forKey:@"email"];

            }
            if ([self.data objectForKey:@"ovatar_town"] != nil) {
                [user setObject:[self.data objectForKey:@"ovatar_town"] forKey:@"city"];
                
            }
            if ([self.data objectForKey:@"ovatar_country"] != nil) {
                [user setObject:[self.data objectForKey:@"ovatar_country"] forKey:@"country"];
            
            }
            if ([[output objectForKey:@"sex"] isEqualToString:@"M"]) [user setObject:@"Male" forKey:@"sex"];
            else [user setObject:@"Female" forKey:@"sex"];
            break;
            
        }
        
    }
   
    return user;
   
    
}

@end
