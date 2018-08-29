//
//  OGalleryPickerController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 29/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OGalleryPickerController.h"
#import "OGalleryCell.h"
#import "OConstants.h"

@interface OGalleryPickerController ()

@end

@implementation OGalleryPickerController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.images = [[NSMutableArray alloc] init];
    
    self.imageobj = [OImageObject sharedInstance];
    
    [self.collectionView registerClass:[OGalleryCell class] forCellWithReuseIdentifier:@"thumbnail"];

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.images count];
    
}

-(void)collectionViewAnimateVisibleCells:(BOOL)animate {
    for (OGalleryCell *cell in self.collectionView.visibleCells) {
        [cell.viewContainer setAlpha:0.0];
        [cell.viewContainer setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        
        if (animate) {
            [UIView animateWithDuration:0.1 delay:0.3 + (0.03 * cell.index.row) options:UIViewAnimationOptionCurveEaseIn animations:^{
                [cell.viewContainer setAlpha:1.0];
                [cell.viewContainer setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                [cell.viewContainer setFrame:cell.bounds];
                [cell.viewOverlay setFrame:cell.viewContainer.bounds];
                
            } completion:nil];
            
        }
        
    }
    
    self.revealed = true;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OGalleryCell *cell = (OGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnail" forIndexPath:indexPath];
    
    [cell.viewContainer setAlpha:self.revealed];
    [cell.viewContainer setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    [cell.viewContainer setFrame:cell.bounds];
    [cell.viewOverlay setFrame:cell.viewContainer.bounds];
    if (self.selected == [self.images objectAtIndex:indexPath.row] && self.selected != nil) {
        [cell.viewOverlay setAlpha:1.0];
        [cell.viewOverlay setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

    }
    else {
        [cell.viewOverlay setAlpha:0.0];
        [cell.viewOverlay setTransform:CGAffineTransformMakeScale(1.25, 1.25)];

    }

    [cell.contentView setBackgroundColor:[UIColor clearColor]];
    [cell setBackgroundColor:[UIColor clearColor]];

    [cell setIndex:indexPath];
    [self.imageobj imagesFromAsset:[self.images objectAtIndex:indexPath.row] thumbnail:true completion:^(NSDictionary *exifdata, NSData *image) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [cell.viewContainer setImage:[UIImage imageWithData:image]];
            
        }];

    }];
     
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OGalleryCell *cell = (OGalleryCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (self.selected != [self.images objectAtIndex:indexPath.row]) {
        self.selected = [self.images objectAtIndex:indexPath.row];
        
    }
    else self.selected = nil;
    
    for (OGalleryCell *visible in self.collectionView.visibleCells) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if (cell == visible && self.selected != nil) {
                [visible.viewOverlay setAlpha:1.0];
                //[visible.viewOverlay setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

            }
            else {
                [visible.viewOverlay setAlpha:0.0];
                //[visible.viewOverlay setTransform:CGAffineTransformMakeScale(1.25, 1.25)];

            }
            
        } completion:nil];
        
    }
    
}

@end
