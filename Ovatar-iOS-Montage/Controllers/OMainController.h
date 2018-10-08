//
//  OMainController.h
//  Ovatar-iOS-DaySnap
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <UserNotifications/UserNotifications.h>
#import <SafariServices/SafariServices.h>
#import <AudioToolbox/AudioServices.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

#import "OImageObject.h"
#import "ODataObject.h"
#import "OExportObject.h"

#import "OEntryController.h"
#import "OGalleryPickerController.h"
#import "OFeedbackController.h"

#import "OTitleView.h"
#import "ODayCell.h"
#import "OStoriesLayout.h"
#import "OInformationLabel.h"
#import "OPaymentObject.h"
#import "OSettingsController.h"
#import "OAlertController.h"
#import "OPlaybackController.h"
#import "OShareController.h"
#import "ODocumentController.h"

#import "AppDelegate.h"
#import "Mixpanel.h"
#import "NSlackObject.h"

@protocol OMainDelegate;
@interface OMainController : UIViewController <OTitleViewDelegate, OEntryViewDelegate, OGalleryPickerDelegate, ODataDelegate, OPaymentDelegate, OAlertDelegate, OFeedbackDelegate, OSettingsDelegate, OPlaybackDelegate, OShareDelegate, GDActionSheetDelegate, ODocumentDelegate, UNUserNotificationCenterDelegate, SFSafariViewControllerDelegate, MPMediaPickerControllerDelegate>

-(void)viewAuthorize;

@property (nonatomic, strong) id <OMainDelegate> delegate;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) OExportObject *exportobj;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) AppDelegate *appdel;
@property (nonatomic, strong) OPaymentObject *payment;
@property (nonatomic, strong) OStatsObject *stats;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;
@property (nonatomic, strong) NSlackObject *slack;
@property (nonatomic) SFSafariViewController *safari;
@property (nonatomic, strong) AVURLAsset *soundtrack;

@property (nonatomic, assign) float paddingtop;
@property (nonatomic, assign) float paddingbottom;
@property (nonatomic, assign) int items;
@property (nonatomic, assign) ODayCell *selected;
@property (nonatomic, strong) NSURL *exported;
@property (nonatomic, assign) BOOL exporting;
@property (nonatomic, assign) BOOL importing;

@property (nonatomic, strong) OEntryController *viewStory;
@property (nonatomic, strong) OStoriesLayout *viewStoriesLayout;
@property (nonatomic, strong) OGalleryPickerController *viewGallery;
@property (nonatomic, strong) OFeedbackController *viewFeeback;
@property (nonatomic, strong) OTitleView *viewHeader;
@property (nonatomic, strong) OSettingsController *viewSettings;
@property (nonatomic, strong) OAlertController *viewAlert;
@property (nonatomic, strong) OPlaybackController *viewPlayer;
@property (nonatomic, strong) OShareController *viewShare;
@property (nonatomic, strong) ODocumentController *viewDocument;
@property (nonatomic, strong) GDActionSheet *viewSheet;

-(void)paymentApplyPromoCode:(NSString *)code;

@end

@protocol OMainDelegate <NSObject>

-(void)viewStatusStyle:(UIStatusBarStyle)style;

@optional



@end

