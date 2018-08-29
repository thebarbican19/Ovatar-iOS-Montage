//
//  OStoriesLayout.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 15/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OStoriesLayout.h"

@implementation OStoriesLayout

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attributes.size = self.itemSize;
    
    CGFloat cY = (self.scrollDirection == UICollectionViewScrollDirectionVertical ? self.collectionView.contentOffset.y : self.collectionView.contentOffset.x) + self.itemSize.height / 2;
    CGFloat attributesY = self.itemSize.height * indexPath.row + self.itemSize.height / 2;
    attributes.zIndex = -ABS(attributesY - cY);
    
    CGFloat delta = cY - attributesY;
    CGFloat ratio =  - delta / (self.itemSize.height * 2);
    CGFloat scale = 1 - ABS(delta) / (self.itemSize.height * 6.0) * cos(ratio * M_PI_4);
    attributes.transform = CGAffineTransformMakeScale(scale, scale);
    CGFloat centerY = cY + sin(ratio * M_PI_2) * self.itemSize.height * 0.65;

    attributes.center = CGPointMake(centerY, CGRectGetHeight(self.collectionView.frame) / 2);

    return attributes;
    
}



-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attribs = [super layoutAttributesForElementsInRect:rect];

    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;

    for (UICollectionViewLayoutAttributes *attributes in attribs) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distanceFromCenter = CGRectGetMidX(visibleRect) - attributes.center.x;
            CGFloat normalizedDistance = distanceFromCenter / 400.0f;
            CGRect rect = attributes.frame;
            attributes.frame = rect;
            CGFloat zoom = 1 + 0.1 * (- ABS(normalizedDistance));
            attributes.transform = CGAffineTransformMakeScale(zoom, zoom);

        }
    }

    return attribs;
    
}

-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    
    return CGPointMake((proposedContentOffset.x + offsetAdjustment) + 20.0, proposedContentOffset.y);
    
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return true;
    
}

@end
