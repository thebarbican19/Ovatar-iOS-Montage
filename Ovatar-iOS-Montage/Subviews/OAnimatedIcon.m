//
//  OAnimatedIcon.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OAnimatedIcon.h"

@implementation OAnimatedIcon

-(void)drawRect:(CGRect)rect {
    self.dataobj = [[ODataObject alloc] init];
    self.imageobj = [OImageObject sharedInstance];
    
    NSString *file;
    if (self.type == OAnimatedIconTypePush) file = @"Montage-Icon-Push";
    else if (self.type == OAnimatedIconTypeError) file = @"Montage-Icon-Error";
    else if (self.type == OAnimatedIconTypeComplete) file = @"Montage-Icon-Complete";
    else if (self.type == OAnimatedIconTypeOvatar) file = @"Montage-Icon-Ovatar";

    if (![self.subviews containsObject:self.player.view]) {
        self.player = [[AVPlayerViewController alloc] init];
        self.player.view.frame = self.bounds;
        self.player.view.backgroundColor = [UIColor clearColor];
        self.player.showsPlaybackControls = false;
        self.player.videoGravity = AVLayerVideoGravityResizeAspect;
        self.player.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.player.player.allowsExternalPlayback = false;
        self.player.allowsPictureInPicturePlayback = false;
        self.player.view.userInteractionEnabled = false;
        self.player.view.hidden = true;
        [self addSubview:self.player.view];
        
        self.loader = [[OLoaderView alloc] initWithFrame:self.bounds];
        self.loader.backgroundColor = [UIColor clearColor];
        self.loader.speed = 0.6;
        self.loader.scale = 90.0;
        self.loader.layer.cornerRadius = self.bounds.size.height / 2;
        self.loader.clipsToBounds = true;
        self.loader.hidden = true;
        [self addSubview:self.loader];
       
    }
    
    if (self.type == OAnimatedIconTypeLoading || self.type == OAnimatedIconTypeRender) {
        [self.player.player pause];
        [self.player.view setHidden:true];
        [self.loader setHidden:false];
        [self.loader loaderTerminate];

        if (self.type == OAnimatedIconTypeRender) {
            NSMutableArray *images = [[NSMutableArray alloc] init];
            for (NSDictionary *entry in [self.dataobj storyEntries:self.dataobj.storyActiveKey]) {
                [self.imageobj imageReturnFromAssetKey:[entry objectForKey:@"assetid"] completion:^(PHAsset *asset) {
                    [self.imageobj imagesFromAsset:asset thumbnail:true completion:^(NSDictionary *exifdata, NSData *image) {
                        if (image != nil) [images addObject:[UIImage imageWithData:image]];
                         
                    }];

                }];
                
            }
            
            [self.loader loaderPresentWithImages:images animated:false];
            
        }
        else {
            [self.loader loaderPresentWithImages:@[@"splash_loader_0", @"splash_loader_1", @"splash_loader_2", @"splash_loader_3", @"splash_loader_4", @"splash_loader_5", @"splash_loader_6"] animated:false];
            
        }
    }
    else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loop)  name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.player.currentItem];

        [self.loader setHidden:true];
        [self.player.view setHidden:false];
        [self.player setPlayer:[AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]  pathForResource:file ofType:@"mov"]]]];
        [self.player.player play];

    }

}

-(void)loop {
    if (self.loopvid) {
        [self.player.player seekToTime:kCMTimeZero];
        [self.player.player play];
        
    }
    
}

@end
