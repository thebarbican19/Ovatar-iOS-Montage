//
//  OPresentationController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 26/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OPresentationController.h"
#import "OConstants.h"

@interface OPresentationController ()

@end

@implementation OPresentationController

-(void)viewWillLayoutSubviews {
    [self.viewShare setFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 100.0, self.view.bounds.size.height - 182.0, 200.0, 90.0)];
    [self.viewRestart setFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 80.0, self.view.bounds.size.height - 100.0, 160.0, 75.0)];
    [self.viewTabbar setFrame:CGRectMake(0.0, self.view.bounds.size.height - 80.0, self.view.bounds.size.width, 80.0)];
    [self.viewPurchase setFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 120.0, self.view.bounds.size.height - 80.0, 240.0, 75.0)];

}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.imageobj = [OImageObject sharedInstance];

    self.dataobj = [[ODataObject alloc] init];
    self.dataobj.delegate = self;
    //self.cloudServiceController = [SKCloudServiceController new];

    self.viewPlayer = [[AVPlayerViewController alloc] init];
    self.viewPlayer.view.frame = CGRectMake(36.0, 26.0, self.view.bounds.size.width - 72.0, self.view.bounds.size.height - 128.0);
    self.viewPlayer.view.backgroundColor = [UIColor blackColor];
    self.viewPlayer.view.clipsToBounds = true;
    self.viewPlayer.view.layer.cornerRadius = 8.0;
    self.viewPlayer.showsPlaybackControls = false;
    self.viewPlayer.videoGravity = AVLayerVideoGravityResizeAspect;
    self.viewPlayer.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    self.viewPlayer.player = nil;
    self.viewPlayer.player.allowsExternalPlayback = false;
    self.viewPlayer.allowsPictureInPicturePlayback = false;
    self.viewPlayer.view.userInteractionEnabled = false;
    self.viewPlayer.view.alpha = 0.0;
    [self.view addSubview:self.viewPlayer.view];
    
    self.viewElapsed = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 114.0, 30.0, 70.0, 26.0)];
    self.viewElapsed.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
    self.viewElapsed.textColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    self.viewElapsed.shadowOffset = CGSizeMake(0.0, 1.0);
    self.viewElapsed.shadowColor = [UIColorFromRGB(0x464655) colorWithAlphaComponent:0.1];
    self.viewElapsed.font = [UIFont fontWithName:@"Avenir-Heavy" size:11.0];
    self.viewElapsed.textAlignment = NSTextAlignmentRight;
    self.viewElapsed.backgroundColor = [UIColor clearColor];
    self.viewElapsed.text = nil;
    [self.view addSubview:self.viewElapsed];
    
    self.viewTick = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 50.0, self.viewPlayer.view.frame.origin.y + 40.0, 100.0, 100.0)];
    self.viewTick.backgroundColor = [UIColor clearColor];
    self.viewTick.contentMode = UIViewContentModeScaleAspectFit;
    self.viewTick.image = [UIImage imageNamed:@"export_complete"];
    self.viewTick.transform = CGAffineTransformMakeScale(0.9, 0.9);
    self.viewTick.alpha = 0.0;
    [self.view addSubview:self.viewTick];

    self.viewStatus = [[SAMLabel alloc] initWithFrame:CGRectMake(50.0, self.viewTick.frame.origin.y + 180.0, self.view.bounds.size.width - 100.0, 105.0)];
    self.viewStatus.textColor = UIColorFromRGB(0xAAAAB8);
    self.viewStatus.attributedText = [self format:NSLocalizedString(@"Export_Saved_Description", nil)];
    self.viewStatus.font = [UIFont fontWithName:@"Avenir-Medium" size:15.0];
    self.viewStatus.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
    self.viewStatus.textAlignment = NSTextAlignmentCenter;
    self.viewStatus.numberOfLines = 9;
    self.viewStatus.alpha = 0.0;
    [self.view addSubview:self.viewStatus];
    
    self.viewShare = [[OActionButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 100.0, self.view.bounds.size.height - 240.0, 200.0, 90.0)];
    self.viewShare.backgroundColor = [UIColor clearColor];
    self.viewShare.clipsToBounds = false;
    self.viewShare.delegate = self;
    self.viewShare.title = NSLocalizedString(@"Export_Share_Action", nil);
    self.viewShare.key = @"share";
    self.viewShare.alpha = 0.0;
    [self.view addSubview:self.viewShare];
    
    self.viewRestart = [[OActionButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 100.0, self.view.bounds.size.height - 240.0, 200.0, 90.0)];
    self.viewRestart.backgroundColor = [UIColor clearColor];
    self.viewRestart.clipsToBounds = false;
    self.viewRestart.delegate = self;
    self.viewRestart.title = NSLocalizedString(@"Export_Restart_Action", nil);
    self.viewRestart.key = @"restart";
    self.viewRestart.fontsize = 9.0;
    self.viewRestart.grayscale = true;
    self.viewRestart.alpha = 0.0;
    [self.view addSubview:self.viewRestart];
    
//    self.viewTabbar = [[OTabbarView alloc] initWithFrame:CGRectMake(0.0, self.view.bounds.size.height - 80.0, self.view.bounds.size.width, 80.0)];
//    self.viewTabbar.buttons = @[@{@"text":NSLocalizedString(@"Export_Watermark_Tabbar", nil),
//                                  @"image":@"export_tabbar_watermark",
//                                  @"key":@"watermark"},
//                                @{@"text":NSLocalizedString(@"Export_Speed_Title", nil),
//                                  @"image":@"export_tabbar_speed",
//                                  @"key":@"speed"},
//                                @{@"text":NSLocalizedString(@"Export_Music_Title", nil),
//                                  @"image":@"export_tabbar_music",
//                                  @"key":@"music"}];
//    self.viewTabbar.delegate = self;
//    self.viewTabbar.backgroundColor = [UIColor clearColor];
//    self.viewTabbar.alpha = 0.0;
//    self.viewTabbar.clipsToBounds = true;
//    [self.view addSubview:self.viewTabbar];
    
    self.viewPurchase = [[OActionButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width * 0.5) - 140.0, self.view.bounds.size.height - 240.0, 280.0, 90.0)];
    self.viewPurchase.backgroundColor = [UIColor clearColor];
    self.viewPurchase.clipsToBounds = false;
    self.viewPurchase.delegate = self;
    self.viewPurchase.title = NSLocalizedString(@"Export_Purchase_Action", nil);
    self.viewPurchase.key = @"purchase";
    self.viewPurchase.grayscale = true;
    self.viewPurchase.icon = [UIImage imageNamed:@"export_purchase_lock"];
    self.viewPurchase.alpha = 0.0;
    [self.view addSubview:self.viewPurchase];

    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(videoElapsed) userInfo:nil repeats:true];
        
}

-(void)viewPresentOutput:(NSURL *)file {
    float videoscale = (self.view.bounds.size.width - 72.0) / self.videosize.width;
    float videoheight = self.videosize.height * videoscale;
    float videowidth = self.videosize.width * videoscale;
    
    if (videoheight >= (self.view.bounds.size.height + 95.0)) videoheight = (self.view.bounds.size.height + 95.0);
    
    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
    } completion:^(BOOL finished) {
        [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        [self.viewPlayer setPlayer:[AVPlayer playerWithURL:file]];
        [self.viewPlayer.player play];
        [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewPlayer.view setAlpha:1.0];
            [self.viewPlayer.view setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [self.viewPlayer.view setFrame:CGRectMake((self.view.bounds.size.width / 2) - (videowidth / 2), 26.0, videowidth, videoheight)];
            [self.viewElapsed setAlpha:1.0];
            [self.viewTabbar setAlpha:1.0];
            [self.viewPurchase setAlpha:1.0];

        } completion:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoReset:)  name:AVPlayerItemDidPlayToEndTimeNotification object:self.viewPlayer.player.currentItem];

    }];
    
}

-(void)tabbarAction:(UIButton *)button {
    NSString *key = [[self.viewTabbar.buttons objectAtIndex:button.tag] objectForKey:@"key"];
    if ([key isEqualToString:@"watermark"]) {
        [self.delegate viewPresentError:@"Cannot remove *watermarks* in this version."];
        
    }
    else if ([key isEqualToString:@"speed"]) {
//        [self.dataobj storyAppendSpeed:self.dataobj.storyActiveKey speed:0.1 completion:^(NSError *error) {
//            if (error.code == 200) {
//                [self.delegate viewPresentLoader:true text:@"x1.0"];
//                [self.delegate viewExportWithSize:self.videosize];
//
//            }
//            else [self.delegate viewPresentError:error.localizedDescription];
//
//        }];
        
        [self.delegate viewPresentError:@"Cannot change clip *speed* in this version."];

        
    }
    else if ([key isEqualToString:@"music"]) {
        [SKCloudServiceController requestAuthorization:^(SKCloudServiceAuthorizationStatus status) {
            if (status == SKCloudServiceAuthorizationStatusAuthorized) {
                MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
                mediaPicker.delegate = self;
                mediaPicker.allowsPickingMultipleItems = NO; // this is the default
                [self presentViewController:mediaPicker animated:YES completion:nil];
                
            }
            else {
                
            }
          
        }];
        
    }
    
}

-(void)viewReset {
    [self.viewPlayer setPlayer:nil];
    [self.viewPlayer.view setAlpha:0.0];
    [self.viewElapsed setAlpha:0.0];
    [self.viewTick setAlpha:0.0];
    [self.viewShare setAlpha:0.0];
    [self.viewRestart setAlpha:0.0];
    [self.viewStatus setAlpha:0.0];
    [self.viewTabbar setAlpha:0.0];
    [self.viewPurchase setAlpha:0.0];

    [[NSNotificationCenter defaultCenter] removeObserver:AVPlayerItemDidPlayToEndTimeNotification];
    
}

-(void)videoReset:(NSNotification *)notification {
    [self.viewPlayer.player seekToTime:kCMTimeZero];
    [self.viewPlayer.player play];
    
}

-(void)videoElapsed {
    NSInteger currentseconds = ((NSInteger)CMTimeGetSeconds(self.viewPlayer.player.currentItem.currentTime)) % 60;
    NSInteger currentminutes = (currentseconds / 60) % 60;
    NSInteger durationseconds = ((NSInteger)CMTimeGetSeconds(self.viewPlayer.player.currentItem.duration)) % 60;
    NSInteger durationminutes = (durationseconds / 60) % 60;
    
    [self.viewElapsed setText:[NSString stringWithFormat:@"%02ld:%02ld/%02ld:%02ld" ,(long)currentminutes, (long)currentseconds, (long)durationminutes, (long)durationseconds]];
    
}

-(void)viewExportSucsessful {
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewPlayer.view setAlpha:0.0];
        [self.viewElapsed setAlpha:0.0];
        [self.viewTabbar setAlpha:0.0];
        [self.viewPurchase setAlpha:0.0];

    } completion:^(BOOL finished) {
        [self.viewTick setTransform:CGAffineTransformMakeScale(0.9, 0.9)];
        [self.viewShare setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
        [self.viewStatus setFrame:CGRectMake(self.viewStatus.frame.origin.x, self.viewStatus.frame.origin.y - 16.0, self.viewStatus.bounds.size.width, self.viewStatus.bounds.size.height)];
        [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewTick setAlpha:1.0];
            [self.viewTick setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [self.viewStatus setAlpha:1.0];
            [self.viewStatus setFrame:CGRectMake(self.viewStatus.frame.origin.x, self.viewStatus.frame.origin.y + 16.0, self.viewStatus.bounds.size.width, self.viewStatus.bounds.size.height)];

        } completion:nil];
        
        [UIView animateWithDuration:0.3 delay:0.6 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewShare setAlpha:1.0];
            [self.viewShare setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

        } completion:nil];
        
        [UIView animateWithDuration:0.3 delay:0.7 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewRestart setAlpha:1.0];
            
        } completion:nil];
        
    }];
    
    NSURL *sfx = [[NSBundle mainBundle] URLForResource:@"complete_sfx" withExtension:@"mp3"];
    SystemSoundID audioid;
    OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)sfx, &audioid);
    if (error == kAudioServicesNoError) {
        self.complete = audioid;
        AudioServicesPlaySystemSound(self.complete);
        
    }
     
}

-(void)viewActionTapped:(OActionButton *)action {
    if ([action.key isEqualToString:@"share"]) {
        if (self.exported != nil) {
            UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[self.exported] applicationActivities:nil];
            [super presentViewController:share animated:true completion:^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
                
            }];
            
        }
        
    }
    else if ([action.key isEqualToString:@"purchase"]) {
        BOOL __block someoneisdoingwell = false;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"json"];
        NSArray *content = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil];
        
        [self.imageobj imagesFromAlbum:nil limit:25 completion:^(NSArray *images) {
            for (NSDictionary *item in [images.firstObject objectForKey:@"images"]) {
                PHAsset *asset = [item objectForKey:@"asset"];
                for (NSDictionary *place in content) {
                    float latitude = [[place objectForKey:@"latitude"] floatValue];
                    float longitude = [[place objectForKey:@"longitude"] floatValue];
                    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
                    CLLocationDistance distance = [asset.location distanceFromLocation:location];
                    float miles = (distance / 1609.344);
                    if (miles <= 1.3) {
                        someoneisdoingwell = true;
                        break;
                        
                    }
                    
                    NSLog(@"\nPlace: %@ distance : %fm" ,[place objectForKey:@"name"] ,(distance / 1609.344));
                    
                }
                
            }
            
        }];
       
        NSString *identifyer = nil;
        if (someoneisdoingwell) identifyer = @"com.ovatar.watermarkremove_tier_2";
        else identifyer = @"com.ovatar.watermarkremove_tier_1";
        
        [self.delegate viewPurchaseInitialiseWithIdentifyer:identifyer];
        
    }
    else {
        NSString *name = [NSString stringWithFormat:@"montage #%d" ,self.dataobj.storyExports + 1];
        NSDictionary *data = @{@"name":name};
        [self.dataobj storyCreateWithData:data completion:^(NSString *key, NSError *error) {
            [self.dataobj entryCreate:key assets:nil completion:^(NSError *error, NSArray *keys) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self.delegate viewPresentSubviewWithIndex:1 animate:true];
                    
                }];
                
            }];

        }];
        
    }
    
}

-(NSMutableAttributedString *)format:(NSString *)text {
    if (text != nil) {
        NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:text];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
        NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0.0, text.length)];
        
        [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Medium" size:15.0] range:NSMakeRange(0, text.length)];
        [formatted addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xAAAAB8)range:NSMakeRange(0, text.length)];
        
        for (NSTextCheckingResult *match in matches) {
            [formatted addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:15.0] range:NSMakeRange(match.range.location, match.range.length)];
            [formatted addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x7490FD)range:NSMakeRange(match.range.location, match.range.length)];
            
        }
        
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        [formatted.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, formatted.string.length)];
        
        return formatted;
        
    }
    else return nil;
    
}

-(void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    if (mediaItemCollection.count > 0) {
        self.song = mediaItemCollection.items.firstObject;
        self.soundtrack = [AVURLAsset URLAssetWithURL:[self.song valueForProperty:MPMediaItemPropertyAssetURL] options:nil];

        NSLog(@"[self.song valueForProperty:MPMediaItemPropertyAssetURL] %@" ,[self.song valueForProperty:MPMediaItemPropertyAssetURL]);
        if ([self mediaCanPlayFile:[self.song valueForProperty:MPMediaItemPropertyAssetURL]]) {
            
        }
        else {
            [self.delegate viewPresentError:[NSString stringWithFormat:NSLocalizedString(@"Error_MusicDRM_Title", nil), self.song.title]];
             
        }
        NSLog(@"Song: %@" ,self.song.title);
        NSLog (@"Core Audio %@ directly open library URL",
               [self mediaCanPlayFile:[self.song valueForProperty:MPMediaItemPropertyAssetURL]]?@"can":@"cannot");
    }
    
    [self dismissViewControllerAnimated:true completion:^{
        [self.delegate viewPresentSubviewWithIndex:2 animate:false];
        [self.delegate viewPresentLoader:false text:nil];
        
    }];
    
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:true completion:nil];

}

-(BOOL)mediaCanPlayFile:(NSURL *)url {
    OSStatus openErr = noErr;
    AudioFileID audioFile = NULL;
    openErr = AudioFileOpenURL((__bridge CFURLRef) url, kAudioFileReadPermission, 0, &audioFile);
    if (audioFile) {
        AudioFileClose(audioFile);
    }
    
    return openErr ? NO : YES;
    
}

@end
