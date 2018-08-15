//
//  AppDelegate.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 10/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "AppDelegate.h"
#import "OConstants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.data =  [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
    self.payment = [[OPaymentObject alloc] init];

    [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"_UIConstraintBasedLayoutLogUnsatisfiable"];

    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        [self.data setBool:true forKey:@"app_inactive"];
        [self.data synchronize];
        
    }
    
    [self.payment paymentRetriveCurrentPricing];

    [self applicationVersionCheck];
    [self applicationCheckCrashes];
    [self applicationSetActiveTimer:true];
    
    [self.data setBool:true forKey:@"app_installed"];
    
    return true;
    
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
    if ([[self.data objectForKey:@"app_installed"] boolValue] && ([[self.data objectForKey:@"app_version"] floatValue] != APP_VERSION_FLOAT || [[self.data objectForKey:@"app_build"] floatValue] != APP_BUILD_FLOAT || [[self.data objectForKey:@"app_version"] floatValue] == 0)) {
        [self.data setFloat:APP_VERSION_FLOAT forKey:@"app_version"];
        [self.data setFloat:APP_BUILD_FLOAT forKey:@"app_build"];
        
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
    self.model = [[ODataObject alloc] init];
    if (self.applicationTimer > 60 * 3 && self.applicationRated == false && self.model.storyExports > 0) {
        if (APP_DEVICE_FLOAT >= 10.3) {
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

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
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
        
        [(UINavigationController  *)self.window.rootViewController popToRootViewControllerAnimated:false];
        [(UINavigationController  *)self.window.rootViewController dismissViewControllerAnimated:false completion:nil];
        
        if ([url.host isEqualToString:@"promo"]) {
//            SHUpgradeController *viewUpgraded = [[SHUpgradeController alloc] init];
//            viewUpgraded.view.backgroundColor = [UIColor whiteColor];
//
//            [(UINavigationController  *)self.window.rootViewController presentViewController:viewUpgraded animated:false completion:^{
//                [viewUpgraded purchaseWithPromoCode:[parameters objectForKey:@"code"]];
//
//            }];
            
        }
        
    }
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
   
}


-(void)applicationWillEnterForeground:(UIApplication *)application {
    
}


-(void)applicationDidBecomeActive:(UIApplication *)application {
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    self.mixpanel = [Mixpanel sharedInstance];
    
    [self.mixpanel.people addPushDeviceToken:deviceToken];
    
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


@end
