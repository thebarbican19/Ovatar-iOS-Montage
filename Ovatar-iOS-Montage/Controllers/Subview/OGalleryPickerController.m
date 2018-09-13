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

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.images = [[NSMutableArray alloc] init];
    
    self.imageobj = [OImageObject sharedInstance];
    
    self.dataobj = [[ODataObject alloc] init];
    
    [self.collectionView registerClass:[OGalleryCell class] forCellWithReuseIdentifier:@"thumbnail"];
    [self.collectionView registerClass:[OGalleryReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"header"];

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.images count];
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[[self.images objectAtIndex:section] objectForKey:@"images"] count];
    
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([[[self.images objectAtIndex:section] objectForKey:@"images"] count] > 0 && section > 0) {
        return CGSizeMake(self.view.bounds.size.width, 45.0);

    }
    else return CGSizeMake(self.view.bounds.size.width, 20.0);
    
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
    

-(void)collectionViewAnimateVisibleCells:(BOOL)animate {
//    for (NSInteger i = self.lastviewed.row; i < self.collectionView.visibleCells.count + 1; i++) {
//        OGalleryCell *cell = (OGalleryCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.lastviewed.row + (i - 1) inSection:0]];
//        [cell.viewContainer setAlpha:0.0];
//        [cell.viewContainer setFrame:cell.bounds];
//        //[cell.viewContainer setTransform:CGAffineTransformMakeScale(0.3, 0.8)];
//
//        if (animate) {
//            [UIView animateWithDuration:0.1 delay:0.3 + (0.03 * i) options:UIViewAnimationOptionCurveEaseIn animations:^{
//                [cell.viewContainer setAlpha:1.0];
//                [cell.viewContainer setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
//                [cell.viewContainer setFrame:cell.bounds];
//                [cell.viewOverlay setFrame:cell.viewContainer.bounds];
//
//            } completion:nil];
//
//        }
//
//    }
    
    self.selected = [[NSMutableArray alloc] init];
    self.revealed = true;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OGalleryCell *cell = (OGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnail" forIndexPath:indexPath];
    PHAsset *asset = [[[[self.images objectAtIndex:indexPath.section] objectForKey:@"images"] objectAtIndex:indexPath.row] objectForKey:@"asset"];
    BOOL exists = [self.dataobj storyContainsAssets:self.dataobj.storyActiveKey asset:asset.localIdentifier];

    //[cell.viewContainer setAlpha:self.revealed?1.0:0.0];
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
    OGalleryCell *cell = (OGalleryCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    PHAsset *asset = [[[[self.images objectAtIndex:indexPath.section] objectForKey:@"images"] objectAtIndex:indexPath.row] objectForKey:@"asset"];
    BOOL exists = [self.dataobj storyContainsAssets:self.dataobj.storyActiveKey asset:asset.localIdentifier];
    
    if (![self.selected containsObject:asset]) [self.selected addObject:asset];
    else {
        if (![self.dataobj storyContainsAssets:self.dataobj.storyActiveKey asset:asset.localIdentifier]) {
            [self.selected removeObject:asset];

        }
        
    }

    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        if ([self.selected containsObject:asset] || exists) {
            if (exists) [cell.viewOverlay setBackgroundColor:[UIColorFromRGB(0x464655) colorWithAlphaComponent:0.7]];
            else [cell.viewOverlay setBackgroundColor:[UIColorFromRGB(0x7490FD) colorWithAlphaComponent:0.7]];
                
            [cell.viewOverlay setAlpha:1.0];
            [self setLastviewed:indexPath];

        }
        else [cell.viewOverlay setAlpha:0.0];
        
    } completion:nil];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.delegate viewDidScrollSubview:scrollView.contentOffset.y];
    
}

@end
