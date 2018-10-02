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
#import "OInformationLabel.h"

@protocol OEntryViewDelegate;
@interface OEntryController : UICollectionViewController <ODayCellDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDragDelegate, UICollectionViewDropDelegate>

@property (nonatomic, strong) id <OEntryViewDelegate> delegate;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) ODayCell *active;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) BOOL scrollauto;
@property (nonatomic, assign) BOOL scrolldragging;
@property (nonatomic, strong) NSIndexPath *dragging;

@property (nonatomic, strong) OInformationLabel *viewInformation;

-(void)viewUpdateContent:(NSArray *)content;
-(void)viewEditorDidScroll:(ODayCell *)selected;
-(void)viewUpdateEntry:(ODayCell *)cell loading:(BOOL)loading;
-(void)viewCollectionScroll:(NSIndexPath *)index;

@end

@protocol OEntryViewDelegate <NSObject>

@optional

-(void)viewPresentGalleryPicker:(ODayCell *)day;
-(void)viewPresentError:(NSError *)error key:(NSString *)key;

@end

