//
//  ODataObject.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 31/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "ODataObject.h"
#import "OConstants.h"

@implementation ODataObject

-(instancetype)init {
    self = [super init];
    if (self) {
        self.imageobj = [[OImageObject alloc] init];
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.persistancecont = [[NSPersistentContainer alloc] initWithName:@"ODataModel"];
        [self.persistancecont loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
            if (error != nil) NSLog(@"Couldn't load database: %@ - %@" ,error, description);
            
        }];
        
        self.context = self.persistancecont.viewContext;
        self.stories = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:self.context];
        self.entry = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:self.context];
        
    }
    
    return self;
    
}

-(void)storyDestoryWithKey:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,key];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    if (key != nil) fetch.predicate = predicate;
    
    for (Entry *entry in [self.context executeFetchRequest:fetch error:nil]) {
        [self.context deleteObject:entry];
        NSLog(@"entry deteted %@" ,self.context.deletedObjects);
        
    }
    
}

-(void)storyCreateWithData:(NSDictionary *)data completion:(void (^)(NSString *key, NSError *error))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@" ,[data objectForKey:@"name"]];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    if ([data objectForKey:@"name"] == nil) {
        completion(nil, [NSError errorWithDomain:@"Story start name is empty" code:422 userInfo:nil]);

    }
    else if ([self.context countForFetchRequest:fetch error:nil] > 0) {
        completion(nil, [NSError errorWithDomain:@"Story already created with that name" code:409 userInfo:nil]);
        
    }
    else {
        Story *newstory = [[Story alloc] initWithEntity:self.stories insertIntoManagedObjectContext:self.context];
        newstory.created = [NSDate date];
        newstory.name = [data objectForKey:@"name"];
        newstory.key = self.uniquekey;

        NSError *saveerr;
        if ([self.context save:&saveerr]) {
            [self storySetActive:newstory.key];
            
            completion(newstory.key, [NSError errorWithDomain:@"Story saved" code:200 userInfo:nil]);

        }
        else completion(nil, saveerr);
        
    }
    
}

-(NSDictionary *)storyWithIdentifyer:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,key];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    fetch.fetchLimit = 1;
    
    return [[self.context executeFetchRequest:fetch error:nil] firstObject];
    
}

-(NSDictionary *)storyLatest {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:true];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.sortDescriptors = @[sort];
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    fetch.fetchLimit = 1;
    
    return [[self.context executeFetchRequest:fetch error:nil] firstObject];
    
}

-(NSString *)storyLatestKey {
    return [self.storyLatest objectForKey:@"key"];
}

-(NSDictionary *)storyActive {
    return [self storyWithIdentifyer:self.storyActiveKey];
    
}

-(NSString *)storyActiveKey {
    return [self.data objectForKey:@"story_active_key"];
    
}

-(NSArray *)storyEntries:(NSString *)key {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"created" ascending:true];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"story == %@" ,key];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.sortDescriptors = @[sort];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    
    NSArray *entries = [self.context executeFetchRequest:fetch error:nil];
//    if (entries.count > 0) {
//        for (int i = 0; i < entries.count - 1; i++) {
//            //if ([[[entries objectAtIndex:i] objectForKey:@"assetid"] length] > 0) {
//                [output addObject:[entries objectAtIndex:i]];
//
//            //}
//
//        }
//
//        if ([[entries.lastObject objectForKey:@"assetid"] length] > 0) {
//            [self entryCreate:self.storyActiveKey completion:^(NSError *error, NSString *key) {
//                NSLog(@"error %@" ,error);
//                [output addObject:[self entryWithKey:key]];
//
//            }];
//
//            return output;
//
//        }
//        else {
//            return output;
//
//        }
//
//    }
//    else return output;
    
    return entries;

}

-(int)storyEntriesWithAssets:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"story == %@ && assetid != %@" ,key, @""];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    
    return (int)[self.context countForFetchRequest:fetch error:nil];
            
}

-(NSArray *)storyEntriesPreviews:(NSString *)key {
    NSMutableArray *identifyers = [[NSMutableArray alloc] init];
    NSMutableArray *output = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"story == %@ && assetid != %@" ,key, @""];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    
    for (NSDictionary *item in [self.context executeFetchRequest:fetch error:nil]) {
        if ([item objectForKey:@"assetid"] != nil && ![identifyers containsObject:[item objectForKey:@"assetid"]]) {
            [identifyers addObject:[item objectForKey:@"assetid"]];
            
        }
        
    }
    
    NSLog(@"identifyers %@" ,identifyers);
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:identifyers options:nil];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [output addObject:obj];
        
    }];

    return output;
    
}

-(int)storyExports {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exported == 1"];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    
    return (int)[self.context countForFetchRequest:fetch error:nil];
    
}

-(void)storySetActive:(NSString *)story {
    if (story == nil) [self.data removeObjectForKey:@"story_active_key"];
    else [self.data setObject:story forKey:@"story_active_key"];
    [self.data synchronize];
    
}

-(void)storyCreateVideo:(NSString *)story completion:(void (^)(NSString *file, NSError *error))completion {
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *videoCompositionTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    NSMutableArray *instructions = [[NSMutableArray alloc] init];
    
    //CGSize videosize = CGSizeMake(1080.0, 1920.0);
    CMTime videotime = kCMTimeZero;
    CGSize videosize = CGSizeZero;
    CGRect videoresize = CGRectMake(0.0, 0.0, 1080, 1920);
    CGFloat videoscale = 0.0;
    
    for (NSDictionary *item in [self storyEntries:story]) {
        NSString *filename = [NSString stringWithFormat:@"%@/%@.mov", APP_DOCUMENTS ,[item objectForKey:@"key"]];
        AVAsset *asset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filename]];
        
        if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] > 0) {
            AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
            NSError *videoError;
            [videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration)
                                           ofTrack:videoAssetTrack
                                            atTime:videotime
                                             error:&videoError];
            if (videoError) {
                NSLog(@"\\Video Error - %@", videoError.debugDescription);
                completion(nil, videoError);
                
            }
            
           
            //
            /*
            if (videoCompositionTrack.naturalSize.width < videoCompositionTrack.naturalSize.height) {
                videoscale = videoresize.width / videoCompositionTrack.naturalSize.width;
            }
            else {
                videoscale = videoresize.width / videoCompositionTrack.naturalSize.height;
            }
            
            CGSize scaledSize = CGSizeMake(videoCompositionTrack.naturalSize.width * videoscale, videoCompositionTrack.naturalSize.height * videoscale);
            CGPoint topLeft = CGPointMake(videoresize.width * 0.5 - scaledSize.width * 0.5, videosize.width  * .5 - scaledSize.height * .5);
            
            CGAffineTransform orientationTransform = videoAssetTrack.preferredTransform;
            if (orientationTransform.tx == videoCompositionTrack.naturalSize.width || orientationTransform.tx == videoCompositionTrack.naturalSize.height) {
                orientationTransform.tx = videoresize.width;
            }
            
            if (orientationTransform.ty == videoCompositionTrack.naturalSize.width || orientationTransform.ty == videoCompositionTrack.naturalSize.height) {
                orientationTransform.ty = videoresize.width;
            }
            
            CGAffineTransform transform = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformMakeScale(videoscale, videoscale),  CGAffineTransformMakeTranslation(topLeft.x, topLeft.y)), orientationTransform);
            */
            //
         
//            float imagescale = self.scale / image.size.width;
//            float imageheight = image.size.height * imagescale;
//            float imagewidth = image.size.width * imagescale;
//
            /*
            UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];
            
            CGAffineTransform t1 = CGAffineTransformIdentity;
            CGAffineTransform t2 = CGAffineTransformIdentity;
            
            switch (videoOrientation) {
                case UIImageOrientationUp:
                    t1 = CGAffineTransformMakeTranslation(1080, 1920);
                    t2 = CGAffineTransformRotate(t1, M_PI_2 );
                    NSLog(@"UIImageOrientationUp");
                    break;
                case UIImageOrientationDown:
                    t1 = CGAffineTransformMakeTranslation(0.0, cropWidth - cropOffY); // not fixed width is the real height in upside downvideoCompositionTrack                    t2 = CGAffineTransformRotate(t1, - M_PI_2 );
                    NSLog(@"UIImageOrientationDown");
                    break;
                case UIImageOrientationRight:
                    t1 = CGAffineTransformMakeTranslation(0 - cropOffX, 0 - cropOffY );
                    t2 = CGAffineTransformRotate(t1, 0 );
                    break;
                case UIImageOrientationLeft:
                    t1 = CGAffineTransformMakeTranslation(cropWidth - cropOffX, cropHeight - cropOffY );
                    t2 = CGAffineTransformRotate(t1, M_PI  );
                    break;
                default:
                    NSLog(@"no supported orientation has been found in this video");
                    break;
            }
            */
            
            CGRect cropRect = CGRectZero;
            CGSize naturalSize = CGSizeMake(videoCompositionTrack.naturalSize.height, videoCompositionTrack.naturalSize.width);
            
            cropRect = CGRectMake(0, 0, naturalSize.width, 1920);
            
            CGFloat cropOffX = cropRect.origin.x;
            CGFloat cropOffY = cropRect.origin.y;
            CGFloat cropWidth = cropRect.size.width;
            CGFloat cropHeight = cropRect.size.height;
            
            CGAffineTransform t1 = CGAffineTransformIdentity;
            CGAffineTransform t2 = CGAffineTransformIdentity;
            
            UIImageOrientation videoOrientation = [self getVideoOrientationFromAsset:asset];

            switch (videoOrientation) {
                case UIImageOrientationUp:
                    t1 = CGAffineTransformMakeTranslation(naturalSize.height, 0 - cropOffY );
                    t2 = CGAffineTransformRotate(t1, M_PI_2 );
                    break;
                case UIImageOrientationDown:
                    t1 = CGAffineTransformMakeTranslation(0 - cropOffX, naturalSize.height - cropOffY ); // not fixed width is the real height in upside down
                    t2 = CGAffineTransformRotate(t1, - M_PI_2 );
                    break;
                case UIImageOrientationRight:
                    t1 = CGAffineTransformMakeTranslation(0 - cropOffY, 0 - cropOffX );
                    t2 = CGAffineTransformRotate(t1, 0 );
                    break;
                case UIImageOrientationLeft:
                    t1 = CGAffineTransformMakeTranslation(naturalSize.width - cropOffX, naturalSize.height - cropOffY );
                    t2 = CGAffineTransformRotate(t1, M_PI );
                    break;
                default:
                    NSLog(@"no supported orientation has been found in this video");
                    break;
            }
            
            CGAffineTransform finalTransform = t2;
          
            //
            
            AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoAssetTrack];
            [videolayerInstruction setTransform:finalTransform atTime:kCMTimeZero];
            
            AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
            [videoCompositionInstruction setTimeRange:CMTimeRangeMake(videotime, videoAssetTrack.timeRange.duration)];
            [videoCompositionInstruction setLayerInstructions:@[videolayerInstruction]];
            
            videotime = CMTimeAdd(videotime, videoAssetTrack.timeRange.duration);
            videosize = CGSizeMake(videoresize.size.width, videoresize.size.height);
            
            [instructions addObject:videoCompositionInstruction];
            
        }
        
    }
    
    NSString *output = [NSString stringWithFormat:@"%@/%@_export.mov", APP_DOCUMENTS ,story];
    if ([[NSFileManager defaultManager] fileExistsAtPath:output]) {
        [[NSFileManager defaultManager] removeItemAtPath:output error:nil];
        
    }
    
    CATextLayer *watermarktext = [[CATextLayer alloc] init];
    [watermarktext setFont:@"Avenir-Heavy"];
    [watermarktext setFontSize:36];
    [watermarktext setFrame:CGRectMake(0.0, 0.0, videosize.width - 80.0, 70.0)];
    [watermarktext setString:@"ovatar.io"];
    [watermarktext setAlignmentMode:kCAAlignmentRight];
    [watermarktext setForegroundColor:[[UIColor colorWithWhite:1.0 alpha:0.7] CGColor]];
    [watermarktext setBackgroundColor:[[UIColor clearColor] CGColor]];
    
    CALayer *watermarklogo = [CALayer layer];
    [watermarklogo setContents:(id)[[UIImage imageNamed:@"logo_placeholder"] CGImage]];
    [watermarklogo setFrame:CGRectMake(videosize.width - (watermarktext.bounds.size.height + 10.0), 20.0, watermarktext.bounds.size.height,  watermarktext.bounds.size.height - 22.0)];
    [watermarklogo setContentsGravity:kCAGravityResizeAspect];
    
    CALayer *watermark = [CALayer layer];
    [watermark addSublayer:watermarktext];
    [watermark addSublayer:watermarklogo];
    [watermark setFrame:CGRectMake(0.0, 0.0, videosize.width, watermarktext.bounds.size.height)];
    [watermark setBackgroundColor:[UIColor clearColor].CGColor];
    [watermark setMasksToBounds:true];
    
    CALayer *parentLayer = [CALayer layer];
    CALayer *videoLayer = [CALayer layer];
    [parentLayer setFrame:CGRectMake(0, 0, videosize.width, videosize.height)];
    [parentLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [videoLayer setFrame:CGRectMake(20, 20, videosize.width - 40.0, videosize.height - 40.0)];
    [videoLayer setBackgroundColor:[UIColor clearColor].CGColor];
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:watermark];
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.instructions = instructions;
    mutableVideoComposition.frameDuration = CMTimeMake(1, 30);
    mutableVideoComposition.renderSize = videosize;
    mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool
                                             videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    exporter.videoComposition = mutableVideoComposition;
    exporter.outputURL = [[NSURL alloc] initFileURLWithPath:output];
    exporter.outputFileType = @"com.apple.quicktime-movie";
    exporter.shouldOptimizeForNetworkUse = true;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            completion(output, [NSError errorWithDomain:@"exported okay" code:200 userInfo:nil]);
            
        }
        else {
            NSLog(@"exporter.error %@" ,exporter.error);
            completion(nil, exporter.error);
            
        }
        
    }];
    
}

- (UIImageOrientation)getVideoOrientationFromAsset:(AVAsset *)asset
{
    AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize size = [videoTrack naturalSize];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    if (size.width == txf.tx && size.height == txf.ty)
        return UIImageOrientationLeft; //return UIInterfaceOrientationLandscapeLeft;
    else if (txf.tx == 0 && txf.ty == 0)
        return UIImageOrientationRight; //return UIInterfaceOrientationLandscapeRight;
    else if (txf.tx == 0 && txf.ty == size.width)
        return UIImageOrientationDown; //return UIInterfaceOrientationPortraitUpsideDown;
    else
        return UIImageOrientationUp;  //return UIInterfaceOrientationPortrait;
}

/*
-(NSArray *)storyDates:(NSString *)story {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,story];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    fetch.resultType = NSDictionaryResultType;

    NSDictionary *item = [[self.context executeFetchRequest:fetch error:nil] firstObject];
    if (item != nil) {
        NSDate *start = [item objectForKey:@"startdate"];
        NSDate *end = [item objectForKey:@"enddate"];
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:start toDate:end options:0];
        for (int i = 0; i < components.day; i++) {
            [dates addObject:[start dateByAddingTimeInterval:60*60*24*i]];
            
        }
        
        return dates;

    }
    else return nil;

}


-(void)entryAutoImport:(BOOL)initiate story:(NSString *)story {
    if (initiate) {
        self.importlist = [[NSMutableArray alloc] initWithArray:[self storyDates:story]];

    }
    
    if (self.importlist.count > 0) {
        [self.delegate dataImportUpdatedWithProgress:(100 / ([[self storyDates:story] count] - [self.importlist count]))];
        [self entryCreateWithDate:self.importlist.firstObject story:story completion:^(NSError *error) {
            [self.importlist removeObjectAtIndex:0];
            [self entryAutoImport:false story:story];
            
        }];
        
    }
    else [self.delegate dataImportCompleteWithError:[NSError errorWithDomain:@"import complete" code:200 userInfo:nil]];
    
}
*/

-(void)entryCreate:(NSString *)story completion:(void (^)(NSError *error, NSString *key))completion {
    if ([self storyWithIdentifyer:story] == nil) {
        completion([NSError errorWithDomain:@"Story does not exist" code:404 userInfo:nil], nil);

    }
    else {
        Entry *newentry = [[Entry alloc] initWithEntity:self.entry insertIntoManagedObjectContext:self.context];
        newentry.story = story;
        newentry.key = self.uniquekey;
        newentry.export = true;
        newentry.updated = [NSDate date];
        newentry.created = [NSDate date];

        NSError *saveerr;
        if ([self.context save:&saveerr]) {
            completion([NSError errorWithDomain:@"Entry saved" code:200 userInfo:nil], [newentry key]);
            
        }
        else completion(saveerr, nil);
        
    }
    
}

-(void)entryAppendWithImageData:(PHAsset *)asset animated:(BOOL)animated orentation:(NSInteger)orentation entry:(NSString *)entry completion:(void (^)(NSError *error))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,entry];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    
    if ([self.context countForFetchRequest:fetch error:nil] == 0) {
        [self.imageobj imageCreateEntryFromAsset:asset animate:animated key:entry completion:^(NSError *error, BOOL animated, NSInteger orentation) {
            if (error.code == 200) {
                Entry *existing = [[self.context executeFetchRequest:fetch error:nil] firstObject];
                existing.assetid = asset.localIdentifier;
                existing.animate = animated;
                existing.orentation = orentation;
                
                [self.context save:nil];
                
                completion([NSError errorWithDomain:@"Entry updated" code:200 userInfo:nil]);

            }
            else completion(error);
            
        }];
        
    }
    else {
        Entry *existing = [[self.context executeFetchRequest:fetch error:nil] firstObject];
        existing.assetid = asset.localIdentifier;
        existing.animate = animated;
        existing.orentation = orentation;

        if ([self.context save:nil]) {
            completion([NSError errorWithDomain:@"Entry updated" code:200 userInfo:nil]);
        
        }
        else {
            completion([NSError errorWithDomain:@"Entry not updated" code:409 userInfo:nil]);

        }
        
    }

}

-(NSDictionary *)entryWithKey:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,key];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    fetch.fetchLimit = 1;
    
    return [[self.context executeFetchRequest:fetch error:nil] firstObject];
    
}

-(void)entryDestoryWithKey:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"story == %@" ,key];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    if (key != nil) fetch.predicate = predicate;
    
    for (Entry *entry in [self.context executeFetchRequest:fetch error:nil]) {
        [self.context deleteObject:entry];
        
    }
    
}

-(NSString*)uniquekey {
    NSMutableString *output = [NSMutableString stringWithCapacity:20];
    for (int i = 0; i < 20; i++) {
        [output appendFormat:@"%C", (unichar)('a' + arc4random_uniform(26))];
    }
    
    return output;
    
}

@end
