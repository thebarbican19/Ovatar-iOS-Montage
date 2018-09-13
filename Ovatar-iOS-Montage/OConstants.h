//
//  OOvatar.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 26/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#ifdef DEBUG
#define APP_DEBUG_MODE true

#else
#define APP_DEBUG_MODE false

#endif

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#define ENTRY_LIMIT_DURATION 1.0

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_X (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 812.0f)

#define APP_BUNDLE_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]
#define APP_STORE_ID @"1177562048"
#define APP_STORE_URL @"https://itunes.apple.com/us/app/blrrd/id1177562048?ls=1&mt=8"
#define APP_DEVICE [[UIDevice currentDevice] systemVersion]
#define APP_SAVE_DIRECTORY @"group.com.ovatar.io"
#define APP_DEVICE_FLOAT [APP_DEVICE floatValue]
#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define APP_VERSION_FLOAT [APP_VERSION floatValue]
#define APP_BUILD [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]
#define APP_BUILD_FLOAT [APP_BUILD floatValue]
#define APP_LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0]
#define APP_COUNTRY_CODE [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]
#define APP_STATUSBAR_HEIGHT [UIApplication sharedApplication].statusBarFrame.size.height
#define APP_DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define REGEX_EMAIL @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
