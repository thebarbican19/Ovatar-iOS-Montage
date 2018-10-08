//
//  OStatsObject.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 03/10/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OStatsObject.h"
#import "OConstants.h"

@implementation OStatsObject

+(OStatsObject *)sharedInstance {
    static OStatsObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OStatsObject alloc] init];
        
        
    });
    
    return sharedInstance;
    
}

-(instancetype)init {
    self = [super init];
    if (self) {
        if (@available(iOS 11.0, *)) {
            self.places = [[GoogLeNetPlaces alloc] init];
            self.foods = [[Food101 alloc] init];
            self.tags = [[Inceptionv3 alloc] init];
            
        }
    
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.geocoder = [[CLGeocoder alloc] init];
        self.persistancecont = [[NSPersistentContainer alloc] initWithName:@"ODataModel"];
        [self.persistancecont loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
            if (error != nil) NSLog(@"Couldn't load database: %@ - %@" ,error, description);
            
        }];
        
        self.context = self.persistancecont.viewContext;
        self.images = [NSEntityDescription entityForName:@"Images" inManagedObjectContext:self.context];
        
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.qualityOfService = NSQualityOfServiceUtility;
        self.queue.maxConcurrentOperationCount = 1;
        
    }
    
    return self;
    
}

-(void)initiate {
    [self setActive:true];
    [[OImageObject sharedInstance] imageAuthorization:false completion:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [[OImageObject sharedInstance] imagesFromAlbum:nil limit:0 completion:^(NSArray *images) {
                int total = (int)[[images.firstObject objectForKey:@"images"] count] - 1;
                for (int i = 0; i < total; i++) {
                    if (self.active) {
                        [self.queue addOperationWithBlock:^{
                            NSDictionary *item = [[images.firstObject objectForKey:@"images"] objectAtIndex:i];
                            PHAsset *asset = [item objectForKey:@"asset"];
                            if (![self imageStored:asset.localIdentifier]) {
                                [[OImageObject sharedInstance] imagesFromAsset:asset thumbnail:true completion:^(NSDictionary *exifdata, NSData *image) {
                                    NSString __block *city = nil;
                                    NSString __block *country = nil;
                                    NSString __block *state = nil;
                                    NSString __block *street = nil;
                                    
                                    [self.geocoder reverseGeocodeLocation:asset.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                        CLPlacemark *placemark = placemarks.firstObject;
                                        country = placemark.country;
                                        state = placemark.administrativeArea;
                                        street = placemark.thoroughfare;

                                        if (placemark.subLocality != nil) city = placemark.subLocality;
                                        else if (placemark.locality != nil) city = placemark.locality;
                                        
                                        Images *newimage = [[Images alloc] initWithEntity:self.images insertIntoManagedObjectContext:self.context];
                                        newimage.asset = asset.localIdentifier;
                                        newimage.captured = asset.creationDate;
                                        newimage.latitude = asset.location.coordinate.latitude;
                                        newimage.longitude = asset.location.coordinate.longitude;
                                        newimage.altitude = asset.location.altitude;
                                        newimage.type = [self imageType:asset];
                                        newimage.favorited = asset.favorite;
                                        newimage.hidden = asset.hidden;
                                        newimage.added = [NSDate date];
                                        newimage.city = city;
                                        newimage.country = country;
                                        newimage.state = state;
                                        newimage.street = street;
                                        newimage.lastphototime = [self statsLastPhotoSeconds:asset];
                                        newimage.tags = [self statsRecongizedTags:image];
                                        newimage.scene = [self statsRecongizedScenes:image];
                                        newimage.food = [self statsRecongisedFood:image];

                                        NSLog(@"saving: %@" ,newimage);
                                        [self.context save:nil];
                                        
                                    }];
                                    
                                }];
                                
                            }
                            
                        }];
                        
                    }
                    
                }
                
            }];
            
            [self.queue addObserver:self forKeyPath:@"operations" options:0 context:@"kQueueOperationsChanged"];
            
        }
        
    }];

}

-(void)suspend {
    [self setActive:false];
    [self.queue cancelAllOperations];
    
}

-(double)statsLastPhotoSeconds:(PHAsset *)current {
    NSDictionary *lastphoto = [[NSDictionary alloc] initWithDictionary:self.stored.firstObject];
    NSDate *lastdate = [lastphoto objectForKey:@"captured"];
    
    return (double)[lastdate timeIntervalSinceDate:current.creationDate];
    
}

-(NSString *)statsRecongizedTags:(NSData *)image {
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    NSError *error;
    CGImageRef scaled = [self imageScale:[UIImage imageWithData:image] scale:299];
    CVPixelBufferRef reference = [self imageBuffer:scaled scale:299];
    
    Inceptionv3Input *tagsinput = [[Inceptionv3Input alloc] initWithImage:reference];
    Inceptionv3Output *tagsoutput = [self.tags predictionFromFeatures:tagsinput error:&error];
    
    for (NSString *key in tagsoutput.classLabelProbs.allKeys) {
        if ([[tagsoutput.classLabelProbs objectForKey:key] floatValue] > 0.7) {
            [objects addObject:key];

        }
        
    }
    
    return [objects componentsJoinedByString:@","];
    
}

-(NSString *)statsRecongizedScenes:(NSData *)image {
    NSError *error;
    CGImageRef scaled =[self imageScale:[UIImage imageWithData:image] scale:224];
    CVPixelBufferRef reference = [self imageBuffer:scaled scale:224];
    
    GoogLeNetPlacesInput *placesinput = [[GoogLeNetPlacesInput alloc] initWithSceneImage:reference];
    GoogLeNetPlacesOutput *placesoutput = [self.places predictionFromFeatures:placesinput error:&error];
    
    NSLog(@"Scenes: %@ Probs : %f" ,[placesoutput sceneLabel] ,[[placesoutput.sceneLabelProbs valueForKey:placesoutput.sceneLabel] floatValue])
    
    if ([[placesoutput.sceneLabelProbs valueForKey:placesoutput.sceneLabel] floatValue] < 0.5) return nil;
    else return placesoutput.sceneLabel;
    
}

-(NSString *)statsRecongisedFood:(NSData *)image {
    NSError *error;
    CGImageRef scaled =[self imageScale:[UIImage imageWithData:image] scale:299];
    CVPixelBufferRef reference = [self imageBuffer:scaled scale:299];
    
    Food101Input *foodinput = [[Food101Input alloc] initWithImage:reference];
    Food101Output *foodoutput = [self.foods predictionFromFeatures:foodinput error:&error];
    
    if ([[foodoutput.foodConfidence valueForKey:foodoutput.classLabel] floatValue] < 0.5) return nil;
    else return foodoutput.classLabel;

}

-(NSString *)imageType:(PHAsset *)asset {
    if (asset != nil) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return @"livephoto";
            else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoPanorama) return @"panorama";
            else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoScreenshot) return @"screenshot";
            else if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoDepthEffect) return @"portrait";

            else return @"image";
            
        }
        else return @"video";
        
    }
    else return @"";
    
}

-(CGImageRef)imageScale:(UIImage *)image scale:(int)scale {
    float height = image.size.height * scale;
    float width = image.size.width * scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage.CGImage;
    
}

-(CVPixelBufferRef)imageBuffer:(CGImageRef)image scale:(int)scale {
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@(true), kCVPixelBufferCGImageCompatibilityKey, @(true), kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          scale,
                                          scale,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, scale, scale, 8, CVPixelBufferGetBytesPerRow(pxbuffer), space, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0, 0, scale, scale), image);
    CGColorSpaceRelease(space);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
    
    
}

-(NSArray *)stored {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"captured" ascending:false];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
    fetch.sortDescriptors = @[sort];
    fetch.returnsDistinctResults = true;
    fetch.resultType = NSDictionaryResultType;
    
    return [self.context executeFetchRequest:fetch error:nil];
    
}

-(BOOL)imageStored:(NSString *)asset {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"asset == %@" ,asset];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    if ([self.context countForFetchRequest:fetch error:nil] > 0) return true;
    else return false;
    
}

-(int)capturesTotal {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type != %@ && type != %@)" ,@"screenshot", @"video"];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    return (int)[self.context countForFetchRequest:fetch error:nil];
    
}

-(NSArray *)capturesByMonth:(int)month {
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange daysinmonth = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:today];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond|NSCalendarUnitYear fromDate:today];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    components.month = month;
    components.day = 1;
    components.year = components.year;

    NSDate *daystart = [calendar dateFromComponents:components];
    
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    components.month = components.month;
    components.day = daysinmonth.length;
    components.year = components.year;
    
    NSDate *dayend= [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSLog(@"Days between : %@ - %@" ,daystart, dayend);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(type != %@ && type != %@) && (captured >= %@ && captured <= %@)" ,@"screenshot", @"video", daystart, dayend];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    fetch.resultType = NSDictionaryResultType;

    return [self.context executeFetchRequest:fetch error:nil];
    
}

-(int)capturesThisMonth {
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:today];
    
    return (int)[[self capturesByMonth:(int)components.month] count];

}

-(int)capturesLastMonth {
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:today];
    
    return (int)[[self capturesByMonth:(int)components.month - 1] count];
    
}

-(NSArray *)visitedCountries {
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(country != %@)" ,nil];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    fetch.resultType = NSDictionaryResultType;

    for (NSDictionary *item in [self.context executeFetchRequest:fetch error:nil]) {
        if (![locations containsObject:[item objectForKey:@"country"]]) {
            [locations addObject:[item objectForKey:@"country"]];
            
        }
        
    }
    
    return locations;
    
}

-(NSArray *)vistedUnescoSites {
    NSMutableArray *sites = [[NSMutableArray alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Unesco" ofType:@"json"];
    NSArray *content = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:0 error:nil] objectForKey:@"locations"];
    
    for (NSDictionary *place in content) {
        float unescolatitude = [[place objectForKey:@"latitude"] floatValue];
        float unescolongitude = [[place objectForKey:@"longitude"] floatValue];
        CLLocation *unescolocation = [[CLLocation alloc] initWithLatitude:unescolatitude longitude:unescolongitude];

        for (NSDictionary *item in self.stored) {
            float imagelatitude = [[item objectForKey:@"latitude"] floatValue];
            float imagelongitude = [[item objectForKey:@"longitude"] floatValue];
            CLLocation *imageslocation = [[CLLocation alloc] initWithLatitude:imagelatitude longitude:imagelongitude];
            CLLocationDistance distance = [imageslocation distanceFromLocation:unescolocation];
            
            if ((distance / 1609.344) < 1.5) {
                [sites addObject:[place objectForKey:@"site"]];
                break;
                
            }
            
        }
        
    }
    
    return sites;
    
}

-(NSString *)favoritePlace {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:false];
    NSMutableArray *places = [[NSMutableArray alloc] init];
    NSMutableArray *merged = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(state != %@ && country != %@)" ,nil ,nil];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    fetch.resultType = NSDictionaryResultType;
    
    for (NSDictionary *item in [self.context executeFetchRequest:fetch error:nil]) {
        [places addObject:@{@"state":[item objectForKey:@"state"],
                            @"country":[item objectForKey:@"country"]}];
        
    }
    
    NSCountedSet *counted = [[NSCountedSet alloc] initWithArray:places];
    for (NSDictionary *locations in counted) {
        NSMutableDictionary *append = [[NSMutableDictionary alloc] init];
        [append addEntriesFromDictionary:locations];
        [append setObject:@([counted countForObject:locations]) forKey:@"count"];
        
        [merged addObject:append];
    }
    
    NSDictionary *output = [[merged sortedArrayUsingDescriptors:@[sort]] firstObject];
    NSLog(@"Country: %@" ,output);

    return [NSString stringWithFormat:@"%@, %@" ,[output objectForKey:@"state"], [output objectForKey:@"country"]];

}

-(NSString *)favoriteFood {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:false];
    NSMutableArray *food = [[NSMutableArray alloc] init];
    NSMutableArray *merged = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"food != %@" ,nil];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    fetch.resultType = NSDictionaryResultType;
    
    for (NSDictionary *item in [self.context executeFetchRequest:fetch error:nil]) {
        [food addObject:@{@"food":[item objectForKey:@"food"]}];
        
    }
    
    NSCountedSet *counted = [[NSCountedSet alloc] initWithArray:food];
    for (NSDictionary *locations in counted) {
        NSMutableDictionary *append = [[NSMutableDictionary alloc] init];
        [append addEntriesFromDictionary:locations];
        [append setObject:@([counted countForObject:locations]) forKey:@"count"];
        
        [merged addObject:append];
    }
    
    NSDictionary *output = [[merged sortedArrayUsingDescriptors:@[sort]] firstObject];
    NSLog(@"Food: %@" ,output);
    
    return [NSString stringWithFormat:@"%@" ,[output objectForKey:@"food"]];
    
}

-(NSArray *)tagsFromAssetKeys:(NSArray *)tags {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"asset IN %@" ,tags];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Images"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    fetch.resultType = NSDictionaryResultType;
    
    NSLog(@"items %@" ,[self.context executeFetchRequest:fetch error:nil]);
    
    for (NSDictionary *data in [self.context executeFetchRequest:fetch error:nil]) {
        NSString *tag = nil;
        NSDateFormatter *year = [[NSDateFormatter alloc] init];
        year.dateFormat = @"yyyy";
        NSDateFormatter *month = [[NSDateFormatter alloc] init];
        month.dateFormat = @"MMMM";
        
        if (![output containsObject:[year stringFromDate:[data objectForKey:@"captured"]]]) {
            [output addObject:[year stringFromDate:[data objectForKey:@"captured"]]];
            
        }
        
        if (![output containsObject:[month stringFromDate:[data objectForKey:@"captured"]]]) {
            [output addObject:[month stringFromDate:[data objectForKey:@"captured"]]];
            
        }
        
        if ([data objectForKey:@"city"] != nil) {
            tag = [data objectForKey:@"city"];
            if (![output containsObject:tag]) [output addObject:tag];
            
        }
        
        if ([data objectForKey:@"food"] != nil) {
            tag = [data objectForKey:@"food"];
            if (![output containsObject:tag]) [output addObject:tag];
        
        }
        
        if ([data objectForKey:@"state"] != nil) {
            tag = [data objectForKey:@"state"];
            if (![output containsObject:tag]) [output addObject:tag];
            
        }
        
        if ([data objectForKey:@"country"] != nil) {
            tag = [data objectForKey:@"country"];
            if (![output containsObject:tag]) [output addObject:tag];
            
        }

        if ([data objectForKey:@"scene"] != nil) {
            tag = [data objectForKey:@"scene"];
            if (![output containsObject:tag]) [output addObject:tag];
            
        }
        
        if ([[[data objectForKey:@"tags"] componentsSeparatedByString:@","] count] > 0) {
            for (NSString *tag in [[data objectForKey:@"tags"] componentsSeparatedByString:@","]) {
                if (![output containsObject:tag] && [tag length] > 0) [output addObject:tag];
                
            }
            
        }
        
    }
    
    return output;
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self.queue && [keyPath isEqualToString:@"operations"]) {
        if ([self.queue.operations count] == 0) {
            NSLog(@"queue has completed");
            
        }
        
    }
    else [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];

}

@end
