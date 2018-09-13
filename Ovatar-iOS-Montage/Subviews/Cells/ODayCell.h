//
//  ODayCell.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <UIImage+BlurEffects.h>
#import "BLMultiColorLoader.h"

#import "OImageObject.h"

@protocol ODayCellDelegate;
@interface ODayCell : UICollectionViewCell

@property (nonatomic, strong) id <ODayCellDelegate> delegate;
@property (nonatomic, strong) UIImageView *cellImage;
@property (nonatomic, strong) UIView *cellShadow;
@property (nonatomic, strong) AVPlayerViewController *cellPlayer;
@property (nonatomic, strong) UIImageView *cellPlaceholder;
@property (nonatomic, strong) BLMultiColorLoader *cellLoader;
@property (nonatomic, strong) UIButton *cellDelete;
@property (nonatomic, strong) UIButton *cellAnimate;

@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *video;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *assetid;
@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSIndexPath *index;
@property (nonatomic, strong) PHAsset *asset;

@property (nonatomic, strong) OImageObject *imageobj;

-(void)setup:(NSDictionary *)content animated:(BOOL)animated;
-(void)loop:(NSNotification *)notification;

@end

@protocol ODayCellDelegate <NSObject>

@optional

-(void)collectionViewDeleteAsset:(ODayCell *)day;
-(void)collectionToggleAnimation:(ODayCell *)day;

@end

