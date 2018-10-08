//
//  OExportObject.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 15/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OExportObject.h"
#import "OConstants.h"

#define CDPRadians( degrees ) (M_PI * ( degrees ) / 180.0 )

@implementation OExportObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.imageobj = [[OImageObject alloc] init];
        self.dataobj = [[ODataObject alloc] init];
        
        self.videoframes = 29.96;
        self.videoresize = CGSizeMake(1080, 1920);
        self.videoseconds = 1.5;

    }
    
    return self;
    
}

-(void)exportMontage:(NSString *)story completion:(void (^)(NSString *file, NSError *error))completion {
    self.story = story;
    if (CGSizeEqualToSize(CGSizeZero, self.videoresize)) {
        completion(nil, [NSError errorWithDomain:@"no size specifyed" code:402 userInfo:nil]);
        
    }
    else {
        int clip = 1;
        NSMutableDictionary *storydata = [[NSMutableDictionary alloc] init];
        [storydata addEntriesFromDictionary:[self.dataobj storyWithKey:story]];

        AVMutableComposition *mutableComposition = [AVMutableComposition composition];
        AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        
        NSMutableArray *watermark = [[NSMutableArray alloc] init];
        NSMutableArray *instructions = [[NSMutableArray alloc] init];
        CMTime videotime = kCMTimeZero;
        for (NSDictionary *item in [self.dataobj storyEntries:story]) {
            NSString *filename = [NSString stringWithFormat:@"%@/%@.mov", APP_DOCUMENTS ,[item objectForKey:@"key"]];
            AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filename]];
            BOOL audioenabled = [[item objectForKey:@"audio"] boolValue];
            //float limit = [[item objectForKey:@"limitduration"] floatValue];
            
            if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
                AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
                AVAssetTrack *audioAssetTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];;
                
                NSError *videoError;
                [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:videotime error:&videoError];
                
                if (videoError) completion(nil, videoError);
                
                if (audioenabled) {
                    [[mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid] insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:videotime error:nil];
                    
                }
                
                AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
                [videolayerInstruction setTransform:[self exportTransform:asset] atTime:kCMTimeZero];

                CMTime videoduration = kCMTimeZero;
                if (self.videoseconds > CMTimeGetSeconds(videoAssetTrack.timeRange.duration)) {
                    videoduration = CMTimeMakeWithSeconds(self.videoseconds, self.videoframes);
                    
                }
                else videoduration = videoAssetTrack.timeRange.duration;
                
                AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
                [videoCompositionInstruction setTimeRange:CMTimeRangeMake(videotime, videoduration)];
                [videoCompositionInstruction setLayerInstructions:@[videolayerInstruction]];
                
                [watermark addObject:@{@"begin":@(CMTimeGetSeconds(videotime)),
                                       @"duration":@(CMTimeGetSeconds(videoduration)),
                                       @"timestamp":[item objectForKey:@"captured"],
                                       @"location":[self exportLocation:item story:storydata]
                                       }];

                videotime = CMTimeAdd(videotime, videoduration);
                clip++;

                [instructions addObject:videoCompositionInstruction];
                
            }
            
        }
        
        if ([self.dataobj musicActive] != nil) {
            if ([[self.dataobj.musicActive objectForKey:@"type"] isEqualToString:@"bundle"]) {
                NSString *soundtrack = [[NSBundle mainBundle] pathForResource:[self.dataobj.musicActive objectForKey:@"file"] ofType:@"mp3"];
                AVMutableCompositionTrack *soundtrackCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                AVAsset *soundtrackAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:soundtrack]];
                AVAssetTrack *soundtrackAssetTrack = [[soundtrackAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

                [soundtrackCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videotime) ofTrack:soundtrackAssetTrack atTime:kCMTimeZero error:nil];
                
            }
            else {
                NSString *soundtrack = [self.dataobj.musicActive objectForKey:@"file"];
                AVMutableCompositionTrack *soundtrackCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
                AVURLAsset *soundtrackAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:soundtrack] options:nil];
                AVAssetTrack *soundtrackAssetTrack = [[soundtrackAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];

                [soundtrackCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videotime) ofTrack:soundtrackAssetTrack atTime:kCMTimeZero error:nil];
                
            }
            
        }
        
        
        NSString *output = [NSString stringWithFormat:@"%@/%@_export.mov", APP_DOCUMENTS ,story];
        if ([[NSFileManager defaultManager] fileExistsAtPath:output]) {
            [[NSFileManager defaultManager] removeItemAtPath:output error:nil];
            
        }
        
        AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
        mutableVideoComposition.instructions = instructions;
        mutableVideoComposition.frameDuration = CMTimeMake(1.0, self.videoframes);
        mutableVideoComposition.renderSize =  CGSizeMake(self.videoresize.width, self.videoresize.height);;
        mutableVideoComposition.animationTool = [self exportWatermark:storydata instructions:watermark];
        
        self.exporttimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(exportStatus:) userInfo:nil repeats:true];
        self.exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
        self.exporter.videoComposition = mutableVideoComposition;
        self.exporter.outputURL = [[NSURL alloc] initFileURLWithPath:output];
        self.exporter.outputFileType = @"com.apple.quicktime-movie";
        self.exporter.shouldOptimizeForNetworkUse = true;
        
        [self.exporter exportAsynchronouslyWithCompletionHandler:^{
            if (self.exporter.status != AVAssetExportSessionStatusExporting) {
                if (self.exporter.status == AVAssetExportSessionStatusCompleted) {
                    completion(output, [NSError errorWithDomain:@"exported okay" code:200 userInfo:nil]);
                    
                }
                else {
                    NSLog(@"exporter.error %@" ,self.exporter.error);
                    completion(nil, self.exporter.error);
                    
                }
                
            }
            else {
                NSLog(@"exporting video: %f" ,self.exporter.progress);
                
            }
            
        }];
        
    }
    
}

-(NSString *)exportLocation:(NSDictionary *)asset story:(NSDictionary *)story {
    NSMutableString *append = [[NSMutableString alloc] init];
    if ([[asset objectForKey:@"city"] length] > 0) [append appendString:[asset objectForKey:@"city"]];
    if ([append length] > 1 && [[asset objectForKey:@"country"] length] > 0) [append appendString:@", "];
    if ([[asset objectForKey:@"country"] length] > 0) [append appendString:[asset objectForKey:@"country"]];
    
    if ([append length] < 3) {
        if ([[story objectForKey:@"city"] length] > 0) [append appendString:[story objectForKey:@"city"]];
        if ([append length] > 1 && [[story objectForKey:@"country"] length] > 0) [append appendString:@", "];
        if ([[story objectForKey:@"country"] length] > 0) [append appendString:[story objectForKey:@"country"]];
        
    }
    
    if ([append length] < 3) [append appendString:NSLocalizedString(@"Settings_Watermark_EmptyLocation", nil)];
    
    return append;
    
}

-(void)exportTerminate {
    NSString *output = [NSString stringWithFormat:@"%@/%@_export.mov", APP_DOCUMENTS ,self.story];
    if (self.story != nil) {
        [self.exporter cancelExport];
        [self setStory:nil];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:output]) {
            [[NSFileManager defaultManager] removeItemAtPath:output error:nil];
            
        }
        
    }
    
}

-(void)exportStatus:(NSTimer *)timer {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoaderExportStatus" object:@{@"progress":@(self.exporter.progress)}];
    
}

-(CGAffineTransform)exportTransform:(AVAsset *)asset {
    AVAssetTrack *track = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
    UIImageOrientation orientation = UIImageOrientationUp;
    BOOL portrait = false;
    CGAffineTransform preferred = track.preferredTransform;
    
    CGFloat videoOffY  = 0.0;
    CGFloat videoOffX  = 0.0;
    CGSize naturalSize = track.naturalSize;
    CGSize renderSize  = CGSizeMake(self.videoresize.width, self.videoresize.height);
    CGAffineTransform mixedTransform = CGAffineTransformIdentity;
    
    if (preferred.a == 0 && preferred.b == 1.0 && preferred.c == -1.0 && preferred.d == 0) {
        orientation = UIImageOrientationRight;
        portrait = false;

    }
    else if (preferred.a == 0 && preferred.b == -1.0 && preferred.c == 1.0 && preferred.d == 0) {
        orientation = UIImageOrientationLeft;
        portrait = false;

    }
    else if (preferred.a == 1.0 && preferred.b == 0 && preferred.c == 0 && preferred.d == 1.0) {
        orientation = UIImageOrientationUp;
        portrait = true;

    }
    else if (preferred.a == -1.0 && preferred.b == 0 && preferred.c == 0 && preferred.d == -1.0) {
        orientation = UIImageOrientationDown;
        portrait = true;
        
    }
    
    if (!portrait) naturalSize = CGSizeMake(naturalSize.height, naturalSize.width);

    renderSize = CGSizeMake(renderSize.width, renderSize.width * naturalSize.height/naturalSize.width);
    
    CGFloat aspectratio;
    if (self.videoresize.width > self.videoresize.height) aspectratio = self.videoresize.width /  track.naturalSize.width;
    else aspectratio = self.videoresize.height /  track.naturalSize.height;
    CGAffineTransform scale = CGAffineTransformMakeScale(aspectratio, aspectratio);

    if (orientation == UIImageOrientationRight) {
        mixedTransform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(renderSize.width + videoOffX, videoOffY), M_PI_2);
        
    }
    else if (orientation == UIImageOrientationLeft) {
        mixedTransform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(videoOffX, renderSize.height + videoOffY), M_PI_2*3.0);
        
    }
    else if (orientation == UIImageOrientationDown) {
        mixedTransform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(renderSize.width + videoOffX, renderSize.height + videoOffY), M_PI);
    }
    
    CGAffineTransform output;
    if (CGAffineTransformIsIdentity(mixedTransform)) output = CGAffineTransformConcat(track.preferredTransform, scale);
    else output = CGAffineTransformConcat(scale, mixedTransform);
   
    if (self.videoresize.width > self.videoresize.height) {
        if (portrait) {
            if (renderSize.height > ((self.videoresize.width / 4) * 3)) return CGAffineTransformConcat(output, CGAffineTransformMakeTranslation(0.0, 0.0));
            else return CGAffineTransformConcat(output, CGAffineTransformMakeTranslation(0.0, -(self.videoresize.width / 4) * 3));
            
        }
        else return CGAffineTransformConcat(output, CGAffineTransformMakeTranslation(0.0, -(self.videoresize.width / 4) * 3));
        
    }
    else {
        if (portrait) {
            if (renderSize.height > ((self.videoresize.width / 4) * 3)) return CGAffineTransformConcat(output, CGAffineTransformMakeTranslation(0.0, 0.0));
            else return CGAffineTransformConcat(output, CGAffineTransformMakeTranslation(-((self.videoresize.width / 4) * 3), 0.0));
            
        }
        else return CGAffineTransformConcat(output, CGAffineTransformMakeTranslation(0.0, 0.0));
        
    }
    
}

-(AVVideoCompositionCoreAnimationTool *)exportWatermark:(NSDictionary *)data instructions:(NSArray *)instructions {
    CALayer *watermark = [CALayer layer];
    UIImage *wimage = nil;
    NSString *wtext = @"";
    NSString *wkey = [data objectForKey:@"watermark"];

    NSLog(@"watermarl %@" ,data);
    if ([wkey isEqualToString:@"watermark_default"] || [wkey isEqualToString:@"watermark_title"]) {
        if ([wkey isEqualToString:@"watermark_title"]) {
            wimage = nil;
            wtext = [data objectForKey:@"name"];
            
        }
        else {
            wimage = [UIImage imageNamed:@"watermark_default"];
            wtext = @"ovatar.io/montage";
            
        }
        
        CATextLayer *watermarktext = [[CATextLayer alloc] init];
        [watermarktext setFont:@"Avenir-Black"];
        [watermarktext setFontSize:36];
        if (wimage == nil) [watermarktext setFrame:CGRectMake(30.0, 0.0, self.videoresize.width, 70.0)];
        else [watermarktext setFrame:CGRectMake(70.0, 0.0, self.videoresize.width, 70.0)];
        [watermarktext setString:wtext];
        [watermarktext setAlignmentMode:kCAAlignmentLeft];
        [watermarktext setOpacity:1.0];
        [watermarktext setForegroundColor:[[UIColor colorWithWhite:1.0 alpha:0.7] CGColor]];
        [watermarktext setBackgroundColor:[[UIColor clearColor] CGColor]];
        [watermark addSublayer:watermarktext];
        
    }
    else {
        for (int i = 0; i < [instructions count]; i++) {
            NSDictionary *wprevious;
            if (i > 0) wprevious = [instructions objectAtIndex:i - 1];
            NSString *wpreviousstring = nil;
            NSDictionary *wnext;
            if (i < ([instructions count] - 1)) wnext = [instructions objectAtIndex:i + 1];
            NSString *wnextstring = nil;
            NSDictionary *instruction = [instructions objectAtIndex:i];
            float watermarkbegin = [[instruction objectForKey:@"begin"] floatValue];
            float watermarkduration = [[instruction objectForKey:@"duration"] floatValue];

            if (watermarkbegin == 0) watermarkbegin = 0.01;
            
            if ([[data objectForKey:@"watermark"] isEqualToString:@"watermark_timetamp"]) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"EEE d MMMM YYYY";
                formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                
                if (wprevious != nil) wpreviousstring = [formatter stringFromDate:[wprevious objectForKey:@"timestamp"]];
                if (wnext != nil) wnextstring = [formatter stringFromDate:[wnext objectForKey:@"timestamp"]];
                
                wtext = [formatter stringFromDate:[instruction objectForKey:@"timestamp"]];
                wimage = nil;
                
            }
            else if ([[data objectForKey:@"watermark"] isEqualToString:@"watermark_location"]) {
                if (wprevious != nil) wpreviousstring = [wprevious objectForKey:@"location"];
                if (wnext != nil) wnextstring = [wnext objectForKey:@"location"];
                
                wtext = [instruction objectForKey:@"location"];
                wimage = nil;
                
            }
            
            float wstartopacity = 0;
            if ([wpreviousstring isEqualToString:wtext]) wstartopacity = 1.0;
            else wstartopacity = 0.0;
            
            float wendopacity = 0;
            if ([wnextstring isEqualToString:wtext]) wendopacity = 1.0;
            else wendopacity = 0.0;
    
            CATextLayer *watermarktext = [[CATextLayer alloc] init];
            [watermarktext setFont:@"Avenir-Black"];
            [watermarktext setFontSize:36];
            if (wimage == nil) [watermarktext setFrame:CGRectMake(30.0, 0.0, self.videoresize.width, 70.0)];
            else [watermarktext setFrame:CGRectMake(70.0, 0.0, self.videoresize.width, 70.0)];
            [watermarktext setString:wtext];
            [watermarktext setAlignmentMode:kCAAlignmentLeft];
            [watermarktext setOpacity:0.0];
            [watermarktext setForegroundColor:[[UIColor colorWithWhite:1.0 alpha:0.7] CGColor]];
            [watermarktext setBackgroundColor:[[UIColor clearColor] CGColor]];
            [watermark addSublayer:watermarktext];
            
            CAKeyframeAnimation *watermarkreveal = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
            watermarkreveal.values = @[@(wstartopacity), @(1.0), @(1.0), @(wendopacity)];
            watermarkreveal.keyTimes = @[@(0.0), @(0.1), @(0.9), @(1.0)];
            watermarkreveal.beginTime = watermarkbegin;
            watermarkreveal.duration = watermarkduration;
            watermarkreveal.removedOnCompletion = false;
            [watermarktext addAnimation:watermarkreveal forKey:[instruction objectForKey:@"label"]];
            
        }
        
    }
    
    CALayer *watermarklogo = [CALayer layer];
    [watermarklogo setContents:(id)wimage.CGImage];
    [watermarklogo setFrame:CGRectMake(20.0, 24.0, 40.0, 40.0)];
    [watermarklogo setOpacity:0.8];
    [watermarklogo setContentsGravity:kCAGravityResizeAspect];
    
    [watermark addSublayer:watermarklogo];
    [watermark setFrame:CGRectMake(0.0, 0.0, self.videoresize.width, 70.0)];
    [watermark setBackgroundColor:[UIColor clearColor].CGColor];
    [watermark setMasksToBounds:true];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    [parentLayer setFrame:CGRectMake(0, 0, self.videoresize.width, self.videoresize.height)];
    [parentLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [videoLayer setFrame:CGRectMake(0.0, 0.0, self.videoresize.width, self.videoresize.height)];
    [videoLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:watermark];
    
    return [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    
}

-(void)exportClipWithType:(id)type key:(NSString *)key completion:(void (^)(NSError* error))completion {
    NSString *videofilename;
    AVAsset *videoasset;
    BOOL videoslideshow = false;
    if ([type isKindOfClass:[UIImage class]]) {
        videofilename = [[NSBundle mainBundle]  pathForResource:@"Montage-Template" ofType:@"mov"];
        videoasset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videofilename]];
        videoslideshow = true;

    }
    else if ([type isKindOfClass:[NSURL class]]) {
        videoasset = [AVAsset assetWithURL:type];
        videoslideshow = false;
        
    }
    
    AVAssetTrack *videotrack = [[videoasset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    NSLog(@"self.videoseconds %f/%f frames %f" ,self.videoseconds ,CMTimeGetSeconds(videotrack.timeRange.duration) ,self.videoframes);
    CMTime videotime = CMTimeMakeWithSeconds(self.videoseconds, self.videoframes);
    AVMutableComposition *videocomposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *videoCompositionTrack = [videocomposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videotime) ofTrack:videotrack atTime: kCMTimeZero error:nil];
    
    AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videotrack];
    
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    [videoCompositionInstruction setTimeRange:CMTimeRangeMake(kCMTimeZero, videotime)];
    [videoCompositionInstruction setLayerInstructions:@[videolayerInstruction]];

    CALayer *imagelayer = [CALayer layer];
    if (videoslideshow) {
        int random = (arc4random() % 2);
        UIImage *slide = (UIImage *)type;
        [imagelayer setContents:(id)slide.CGImage];
        [imagelayer setFrame:CGRectMake(0.0, 0.0, self.videoresize.width, self.videoresize.height)];
        [imagelayer setOpacity:1.0];
        [imagelayer setContentsGravity:kCAGravityResizeAspectFill];
        [imagelayer setBackgroundColor:[UIColor blackColor].CGColor];
        [imagelayer setMasksToBounds:true];

        CABasicAnimation* panning = [CABasicAnimation animationWithKeyPath:@"position"];
        panning.fromValue = [NSValue valueWithCGPoint:CGPointMake(10, 0.0)];
        panning.toValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
        panning.additive = true;
        
        CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        scale.additive = true;
        if (random == 0) {
            scale.fromValue = [NSNumber numberWithFloat:0.03];
            scale.toValue = [NSNumber numberWithFloat:0.0];
        
        }
        else {
            scale.fromValue = [NSNumber numberWithFloat:0.0];
            scale.toValue = [NSNumber numberWithFloat:0.03];
            
        }
    
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[panning ,scale];
        group.duration = CMTimeGetSeconds(videotime);
        group.removedOnCompletion = false;
        group.beginTime = 1e-100;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [imagelayer addAnimation:group forKey:nil];
        
    }
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    [parentLayer setFrame:CGRectMake(0, 0, self.videoresize.width, self.videoresize.height)];
    [parentLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [videoLayer setFrame:parentLayer.bounds];
    [videoLayer setBackgroundColor:[UIColor orangeColor].CGColor];
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:imagelayer];

    NSLog(@"\n\nvideotime %f\n\n" ,(float)videotime.value);
    
    NSString *output = [APP_DOCUMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", key]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:output]) {
        [[NSFileManager defaultManager] removeItemAtPath:output error:nil];
        
    }
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = @[videoCompositionInstruction];
    mutableVideoComposition.frameDuration = CMTimeMake(1.0, self.videoframes);;
    mutableVideoComposition.renderSize = CGSizeMake(self.videoresize.width, self.videoresize.height);
    mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];;
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:videocomposition presetName:AVAssetExportPreset1920x1080];
    exporter.videoComposition = mutableVideoComposition;
    exporter.outputURL = [[NSURL alloc] initFileURLWithPath:output];
    exporter.outputFileType = AVFileTypeMPEG4;
    exporter.shouldOptimizeForNetworkUse = true;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            completion([NSError errorWithDomain:@"video created" code:200 userInfo:nil]);
            
        }
        else if (exporter.status == AVAssetExportSessionStatusFailed) completion(exporter.error);
        
    }];
    
}

@end
