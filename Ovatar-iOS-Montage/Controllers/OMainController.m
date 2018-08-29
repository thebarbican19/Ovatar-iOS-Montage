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
        
    self.viewContainer.frame = CGRectMake(0.0, self.paddingtop, self.view.bounds.size.width, self.view.bounds.size.height - self.paddingtop);
    self.viewContainer.contentSize = CGSizeMake(self.view.bounds.size.width * 3, self.viewContainer.bounds.size.height);
    self.viewPermissions.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 0, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - self.paddingbottom);
    self.viewStory.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 1, self.viewContainer.frame.origin.y, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - 64.0);
    self.viewStoriesLayout.itemSize = CGSizeMake(self.viewContainer.bounds.size.width - 70.0, self.viewStory.collectionView.bounds.size.height - 120.0);
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
                        [self.dataobj storyCreateWithData:@{@"name":@"my first story"} completion:^(NSString *key, NSError *error) {
                            [self.dataobj entryCreate:key completion:^(NSError *error, NSString *key) {
                                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                    [self.viewStory viewUpdateContent:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
                                    [self viewPresentSubviewWithIndex:1 animate:animateview];
                                    
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
                    [self.imageobj imagesFromAlbum:nil completion:^(NSArray *images) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self.viewGallery.images removeAllObjects];
                            [self.viewGallery.images addObjectsFromArray:images];
                            [self.viewGallery.collectionView reloadData];
                            
                            [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
                            
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
            
            [self.viewStory viewCollectionScroll:day.index];
            [self.viewGallery setSelected:nil];
            [self.viewGallery.collectionView scrollRectToVisible:CGRectMake(0.0, 0.0, self.viewGallery.view.bounds.size.width, self.viewGallery.view.bounds.size.height) animated:false];

            [self.selected setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [self.selected setAlpha:1.0];
            
        }];
        
    }
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xF4F6F8);
    
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
    self.viewStoriesLayout.sectionInset = UIEdgeInsetsMake(40.0, 20.0, 80.0, 20.0);
    
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
    self.viewGalleryLayout.sectionInset = UIEdgeInsetsMake(40.0, 20.0, 40.0, 20.0);
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
            [self.appdel applicationLoadingScreen:true];
            
        }
        
    }
    else {
        if (!self.viewFeeback.view.isHidden) {
            [self.viewHeader setTitle:NSLocalizedString(@"Main_Support_Title", nil)];
            [self.viewHeader setBackbutton:true];
            [self.viewHeader setup:@[] animate:animate];
            
            [self.viewFeeback.viewInput becomeFirstResponder];
            
        }
        
    }
    
    [self setPageindex:index];

}


-(void)titleNavigationBackTapped:(UIButton *)button {
    [self.view endEditing:true];
    [self.viewPresentation.viewPlayer.player pause];
    [self viewPresentSubviewWithIndex:self.pageindex - 1 animate:true];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void) {
        if (!self.viewPresentation.view.hidden) {
            [self.viewPresentation viewReset];
            [self.exportobj.exporter cancelExport];
            [self.appdel applicationLoadingScreen:false];

            [[NSFileManager defaultManager] removeItemAtPath:self.exported.absoluteString error:nil];
        
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
            [self.exportobj setWatermark:@"ovatar.io/montage"];
            [self.exportobj setVideoresize:CGSizeMake(1080, 1920)];
            //[self.exportobj setVideoresize:CGSizeMake(1080, 1080)];
            //[self.exportobj setVideoresize:CGSizeMake(1920, 1080)];

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
                        
                        [self.appdel applicationLoadingScreen:false];
                        
                    }
                    
                }];
                
            }];
            
            
        }
        else {
            [self.viewNotification notificationPresentWithTitle:NSLocalizedString(@"Error_LimitedMedia_Title", nil) type:ONotificationTypeError];
            
        }
        
    }
    else if (button == OTitleButtonTypeSettings) {
        [self.viewSettings.view setHidden:false];
        [self.viewPresentation.view setHidden:true];

        [self viewPresentSubviewWithIndex:2 animate:true];

    }
    else if (button == OTitleButtonTypeExport) {
        [self.dataobj storyExport:self.dataobj.storyActiveKey completion:^(NSError *error) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (error.code == 200) {
                    [self.viewHeader setup:@[] animate:true];
                    [self.viewPresentation setExported:self.exported];
                    [self.viewPresentation viewExportSucsessful];
                    
                }
                else [self.viewNotification notificationPresentWithTitle:error.domain type:ONotificationTypeError];

            }];
            
        }];
        
    }
    else if (button == OTitleButtonTypeSelect) {
        if (self.viewGallery.selected != nil) {
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

-(void)viewGallerySelectedImage:(PHAsset *)asset {
    [self.viewStory viewUpdateEntry:self.viewStory.active loading:true];
    [self.imageobj imageCreateEntryFromAsset:asset animate:true key:self.selected.key completion:^(NSError *error, BOOL animated) {
        if (error == nil || error.code == 200) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewStory viewUpdateEntry:self.selected loading:true];
                
            }];
            
            dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
            dispatch_after(delay, dispatch_get_main_queue(), ^(void){
                [self.dataobj entryAppendWithImageData:asset animated:true entry:self.selected.key completion:^(NSError *error) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.viewStory viewUpdateEntry:self.selected loading:false];
                        [self.viewStory viewEditorDidScroll:self.selected];
                        [self setSelected:nil];
                        
                    }];

                }];
                
            });

        }
        else {
            [self.viewNotification notificationPresentWithTitle:error.domain type:ONotificationTypeError];
            
        }
        
    }];
    
}

-(void)viewRestorePurchases {
    [self.payment purchaseRestore];
    [self.appdel setLassets:nil];
    [self.appdel applicationLoadingScreen:true];
    
}

-(void)photoLibraryDidChange:(PHChange *)changeInstance {
    [self.imageobj imagesFromAlbum:nil completion:^(NSArray *images) {
        if (self.viewGallery.images.count != images.count) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewGallery.images removeAllObjects];
                [self.viewGallery.images addObjectsFromArray:images];
                
                [self.viewGallery.collectionView reloadData];
                
            }];
            
        }
        
    }];
    
}

-(void)paymentSucsessfullyUpgradedWithState:(OPaymentState)state {
    if (state == OPaymentStateRestored) {
        [self.viewNotification notificationPresentWithTitle:NSLocalizedString(@"Error_PaymentRestored_Title", nil) type:ONotificationTypeNotice];
        
    }
    else if (state == OPaymentStatePurchased) {
        
    }
    else {
        
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
