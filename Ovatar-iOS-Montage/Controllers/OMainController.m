//
//  OMainController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OMainController.h"
#import "OConstants.h"

@interface OMainController ()

@end

@implementation OMainController

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    float videoscale = (self.view.bounds.size.width - 60.0) / self.exportobj.videoresize.width;
    float videoheight = self.exportobj.videoresize.height * videoscale;
    float videowidth = self.exportobj.videoresize.width * videoscale;
    float videomax = self.view.bounds.size.height - (self.paddingbottom + self.paddingtop + 60 + MAIN_HEADER_HEIGHT);

    if (videoheight > videomax) videoheight = videomax;
    
    self.viewStory.view.frame = CGRectMake(0.0, MAIN_HEADER_HEIGHT + self.paddingtop, self.view.bounds.size.width, videoheight + 60.0);
    self.viewStoriesLayout.itemSize = CGSizeMake(videowidth, videoheight);
    self.viewHeader.frame = CGRectMake(0.0, self.paddingtop, self.view.bounds.size.width, MAIN_HEADER_HEIGHT);
    self.viewAlert.padding = self.paddingbottom;
    self.viewSettings.padding = self.paddingbottom;
    self.viewPlayer.paddingtop = self.paddingtop;
    self.viewPlayer.paddingbottom = self.paddingbottom;
    self.viewSheet.safearea = self.paddingbottom;

}

-(void)viewAuthorize {
    [self.queue addOperationWithBlock:^{
        if (self.dataobj.storyLatest == nil) {
            NSString *name = [NSString stringWithFormat:NSLocalizedString(@"Default_Project_Name", nil) ,self.dataobj.storyExports + 1];
            NSDictionary *data = @{@"name":name};
            [self.dataobj storyCreateWithData:data completion:^(NSString *key, NSError *error) {
                [self.dataobj entryCreate:key assets:nil completion:^(NSError *error, NSArray *keys) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
            
                        [self.viewHeader setTitle:self.dataobj.storyActiveName];
                        [self.viewHeader setBackbutton:false];
                        [self.viewHeader setHeadergeature:true];
                        [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];
                        
                        [self viewPresentGalleryPicker:self.viewStory.collectionView.visibleCells.lastObject];
                        [self viewMonitorEnties];
                        
                    }];
                    
                }];
                
            }];
            
        }
        else {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                
                [self.viewHeader setTitle:self.dataobj.storyActiveName];
                [self.viewHeader setBackbutton:false];
                [self.viewHeader setHeadergeature:true];
                [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];
                
            }];

        }
        
    }];
    
    [self.queue addOperationWithBlock:^{
        [self.viewGallery setup];

    }];
    
}

-(void)viewPresentGalleryPicker:(ODayCell *)day {
    if (day != nil) {
        [self.viewGallery setRevealed:false];
        [self.viewGallery setSelected:nil];
        [self.viewGallery setEntry:day];
        [self.viewGallery present];
        [self setSelected:day];
        
    }
    else {
        [self.viewStory viewCollectionScroll:day.index];
        
    }
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor orangeColor];
    
    self.stats = [[OStatsObject alloc] init];
    
    self.slack = [[NSlackObject alloc] init];
    
    self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];

    self.generator = [[UINotificationFeedbackGenerator alloc] init];

    self.appdel = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    self.mixpanel = [Mixpanel sharedInstance];
    
    self.payment = [[OPaymentObject alloc] init];
    self.payment.delegate = self;
    
    self.dataobj = [[ODataObject alloc] init];
    self.dataobj.delegate = self;
    
    self.exportobj = [[OExportObject alloc] init];
    
    self.imageobj = [OImageObject sharedInstance];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.qualityOfService = NSQualityOfServiceUtility;
    self.queue.maxConcurrentOperationCount = 1;
    
    self.viewStoriesLayout = [[OStoriesLayout alloc] init];
    self.viewStoriesLayout.minimumLineSpacing = 0.0;
    self.viewStoriesLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.viewStoriesLayout.sectionInset = UIEdgeInsetsMake(20.0, 20.0, 20.0, 20.0);
    
    self.viewStory = [[OEntryController alloc] initWithCollectionViewLayout:self.viewStoriesLayout];
    self.viewStory.delegate = self;
    self.viewStory.collectionView.clipsToBounds = true;
    self.viewStory.view.frame = CGRectMake(0.0, self.paddingtop, self.view.bounds.size.width, self.view.bounds.size.height);
    self.viewStory.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:self.viewStory];
    [self.view addSubview:self.viewStory.view];
    
    self.viewPlayer = [[OPlaybackController alloc] init];
    self.viewPlayer.view.frame = CGRectMake(self.view.bounds.size.width, self.viewStory.view.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height);
    self.viewPlayer.view.backgroundColor = [UIColor clearColor];
    self.viewPlayer.delegate = self;
    [self addChildViewController:self.viewPlayer];
    [self.view addSubview:self.viewPlayer.view];
    
    self.viewSheet = [[GDActionSheet alloc] initWithFrame:self.view.bounds];
    self.viewSheet.backgroundColor = [UIColor clearColor];
    self.viewSheet.delegate = self;

    self.viewGallery = [[OGalleryPickerController alloc] init];
    self.viewGallery.backgroundColor = [UIColor clearColor];
    self.viewGallery.delegate = self;
    
    self.viewSettings = [[OSettingsController alloc] init];
    self.viewSettings.backgroundColor = [UIColor clearColor];
    self.viewSettings.delegate = self;
    
    self.viewAlert = [[OAlertController alloc] init];
    self.viewAlert.backgroundColor = [UIColor clearColor];
    self.viewAlert.delegate = self;
    
    self.viewFeeback = [[OFeedbackController alloc] init];
    self.viewFeeback.backgroundColor = [UIColor clearColor];
    self.viewFeeback.delegate = self;
    
    self.viewShare = [[OShareController alloc] init];
    self.viewShare.backgroundColor = [UIColor clearColor];
    self.viewShare.delegate = self;
    
    self.viewDocument = [[ODocumentController alloc] init];
    self.viewDocument.backgroundColor = [UIColor clearColor];
    self.viewDocument.delegate = self;
    
    self.viewHeader = [[OTitleView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, MAIN_HEADER_HEIGHT)];
    self.viewHeader.backgroundColor = [UIColor clearColor];
    self.viewHeader.delegate = self;
    self.viewHeader.rounded = true;
    [self.view addSubview:self.viewHeader];
    [self.viewHeader shadow:1.0];

}

-(void)viewPresentError:(NSError *)error key:(NSString *)key {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    [buttons addObject:@{@"title":NSLocalizedString(@"Settings_ActionSheet_Dismiss", nil),
                         @"key":@"dismiss",
                         @"primary":@(false),
                         @"dismiss":@(true)}];
    
    if (error.code == 200 || error == nil) {
        [self.viewAlert setSubtitle:error.domain];
        [self.viewAlert setType:OAlertControllerTypeComplete];
    }
    else {
        [self.viewAlert setError:error];
        [self.viewAlert setType:OAlertControllerTypeError];
        
    }
    
    [self.viewAlert setCandismiss:true];
    [self.viewAlert setButtons:buttons];
    [self.viewAlert setKey:key];
    [self.viewAlert present];
    
}

-(void)titleNavigationBackTapped:(UIButton *)button {
    [self.viewPlayer destroy:^(BOOL dismissed) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewStory.view setFrame:CGRectMake(0.0, self.viewStory.view.frame.origin.y, self.viewStory.view.bounds.size.width, self.viewStory.view.bounds.size.height)];
            [self.viewPlayer.view setFrame:CGRectMake(self.view.bounds.size.width, self.viewStory.view.frame.origin.y, self.viewStory.view.bounds.size.width, self.viewPlayer.view.bounds.size.height)];

        } completion:^(BOOL finished) {
            [self.viewHeader setBackbutton:false];
            [self.viewHeader setHeadergeature:true];
            [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];

        }];
        
    }];
    
}

-(void)titleNavigationButtonTapped:(OTitleButtonType)button {
    if (button == OTitleButtonTypePreview) {
        if ([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey] > 2) {
            [self viewExportWithSize:CGSizeMake(1080, 1920)];
    
        }
        else {
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            [buttons addObject:@{@"title":NSLocalizedString(@"Error_Button_AddMore", nil),
                                 @"key":@"addmore",
                                 @"primary":@(false),
                                 @"dismiss":@(true)}];
            
            [self.viewAlert setError:[NSError errorWithDomain:NSLocalizedString(@"Error_Description_IncompleteStory", nil) code:201 userInfo:nil]];
            [self.viewAlert setType:OAlertControllerTypeError];
            [self.viewAlert setKey:@"export_addmore_error"];
            [self.viewAlert setButtons:buttons];
            [self.viewAlert present];
                        
        }
        
    }
    else if (button == OTitleButtonTypeSettings) {
        [self.viewSettings present:OSettingsSubviewTypeMain];

    }
    else if (button == OTitleButtonTypeExport) {
        [self.mixpanel timeEvent:@"App Exported Video"];
        [self.dataobj storyExport:self.dataobj.storyActiveKey completion:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (error.code == 200) {
                    [self.viewHeader setup:@[] animate:true];
                    [self.viewShare setExported:self.exported];
                    [self.viewShare present];
                    [self.mixpanel track:@"App Exported Video" properties:@{
                                                @"Items":@([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey]),
                                                @"Tags":[self.stats tagsFromAssetKeys:[self.dataobj storyAssetKeys:self.dataobj.storyActiveKey]]}];
                    

                }
                else {
                    [self.viewAlert setError:error];
                    [self.viewAlert setType:OAlertControllerTypeError];
                    [self.viewAlert setKey:@"export_error"];
                    [self.viewAlert present];
                    
                }

            }];
            
        }];
        
    }
    
}

-(void)titleNavigationHeaderTapped:(OTitleView *)view {
    [self.viewSettings present:OSettingsSubviewTypeMain];

}

-(void)viewExportWithSize:(CGSize)size {
    if (!self.exporting) {
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        [buttons addObject:@{@"title":NSLocalizedString(@"Export_Stop_Action", nil),
                             @"key":@"killrender",
                             @"primary":@(false),
                             @"dismiss":@(true)}];
        
        [self.viewAlert setType:OAlertControllerTypeRender];
        [self.viewAlert setKey:@"export_render"];
        [self.viewAlert setButtons:buttons];
        [self.viewAlert present];
        
        [self setExporting:true];
        [self.exportobj setVideoframes:29.96];
        [self.exportobj setVideoseconds:1.3];
        [self.exportobj setVideoresize:size];
        
        NSLog(@"Stats tags: %@" ,[self.stats tagsFromAssetKeys:[self.dataobj storyAssetKeys:self.dataobj.storyActiveKey]]);
        [self.exportobj exportMontage:self.dataobj.storyActiveKey completion:^(NSString *file, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (error.code == 200 || error == nil) {
                    [self.viewAlert dismiss:^(BOOL dismissed) {
                        if (file != nil) {
                            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                                [self.viewStory.view setFrame:CGRectMake(-self.view.bounds.size.width, self.viewStory.view.frame.origin.y, self.viewStory.view.bounds.size.width, self.viewStory.view.bounds.size.height)];
                                [self.viewPlayer.view setFrame:CGRectMake(0.0, self.viewStory.view.frame.origin.y, self.viewStory.view.bounds.size.width, self.view.bounds.size.height)];

                            } completion:^(BOOL finished) {
                                [self.viewPlayer setVideosize:size];
                                [self.viewPlayer setup:[NSURL fileURLWithPath:file]];
                                
                                [self.mixpanel track:@"App Previewed Video" properties:@{
                                                     @"Items":@([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey]),
                                                     @"Tags":[self.stats tagsFromAssetKeys:[self.dataobj storyAssetKeys:self.dataobj.storyActiveKey]]}];
                                
                                [self.viewHeader setHeadergeature:false];
                                [self.viewHeader setBackbutton:true];
                                [self.viewHeader setup:@[@"navigation_export"] animate:true];
                                                                
                            }];
                            
                        }
                        
                    }];
                   
                }
                else {
                    NSMutableArray *buttons = [[NSMutableArray alloc] init];
                    [buttons addObject:@{@"title":NSLocalizedString(@"Feedback_Retry_Action", nil),
                                         @"key":@"retry",
                                         @"primary":@(false),
                                         @"dismiss":@(true)}];
                    
                    [buttons addObject:@{@"title":NSLocalizedString(@"Settings_ActionSheet_Dismiss", nil),
                                         @"key":@"dismiss",
                                         @"primary":@(false),
                                         @"dismiss":@(true)}];
                    
                    [self.viewAlert setError:error];
                    [self.viewAlert setType:OAlertControllerTypeError];
                    [self.viewAlert setKey:@"export_error"];
                    [self.viewAlert setButtons:buttons];
                    [self.viewAlert present];
                    
                }
                
                [self setExporting:false];

            }];
            
        }];
        
    }
    
    
}

-(void)viewGallerySelectedImage:(NSArray *)assets shortcut:(BOOL)shortcut {
    int originalcount = (int)[[self.dataobj storyEntries:self.dataobj.storyActiveKey] count];
    NSMutableArray *append = [[NSMutableArray alloc] initWithArray:assets];
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    [buttons addObject:@{@"title":NSLocalizedString(@"Export_Stop_Action", nil),
                         @"key":@"stop",
                         @"primary":@(false),
                         @"dismiss":@(true)}];
    
    [self.viewStory viewUpdateEntry:self.selected loading:true];
    if (self.selected != nil) {
        PHAsset *asset = append.firstObject;
        NSString *key = self.selected.key;
        [self.dataobj entryAppendWithImageData:asset animated:true entry:key completion:^(NSError *error) {
            [self.imageobj imageCreateEntryFromAsset:asset animate:true key:key completion:^(NSError *error, BOOL animated) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (error.code == 200 || error == nil) {
                        [self.viewStory viewUpdateEntry:self.selected loading:false];
                        [self.viewStory viewEditorDidScroll:self.selected];
                        [self.viewStory setActive:self.selected];
                        [self setSelected:nil];
                        
                        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                        dispatch_after(delay, dispatch_get_main_queue(), ^(void) {
                            [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                            
                        });

                    }
                    else {
                        [self.viewAlert setError:error];
                        [self.viewAlert setType:OAlertControllerTypeError];
                        [self.viewAlert setKey:@"entrycreat_error"];
                        [self.viewAlert present];
                        
                        [self.viewStory viewUpdateEntry:self.selected loading:false];
                        
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoaderExportStatus" object:@{@"progress":@(0)}];
                    
                }];
            
            }];
            
        }];
        
        [append removeObjectAtIndex:0];
    
    }
    
    if (append.count > 0) {
        [self setImporting:true];
        [self.viewAlert setType:OAlertControllerTypeImporting];
        [self.viewAlert setKey:@"import_images"];
        [self.viewAlert setButtons:buttons];
        [self.viewAlert present];
        
        [self.dataobj entryCreate:self.dataobj.storyActiveKey assets:append completion:^(NSError *error, NSArray *keys) {
            float __block progress = 0;
            float __block added = 0;
            float __block total = keys.count;
            for (int i = 0; i < keys.count; i++) {
                NSString *key = [keys objectAtIndex:i];
                NSDictionary *entry = [self.dataobj entryWithKey:key];
                [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                [self.imageobj imageReturnFromAssetKey:[entry objectForKey:@"assetid"] completion:^(PHAsset *asset) {
                    if (asset != nil && self.importing) {
                        [self.imageobj imageCreateEntryFromAsset:asset animate:true key:key completion:^(NSError *error, BOOL animated) {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                NSIndexPath *index = [NSIndexPath indexPathForRow:originalcount + i inSection:0];
                                ODayCell *day = (ODayCell *)[self.viewStory.collectionView cellForItemAtIndexPath:index];
                                
                                [self.viewStory viewUpdateEntry:day loading:true];
                                [self.dataobj entryAppendWithImageData:asset animated:true entry:key completion:^(NSError *error) {
                                    added += 1;
                                    progress = (100.0 / total) * added;
                                    NSLog(@"progress : %f" ,progress);
                                    if (added == total) {
                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                            if (shortcut) {
                                                [self viewPresentError:[NSError errorWithDomain:[NSString stringWithFormat:NSLocalizedString(@"Error_Description_AddedCapturesToday", nil), total] code:200 userInfo:nil] key:@"noimages"];
                                                
                                            }
                                            else {
                                                [self.stats suspend];
                                                [self.viewAlert dismiss:^(BOOL dismissed) {
                                                    [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                                                    [self viewMonitorEnties];

                                                }];
                                                
                                            }
                                            
                                            [self setImporting:false];
                                            
                                        }];
                                        
                                    }
                                    else {
                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                            [self.viewStory viewUpdateEntry:day loading:false];
                                            
                                        }];
                                        
                                    }
                                    
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoaderExportStatus" object:@{@"progress":@(progress / 100)}];

                                }];
                                
                            }];
                            
                        }];
                            
                    }
             
                }];
            
            }
            
        }];
        
    }
    else {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.viewAlert dismiss:^(BOOL dismissed) {
                [self viewMonitorEnties];
                [self setImporting:false];

            }];
            
        }];
        
    }
    
}
         
-(void)viewMonitorEnties {
    if ([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey] == 0) {
        [self.viewGallery present];
        
    }
    else if ([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey] > 3 && ![[self.data objectForKey:@"modal_push_viewed"] boolValue]) {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                    NSMutableArray *buttons = [[NSMutableArray alloc] init];
                    [buttons addObject:@{@"title":NSLocalizedString(@"Permissions_Action_Allow", nil),
                                         @"key":@"authorize",
                                         @"primary":@(true),
                                         @"dismiss":@(true)}];
                    [buttons addObject:@{@"title":NSLocalizedString(@"Permissions_Action_Skip", nil),
                                         @"key":@"dismiss",
                                         @"primary":@(false),
                                         @"dismiss":@(true)}];
                    
                    [self.viewAlert setType:OAlertControllerTypePush];
                    [self.viewAlert setKey:@"push_notify"];
                    [self.viewAlert setButtons:buttons];
                    [self.viewAlert present];
                    
                }
                
            }];
            
        }];
       
    }
    
}

-(void)viewCreateNewStory:(NSString *)name {
    [self.dataobj storyCreateWithData:@{@"name":name} completion:^(NSString *key, NSError *error) {
        [self.dataobj entryCreate:key assets:nil completion:^(NSError *error, NSArray *keys) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                
                [self.viewHeader setTitle:self.dataobj.storyActiveName];
                [self.viewHeader setBackbutton:false];
                [self.viewHeader setHeadergeature:true];
                [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];
                
                [self viewPresentGalleryPicker:self.viewStory.collectionView.visibleCells.lastObject];
                [self viewMonitorEnties];
                
                [self titleNavigationBackTapped:nil];
                
            }];
            
        }];
        
    }];
    
}

-(void)viewRestorePurchases {
    [self.viewAlert setType:OAlertControllerTypeLoading];
    [self.viewAlert setKey:@"subscribe_loading"];
    [self.viewAlert setCandismiss:false];
    [self.viewAlert setButtons:nil];
    [self.viewAlert present];
    
    [self.payment purchaseRestore];
  
}

-(void)viewPurchaseInitialiseWithIdentifyer {
    [self.viewAlert setType:OAlertControllerTypeLoading];
    [self.viewAlert setKey:@"subscribe_loading"];
    [self.viewAlert setCandismiss:false];
    [self.viewAlert setButtons:nil];
    [self.viewAlert present];
    
    [self.payment paymentRecordInterest];
    [self.payment purchaseSubscription];

}

-(void)viewSendFeedback:(NSString *)email message:(NSString *)message {
    if (email != nil) {
        [self.data setObject:email forKey:@"ovatar_email"];
        [self.mixpanel identify:self.mixpanel.distinctId];
        [self.mixpanel.people set:@{@"$email":email}];
    
    }

    [self.viewAlert setType:OAlertControllerTypeLoading];
    [self.viewAlert setKey:@"feedback_sending"];
    [self.viewAlert setCandismiss:false];
    [self.viewAlert setButtons:nil];
    
    [self.slack slackSend:message userdata:[self.appdel applicationUserData] type:NFeedbackTypeGeneral completion:^(NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSMutableArray *buttons = [[NSMutableArray alloc] init];
            if (error == nil || error.code == 200) {
                [buttons addObject:@{@"title":NSLocalizedString(@"Settings_ActionSheet_Dismiss", nil),
                                     @"key":@"dismiss",
                                     @"primary":@(false),
                                     @"dismiss":@(true)}];
                
                [self.viewAlert setType:OAlertControllerTypeComplete];
                [self.viewAlert setKey:@"feedback_sucsessful"];
                [self.viewAlert setSubtitle:NSLocalizedString(@"Feedback_Sent_Placeholder", nil)];
                [self.viewAlert setCandismiss:true];
                [self.viewAlert setButtons:buttons];

            }
            else {
                [self.viewAlert setType:OAlertControllerTypeError];
                [self.viewAlert setError:error];
                [self.viewAlert setKey:@"feedback_error"];
                [self.viewAlert setCandismiss:true];
                [self.viewAlert setButtons:nil];
                
            }
            
            [self.viewAlert present];

        }];
        
    }];
    
}

-(void)modalAlertPresented:(id)view {
    if ([view isKindOfClass:[OAlertController class]]) {
        OAlertController *alert = (OAlertController *)view;
        if (alert.type == OAlertControllerTypeImporting || alert.type == OAlertControllerTypeRender || alert.type == OAlertControllerTypeImporting) {
            [self.stats initiate];
            
        }

    }
    
}

-(void)modalAlertDismissed:(id)view {
    if ([view isKindOfClass:[OSettingsController class]]) {
        [self.viewHeader setTitle:self.dataobj.storyActiveName];
        [self.viewHeader setBackbutton:false];
        [self.viewHeader setHeadergeature:true];
        [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];
        
    }
    else if ([view isKindOfClass:[OAlertController class]]) {
        [self.stats suspend];

    }
    
    [self.delegate viewStatusStyle:UIStatusBarStyleDefault];
    
}

-(void)modalAlertDismissedWithAction:(id)view action:(OActionButton *)action {
    if ([view isKindOfClass:[OAlertController class]]) {
        OAlertController *alert = (OAlertController *)view;
        if ([alert.key isEqualToString:@"export_addmore_error"]) {
            if ([action.key isEqualToString:@"addmore"]) {
                [self viewPresentGalleryPicker:self.viewStory.collectionView.visibleCells.lastObject];
                
            }
            
        }
        else if ([alert.key isEqualToString:@"push_notify"]) {
            if ([action.key isEqualToString:@"authorize"]) {
                [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionSound|UNAuthorizationOptionAlert|UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                        
                    }];
                    
                }];
                
            }
            else {
                [self.data setObject:@(true) forKey:@"modal_push_viewed"];
                [self.data synchronize];
                
            }

        }
        else if ([alert.key isEqualToString:@"music_unauthorized"]) {
            if ([action.key isEqualToString:@"update"]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
                    
                }];
                
            }
            
        }
        else if ([alert.key containsString:@"export"]) {
            if ([action.key isEqualToString:@"retry"]) {
                [self viewExportWithSize:self.exportobj.videoresize];
                
            }
            else if ([action.key isEqualToString:@"killrender"]) {
                [self.exportobj exportTerminate];
                
            }
            
        }
        else if ([alert.key containsString:@"import"]) {
            if ([action.key isEqualToString:@"stop"]) {
                [self setImporting:false];
                [self.viewAlert dismiss:^(BOOL dismissed) {
                    [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];

                }];
                
            }
        }
        else {
            if ([action.key isEqualToString:@"share"]) {
                [self modalAlertCallActivityController:@[[NSURL URLWithString:@"https://ovatar.io/montage"]]];
                
            }
            
        }
        
    }
    
}

-(void)modalAlertCallPurchaseSubview:(int)delay {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    [buttons addObject:@{@"title":[NSString stringWithFormat:NSLocalizedString(@"Subscription_PurchaseMonthly_Action", nil), self.payment.paymentCurrency ,self.payment.paymentAmount],
                         @"key":@"purchase",
                         @"primary":@(true),
                         @"dismiss":@(false)}];
    
    [buttons addObject:@{@"title":NSLocalizedString(@"Permissions_Action_Skip", nil),
                         @"key":@"close",
                         @"primary":@(false),
                         @"dismiss":@(true),
                         @"delay":@(delay)}];
    
    [self.viewAlert setType:OAlertControllerTypeSubscribe];
    [self.viewAlert setKey:@"subscribe_notice"];
    [self.viewAlert setCandismiss:delay==0?true:false];
    [self.viewAlert setButtons:buttons];
    [self.viewAlert present];

}

-(void)modalAlertCallFeedbackSubview {
    [self.viewFeeback present];
    
}

-(void)modalAlertCallSafariController:(NSURL *)url {
    self.safari = [[SFSafariViewController alloc] initWithURL:url];
    if (@available(iOS 11.0, *)) {
        self.safari.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleDone;
        
    }
    self.safari.view.tintColor = UIColorFromRGB(0x140F26);
    self.safari.delegate = self;
    
    [self presentViewController:self.safari animated:true completion:^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];

    }];
    
}

-(void)modalAlertCallActivityController:(NSArray *)items {
    UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [super presentViewController:share animated:true completion:^{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];

    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
    
}

-(void)modalAlertCallMusicController {
    [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (status == SKCloudServiceAuthorizationStatusAuthorized) {
                MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
                picker.delegate = self;
                picker.allowsPickingMultipleItems = false;
                picker.showsItemsWithProtectedAssets = false;
                picker.showsCloudItems = false;

                [self presentViewController:picker animated:true completion:nil];
                
            }
            else {
                NSMutableArray *buttons = [[NSMutableArray alloc] init];
                [buttons addObject:@{@"title":NSLocalizedString(@"Permissions_Action_Update", nil),
                                     @"key":@"update",
                                     @"primary":@(false),
                                     @"dismiss":@(true)}];
                
                [self.viewAlert setError:[NSError errorWithDomain:NSLocalizedString(@"Error_Description_MusicUnauthorized", nil) code:401 userInfo:nil]];
                [self.viewAlert setButtons:buttons];
                [self.viewAlert setType:OAlertControllerTypeError];
                [self.viewAlert setKey:@"music_unauthorized"];
                [self.viewAlert present];
                
            }
            
        }];
        
    }];
    
}

-(void)modalAlertCallActionSheet:(NSArray *)buttons key:(NSString *)key {
    [self.viewSheet setKey:key];
    [self.viewSheet setButtons:buttons];
    [self.viewSheet presentActionAlert];
    
}

-(void)modalAlertCallDocumentController:(ODocumentType)type {
    NSMutableString *content = [[NSMutableString alloc] init];
    NSString *title = nil;
    if (type == ODocumentTypeSubscription) {
        title = NSLocalizedString(@"Terms_Subscription_Title", nil);
        for (NSDictionary *items in [self.payment productsFromIdentifyer:@"montage.monthly"]) {
            [content appendString:@"• "];
            [content appendString:[items objectForKey:@"summary"]];
            [content appendString:@"\n"];
            
        }
        
        [content appendString:@"\n\n"];
        [content appendString:[NSString stringWithFormat:NSLocalizedString(@"Terms_Subscription_Content", nil) ,self.payment.paymentCurrency , self.payment.paymentAmount]];
        
    }
    
    [self.viewDocument setHeader:title];
    [self.viewDocument setContent:content];
    [self.viewDocument present];
    
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    if (mediaItemCollection.count > 0) {
        MPMediaItem *song = mediaItemCollection.items.firstObject;
        if ([song valueForProperty:MPMediaItemPropertyAssetURL] == nil) {
            [self.viewAlert setError:[NSError errorWithDomain:NSLocalizedString(@"Error_Description_MusicCloud", nil) code:404 userInfo:nil]];
            [self.viewAlert setType:OAlertControllerTypeError];
            [self.viewAlert setKey:@"music_cloud"];
            [self.viewAlert present];
            
        }
        else {
            [self dismissViewControllerAnimated:true completion:^{
                NSMutableDictionary *music = [[NSMutableDictionary alloc] init];
                [music setObject:[song title] forKey:@"title"];
                [music setObject:[song artist] forKey:@"artist"];
                [music setObject:@([song beatsPerMinute]) forKey:@"bpm"];
                [music setObject:[song valueForProperty:MPMediaItemPropertyAssetURL] forKey:@"file"];

                [self.dataobj musicCreate:self.dataobj.storyActiveKey music:music type:ODataMusicTypeIPod completion:^(NSError *error) {
                    [self.viewSettings present:OSettingsSubviewTypeMusic];
                    
                }];
                
            }];

        }
        
    }
    
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:true completion:^{
        [self.viewSettings present:OSettingsSubviewTypeMusic];

    }];
    
}

-(void)actionSheetTappedButton:(GDActionSheet *)action index:(NSInteger)index {
    if ([action.key isEqualToString:@"ovatar"]) {
        if ([[[action.buttons objectAtIndex:index] objectForKey:@"key"] isEqualToString:@"instagram"]) {
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@" ,@"ovatar.io"]] options:@{} completionHandler:^(BOOL success) {
                    
                }];
                
            }
            else {
                [self.viewAlert dismiss:^(BOOL dismissed) {
                    [self modalAlertCallSafariController:[NSURL URLWithString:@"http://instagram.com/ovatar.io/"]];
                    
                }];
                
            }
            
        }
        else {
            [self.viewAlert dismiss:^(BOOL dismissed) {
                [self modalAlertCallSafariController:[NSURL URLWithString:@"https://ovatar.io/"]];
                
            }];
            
        }
        
    }
    else if ([action.key isEqualToString:@"legal"]) {
        [self.viewSettings dismiss:^(BOOL dismissed) {
            if ([[[action.buttons objectAtIndex:index] objectForKey:@"key"] isEqualToString:@"subscription"]) {
                [self modalAlertCallDocumentController:ODocumentTypeSubscription];

            }
            else {
                [self modalAlertCallSafariController:[NSURL URLWithString:@"https://ovatar.io/legal"]];

            }
            
        }];

    }
    
}

-(void)paymentSucsessfullyUpgradedWithState:(OPaymentState)state {
    NSString *subtitle = nil;
    if (state == OPaymentStateRestored) subtitle = NSLocalizedString(@"Subscription_Restored_Error", nil);
    else if (state == OPaymentStatePurchased) subtitle = NSLocalizedString(@"Subscription_Purchaesed_Error", nil);
    else if (state == OPaymentStatePromotionAdded) {
        subtitle = NSLocalizedString(@"Subscription_Cheapass_Error", nil);
        NSMutableArray *buttons = [[NSMutableArray alloc] init];
        [buttons addObject:@{@"title":NSLocalizedString(@"Export_Share_Action", nil),
                             @"key":@"share",
                             @"primary":@(false),
                             @"dismiss":@(true)}];
        
        [self.viewAlert setCandismiss:false];;
        [self.viewAlert setButtons:buttons];

    }
    else subtitle = NSLocalizedString(@"Subscription_Deferred_Error", nil);
    
    [self.viewAlert setSubtitle:subtitle];
    [self.viewAlert setType:OAlertControllerTypeComplete];
    [self.viewAlert setKey:@"purchase_sucsess"];
    [self.viewAlert present];

}

-(void)paymentReturnedErrors:(NSError *)error {
    NSMutableArray *buttons = [[NSMutableArray alloc] init];
    [buttons addObject:@{@"title":NSLocalizedString(@"Feedback_Retry_Action", nil),
                         @"key":@"purchase",
                         @"primary":@(false),
                         @"dismiss":@(false)}];
    
    [buttons addObject:@{@"title":NSLocalizedString(@"Settings_ActionSheet_Dismiss", nil),
                         @"key":@"dismiss",
                         @"primary":@(false),
                         @"dismiss":@(true)}];
    
    [self.viewAlert setButtons:buttons];
    [self.viewAlert setError:error];
    [self.viewAlert setType:OAlertControllerTypeError];
    [self.viewAlert setKey:@"payment_error"];
    [self.viewAlert present];

}

-(void)paymentProcessing:(BOOL)restoring {
    [self.viewAlert setType:OAlertControllerTypeLoading];
    [self.viewAlert setKey:@"payment_processing"];
    [self.viewAlert present];
    
}

-(void)paymentCancelled {
    [self modalAlertCallPurchaseSubview:0];
    
}

-(void)paymentApplyPromoCode:(NSString *)code {
    [self.payment purchaseApplyPromotionCode:code];
    
}

@end
