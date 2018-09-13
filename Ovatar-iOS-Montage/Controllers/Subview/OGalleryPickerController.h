//
//  OGalleryPickerController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 29/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

#import "OImageObject.h"
#import "ODataObject.h"

@protocol OGalleryPickerDelegate;
@interface OGalleryPickerController : UICollectionViewController

@property (nonatomic, strong) id <OGalleryPickerDelegate> delegate;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, assign) BOOL revealed;

@property (nonatomic, strong) NSMutableArray *selected;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSIndexPath *lastviewed;

-(void)collectionViewAnimateVisibleCells:(BOOL)animate;

@end

@protocol OGalleryPickerDelegate <NSObject>

@optional

-(void)viewDidScrollSubview:(float)position;
-(void)viewPresentError:(NSString *)text;

@end


