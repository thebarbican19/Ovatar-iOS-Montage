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
    
    [self.imageobj imageAuthorization:false completion:^(PHAuthorizationStatus status) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (status == PHAuthorizationStatusAuthorized) {
                [self viewPresentSubviewWithIndex:1 animate:false];
                [self viewStorySetup];
                
            }
            else [self viewPresentSubviewWithIndex:0 animate:false];
                
        }];
        
    }];
    
    if (@available(iOS 11, *)) {
        self.paddingtop = self.view.safeAreaInsets.top;
        self.paddingbottom = self.view.safeAreaInsets.bottom;
        
    }
        
    self.viewContainer.frame = CGRectMake(0.0, self.paddingtop, self.view.bounds.size.width, self.view.bounds.size.height - self.paddingtop);
    self.viewContainer.contentSize = CGSizeMake(self.view.bounds.size.width * 3, self.viewContainer.bounds.size.height);
    self.viewPermissions.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 0, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - self.paddingbottom);
    self.viewStory.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 1, self.viewStory.view.frame.origin.y, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height);
    self.viewStoriesLayout.itemSize = CGSizeMake(self.view.bounds.size.width - 90.0 , self.viewContainer.contentSize.height - 90.0);
    self.viewHeader.frame = CGRectMake(0.0, self.viewContainer.frame.origin.y, self.view.bounds.size.width, 64.0);
    self.viewPresentation.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 2, 60.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - (60.0 + self.paddingbottom));
    self.viewSettings.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 2, 60.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - 60.0);
    
}

-(void)viewStorySetup {
    [self.imageobj imageAuthorization:true completion:^(PHAuthorizationStatus status) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            if (status == PHAuthorizationStatusAuthorized) {
                if (self.dataobj.storyLatest == nil) {
                    [self.dataobj storyCreateWithData:@{@"name":@"my first story"} completion:^(NSString *key, NSError *error) {
                        [self.dataobj entryCreate:key completion:^(NSError *error, NSString *key) {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                [self.viewStory.collectionView reloadData];

                            }];
                            
                        }];
                        
                    }];
                    
                }
                else {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.viewStory.collectionView reloadData];
                        
                    }];
                    
                }
                
            }
            else [self viewPresentSubviewWithIndex:0 animate:true];
            
        }];
        
    }];
    
}

-(void)viewPresentGalleryPicker:(ODayCell *)day {
    if (day != nil) {
        [self.imageobj imagesFromAlbum:nil completion:^(NSArray *images) {
            [self.viewGallery.images addObjectsFromArray:images];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.viewGallery.view setFrame:CGRectMake(self.viewStory.view.frame.origin.x + 16.0, 0.0, day.bounds.size.width, self.viewContainer.bounds.size.height)];
                [self.viewGalleryLayout setItemSize:CGSizeMake((self.viewGallery.view.bounds.size.width / 3) - 10.0, (self.viewGallery.view.bounds.size.width / 3) - 10.0)];

                [self.viewGallery.collectionView setHidden:false];
                [self.viewGallery.collectionView reloadData];
                
                [self.viewStory.collectionView setHidden:true];

                [self.viewHeader setTitle:@"Select Image"];
                [self.viewHeader setBackbutton:false];
                [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];

            }];
            
        }];
        
    }
    else {
        [self.viewStory.collectionView setHidden:false];

        [self.viewGallery.collectionView reloadData];
        [self.viewGallery.collectionView setHidden:true];
        [self.viewGallery.view setFrame:CGRectMake(self.viewStory.view.frame.origin.x, self.viewStory.view.bounds.size.height, self.viewStory.view.bounds.size.width, self.viewStory.view.bounds.size.height)];

        [self.viewHeader setTitle:@"Editor"];
        [self.viewHeader setBackbutton:false];
        [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];
        
        [self.dataobj entryCreate:self.dataobj.storyActiveKey completion:^(NSError *error, NSString *key) {
            
        }];
        
        [self.selected setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [self.selected setAlpha:1.0];
        
    }
    
    self.selected = day;
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColorFromRGB(0xF4F6F8);
    
    self.appdel = (AppDelegate*) [[UIApplication sharedApplication] delegate];

    self.dataobj = [[ODataObject alloc] init];
    self.dataobj.delegate = self;
    
    self.imageobj = [OImageObject sharedInstance];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.qualityOfService = NSQualityOfServiceUtility;
    
    self.viewNotification = [[ONotificationView alloc] init];
    self.viewNotification.backgroundColor = [UIColor clearColor];
    self.viewNotification.delegate = self;

    self.viewContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, self.paddingtop, self.view.bounds.size.width, self.view.bounds.size.height - (self.paddingtop + self.paddingbottom))];
    self.viewContainer.contentSize = CGSizeMake(self.view.bounds.size.width * 3, self.viewContainer.bounds.size.height);
    self.viewContainer.backgroundColor = self.view.backgroundColor;
    self.viewContainer.pagingEnabled = true;
    self.viewContainer.scrollEnabled = false;
    self.viewContainer.showsHorizontalScrollIndicator = false;
    [self.view addSubview:self.viewContainer];
    
    self.viewPermissions = [[OPermissionsController alloc] init];
    self.viewPermissions.delegate = self;
    self.viewPermissions.view.backgroundColor = [UIColor clearColor];
    self.viewPermissions.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 0, 0.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height);
    [self addChildViewController:self.viewPermissions];
    [self.viewContainer addSubview:self.viewPermissions.view];
    
    self.viewStoriesLayout = [[UICollectionViewFlowLayout alloc] init];
    self.viewStoriesLayout.minimumLineSpacing = 10.0;
    self.viewStoriesLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.viewStoriesLayout.sectionInset = UIEdgeInsetsMake(86.0, 4.0, 4.0, 4.0);
    self.viewStoriesLayout.itemSize = CGSizeMake(180.0, 200);
    
    self.viewStory = [[OEntryController alloc] initWithCollectionViewLayout:self.viewStoriesLayout];
    self.viewStory.delegate = self;
    self.viewStory.collectionView.clipsToBounds = true;
    self.viewStory.view.frame = CGRectMake(self.viewContainer.bounds.size.width * 1, 60.0, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - 60.0);
    self.viewStory.view.backgroundColor = [UIColor clearColor];
    [self addChildViewController:self.viewStory];
    [self.viewContainer addSubview:self.viewStory.view];
    
    self.viewGalleryLayout = [[UICollectionViewFlowLayout alloc] init];
    self.viewGalleryLayout.minimumLineSpacing = 10.0;
    self.viewGalleryLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.viewGalleryLayout.sectionInset = UIEdgeInsetsMake(86.0, 4.0, 4.0, 4.0);
    self.viewGalleryLayout.itemSize = CGSizeMake((self.view.bounds.size.width / 3) - 45.0, (self.view.bounds.size.width / 3) - 45.0);
    
    self.viewGallery = [[OGalleryPickerController alloc] initWithCollectionViewLayout:self.viewGalleryLayout];
    self.viewGallery.delegate = self;
    self.viewGallery.collectionView.backgroundColor = [UIColor clearColor];
    self.viewGallery.view.frame = CGRectMake(self.viewStory.view.frame.origin.x, self.viewContainer.bounds.size.height - 200, self.viewStory.view.bounds.size.width, self.viewStory.view.bounds.size.height);
    self.viewGallery.collectionView.hidden = true;
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
    [self addChildViewController:self.viewSettings];
    [self.viewContainer addSubview:self.viewSettings.view];
    
    self.viewHeader = [[OTitleView alloc] initWithFrame:CGRectMake(0.0, self.viewContainer.frame.origin.y, self.view.bounds.size.width, 64.0)];
    self.viewHeader.backgroundColor = [UIColor clearColor];
    self.viewHeader.delegate = self;
    self.viewHeader.title = @"Getting Started";
    [self.view addSubview:self.viewHeader];

}

-(void)viewPresentSubviewWithIndex:(int)index animate:(BOOL)animate {
    if (animate) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            for (UIView *subview  in self.viewContainer.subviews) {
                [subview setAlpha:0.9];
                [subview setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
                [subview setBackgroundColor:[UIColor whiteColor]];
                [subview.layer setCornerRadius:12.0];

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
        [self.viewHeader setTitle:@"Permissions"];
        [self.viewHeader setBackbutton:false];
        [self.viewHeader setup:@[] animate:animate];

    }
    else if (index == 1) {
        [self.viewHeader setTitle:@"Editor"];
        [self.viewHeader setBackbutton:false];
        [self.viewHeader setup:@[@"navigation_settings", @"navigation_preview"] animate:true];

    }
    else {
        if (self.viewPresentation.view.isHidden) {
            [self.viewHeader setTitle:@"Settings"];
            [self.viewHeader setBackbutton:true];
            [self.viewHeader setup:@[] animate:animate];

        }
        else {
            [self.viewHeader setTitle:@"Preview"];
            [self.viewHeader setBackbutton:true];
            [self.viewHeader setup:@[@"navigation_export"] animate:animate];
            [self.viewPresentation viewPresentLoader:[self.dataobj storyEntriesPreviews:self.dataobj.storyActiveKey]];

        }
        
    }
    
    self.pageindex = index;

}


-(void)titleNavigationBackTapped:(UIButton *)button {
    [self viewPresentSubviewWithIndex:1 animate:true];
    
}

-(void)titleNavigationButtonTapped:(OTitleButtonType)button {
    if (button == OTitleButtonTypePreview) {
        [self.viewSettings.view setHidden:true];
        [self.viewPresentation.view setHidden:false];
        if ([self.dataobj storyEntriesWithAssets:self.dataobj.storyActiveKey] > 2) {
            [self viewPresentSubviewWithIndex:2 animate:true];
            [self.dataobj storyCreateVideo:self.dataobj.storyActiveKey completion:^(NSString *file, NSError *error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if (file != nil) {
                        NSLog(@"output: %@" ,file);
                        [self.viewPresentation viewPresentOutput:[NSURL fileURLWithPath:file]];

                    }
                    else {
                        [self.viewPresentation.viewLoader.timer invalidate];
                        [self.viewNotification notificationPresentWithTitle:error.localizedDescription type:ONotificationTypeError];
                        
                    }
                    
                }];
                
            }];
            
            
        }
        else {
            [self.viewNotification notificationPresentWithTitle:@"At-least 2 items required to preview your story" type:ONotificationTypeError];
            
        }
        
    }
    else if (button == OTitleButtonTypeSettings) {
        [self.viewSettings.view setHidden:false];
        [self.viewPresentation.view setHidden:true];

        [self viewPresentSubviewWithIndex:2 animate:true];

    }
    else if (button == OTitleButtonTypeExport) {
        [self.viewPresentation.viewPlayer.view setHidden:true];
        //[self.appdel applicationRatePrompt];

    }
    
}

-(void)viewGallerySelectedImage:(PHAsset *)asset {
    [self.imageobj imageCreateEntryFromAsset:asset animate:true key:self.selected.key completion:^(NSError *error, BOOL animated, NSInteger orentation) {
        if (error == nil || error.code == 200) {
            [self.dataobj entryAppendWithImageData:asset animated:true orentation:orentation entry:self.selected.key completion:^(NSError *error) {
                [self.dataobj entryCreate:self.dataobj.storyActiveKey completion:^(NSError *error, NSString *key) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self viewPresentGalleryPicker:nil];
                        
                    }];

                }];

            }];

        }
        
    }];
    
}

-(void)entryDeleteAssetContent {
    
}

-(void)entryToggleAssetAnimation {
    
}

@end
