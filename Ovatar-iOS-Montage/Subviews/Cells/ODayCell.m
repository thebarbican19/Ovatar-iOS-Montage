//
//  ODayCell.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "ODayCell.h"
#import "OConstants.h"

@implementation ODayCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.imageobj = [[OImageObject alloc] init];
    if (self) {
        self.cellImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.contentView.frame.origin.x + 12.0, self.contentView.frame.origin.y + 6.0, self.contentView.bounds.size.width - 24.0, self.contentView.bounds.size.height - 12.0)];
        self.cellImage.contentMode = UIViewContentModeCenter;
        self.cellImage.clipsToBounds = true;
        self.cellImage.layer.cornerRadius = 8.0;
        self.cellImage.backgroundColor = UIColorFromRGB(0x464655);
        self.cellImage.image = [UIImage imageNamed:@"editor_placeholder"];
        self.cellImage.userInteractionEnabled = true;
        self.cellImage.alpha = 1.0;
        [self.contentView addSubview:self.cellImage];
        
        self.cellPlayer = [[AVPlayerViewController alloc] init];
        self.cellPlayer.view.frame = self.cellImage.bounds;
        self.cellPlayer.view.backgroundColor = [UIColor clearColor];
        self.cellPlayer.view.userInteractionEnabled = false;
        self.cellPlayer.showsPlaybackControls = false;
        self.cellPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.cellPlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.cellPlayer.player.muted = true;
        self.cellPlayer.player.allowsExternalPlayback = false;
        self.cellPlayer.allowsPictureInPicturePlayback = false;
        self.cellPlayer.view.alpha = 0.0;
        [self.cellImage addSubview:self.cellPlayer.view];
        
        self.cellShadow = [[UIView alloc] initWithFrame:CGRectMake(self.cellImage.frame.origin.x + 4.0, self.cellImage.frame.origin.y + 14.0, self.cellImage.bounds.size.width - 8.0, self.cellImage.bounds.size.height - 16.0)];
        self.cellShadow.layer.shadowOffset = CGSizeMake(0.0, 2.0);
        self.cellShadow.layer.shadowRadius = 10.0;
        self.cellShadow.layer.shadowOpacity = 0.4;
        self.cellShadow.layer.masksToBounds = false;
        self.cellShadow.backgroundColor = UIColorFromRGB(0x464655);
        [self.contentView addSubview:self.cellShadow];
        [self.contentView sendSubviewToBack:self.cellShadow];
        
        self.cellLoader = [[BLMultiColorLoader alloc] initWithFrame:CGRectMake((self.cellImage.bounds.size.width * 0.5) - 25.0, (self.cellImage.bounds.size.height * 0.5) - 25.0, 50.0, 50.0)];
        self.cellLoader.lineWidth = 3.0;
        self.cellLoader.colorArray = @[[UIColor whiteColor]];
        self.cellLoader.backgroundColor = [UIColor clearColor];
        [self.cellImage addSubview:self.cellLoader];
        
        self.cellDelete = [[UIButton alloc] initWithFrame:CGRectMake(self.cellImage.bounds.size.width - 40.0, self.cellImage.bounds.size.height - 46.0, 46.0, 46.0)];
        self.cellDelete.backgroundColor = [UIColor clearColor];
        self.cellDelete.alpha = 0.0;
        self.cellDelete.transform = CGAffineTransformMakeScale(0.9, 0.9);
        self.cellDelete.clipsToBounds = true;
        [self.cellDelete addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellDelete setImage:[UIImage imageNamed:@"entry_delete"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.cellDelete];
        
        self.cellAnimate = [[UIButton alloc] initWithFrame:CGRectMake(18.0, self.cellImage.bounds.size.height - 46.0, 46.0, 46.0)];
        self.cellAnimate.backgroundColor = [UIColor clearColor];
        self.cellAnimate.clipsToBounds = true;
        self.cellAnimate.alpha = 0.0;
        self.cellAnimate.transform = CGAffineTransformMakeScale(0.9, 0.9);
        //[self.cellAnimate addTarget:self action:@selector(animate:) forControlEvents:UIControlEventTouchUpInside];
        [self.cellAnimate setImage:[UIImage imageNamed:@"entry_playback"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.cellAnimate];
    
    }
    return self;
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:AVPlayerItemDidPlayToEndTimeNotification];
    
}

-(void)loop:(NSNotification *)notification {
    [self.cellPlayer.player seekToTime:kCMTimeZero];
    [self.cellPlayer.player play];
    
}

-(void)setup:(NSDictionary *)content animated:(BOOL)animated {
    self.data = [[NSDictionary alloc] initWithDictionary:content];
    self.image = [UIImage imageWithData:[self.data objectForKey:@"image"]];
    self.filename = [NSString stringWithFormat:@"/%@.mov" ,[self.data objectForKey:@"key"]];
    self.video = [NSURL fileURLWithPath:[APP_DOCUMENTS stringByAppendingString:self.filename]];
    self.player = [AVPlayer playerWithURL:self.video];
    self.timestamp = [self.data objectForKey:@"timestamp"];
    self.key = [self.data objectForKey:@"key"];
    self.assetid = [self.data objectForKey:@"assetid"];
    
    if (self.assetid.length > 2) {
        if (self.player.error == nil) {
            [self.cellPlayer setPlayer:self.player];
            [self.cellPlayer.player setMuted:true];
            [self.cellPlayer.view setHidden:false];
            [self.cellLoader stopAnimation];

        }
        else {
            [self.cellPlayer setPlayer:nil];
            [self.cellPlayer.player pause];
            [self.cellPlayer.view setHidden:true];
            [self.cellLoader startAnimation];
            
        }
        
        if (animated) {
            [UIView transitionWithView:self.cellImage duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.cellImage setImage:self.thumbnail];
                [self.cellShadow setBackgroundColor:[self colour:(self.cellShadow.bounds.size.width / 2) - 0.02 ycoordinate:self.cellImage.bounds.size.height - 0.02]];
                [self.cellShadow.layer setShadowColor:self.cellShadow.backgroundColor.CGColor];
                [self.cellPlayer.view setAlpha:1.0];

            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.3 animations:^{
                    [self.cellPlayer.view setAlpha:1.0];
                    
                } completion:nil];
                
            }];

        }
        else {
            [self.cellImage setContentMode:UIViewContentModeScaleAspectFill];
            [self.cellImage setImage:self.thumbnail];
            [self.cellPlayer.view setAlpha:1.0];

        }

    }
    else {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^{
                [self.cellPlayer.view setAlpha:0.0];
                
            } completion:^(BOOL finished) {
                [UIView transitionWithView:self.cellImage duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                    [self.cellImage setContentMode:UIViewContentModeCenter];
                    [self.cellImage setImage:[UIImage imageNamed:@"editor_placeholder"]];
                    
                    [self.cellShadow setBackgroundColor:[self colour:(self.cellShadow.bounds.size.width / 2) - 0.02 ycoordinate:self.cellImage.bounds.size.height - 0.02]];
                    [self.cellShadow.layer setShadowColor:self.cellShadow.backgroundColor.CGColor];
                    
                } completion:nil];
                
            }];
            
        }
        else {
            [self.cellPlayer.view setAlpha:0.0];
            [self.cellImage setContentMode:UIViewContentModeCenter];
            [self.cellImage setImage:[UIImage imageNamed:@"editor_placeholder"]];
            
            [self.cellShadow setBackgroundColor:[self colour:(self.cellShadow.bounds.size.width / 2) - 0.02 ycoordinate:self.cellImage.bounds.size.height - 0.02]];
            [self.cellShadow.layer setShadowColor:self.cellShadow.backgroundColor.CGColor];
            
        }

    }
    
}

-(UIColor *)colour:(int)x ycoordinate:(int)y {
    if (self.cellImage.image.CGImage != NULL && self.cellImage.image.CGImage != nil) {
        CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.cellImage.image.CGImage));
        const UInt8* data = CFDataGetBytePtr(pixelData);
        int pixelInfo = ((self.cellImage.image.size.width * y) + x) * 4;

        if (self.cellImage.image.size.width > 0 && self.cellImage.image.size.height > 1) {
            UInt8 red = data[pixelInfo];
            UInt8 green = data[(pixelInfo + 1)];
            UInt8 blue = data[pixelInfo + 2];
            if (pixelData != nil) CFRelease(pixelData);
            
            UIColor *colour = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:1.0];
            if ([self isdark:colour]) return colour;
            else return UIColorFromRGB(0x464655);
            
        }
        else return UIColorFromRGB(0x464655);
        
    }
    else return UIColorFromRGB(0x464655);
    
}

-(BOOL)isdark:(UIColor *)color {
    const CGFloat *componentColors = CGColorGetComponents(color.CGColor);
    CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
    if (colorBrightness < 0.5) return true;
    else return false;
    
}

    
-(UIImage *)thumbnail {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.video options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = true;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:nil];
    
    return [[UIImage alloc] initWithCGImage:image];
    
}

-(void)delete:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(collectionViewDeleteAsset:)]) {
        [self.delegate collectionViewDeleteAsset:self];;

    }
    
}

-(void)animate:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(collectionToggleAnimation:)]) {
        [self.delegate collectionToggleAnimation:self];;
        
    }
    
}

@end
