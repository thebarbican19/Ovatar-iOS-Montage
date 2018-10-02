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

-(void)viewWillLayoutSubviews {
    [self.viewInformation setFrame:CGRectMake(self.collectionView.frame.origin.x + 44.0, self.collectionView.bounds.size.height - 60.0, self.collectionView.bounds.size.width - (60.0 + self.viewInformation.bounds.size.height), 40.0)];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageobj = [OImageObject sharedInstance];
    
    self.dataobj = [[ODataObject alloc] init];
    
    self.geocoder = [[CLGeocoder alloc] init];

    self.items = [[NSMutableArray alloc] initWithArray:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
    
    self.viewInformation = [[OInformationLabel alloc] initWithFrame:CGRectMake(44.0, self.collectionView.bounds.size.height - 60.0, self.collectionView.bounds.size.width - 88.0, 40.0)];
    self.viewInformation.backgroundColor = [UIColor clearColor];
    //[self.view addSubview:self.viewInformation];
    
    [self.collectionView setDragDelegate:self];
    [self.collectionView setDragInteractionEnabled:true];
    [self.collectionView setDropDelegate:self];
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    [self.collectionView registerClass:[ODayCell class] forCellWithReuseIdentifier:@"day"];
    [self.collectionView setShowsHorizontalScrollIndicator:false];

}

-(void)viewUpdateContent:(NSArray *)content {
    self.items = [[NSMutableArray alloc] initWithArray:content];
    self.active = (ODayCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.collectionView reloadData];
        [self viewEditorDidScroll:self.active];

    }];
    
}

-(void)viewUpdateEntry:(ODayCell *)cell loading:(BOOL)loading {
    if (cell != nil) {
        if (loading) {
            [cell.cellImage setImage:nil];
            [cell.cellImage setBackgroundColor:UIColorFromRGB(0x464655)];
            [cell.cellLoader startAnimation];
            [cell.cellPlayer.view setHidden:true];
            
        }
        else if ([self.dataobj entryWithKey:cell.key] != nil) {
            [self.items replaceObjectAtIndex:cell.index.row withObject:[self.dataobj entryWithKey:cell.key]];
            [cell setup:[self.items objectAtIndex:cell.index.row] animated:true];
            [cell.cellLoader stopAnimation];
            [cell.cellPlayer.player play];
            [cell.cellPlayer.view setHidden:false];

        }
        
    }
    
}

/*
-(UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView dropSessionDidUpdate:(id<UIDropSession>)session  withDestinationIndexPath:(NSIndexPath *)destinationIndexPath API_AVAILABLE(ios(11.0)){
    if (session.localDragSession.localContext == collectionView){
        return [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    }
    
    return [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy
                                                                intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    
}

-(void)collectionView:(UICollectionView *)collectionView dragSessionWillBegin:(id<UIDragSession>)session API_AVAILABLE(ios(11.0)){
    session.localContext = collectionView;
    
}

-(void)collectionView:(nonnull UICollectionView *)collectionView performDropWithCoordinator:(nonnull id<UICollectionViewDropCoordinator>)coordinator API_AVAILABLE(ios(11.0)) {
    if (coordinator.proposal.operation == UIDropOperationCopy) {
        [self collectionView:collectionView performCopyDropWithCoordinator:coordinator];
        
    }
    else if (coordinator.proposal.operation == UIDropOperationMove) {
        [self collectionView:collectionView performMoveDropWithCoordinator:coordinator];
        
    }
    
}

-(void)collectionView:(UICollectionView *)collectionView performCopyDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator API_AVAILABLE(ios(11.0)) {
    NSMutableArray<NSIndexPath *> *indexPaths = [NSMutableArray new];
    NSMutableArray<NSString *> *viewModels = [NSMutableArray new];
    NSUInteger loc = self.items.count;

}

-(void)collectionView:(UICollectionView *)collectionView performMoveDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator API_AVAILABLE(ios(11.0)) {
    id<UICollectionViewDropItem> dropItem = coordinator.items.firstObject;
    [collectionView performBatchUpdates:^{
        [self.dataobj entryAppendOrderSource:[self.items objectAtIndex:dropItem.sourceIndexPath.row] replace:[self.items objectAtIndex:coordinator.destinationIndexPath.row]];
        [self.items exchangeObjectAtIndex:dropItem.sourceIndexPath.item withObjectAtIndex:coordinator.destinationIndexPath.item];
        [collectionView moveItemAtIndexPath:dropItem.sourceIndexPath toIndexPath:coordinator.destinationIndexPath];
        
    } completion:nil];
    
}

-(NSArray<UIDragItem *> *)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    return @[[self dragItemForIndexPath:indexPath]];
    
}

-(UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session API_AVAILABLE(ios(11.0)) {
    
    NSLog(@"previewForLiftingItem");
    UIDragPreviewParameters *previewParameters = [[UIDragPreviewParameters alloc] init];
    previewParameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.0, 40, 200, 200) cornerRadius:10];
    UITargetedDragPreview *dragPreview = [[UITargetedDragPreview alloc] initWithView:interaction.view parameters:previewParameters];
    return dragPreview;
}

-(NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForAddingToSession:(id<UIDragSession>)session withTouchAtPoint:(CGPoint)point API_AVAILABLE(ios(11.0)) {
    return nil;
    
}

-(void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session {
    NSLog(@"willAnimateLiftWithAnimator:session:");
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        if (finalPosition == UIViewAnimatingPositionEnd) {
            //self.dragView.alpha = 0.6;
        }
        
    }];
    
}

-(UIDragItem *)dragItemForIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0)) {
    if (indexPath.section == 0) {
        NSItemProvider *itemProvider = [[NSItemProvider alloc] init];
        UIDragItem *item = [[UIDragItem alloc] initWithItemProvider:itemProvider];
        self.dragging = indexPath;
        return item;
        
    }
    else return nil;
    
}

-(BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session API_AVAILABLE(ios(11.0)) {
    return false;
    
}
*/

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
    
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.items count];
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ODayCell *cell = (ODayCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"day" forIndexPath:indexPath];
    
    [cell setDelegate:self];
    [cell setIndex:indexPath];
    [cell setup:[self.items objectAtIndex:indexPath.row] animated:false];

    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ODayCell *selected = (ODayCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self.delegate viewPresentGalleryPicker:selected];
    
}

-(void)collectionViewDeleteAsset:(ODayCell *)day {
    [self.dataobj entryAppendWithImageData:nil animated:false entry:self.active.key completion:^(NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.collectionView performBatchUpdates:^{
                [self.dataobj entryDestoryWithKey:self.active.key];
                [self.items removeObjectAtIndex:self.active.index.row];
                [self.collectionView deleteItemsAtIndexPaths:@[day.index]];
                
            } completion:^(BOOL finished) {
                [self scrollViewDidScroll:self.collectionView];
                
            }];

        }];
        
    }];
    
}

-(void)collectionToggleAnimation:(ODayCell *)day {
    [self.imageobj imageReturnFromAssetKey:day.assetid completion:^(PHAsset *asset) {
        [self.dataobj entryAppendAnimation:day.key asset:asset completion:^(NSError *error, BOOL enabled) {
            if (error.code == 200) {
                if (enabled) {
                    [self.viewInformation timestamp:NSLocalizedString(@"Entry_Animated_Label", nil)];
                    [self.viewInformation location:@""];

                }
                else {
                    [self.viewInformation timestamp:NSLocalizedString(@"Entry_AnimatDisable_Label", nil)];
                    [self.viewInformation location:@""];

                }
                
            }
            else [self.delegate viewPresentError:error key:@"animationtoggle"];

        }];
        
    }];

}

-(void)collectionViewLoopVideo:(NSNotification *)notification {
    [self.active loop:notification];
    
}

-(void)viewCollectionScroll:(NSIndexPath *)index {
//    if (index != nil) {
//        [UIView animateWithDuration:0.2 delay:1.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [self.collectionView setContentOffset:CGPointMake(self.collectionView.collectionViewLayout.collectionViewContentSize.width - self.collectionView.bounds.size.width, 0.0) animated:false];
//
//        } completion:^(BOOL finished) {
//            [self setActive:(ODayCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
//            [self viewEditorDidScroll:self.active];
//
//        }];
//        
//    }
//    else {
//        ODayCell *lastcell = (ODayCell *)self.collectionView.visibleCells.lastObject;
//        [UIView animateWithDuration:0.2 delay:1.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [self.collectionView scrollToItemAtIndexPath:lastcell.index atScrollPosition:UICollectionViewScrollPositionRight animated:false];
//            
//        } completion:^(BOOL finished) {
//            [self setActive:lastcell];
//            [self viewEditorDidScroll:lastcell];
//            
//        }];
//
//    }

}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    for (ODayCell *cell in self.collectionView.visibleCells) {
        [cell.cellPlayer.player pause];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [cell.cellDelete setAlpha:0.0];
            [cell.cellDelete setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
            [cell.cellAnimate setAlpha:0.0];
            [cell.cellAnimate setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
            
        } completion:nil];
        
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for (ODayCell *cell in self.collectionView.visibleCells) {
        if (sqrt(cell.transform.a * cell.transform.a + cell.transform.c * cell.transform.c) > 0.98) {
            self.active = cell;
            break;
            
        }
        
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self viewEditorDidScroll:self.active];

}

-(void)viewEditorDidScroll:(ODayCell *)selected {
    if ([[self.active.data objectForKey:@"assetid"] length] > 2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEEE d MMMM";
        formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        NSString *timestamp = [formatter stringFromDate:[selected.data objectForKey:@"captured"]];
        NSMutableString *location = [[NSMutableString alloc] init];
        
        float latitude = [[selected.data objectForKey:@"latitude"] floatValue];
        float longitude = [[selected.data objectForKey:@"longitude"] floatValue];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.active.cellDelete setAlpha:1.0];
            [self.active.cellDelete setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            
        } completion:nil];
        
        if (latitude != 0.0 && longitude != 0.0) {
            [self.geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
                CLPlacemark *placemark = placemarks.lastObject;
                
                if (placemark.subLocality != nil) [location appendString:placemark.subLocality];
                else if (placemark.locality != nil) [location appendString:placemark.locality];
                
                if (location.length > 2) [location appendString:@", "];
                
                if (placemark.country != nil) [location appendString:placemark.country];
                else [location appendString:NSLocalizedString(@"Entry_LocationUnknown_Label", nil)];
                
                [self.viewInformation location:location];
                
            }];
            
        }
        
        if (timestamp != nil) [self.viewInformation timestamp:timestamp];
        else [self.viewInformation timestamp:@""];
    
    }
    else {
        [self.viewInformation location:@""];
        [self.viewInformation timestamp:NSLocalizedString(@"Entry_Empty_Label", nil)];
        
    }
    
    if ([[self.active.data objectForKey:@"type"] isEqualToString:@"livephoto"]) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.active.cellAnimate setAlpha:1.0];
            [self.active.cellAnimate setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            
        } completion:nil];
        
    }
   
    [self.active.cellPlayer.player play];

    [[NSNotificationCenter defaultCenter] removeObserver:AVPlayerItemDidPlayToEndTimeNotification];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(collectionViewLoopVideo:)  name:AVPlayerItemDidPlayToEndTimeNotification object:self.active.cellPlayer.player.currentItem];

}

@end
