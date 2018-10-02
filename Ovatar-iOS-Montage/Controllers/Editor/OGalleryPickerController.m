//
//  OGalleryPickerController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 29/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OGalleryPickerController.h"
#import "OGalleryCell.h"
#import "OGalleryReusableView.h"
#import "OConstants.h"

@interface OGalleryPickerController ()

@end

@implementation OGalleryPickerController

#define MODAL_HEIGHT ([UIApplication sharedApplication].delegate.window.bounds.size.height - 120.0)

-(instancetype)init {
    self = [super init];
    if (self) {
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        
        self.images = [[NSMutableArray alloc] init];
        
        self.places = [[NSMutableArray alloc] init];
        
        self.mixpanel = [Mixpanel sharedInstance];
        
        self.geocoder = [[CLGeocoder alloc] init];
        
        self.imageobj = [OImageObject sharedInstance];
        
        self.dataobj = [[ODataObject alloc] init];
        
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.qualityOfService = NSQualityOfServiceBackground;
        self.queue.maxConcurrentOperationCount = 1;
        
    }
    
    return self;
    
}

-(void)present {
    self.selected = [[NSMutableArray alloc] init];
    if (![[UIApplication sharedApplication].delegate.window.subviews containsObject:self.viewOverlay]) {
        self.viewOverlay = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
        self.viewOverlay.backgroundColor = MAIN_MODAL_BACKGROUND;
        self.viewOverlay.alpha = 0.0;
        self.viewOverlay.userInteractionEnabled = true;
        
        self.viewRounded = [CAShapeLayer layer];
        self.viewRounded.path = [UIBezierPath bezierPathWithRoundedRect:self.viewOverlay.bounds byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight cornerRadii:CGSizeMake(MAIN_CORNER_EDGES, MAIN_CORNER_EDGES)].CGPath;
        
        self.viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
        self.viewContainer.backgroundColor = [UIColor lightGrayColor];
        self.viewContainer.backgroundColor = UIColorFromRGB(0xF4F6F8);
        self.viewContainer.layer.mask = self.viewRounded;
        
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        [[UIApplication sharedApplication].delegate.window addSubview:self.viewOverlay];
        [[UIApplication sharedApplication].delegate.window addSubview:self.viewContainer];
        
        self.viewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        self.viewGesture.delegate = self;
        self.viewGesture.enabled = true;
        [self.viewOverlay addGestureRecognizer:self.viewGesture];
        
        self.viewLayout = [[UICollectionViewFlowLayout alloc] init];
        self.viewLayout.minimumLineSpacing = 10.0;
        self.viewLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.viewLayout.sectionInset = UIEdgeInsetsMake(-5.0, 20.0, 10.0, 20.0);
        self.viewLayout.itemSize = CGSizeMake((self.viewContainer.bounds.size.width / 3) - 20.0, (self.viewContainer.bounds.size.width / 3) - 20.0);
        
        self.viewHeader = [[OTitleView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.viewContainer.bounds.size.width, MAIN_HEADER_MODAL_HEIGHT)];
        self.viewHeader.backgroundColor = [UIColor clearColor];
        self.viewHeader.delegate = self;
        self.viewHeader.title = NSLocalizedString(@"Main_ImageSelect_Title", nil);
        self.viewHeader.backbutton = false;
        self.viewHeader.buttons = @[@"navigation_close"].mutableCopy;
        [self.viewContainer addSubview:self.viewHeader];
        
        self.viewCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0.0, MAIN_HEADER_MODAL_HEIGHT, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height) collectionViewLayout:self.viewLayout];
        self.viewCollection.backgroundColor = [UIColor clearColor];
        self.viewCollection.showsHorizontalScrollIndicator = false;
        self.viewCollection.delegate = self;
        self.viewCollection.dataSource = self;
        [self.viewContainer addSubview:self.viewCollection];
        
        [self.viewCollection registerClass:[OGalleryCell class] forCellWithReuseIdentifier:@"thumbnail"];
        [self.viewCollection registerClass:[OGalleryReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewOverlay setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            [self.generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            [self.generator prepare];
            
        }];
        
        [UIView animateWithDuration:0.7 delay:0.25 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT + 80.0)];
            
        } completion:^(BOOL finished) {
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
            
        }];
        
    }
        
}

-(void)setup {
    [self.imageobj imagesFromAlbum:nil limit:0 completion:^(NSArray *images) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.images removeAllObjects];
            [self.images addObjectsFromArray:images];
            
            [self.viewCollection reloadData];

            [self.mixpanel identify:self.mixpanel.distinctId];
            [self.mixpanel.people set:@{@"Photos":@([[images.firstObject objectForKey:@"images"] count])}];
            
            [PHPhotoLibrary.sharedPhotoLibrary registerChangeObserver:self];
            
        }];
    
        for (NSDictionary *item in [images.firstObject objectForKey:@"images"]) {
            [self.queue addOperationWithBlock:^{
                PHAsset *asset = [item objectForKey:@"asset"];
                if (asset.location) {
                    [self.geocoder reverseGeocodeLocation:asset.location completionHandler:^(NSArray *placemarks, NSError *error) {
                        CLPlacemark *placemark = placemarks.lastObject;
                        NSString *placetown = @"";
                        NSString *placecountry = @"";
                        
                        if (placemark.subLocality != nil) placetown = placemark.subLocality;
                        else if (placemark.locality != nil) placetown = placemark.locality;
                        if (placemark.country != nil) placecountry = placemark.country;
                        
                        if (placecountry != nil && placetown != nil) {
                            [self.places addObject:@{@"town":placetown, @"city":placecountry}];
                            NSLog(@"User Location Updated: %@, %@" ,placetown ,placecountry);

                        }
                        
                    }];
                    
                }
                
            }];
            
        }
            
        [self.queue addOperationWithBlock:^{
            if ([self.places count] > 0) {
                NSCountedSet *counted = [[NSCountedSet alloc] initWithArray:self.places];
                NSMutableArray *merged = [[NSMutableArray alloc] init];
                for (NSDictionary *place in counted) {
                    NSMutableDictionary *append = [[NSMutableDictionary alloc] init];
                    [append addEntriesFromDictionary:place];
                    [append setObject:@([counted countForObject:merged]) forKey:@"counted"];
                    
                    [merged addObject:append];
                    
                }
                
                NSLog(@"merged %@" ,merged);
                
                NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"counted" ascending:true];
                NSDictionary *placesorted = [[merged sortedArrayUsingDescriptors:@[sort]] firstObject];
                NSString *placentown = [placesorted objectForKey:@"town"];
                NSString *placencountry = [placesorted objectForKey:@"country"];
                
                if (placentown != nil) [self.data setObject:placentown forKey:@"ovatar_town"];
                if (placencountry != nil) [self.data setObject:placencountry forKey:@"ovatar_country"];
                [self.data synchronize];
                
                if (placentown != nil) {
                    [self.mixpanel identify:self.mixpanel.distinctId];
                    [self.mixpanel.people set:@{@"$city":placentown}];
                    
                }
                
            }
            
        }];
        
    }];
     
}

-(void)gesture:(UITapGestureRecognizer *)gesture {
    [self dismiss:^(BOOL dismissed) {
        
    }];

}

-(void)dismiss:(void (^)(BOOL dismissed))completion {
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewOverlay setAlpha:0.0];
        [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
        
    } completion:^(BOOL finished) {
        [self.viewOverlay removeFromSuperview];
        [self.viewContainer removeFromSuperview];
        
        [[UIApplication sharedApplication].delegate.window removeFromSuperview];
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        
        completion(true);
        
    }];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.images count];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self.images objectAtIndex:section] objectForKey:@"images"] count];
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([[[self.images objectAtIndex:section] objectForKey:@"images"] count] > 0 && section > 0) {
        return CGSizeMake(self.viewContainer.bounds.size.width, 45.0);

    }
    else return CGSizeMake(self.viewContainer.bounds.size.width, 20.0);
    
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"header" forIndexPath:indexPath];
        OGalleryReusableView *header = (OGalleryReusableView *)view;
        header.tag = indexPath.section + 1;
        if ([[[self.images objectAtIndex:indexPath.section] objectForKey:@"images"] count] > 0 && [indexPath section] > 0) {
            header.viewLabel.text = [[self.images objectAtIndex:indexPath.section] objectForKey:@"title"];
            header.viewLabel.backgroundColor = [UIColor clearColor];

        }
        else {
            header.viewLabel.text = nil;
            header.viewLabel.backgroundColor = [UIColor clearColor];
            
        }
        
    }
    
    return view;

}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OGalleryCell *cell = (OGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnail" forIndexPath:indexPath];
    PHAsset *asset = [[[[self.images objectAtIndex:indexPath.section] objectForKey:@"images"] objectAtIndex:indexPath.row] objectForKey:@"asset"];
    BOOL exists = [self.dataobj storyContainsAssets:self.dataobj.storyActiveKey asset:asset.localIdentifier];

    [cell.viewContainer setAlpha:self.revealed?1.0:0.0];
    [cell.viewContainer setAlpha:1.0];
    [cell.viewContainer setFrame:cell.bounds];
    [cell.viewAnimated setFrame:CGRectMake(2.0, cell.viewContainer.bounds.size.height - 22.0, 20.0, 20.0)];
    [cell.viewAnimated setHidden:asset.mediaSubtypes==PHAssetMediaSubtypePhotoLive?false:true];
    [cell.viewOverlay setFrame:cell.bounds];
    if ([self.selected containsObject:asset] || [self.dataobj storyContainsAssets:self.dataobj.storyActiveKey asset:asset.localIdentifier]) {
        if (exists) [cell.viewOverlay setBackgroundColor:[UIColorFromRGB(0x464655) colorWithAlphaComponent:0.7]];
        else [cell.viewOverlay setBackgroundColor:[UIColorFromRGB(0x7490FD) colorWithAlphaComponent:0.7]];
        
        [cell.viewOverlay setAlpha:1.0];

    }
    else [cell.viewOverlay setAlpha:0.0];

    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];

    [cell setIndex:indexPath];
    [self.imageobj imagesFromAsset:asset thumbnail:true completion:^(NSDictionary *exifdata, NSData *image) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [cell.viewContainer setImage:[UIImage imageWithData:image]];

        }];

    }];
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OGalleryCell *cell = (OGalleryCell *)[self.viewCollection cellForItemAtIndexPath:indexPath];
    PHAsset *asset = [[[[self.images objectAtIndex:indexPath.section] objectForKey:@"images"] objectAtIndex:indexPath.row] objectForKey:@"asset"];
    BOOL exists = [self.dataobj storyContainsAssets:self.dataobj.storyActiveKey asset:asset.localIdentifier];
    
    if (![self.selected containsObject:asset]) [self.selected addObject:asset];
    else {
        if (![self.dataobj storyContainsAssets:self.dataobj.storyActiveKey asset:asset.localIdentifier]) {
            [self.selected removeObject:asset];

        }
        
    }
    
    if ([self.selected count] > 0) [self.viewHeader setup:@[@"navigation_close", @"navigation_select"] animate:true];
    else [self.viewHeader setup:@[@"navigation_close"] animate:true];
    
    NSLog(@"self.selected: %@" ,self.selected);

    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if ([self.selected containsObject:asset] || exists) {
            if (exists) [cell.viewOverlay setBackgroundColor:[UIColorFromRGB(0x464655) colorWithAlphaComponent:0.7]];
            else [cell.viewOverlay setBackgroundColor:[UIColorFromRGB(0x7490FD) colorWithAlphaComponent:0.7]];
                
            [cell.viewOverlay setAlpha:1.0];

        }
        else [cell.viewOverlay setAlpha:0.0];
        
    } completion:nil];
    
}

-(void)titleNavigationButtonTapped:(OTitleButtonType)button {
    if (button == OTitleButtonTypeSelect) {
        if (self.selected.count > 0) {
            [self dismiss:^(BOOL dismissed) {
                [self.delegate viewGallerySelectedImage:self.selected];

            }];
            
        }
        
    }
    else if (button == OTitleButtonTypeClose) {
         [self dismiss:^(BOOL dismissed) {
             
         }];
        
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewHeader shadow:self.viewCollection.contentOffset.y];

}

-(void)photoLibraryDidChange:(PHChange *)changeInstance {
    [self.imageobj imagesFromAlbum:nil limit:0 completion:^(NSArray *images) {
        if (self.images.count != images.count) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.images removeAllObjects];
                [self.images addObjectsFromArray:images];
                
                [self.viewCollection reloadData];
                
            }];
            
        }
        
    }];
    
}
    

-(void)dealloc {
    [PHPhotoLibrary.sharedPhotoLibrary unregisterChangeObserver:self];
    
}

@end
