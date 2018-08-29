//
//  OSettingsController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 06/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>

#import "OSettingsHeader.h"
#import "OImageObject.h"
#import "OPaymentObject.h"

#import "AppDelegate.h"

typedef enum {
    OSettingsSubviewFeedback,
    OSettingsSubviewNone

    
} OSettingsSubview;

@protocol OSettingsDelegate;
@interface OSettingsController : UITableViewController <UITableViewDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, strong) id <OSettingsDelegate> delegate;
@property (nonatomic, strong) OSettingsHeader *viewHeader;

@property (nonatomic, strong) OImageObject *imageobj;

@property (nonatomic, strong) NSMutableArray *settings;
@property (nonatomic) SFSafariViewController *safari;

-(void)tableViewContent;

@end

@protocol OSettingsDelegate <NSObject>

@optional

-(void)viewRestorePurchases;
-(void)viewInsertSubview:(OSettingsSubview)view;

@end

