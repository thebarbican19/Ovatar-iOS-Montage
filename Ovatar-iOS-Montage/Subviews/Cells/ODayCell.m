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
    if (self) {
        self.cellImage = [[UIImageView alloc] initWithFrame:self.bounds];
        self.cellImage.contentMode = UIViewContentModeCenter;
        self.cellImage.clipsToBounds = true;
        self.cellImage.backgroundColor = UIColorFromRGB(0x464655);
        self.cellImage.image = [UIImage imageNamed:@"editor_placeholder"];
        [self.contentView addSubview:self.cellImage];
        
        self.cellPlayer = [[AVPlayerViewController alloc] init];
        self.cellPlayer.view.frame = self.bounds;
        self.cellPlayer.view.backgroundColor = [UIColor clearColor];
        self.cellPlayer.showsPlaybackControls = false;
        self.cellPlayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.cellPlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.cellPlayer.player.muted = true;
        self.cellPlayer.player.allowsExternalPlayback = false;
        self.cellPlayer.view.userInteractionEnabled = false;
        self.cellPlayer.allowsPictureInPicturePlayback = false;
        [self.contentView addSubview:self.cellPlayer.view];

        self.cellShadow = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 20.0, self.bounds.size.width, self.bounds.size.height)];
        self.cellShadow.backgroundColor = [UIColor clearColor];
        //[self addSubview:self.cellShadow];
        

    }
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loop:)  name:AVPlayerItemDidPlayToEndTimeNotification object:self.cellPlayer.player.currentItem];
    
    return self;
    
}

-(void)loop:(NSNotification *)notification {
    [self.cellPlayer.player seekToTime:kCMTimeZero];
    [self.cellPlayer.player play];
    
}

-(void)setup:(NSDictionary *)content {
    self.image = [UIImage imageWithData:[content objectForKey:@"image"]];
    self.filename = [NSString stringWithFormat:@"/%@.mov" ,[content objectForKey:@"key"]];
    self.video = [NSURL fileURLWithPath:[APP_DOCUMENTS stringByAppendingString:self.filename]];
    self.timestamp = [content objectForKey:@"timestamp"];
    self.key = [content objectForKey:@"key"];
    self.asset = [content objectForKey:@"assetid"];
    
    if (self.asset != nil) {
        if (self.video != nil) {
            [self.cellPlayer setPlayer:[AVPlayer playerWithURL:self.video]];
            [self.cellPlayer.player play];
            [self.cellPlayer.player setMuted:true];

        }
        else {
            [self.cellPlayer setPlayer:nil];
            [self.cellPlayer.player pause];

        }
        
        [self.cellPlayer.view setHidden:false];
        
    }
    else {
        [self.cellPlayer.view setHidden:true];

    }
    
    
    //if (image) {
    //NSLog(@"load image: %@" ,self.image);
        //[self.cellImage setImage:self.image];
        //[self.cellShadow setImage:[UIImage ty_imageByApplyingBlurToImage:self.image withRadius:40.0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.15] saturationDeltaFactor:1.0 maskImage:nil]];

    //}
    //else {
        //[self.cellImage setImage:nil];

    //}

    
}

@end
