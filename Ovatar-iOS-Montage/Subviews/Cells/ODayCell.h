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

@interface ODayCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *cellImage;
@property (nonatomic, strong) UIImageView *cellShadow;
@property (nonatomic, strong) AVPlayerViewController *cellPlayer;
@property (nonatomic, strong) UIImageView *cellPlaceholder;

@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *video;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *asset;

-(void)setup:(NSDictionary *)content;

@end
