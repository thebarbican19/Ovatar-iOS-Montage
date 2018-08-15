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

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OGalleryCell *cell = (OGalleryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"thumbnail" forIndexPath:indexPath];
    
    [self.imageobj imagesFromAsset:[self.images objectAtIndex:indexPath.row] thumbnail:true completion:^(NSDictionary *exifdata, NSData *image) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [cell.viewContainer setImage:[UIImage imageWithData:image]];
            
        }];

    }];
     
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Asset Selected: %@" ,[self.images objectAtIndex:indexPath.row]);
    OGalleryCell *cell = (OGalleryCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    if (self.selected != [self.images objectAtIndex:indexPath.row]) {
        self.selected = [self.images objectAtIndex:indexPath.row];
        
    }
    else {
        self.selected = nil;
        
    }
    
    for (OGalleryCell *visible in self.collectionView.visibleCells) {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            if (cell == visible && self.selected != nil) {
                [visible.viewOverlay setAlpha:1.0];
                [visible.viewOverlay setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
                
            }
            else {
                [visible.viewOverlay setAlpha:0.0];
                [visible.viewOverlay setTransform:CGAffineTransformMakeScale(1.25, 1.25)];
                
            }
            
        } completion:nil];
        
    }
    
    [self.delegate viewGallerySelectedImage:[self.images objectAtIndex:indexPath.row]];
    
}

@end
