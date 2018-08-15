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

@protocol OGalleryPickerDelegate;
@interface OGalleryPickerController : UICollectionViewController

@property (nonatomic, strong) id <OGalleryPickerDelegate> delegate;
@property (nonatomic, strong) OImageObject *imageobj;

@property (nonatomic, strong) PHAsset *selected;
@property (nonatomic, strong) NSMutableArray *images;

@end

@protocol OGalleryPickerDelegate <NSObject>

@optional

-(void)viewGallerySelectedImage:(PHAsset *)asset;

@end

