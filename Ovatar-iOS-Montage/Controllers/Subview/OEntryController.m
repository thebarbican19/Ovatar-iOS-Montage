//
//  OSnapsViewController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OEntryController.h"
#import "OConstants.h"

@interface OEntryController ()

@end

@implementation OEntryController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageobj = [OImageObject sharedInstance];
    
    self.dataobj = [[ODataObject alloc] init];

    [self.collectionView setClipsToBounds:false];
    [self.collectionView setPagingEnabled:true];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView setDelegate:self];
    [self.collectionView setDataSource:self];
    [self.collectionView registerClass:[ODayCell class] forCellWithReuseIdentifier:@"day"];

}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[self.dataobj storyEntries:self.dataobj.storyActiveKey] count];
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ODayCell *cell = (ODayCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"day" forIndexPath:indexPath];
    
    NSDictionary *item = [[self.dataobj storyEntries:self.dataobj.storyActiveKey] objectAtIndex:indexPath.row];
    
    [cell setup:item];
    [cell.contentView.layer setCornerRadius:8.0];
    [cell.contentView setClipsToBounds:true];
    [cell.contentView setBackgroundColor:[UIColor orangeColor]];
    //[cell setTransform:CGAffineTransformMakeScale(0.9, 0.9)];

    [cell setBackgroundColor:[UIColor colorWithWhite:0.2 + (indexPath.row * 2) alpha:1.0]];

    //check the scrolling direction to verify from which side of the screen the cell should come.
    //CGPoint translation = [collectionView.panGestureRecognizer translationInView:collectionView.superview];
    //if (indexPath.row == 0) cell.frame = CGRectMake(0.0, 0.0, 0, 0);
    //else cell.frame = CGRectMake(cell.frame.origin.x - (40.0 + indexPath.row), 0.0, 0, 0);
    
    return cell;
    
}

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *curIndexPath = self.viewIndex;
    if (indexPath.row == curIndexPath.row) {
        return true;
    }
    
    //[self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    
//        HJCarouselViewLayout *layout = (HJCarouselViewLayout *)collectionView.collectionViewLayout;
//        CGFloat cellHeight = layout.itemSize.height;
//        CGRect visibleRect = CGRectZero;
//        if (indexPath.row > curIndexPath.row) {
//            visibleRect = CGRectMake(0, cellHeight * indexPath.row + cellHeight / 2, CGRectGetWidth(collectionView.frame), cellHeight / 2);
//        } else {
//            visibleRect = CGRectMake(0, cellHeight * indexPath.row, CGRectGetWidth(collectionView.frame), CGRectGetHeight(collectionView.frame));
//        }
//        [self.collectionView scrollRectToVisible:visibleRect animated:YES];
    
    return NO;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ODayCell *selected = (ODayCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [selected setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        [selected setAlpha:0.0];
        
    } completion:^(BOOL finished) {
        [selected setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [self.delegate viewPresentGalleryPicker:selected];

    }];
    
    NSLog(@"item: %@" ,[[self.dataobj storyEntries:self.dataobj.storyActiveKey] objectAtIndex:indexPath.row]);

}

-(NSIndexPath *)viewIndex {
    NSIndexPath *current = nil;
    NSInteger curzIndex = 0;
    for (NSIndexPath *path in [self.collectionView indexPathsForVisibleItems].objectEnumerator) {
        UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:path];
        if (!current) {
            current = path;
            curzIndex = attributes.zIndex;
            continue;
        }
        
        if (attributes.zIndex > curzIndex) {
            current = path;
            curzIndex = attributes.zIndex;
            
        }
        
    }
    
    return current;
    
}

-(void)viewSelectedTimestamp:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE d MMMM";
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
}

@end
