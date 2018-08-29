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
    [self.viewDelete setFrame:CGRectMake(self.view.bounds.size.width - (self.viewInformation.bounds.size.height + 44.0), self.viewInformation.frame.origin.y, self.viewInformation.bounds.size.height, self.viewInformation.bounds.size.height)];

}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageobj = [OImageObject sharedInstance];
    
    self.dataobj = [[ODataObject alloc] init];
    
    self.geocoder = [[CLGeocoder alloc] init];

    self.items = [[NSMutableArray alloc] initWithArray:[self.dataobj storyEntries:self.dataobj.storyActiveKey]];
    
    self.viewInformation = [[OInformationLabel alloc] initWithFrame:CGRectMake(self.collectionView.frame.origin.x + 44.0, self.collectionView.bounds.size.height - 60.0, self.collectionView.bounds.size.width - 60.0, 40.0)];
    self.viewInformation.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.viewInformation];
    
    self.viewDelete = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 64.0, self.viewInformation.frame.origin.y, 56.0, 56.0)];
    self.viewDelete.backgroundColor = UIColorFromRGB(0x7490FD);
    self.viewDelete.clipsToBounds = true;
    [self.viewDelete addTarget:self action:@selector(collectionViewDeleteAsset) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.viewDelete];
    
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
    
    [self.collectionView reloadData];
    [self viewEditorDidScroll:self.active];

}

-(void)viewUpdateEntry:(ODayCell *)cell loading:(BOOL)loading {
    if (cell != nil) {
        if (loading) {
            [cell.cellImage setImage:nil];
            [cell.cellImage setBackgroundColor:UIColorFromRGB(0x464655)];
            [cell.cellLoader startAnimation];
            
        }
        else {
            [self.items replaceObjectAtIndex:cell.index.row withObject:[self.dataobj entryWithKey:cell.key]];
            [cell setup:[self.items objectAtIndex:cell.index.row] animated:true];
            [cell.cellLoader stopAnimation];
            [cell.cellPlayer.player play];
            
            if ([cell.index row] >= ([self.items count] - 1)) {
                if (cell.asset.length > 2) {
                    [self.dataobj entryCreate:self.dataobj.storyActiveKey completion:^(NSError *error, NSString *key) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self.collectionView performBatchUpdates:^{
                                [self.items addObject:[self.dataobj entryWithKey:key]];
                                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.index.row + 1 inSection:cell.index.section]]];
                                
                            } completion:^(BOOL finished) {

                            }];
                            
                        }];
                        
                    }];
                    
                }
        
            }
            else {
                NSLog(@"dont insert new item");

            }

        }
        
    }
    
}

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

-(void)collectionViewDeleteAsset {
    [self.dataobj entryAppendWithImageData:nil animated:false entry:self.active.key completion:^(NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.items replaceObjectAtIndex:self.active.index.row withObject:[self.dataobj entryWithKey:self.active.key]];
            [self.active setup:[self.items objectAtIndex:self.active.index.row] animated:true];
            
            [self viewEditorDidScroll:self.active];

        }];
        
    }];
    
}

-(void)viewCollectionScroll:(NSIndexPath *)index {
    if (index != nil) {
        [UIView animateWithDuration:0.2 delay:1.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.collectionView setContentOffset:CGPointMake(self.collectionView.collectionViewLayout.collectionViewContentSize.width - self.collectionView.bounds.size.width, 0.0) animated:false];

        } completion:^(BOOL finished) {
            [self setActive:(ODayCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
            [self viewEditorDidScroll:self.active];

        }];
        
    }
    else {
//        CGFloat updatedOffset = (self.collectionView.item.width + self.minimumInteritemSpacing) * self.currentPage;
//
//        [UIView animateWithDuration:0.2 delay:1.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [self.collectionView setContentOffset:[NSIndexPath indexPathForRow:<#(NSInteger)#> inSection:<#(NSInteger)#>] animated:false];
//
//        } completion:^(BOOL finished) {
//            [self setActive:(ODayCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
//            [self viewEditorDidScroll:self.active];
//
//        }];
        
    }

}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!self.autoscroll) {
        for (ODayCell *cell in self.collectionView.visibleCells) {
            if (sqrt(cell.transform.a * cell.transform.a + cell.transform.c * cell.transform.c) > 0.98) {
                self.active = cell;
                break;
                
            }
            
        }
        
        [self viewEditorDidScroll:self.active];
        
    }
    
}

-(void)viewEditorDidScroll:(ODayCell *)selected {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE d MMMM";
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSString *timestamp = [formatter stringFromDate:[selected.data objectForKey:@"captured"]];
    NSMutableString *location = [[NSMutableString alloc] init];
    
    float latitude = [[selected.data objectForKey:@"latitude"] floatValue];
    float longitude = [[selected.data objectForKey:@"longitude"] floatValue];
    
    if (latitude != 0.0 && longitude != 0.0) {
        [self.geocoder reverseGeocodeLocation:[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark = placemarks.lastObject;
            
            if (placemark.subLocality != nil) [location appendString:placemark.subLocality];
            else if (placemark.locality != nil) [location appendString:placemark.locality];
            
            if (location.length > 2) [location appendString:@", "];
            
            if (placemark.country != nil) [location appendString:placemark.country];
            else [location appendString:@"Unknown Location"];
            
            [self.viewInformation content:timestamp location:location];
            
        }];
        
    }
    else if (timestamp != nil) [self.viewInformation content:timestamp location:nil];
    else [self.viewInformation content:@"" location:nil];
    
    if ([[selected.data objectForKey:@"assetid"] length] > 2) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.viewDelete setAlpha:1.0];
            [self.viewDelete setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            
        } completion:nil];
        
    }
    else {
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self.viewDelete setAlpha:0.0];
            [self.viewDelete setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
            
        } completion:nil];
        
    }
    
    for (ODayCell *cell in self.collectionView.visibleCells) {
        if (cell == self.active) {
            if ([cell.cellPlayer.player rate] == 0) [cell.cellPlayer.player play];
            
        }
        else {
            if ([cell.cellPlayer.player rate] > 0) [cell.cellPlayer.player pause];
            
        }
        
    }
    
}

@end
