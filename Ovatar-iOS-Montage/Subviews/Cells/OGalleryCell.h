//
//  OGalleryCell.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 29/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OGalleryCell : UICollectionViewCell

@property (nonatomic ,strong) UIImageView *viewContainer;
@property (nonatomic ,strong) UIImageView *viewOverlay;
@property (nonatomic ,strong) UIImageView *viewAnimated;

@property (nonatomic ,strong) NSIndexPath *index;

@end
