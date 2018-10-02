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
#import "OTitleView.h"
#import "ODayCell.h"

#import "Mixpanel.h"

@protocol OGalleryPickerDelegate;
@interface OGalleryPickerController : UIView <PHPhotoLibraryChangeObserver, UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, OTitleViewDelegate> {
    
}

@property (nonatomic, strong) id <OGalleryPickerDelegate> delegate;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, assign) BOOL revealed;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) Mixpanel *mixpanel;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;
@property (nonatomic, strong) NSMutableArray *places;

@property (nonatomic, strong) UICollectionViewFlowLayout *viewLayout;
@property (nonatomic, strong) UICollectionView *viewCollection;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIView *viewOverlay;
@property (nonatomic, strong) CAShapeLayer *viewRounded;
@property (nonatomic, strong) OTitleView *viewHeader;
@property (nonatomic, strong) UITapGestureRecognizer *viewGesture;

@property (nonatomic, strong) NSMutableArray *selected;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) ODayCell *entry;
@property (nonatomic, assign) float padding;
@property (nonatomic, assign) CGRect keyboard;

-(void)present;
-(void)setup;

@end

@protocol OGalleryPickerDelegate <NSObject>

@optional

-(void)viewGallerySelectedImage:(NSArray *)assets;

@end


