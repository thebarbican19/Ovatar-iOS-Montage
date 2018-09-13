//
//  OMainController.h
//  Ovatar-iOS-DaySnap
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#import "OImageObject.h"
#import "ODataObject.h"
#import "OExportObject.h"

#import "OEntryController.h"
#import "OPermissionsController.h"
#import "OGalleryPickerController.h"
#import "OPresentationController.h"
#import "OSettingsController.h"
#import "OFeedbackController.h"

#import "OTitleView.h"
#import "ODayCell.h"
#import "ONotificationView.h"
#import "OStoriesLayout.h"
#import "OInformationLabel.h"
#import "OPaymentObject.h"

#import "AppDelegate.h"
#import "Mixpanel.h"

@interface OMainController : UIViewController <PHPhotoLibraryChangeObserver ,OTitleViewDelegate, OEntryViewDelegate, OGalleryPickerDelegate, OPermissionsViewDelegate, ODataDelegate, ONotificationDelegate, OPaymentDelegate, OSettingsDelegate, OFeedbackDelegate, OPresentationDelegate>

@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, strong) OExportObject *exportobj;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) AppDelegate *appdel;
@property (nonatomic, strong) OPaymentObject *payment;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;

@property (nonatomic, assign) float paddingtop;
@property (nonatomic, assign) float paddingbottom;
@property (nonatomic, assign) int pageindex;
@property (nonatomic, assign) int items;
@property (nonatomic, assign) ODayCell *selected;
@property (nonatomic, strong) NSURL *exported;
@property (nonatomic, assign) BOOL exporting;

@property (nonatomic, strong) OEntryController *viewStory;
@property (nonatomic, strong) OStoriesLayout *viewStoriesLayout;
@property (nonatomic, strong) OGalleryPickerController *viewGallery;
@property (nonatomic, strong) OPermissionsController *viewPermissions;
@property (nonatomic, strong) OPresentationController *viewPresentation;
@property (nonatomic, strong) OSettingsController *viewSettings;
@property (nonatomic, strong) OFeedbackController *viewFeeback;
@property (nonatomic, strong) UICollectionViewFlowLayout *viewGalleryLayout;
@property (nonatomic, strong) UIScrollView *viewContainer;
@property (nonatomic, strong) OTitleView *viewHeader;
@property (nonatomic, strong) ONotificationView *viewNotification;

@end
