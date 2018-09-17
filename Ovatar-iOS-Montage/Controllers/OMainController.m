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
    
    [self.appdel setLtext:@"montage"];
    [self.appdel setLassets:nil];
    [self.appdel applicationLoadingScreen:true];
    [self.imageobj imageAuthorization:false completion:^(PHAuthorizationStatus status) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (status == PHAuthorizationStatusAuthorized) {
                [self viewStorySetup:false];
                [self viewPresentSubviewWithIndex:1 animate:false];
                
            }
            else [self viewPresentSubviewWithIndex:0 animate:false];
            
            [self.appdel applicationLoadingScreen:false];
            
        }];
        
    }];
    
    if (@available(iOS 11, *)) {
        self.paddingtop = self.view.safeAreaInsets.top;
        self.paddingbottom = self.view.safeAreaInsets.bottom;
        
    }
    
    float videoscale = (self.viewContainer.bounds.size.width - 60.0) / self.exportobj.videoresize.width;
    float videoheight = self.exportobj.videoresize.height * videoscale;
    float videowidth = self.exportobj.videoresize.width * videoscale;
    
    self.viewContainer.frame = CGRectMake(0.0, self.paddingtop, self.view.bounds.size.width, self.view.bounds.size.height - self.paddingtop);
    self.viewContainer.contentSize = CGSizeMake(self.view.bounds.size.width * 3, self.viewContainer.bounds.size.height);
    self.viewPermissions.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 0, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - self.paddingbottom);
    self.viewStory.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 1, self.viewContainer.frame.origin.y - 14.0, self.viewContainer.bounds.size.width, videoheight + 60.0);
    self.viewStoriesLayout.itemSize = CGSizeMake(videowidth, videoheight);
    self.viewHeader.frame = CGRectMake(0.0, self.viewContainer.frame.origin.y, self.view.bounds.size.width, 64.0);
    self.viewPresentation.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 2, 64.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - (60.0 + self.paddingbottom));
    self.viewSettings.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 2, self.viewContainer.frame.origin.y, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - 64.0);

}

-(void)viewStorySetup:(BOOL)animateview {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue setQualityOfService:NSQualityOfServiceUtility];
    [queue setMaxConcurrentOperationCount:1];
    
    [self.imageobj imageAuthorization:true completion:^(PHAuthorizationStatus status) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (status == PHAuthorizationStatusAuthorized) {
                [queue addOperationWithBlock:^{
                    if (self.dataobj.storyLatest == nil) {
                        NSString *name = [NSString stringWithFormat:@"montage #%d" ,self.dataobj.storyExports + 1];
                        NSDictionary *data = @{@"name":name};
                        [self.dataobj storyCreateWithData:data completion:^(NSString *key, NSError *error) {
                            [self.dataobj entryCreate:key assets:nil completion:^(NSError *error, NSArray *keys) {
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                    [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                                    
                                }];
                                
                            }];
                            
                        }];
                        
                    }
                    else {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                            
                        }];
       
                    }
                    
                }];
                
                [queue addOperationWithBlock:^{
                    [self.imageobj imagesFromAlbum:nil limit:0 completion:^(NSArray *images) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self.viewGallery.images removeAllObjects];
                            [self.viewGallery.images addObjectsFromArray:images];
                            [self.viewGallery.collectionView reloadData];
                            
                            [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
                            
                            [self viewPresentSubviewWithIndex:1 animate:animateview];

                        }];
                        
                        [queue addOperationWithBlock:^{
                            for (NSDictionary *item in [images.firstObject objectForKey:@"images"]) {
                                PHAsset *asset = [item objectForKey:@"asset"];
                                if (asset.location != nil) {
                                    [self.geocoder reverseGeocodeLocation:asset.location completionHandler:^(NSArray *placemarks, NSError *error) {
                                        CLPlacemark *placemark = placemarks.lastObject;
                                        NSString *placentown = @"";
                                        NSString *placencountry = @"";
                                        
                                        if (placemark.subLocality != nil) placentown = placemark.subLocality;
                                        else if (placemark.locality != nil) placentown = placemark.locality;
                                        if (placemark.country != nil) placencountry = placemark.country;
                                        
                                        [self.data setObject:placentown forKey:@"ovatar_town"];
                                        [self.data setObject:placencountry forKey:@"ovatar_country"];
                                        [self.data synchronize];
                                        
                                        [self.mixpanel.people set:@{@"$city":placentown}];
                                        NSLog(@"User Location Updated: %@, %@" ,placentown ,placencountry);
                                        
                                    }];
                                    
                                    break;
                                    
                                }
                                
                            }
                            
                        }];

                    }];
                    
                }];
                
            }
            else [self viewPresentSubviewWithIndex:0 animate:true];
            
        }];
        
    }];
    
}

-(void)viewPresentGalleryPicker:(ODayCell *)day {
    if (day != nil) {
        [self.viewGalleryLayout setItemSize:CGSizeMake((self.viewGallery.view.bounds.size.width / 3) - 20.0, (self.viewGallery.view.bounds.size.width / 3) - 20.0)];
        [self.viewGallery setRevealed:false];
        [self.viewGallery setSelected:nil];
        [self.viewGallery.collectionView reloadData];
        [self.viewGallery.collectionView setHidden:false];
        [self.viewGallery.collectionView scrollToItemAtIndexPath:self.viewGallery.lastviewed atScrollPosition:UICollectionViewScrollPositionTop animated:false];
        if (self.viewGallery.lastviewed.row >= 3) {
            [self.viewGallery.collectionView scrollRectToVisible:CGRectMake(0.0, self.viewGallery.collectionView.contentOffset.y -28.0, self.viewGallery.collectionView.bounds.size.width, self.viewGallery.collectionView.bounds.size.height) animated:false];
            [self viewDidScrollSubview:self.viewGallery.collectionView.contentOffset.y];
            
        }

        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewContainer setContentOffset:CGPointMake(self.viewContainer.bounds.size.width * self.pageindex, self.viewContainer.bounds.size.height)];
            
        } completion:^(BOOL finished) {
            [self.viewHeader setTitle:NSLocalizedString(@"Main_ImageSelect_Title", nil)];
            [self.viewHeader setBackbutton:false];
            [self.viewHeader setup:@[@"navigation_close", @"navigation_select"] animate:true];
            [self.viewGallery collectionViewAnimateVisibleCells:true];

        }];

        [self setSelected:day];
        
    }
    else {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewContainer setContentOffset:CGPointMake(self.viewContainer.bounds.size.width * self.pageindex, 0.0)];
            
        } completion:^(BOOL finished) {
            [self.viewHeader setTitle:NSLocalizedString(@"Main_Editor_Title", nil)];
            [self.viewHeader setBackbutton:false];
            [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];
            [self.viewHeader shadow:0.0];

            [self.viewStory viewCollectionScroll:day.index];
            
            [self.selected setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [self.selected setAlpha:1.0];
            
        }];
        
    }
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xF4F6F8);
    
    self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];

    self.geocoder = [[CLGeocoder alloc] init];

    self.generator = [[UINotificationFeedbackGenerator alloc] init];

    self.appdel = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    self.payment = [[OPaymentObject alloc] init];
    self.payment.delegate = self;
    
    self.dataobj = [[ODataObject alloc] init];
    self.dataobj.delegate = self;
    
    self.exportobj = [[OExportObject alloc] init];
    
    self.imageobj = [OImageObject sharedInstance];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.qualityOfService = NSQualityOfServiceUtility;
    
    self.viewNotification = [[ONotificationView alloc] init];
    self.viewNotification.backgroundColor = [UIColor clearColor];
    self.viewNotification.delegate = self;

    self.viewContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, self.paddingtop, self.view.bounds.size.width, self.view.bounds.size.height - (self.paddingtop + self.paddingbottom))];
    self.viewContainer.contentSize = CGSizeMake(self.view.bounds.size.width * 3, self.viewContainer.bounds.size.height * 2);
    self.viewContainer.backgroundColor = self.view.backgroundColor;
    self.viewContainer.pagingEnabled = true;
    self.viewContainer.scrollEnabled = false;
    self.viewContainer.showsHorizontalScrollIndicator = false;
    self.viewContainer.showsVerticalScrollIndicator = false;
    [self.view addSubview:self.viewContainer];
    
    self.viewPermissions = [[OPermissionsController alloc] init];
    self.viewPermissions.delegate = self;
    self.viewPermissions.view.backgroundColor = [UIColor clearColor];
    self.viewPermissions.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 0, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height);
    [self addChildViewController:self.viewPermissions];
    [self.viewContainer addSubview:self.viewPermissions.view];
    
    self.viewStoriesLayout = [[OStoriesLayout alloc] init];
    self.viewStoriesLayout.minimumLineSpacing = 0.0;
    self.viewStoriesLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.viewStoriesLayout.sectionInset = UIEdgeInsetsMake(60.0, 20.0, 20.0, 20.0);
    
    self.viewStory = [[OEntryController alloc] initWithCollectionViewLayout:self.viewStoriesLayout];
    self.viewStory.delegate = self;
    self.viewStory.collectionView.clipsToBounds = true;
    self.viewStory.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 1, 60.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height);
    self.viewStory.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:self.viewStory];
    [self.viewContainer addSubview:self.viewStory.view];
    
    self.viewGalleryLayout = [[UICollectionViewFlowLayout alloc] init];
    self.viewGalleryLayout.minimumLineSpacing = 10.0;
    self.viewGalleryLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.viewGalleryLayout.sectionInset = UIEdgeInsetsMake(10.0, 20.0, 10.0, 20.0);
    self.viewGalleryLayout.itemSize = CGSizeMake((self.view.bounds.size.width / 3) - 45.0, (self.view.bounds.size.width / 3) - 45.0);
    
    self.viewGallery = [[OGalleryPickerController alloc] initWithCollectionViewLayout:self.viewGalleryLayout];
    self.viewGallery.delegate = self;
    self.viewGallery.collectionView.backgroundColor = [UIColor clearColor];
    self.viewGallery.view.frame = CGRectMake(self.viewStory.view.frame.origin.x, self.viewStory.view.bounds.size.height, self.viewStory.view.bounds.size.width, self.viewStory.view.bounds.size.height);
    self.viewGallery.collectionView.hidden = true;
    self.viewGallery.collectionView.clipsToBounds = true;
    [self addChildViewController:self.viewGallery];
    [self.viewContainer addSubview:self.viewGallery.view];
    
    self.viewPresentation = [[OPresentationController alloc] init];
    self.viewPresentation.view.backgroundColor = [UIColor clearColor];
    self.viewPresentation.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 2, 60.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - 60.0);
    self.viewPresentation.view.hidden = true;
    self.viewPresentation.delegate = self;
    [self addChildViewController:self.viewPresentation];
    [self.viewContainer addSubview:self.viewPresentation.view];
    
    self.viewSettings = [[OSettingsController alloc] init];
    self.viewSettings.view.backgroundColor = [UIColor clearColor];
    self.viewSettings.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 2, 60.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - 60.0);
    self.viewSettings.view.hidden = true;
    self.viewSettings.delegate = self;
    [self addChildViewController:self.viewSettings];
    [self.viewContainer addSubview:self.viewSettings.view];
    
    self.viewHeader = [[OTitleView alloc] initWithFrame:CGRectMake(0.0, self.viewContainer.frame.origin.y, self.view.bounds.size.width, 64.0)];
    self.viewHeader.backgroundColor = [UIColor clearColor];
    self.viewHeader.delegate = self;
    self.viewHeader.title = NSLocalizedString(@"Main_GettingStarted_Title", nil);
    [self.view addSubview:self.viewHeader];
    
}

-(void)viewPresentError:(NSString *)text {
    [self.viewNotification notificationPresentWithTitle:text type:ONotificationTypeError];
    [self.mixpanel track:@"App Error Presented" properties:@{@"Text":[NSString stringWithFormat:@"%@" ,text]}];
    
}

-(void)viewPresentLoader:(BOOL)present text:(NSString *)text {
    [self.appdel setLtext:text];
    [self.appdel setLassets:nil];
    [self.appdel applicationLoadingScreen:present];
    
}

-(void)viewInsertSubview:(OSettingsSubview)view {
    if (view != OSettingsSubviewNone) {
        if (view == OSettingsSubviewFeedback) {
            self.viewFeeback = [[OFeedbackController alloc] init];
            self.viewFeeback.delegate = self;
            self.viewFeeback.view.backgroundColor = [UIColor clearColor];
            self.viewFeeback.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 3, 60.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - 60.0);
            [self addChildViewController:self.viewFeeback];
            [self.viewContainer addSubview:self.viewFeeback.view];
            [self.viewFeeback.viewEmail becomeFirstResponder];
            
        }
        
        [self viewPresentSubviewWithIndex:3 animate:true];
        [self.viewContainer setContentSize:CGSizeMake(self.viewContainer.contentSize.width + self.view.bounds.size.width, self.viewContainer.contentSize.height)];

    }
    else {
        [self viewPresentSubviewWithIndex:1 animate:true];
        [self.viewContainer setContentSize:CGSizeMake(self.view.bounds.size.width * 2, self.viewContainer.contentSize.height)];
        [self.viewFeeback.view removeFromSuperview];

    }
    
}

-(void)viewPresentSubviewWithIndex:(int)index animate:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            for (UIView *subview  in self.viewContainer.subviews) {
                [subview setAlpha:0.9];
                [subview setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
                [subview setBackgroundColor:[UIColor clearColor]];
                [subview.layer setCornerRadius:8.0];

            }
            
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.viewContainer setContentOffset:CGPointMake(self.viewContainer.bounds.size.width * index, 0.0)];
                
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.4 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    for (UIView *subview  in self.viewContainer.subviews) {
                        [subview setAlpha:1.0];
                        [subview setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                        [subview setBackgroundColor:[UIColor clearColor]];
                        [subview.layer setCornerRadius:0.0];

                    }
                    
                } completion:nil];
                    
            }];
            
        }];
        
    }
    else [self.viewContainer setContentOffset:CGPointMake(self.viewContainer.bounds.size.width * index, 0.0)];
    
    if (index == 0) {
        [self.viewHeader setTitle:NSLocalizedString(@"Main_Permissions_Title", nil)];
        [self.viewHeader setBackbutton:false];
        [self.viewHeader setup:@[] animate:animate];

    }
    else if (index == 1) {
        [self.viewHeader setTitle:NSLocalizedString(@"Main_Editor_Title", nil)];
        [self.viewHeader setBackbutton:false];
        [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];
        
        [self.viewStory viewEditorDidScroll:self.viewStory.collectionView.visibleCells.firstObject];
        [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];

    }
    else if (index == 2) {
        if (self.viewPresentation.view.isHidden) {
            [self.viewHeader setTitle:NSLocalizedString(@"Main_Settings_Title", nil)];
            [self.viewHeader setBackbutton:true];
            [self.viewHeader setup:@[] animate:animate];

            [self.viewSettings.settings removeAllObjects];
            [self.viewSettings tableViewContent];
            
        }
        else {
            [self.viewHeader setTitle:NSLocalizedString(@"Main_Preview_Title", nil)];
            [self.viewHeader setBackbutton:true];
            [self.viewHeader setup:@[] animate:animate];
            
            [self.appdel setLassets:[self.dataobj storyEntriesPreviews:self.dataobj.storyActiveKey]];
            [self.appdel setLtext:@"00%"];
            [self.appdel applicationLoadingScreen:true];
            
        }
        
    }
    else {
        if (!self.viewFeeback.view.isHidden) {
            [self.viewHeader setTitle:NSLocalizedString(@"Main_Support_Title", nil)];
            [self.viewHeader setBackbutton:true];
            [self.viewHeader setup:@[] animate:animate];
            [self.viewFeeback.viewEmail becomeFirstResponder];
            
        }
        
    }
    
    [self.viewHeader shadow:0.0];
    [self setPageindex:index];

}


-(void)titleNavigationBackTapped:(UIButton *)button {
    [self.view endEditing:true];
    [self.viewPresentation.viewPlayer.player pause];
    [self viewPresentSubviewWithIndex:self.pageindex - 1 animate:true];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
        if (!self.viewPresentation.view.hidden) {
            [self.viewPresentation viewReset];
            [self.appdel applicationLoadingScreen:false];

            [[NSFileManager defaultManager] removeItemAtPath:self.exported.absoluteString error:nil];
        
        }
        
        if (![self.view.subviews containsObject:self.viewFeeback.view]) {
            [self.viewFeeback removeFromParentViewController];
            
        }
        
    });

}

-(void)titleNavigationButtonTapped:(OTitleButtonType)button {
    if (button == OTitleButtonTypePreview) {
        [self.viewSettings.view setHidden:true];
        [self.viewPresentation.view setHidden:false];
        [self.viewPresentation viewReset];
        if ([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey] > 2) {
            [self viewPresentSubviewWithIndex:2 animate:true];
            [self viewExportWithSize:CGSizeMake(1080, 1920)];
            [self.mixpanel track:@"App Previewed Video" properties:@{@"Items":@([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey])}];

        }
        else {
            [self viewPresentSubviewWithIndex:1 animate:true];
            [self.viewNotification notificationPresentWithTitle:NSLocalizedString(@"Error_LimitedMedia_Title", nil) type:ONotificationTypeError];
            
        }
        
    }
    else if (button == OTitleButtonTypeSettings) {
        [self.viewSettings.view setHidden:false];
        [self.viewPresentation.view setHidden:true];

        [self viewPresentSubviewWithIndex:2 animate:true];

    }
    else if (button == OTitleButtonTypeExport) {
        [self.mixpanel timeEvent:@"App Exported Video"];
        [self.dataobj storyExport:self.dataobj.storyActiveKey completion:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (error.code == 200) {
                    [self.viewHeader setup:@[] animate:true];
                    [self.viewPresentation setExported:self.exported];
                    [self.viewPresentation viewExportSucsessful];
                    [self.mixpanel track:@"App Exported Video" properties:@{@"Items":@([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey])}];

                }
                else [self.viewNotification notificationPresentWithTitle:error.domain type:ONotificationTypeError];

            }];
            
        }];
        
    }
    else if (button == OTitleButtonTypeSelect) {
        if (self.viewGallery.selected.count > 0) {
            [self viewGallerySelectedImage:self.viewGallery.selected];
            [self viewPresentGalleryPicker:nil];

        }
        else {
            [self.viewNotification notificationPresentWithTitle:NSLocalizedString(@"Error_GallerySelectionEmpty_Title", nil) type:ONotificationTypeError];

        }
        
    }
    else if (button == OTitleButtonTypeClose) {
        [self viewPresentGalleryPicker:nil];
        
    }
    
}

-(void)viewExportWithSize:(CGSize)size {
    if (!self.exporting) {
        [self setExporting:true];
        if ([self.payment paymentPurchasedItemWithIdentifyer:@"watermarkremove"]) {
            [self.exportobj setWatermark:nil];
            [self.viewPresentation.viewPurchase setHidden:true];
            
        }
        else {
            [self.exportobj setWatermark:@"ovatar.io/montage"];
            [self.viewPresentation.viewPurchase setHidden:false];
            
        }
        
        [self.exportobj setVideoframes:29.96];
        [self.exportobj setVideoseconds:1.3];
        [self.exportobj setVideoresize:size];
        [self.exportobj exportMontage:self.dataobj.storyActiveKey completion:^(NSString *file, NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (self.pageindex == 2 && self.viewPresentation.view.hidden == false) {
                    if (file != nil) {
                        [self setExported:[NSURL fileURLWithPath:file]];
                        [self.viewPresentation setVideosize:self.exportobj.videoresize];
                        [self.viewPresentation viewPresentOutput:self.exported];
                        [self.viewHeader setup:@[@"navigation_export"] animate:true];
                        
                        [self.generator notificationOccurred:UINotificationFeedbackTypeSuccess];
                        [self.generator prepare];
                        
                    }
                    else {
                        [self.viewNotification notificationPresentWithTitle:error.localizedDescription type:ONotificationTypeError];
                        
                        [self.generator notificationOccurred:UINotificationFeedbackTypeError];
                        [self.generator prepare];
                        
                    }
                    
                    [self setExporting:false];
                    [self.appdel applicationLoadingScreen:false];
                    
                }
                
            }];
            
        }];
        
    }
    
    
}

-(void)viewGallerySelectedImage:(NSArray *)assets {
    int originalcount = (int)[[self.dataobj storyEntries:self.dataobj.storyActiveKey] count];
    NSMutableArray *append = [[NSMutableArray alloc] initWithArray:assets];
    
    NSLog(@"first item %@" ,assets);
    [self.viewStory viewUpdateEntry:self.selected loading:true];
    if (self.selected != nil) {
        PHAsset *asset = append.firstObject;
        NSString *key = self.selected.key;
        [self.dataobj entryAppendWithImageData:asset animated:true entry:key completion:^(NSError *error) {
            [self.imageobj imageCreateEntryFromAsset:asset animate:true key:key completion:^(NSError *error, BOOL animated) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (error.code == 200 || error == nil) {
                        NSLog(@"create story in selected : %@ in cell %@" ,error ,self.selected.key);
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
                        [self viewPresentError:error.localizedDescription];
                        [self.viewStory viewUpdateEntry:self.selected loading:false];
                        
                    }
                    
                }];
            
            }];
            
        }];
        
        [append removeObjectAtIndex:0];
    
    }
    
    if (append.count > 0) {
        [self.dataobj entryCreate:self.dataobj.storyActiveKey assets:append completion:^(NSError *error, NSArray *keys) {
            for (int i = 0; i < keys.count; i++) {
                NSString *key = [keys objectAtIndex:i];
                NSDictionary *entry = [self.dataobj entryWithKey:key];
                [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                [self.imageobj imageReturnFromAssetKey:[entry objectForKey:@"assetid"] completion:^(PHAsset *asset) {
                    if (asset != nil) {
                        [self.imageobj imageCreateEntryFromAsset:asset animate:true key:key completion:^(NSError *error, BOOL animated) {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                NSIndexPath *index = [NSIndexPath indexPathForRow:originalcount + i inSection:0];
                                ODayCell *day = (ODayCell *)[self.viewStory.collectionView cellForItemAtIndexPath:index];
                                
                                [self.viewStory viewUpdateEntry:day loading:true];
                                [self.dataobj entryAppendWithImageData:asset animated:true entry:key completion:^(NSError *error) {
                                    [self.viewStory viewUpdateEntry:day loading:false];
                                    
                                }];
                                
                            }];
                            
                        }];
                        
                    }
                    else NSLog(@"no asset found");
                    
                }];
            
            }
            
        }];
        
    }
    
}

-(void)viewDidScrollSubview:(float)position {
    [self.viewHeader shadow:position];
    
}

-(void)photoLibraryDidChange:(PHChange *)changeInstance {
    [self.imageobj imagesFromAlbum:nil limit:0 completion:^(NSArray *images) {
        if (self.viewGallery.images.count != images.count) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewGallery.images removeAllObjects];
                [self.viewGallery.images addObjectsFromArray:images];
                
                [self.viewGallery.collectionView reloadData];
                
            }];
            
        }
        
    }];
    
}

-(void)viewRestorePurchases {
    [self.payment purchaseRestore];
    [self.appdel setLtext:NSLocalizedString(@"Subscription_Loading_Title", nil)];
    [self.appdel setLassets:nil];
    [self.appdel applicationLoadingScreen:true];

    
}

-(void)viewPurchaseInitialiseWithIdentifyer:(NSString *)identifyer {
    [self.payment purchaseItemWithIdentifyer:identifyer];
    [self.payment paymentRecordInterest];

}

-(void)paymentSucsessfullyUpgradedWithState:(OPaymentState)state {
    if (state == OPaymentStateRestored) {
        if (self.pageindex == 2 && self.viewPresentation.view.hidden == false) {
            [self viewPresentSubviewWithIndex:2 animate:true];
            [self viewExportWithSize:CGSizeMake(1080, 1920)];

        }
        else {
            [self.viewNotification notificationPresentWithTitle:NSLocalizedString(@"Subscription_Restored_Error", nil) type:ONotificationTypeNotice];
            
        }

    }
    else if (state == OPaymentStatePurchased) {
        if (self.pageindex == 2 && self.viewPresentation.view.hidden == false) {
            [self viewPresentSubviewWithIndex:2 animate:true];
            [self viewExportWithSize:CGSizeMake(1080, 1920)];
        }
        else {
            [self.viewNotification notificationPresentWithTitle:NSLocalizedString(@"Subscription_Purchaesed_Error", nil) type:ONotificationTypeNotice];
            
        }

    }
    else {
        [self.viewNotification notificationPresentWithTitle:NSLocalizedString(@"Subscription_Deferred_Error", nil) type:ONotificationTypeNotice];

    }

    [self.appdel applicationLoadingScreen:false];

}

-(void)paymentReturnedErrors:(NSError *)error {
    [self.appdel applicationLoadingScreen:false];
    [self.viewNotification notificationPresentWithTitle:error.localizedDescription type:ONotificationTypeError];

}

-(void)paymentProcessing:(BOOL)restoring {
    
}

-(void)paymentCancelled {
    [self.appdel applicationLoadingScreen:false];

}

-(void)dealloc {
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self];
    
}

@end
