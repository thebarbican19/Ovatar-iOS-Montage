//
//  OImageObject.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OImageObject.h"
#import "OConstants.h"
#import "OExportObject.h"

@implementation OImageObject

+(OImageObject *)sharedInstance {
    static OImageObject *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OImageObject alloc] init];
        
        
    });
    
    return sharedInstance;
    
}

-(instancetype)init {
    self = [super init];
    if (self) {
    
    }
    
    return self;
    
}

-(void)imageAuthorization:(BOOL)request completion:(void (^)(PHAuthorizationStatus status))completion {
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        if (request) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                completion(authorizationStatus);
                
            }];
            
        }
        else completion([PHPhotoLibrary authorizationStatus]);
        
    }
    else completion([PHPhotoLibrary authorizationStatus]);
    
}

-(void)imageExportWithValue:(id)value location:(CLLocation *)location completion:(void (^)(NSError* error, NSString *asseid))completion {
    __block PHObjectPlaceholder *placeholder = nil;
    if ([value isKindOfClass:[NSURL class]]) {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest *new = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:value];
            new.location = location;
            new.creationDate = [NSDate date];
            new.favorite = true;
            placeholder = new.placeholderForCreatedAsset;
            
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) completion([NSError errorWithDomain:@"Exported" code:200 userInfo:nil], [placeholder localIdentifier]);
            else completion(error, nil);
            
        }];
        
    }
    else {
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            NSString *identifyer = (NSString *)value;
            PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifyer] options:nil];
            if (result.count > 0) {
                PHAssetChangeRequest *new = [PHAssetChangeRequest changeRequestForAsset:result.firstObject];
                new.location = location;
                placeholder = new.placeholderForCreatedAsset;

            }
            else {
                completion([NSError errorWithDomain:@"Asset does not exist" code:404 userInfo:nil], nil);
                
            }

        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) completion([NSError errorWithDomain:@"Exported" code:200 userInfo:nil], [placeholder localIdentifier]);
            else completion(error, nil);
            
        }];
        
    }
    
}

-(void)imageReturnFromAssetKey:(NSString *)key completion:(void (^)(PHAsset *asset))completion {
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:@[key] options:nil];
    if (result.count > 0) {
        PHAsset *asset = result.firstObject;
        completion(asset);
    
    }
    else completion(nil);
    
}

-(void)imageCreateAlbum {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *collection = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"Montage"];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        
    }];
    
}

-(void)imagesFromAsset:(PHAsset *)asset thumbnail:(BOOL)thumbnail completion:(void (^)(NSDictionary *exifdata, NSData *image))completion {
    PHImageRequestOptions  *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = thumbnail?PHImageRequestOptionsDeliveryModeOpportunistic:PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = true;
    options.networkAccessAllowed = true;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    [manager requestImageForAsset:asset targetSize:CGSizeMake(thumbnail?100.0:asset.pixelWidth, thumbnail?100.0:asset.pixelHeight) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage* image, NSDictionary *info) {
        if ([[info valueForKey:PHImageResultIsInCloudKey] boolValue]) {
            [manager requestImageDataForAsset:asset options:options resultHandler:^(NSData *imagedata, NSString * dataUTI, UIImageOrientation orientation, NSDictionary *options) {
                BOOL downloaded = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                if (downloaded) {
                    completion([self imageMetadata:imagedata], imagedata);
                    
                }
                else {
                    NSLog(@"Image downloading icloud %@" ,[self imageMetadata:imagedata]);
                    
                }
                
            }];
            
        }
        else {
            completion([self imageMetadata:UIImageJPEGRepresentation(image, 1.0)], UIImageJPEGRepresentation(image, 1.0));
            
        }
        
    }];
    
}

-(void)imageReturnFromDay:(NSDate *)day completion:(void (^)(NSArray *images))completion {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:day];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    NSDate *daystart = [[NSCalendar currentCalendar] dateFromComponents:components];
    
    components.hour = 23;
    components.minute = 59;
    components.second = 59;
    
    NSDate *dayend= [[NSCalendar currentCalendar] dateFromComponents:components];
    
    NSPredicate *predidate = [NSPredicate predicateWithFormat:@"creationDate >= %@ && creationDate <= %@" ,daystart, dayend];
    NSPredicate *mediatype = [NSPredicate predicateWithFormat:@"mediaType = %d", PHAssetMediaTypeImage];
    NSCompoundPredicate *compound = [NSCompoundPredicate andPredicateWithSubpredicates:@[predidate, mediatype]];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    options.predicate = compound;
    
    PHFetchResult *fetch = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    completion((NSArray *)fetch);
    
}

-(void)imageCreateEntryFromAsset:(PHAsset *)asset animate:(BOOL)animate key:(NSString *)key completion:(void (^)(NSError *error, BOOL animated))completion {
    OExportObject *exportobj = [[OExportObject alloc] init];
    exportobj.videoresize = CGSizeMake(1080, 1920);
    
    if ([asset isKindOfClass:[PHAsset class]]){
        NSString *path = [APP_DOCUMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", key]];
        NSURL *url = [NSURL fileURLWithPath:path];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            
        }
        
        PHImageRequestOptions  *imageoptions = [[PHImageRequestOptions alloc] init];
        imageoptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        imageoptions.synchronous = true;
        imageoptions.networkAccessAllowed = true;
        
        PHLivePhotoRequestOptions* liveoptions = [PHLivePhotoRequestOptions new];
        liveoptions.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        liveoptions.networkAccessAllowed = true;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageDataForAsset:asset options:imageoptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            [manager requestLivePhotoForAsset:asset targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) contentMode:PHImageContentModeDefault options:liveoptions resultHandler:^(PHLivePhoto * _Nullable livephoto, NSDictionary * _Nullable info) {
                if (livephoto) {
                    NSArray *resorces = [PHAssetResource assetResourcesForLivePhoto:livephoto];
                    PHAssetResource *output = nil;
                    for (PHAssetResource *resource in resorces) {
                        if (animate) {
                            if (resource.type == PHAssetResourceTypePairedVideo) {
                                output = resource;
                                break;
                                
                            }
                            
                        }
                        
                    }
                    
                    if (output.type == PHAssetResourceTypePairedVideo){
                        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:output toFile:url options:nil completionHandler:^(NSError * _Nullable error) {
//                            if (error.code == 200 || error == nil) {
//                                [exportobj exportClipWithType:url key:key completion:^(NSError *error) {
//                                    completion(error, false);
//
//                                }];
//
//                            }
//                            else completion(error, true);
                            completion(error, true);
                            
                        }];
                        
                    }
                    else {
                        [self imagesFromAsset:asset thumbnail:false completion:^(NSDictionary *exifdata, NSData *image) {
                            [exportobj exportClipWithType:[UIImage imageWithData:image] key:key completion:^(NSError *error) {
                                completion(error, false);
                                NSLog(@"imageCreateEntryFromStaticPhoto");
                                
                            }];
                            
                        }];
                        
                    }
                    
                }
                else {
                    [self imagesFromAsset:asset thumbnail:false completion:^(NSDictionary *exifdata, NSData *image) {
                        [exportobj exportClipWithType:[UIImage imageWithData:image] key:key completion:^(NSError *error) {
                            NSLog(@"imageCreateEntryFromStaticPhoto");
                            completion(error, false);
                            
                        }];
                        
                    }];
                    
                }
                
            }];
            
        }];
        
    }
    else completion([NSError errorWithDomain:@"" code:422 userInfo:nil], false);
    
}

-(void)imagesFromAlbum:(NSString *)album limit:(int)limit completion:(void (^)(NSArray *images))completion {
    NSMutableArray *images = [[NSMutableArray alloc] init];
    //NSMutableArray *dates = [[NSMutableArray alloc] init];
    NSMutableArray *sections = [[NSMutableArray alloc] init];

    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d || mediaType == %d", PHAssetMediaTypeVideo, PHAssetMediaTypeImage];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        if (limit == 0 || limit > images.count) {
            [images addObject:@{@"asset":asset, @"section":@""}];
        
        }

    }];
    
    [sections addObject:@{@"images":images, @"title":@"Camera Roll"}];
    
    completion(sections);
    
}

-(void)imagesFromLocationRadius:(CLLocation *)location radius:(float)radius completion:(void (^)(NSArray *images))completion {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    options.predicate = [NSPredicate predicateWithFormat:@"distanceToLocation:fromLocation:(%K,%@) < %f", location, radius];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [output addObject:obj];
        
    }];
    
    completion(output);
    
}

-(void)imagesFromFavorites:(void (^)(NSArray *images))completion {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d && favorite == true", PHAssetMediaTypeImage];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [output addObject:asset];
        
    }];
    
    completion(output);
    
}

-(NSDictionary*)imageMetadata:(NSData*)image {
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(image), NULL);
    if (imageSource) {
        NSDictionary *options = @{(NSString *)kCGImageSourceShouldCache:[NSNumber numberWithBool:NO]};
        CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, (__bridge CFDictionaryRef)options);
        if (imageProperties) {
            NSDictionary *metadata = (__bridge NSDictionary *)imageProperties;
            CFRelease(imageProperties);
            CFRelease(imageSource);
            return metadata;
            
        }
        
        CFRelease(imageSource);
        
    }
    
    return nil;
}

@end
