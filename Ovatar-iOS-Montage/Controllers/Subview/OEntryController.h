//
//  OSnapsViewController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OImageObject.h"
#import "ODataObject.h"
#import "ODayCell.h"

@protocol OEntryViewDelegate;
@interface OEntryController : UICollectionViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) id <OEntryViewDelegate> delegate;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;

@property (nonatomic, strong) ODayCell *active;
@property (nonatomic, assign) int page;

@end

@protocol OEntryViewDelegate <NSObject>

@optional

-(void)viewPresentSubviewWithIndex:(int)index animate:(BOOL)animate;
-(void)viewPresentGalleryPicker:(ODayCell *)day;

@end

