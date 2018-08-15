//
//  OImageObject.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OImageObject.h"
#import "OConstants.h"

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

-(void)imageInformationFromEntry:(NSString *)key completion:(void (^)(NSString *captured, NSString *location))completion {
    
    
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

-(void)imageCreateEntryFromAsset:(PHAsset *)asset animate:(BOOL)animate key:(NSString *)key completion:(void (^)(NSError* error, BOOL animated, NSInteger orentation))completion {
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
                if (livephoto && animate) {
                    NSArray *resorces = [PHAssetResource assetResourcesForLivePhoto:livephoto];
                    NSLog(@"\n\nresorces: %@" ,resorces);
                    PHAssetResource *output = nil;
                    for (PHAssetResource *resource in resorces) {
                        if (resource.type == PHAssetResourceTypePairedVideo) {
                            output = resource;
                            break;
                            
                        }
                        
                    }
                    
                    if (output){
                        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:output toFile:url options:nil completionHandler:^(NSError * _Nullable error) {
                            completion(error, true, [self imageOrentation:orientation]);
                            
                        }];
                    }
                    else {
                        [self imagesFromAsset:asset thumbnail:false completion:^(NSDictionary *exifdata, NSData *image) {
                            [self imageCreateEntryFromStaticPhoto:[UIImage imageWithData:image] key:key completion:^(NSError *error) {
                                completion(error, false, [self imageOrentation:orientation]);
                                NSLog(@"imageCreateEntryFromStaticPhoto");
                                
                            }];

                        }];
                        
                    }
                    
                }
                else {
                    [self imagesFromAsset:asset thumbnail:false completion:^(NSDictionary *exifdata, NSData *image) {
                        [self imageCreateEntryFromStaticPhoto:[UIImage imageWithData:image] key:key completion:^(NSError *error) {
                            NSLog(@"imageCreateEntryFromStaticPhoto");
                            completion(error, false, [self imageOrentation:orientation]);

                        }];
                        
                    }];
                    
                }
                
            }];
            
        }];
        
    }
    else completion([NSError errorWithDomain:@"" code:422 userInfo:nil], false, 0);

}

-(void)imageCreateEntryFromStaticPhoto:(UIImage *)image key:(NSString *)key completion:(void (^)(NSError* error))completion {
    NSString *path = [APP_DOCUMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", key]];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSError *error = nil;
    
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:&error];
    NSDictionary *videoSettings = @{AVVideoCodecKey:AVVideoCodecTypeH264, AVVideoWidthKey:@(image.size.width), AVVideoHeightKey:@(image.size.height)};
    AVAssetWriterInput* writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];

    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    [videoWriter addInput:writerInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    [adaptor appendPixelBuffer:[self pixelBufferFromCGImage:image.CGImage] withPresentationTime:CMTimeMakeWithSeconds(0, 30.0)];
    [adaptor appendPixelBuffer:[self pixelBufferFromCGImage:image.CGImage] withPresentationTime:CMTimeMakeWithSeconds(1, 30.0)];

    [writerInput markAsFinished];
    [videoWriter finishWritingWithCompletionHandler:^{
        if (videoWriter.status != AVAssetWriterStatusFailed && videoWriter.status == AVAssetWriterStatusCompleted) {
            completion([NSError errorWithDomain:@"video created" code:200 userInfo:nil]);
            
        }
        else {
            completion(videoWriter.error);

        }
      
    }];

}

-(CVPixelBufferRef)pixelBufferFromCGImage: (CGImageRef) image {
    CGSize frameSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, frameSize.width, frameSize.height, kCVPixelFormatType_32BGRA, nil, &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    void *data = CVPixelBufferGetBaseAddress(pixelBuffer);
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, frameSize.width, frameSize.height, 8, CVPixelBufferGetBytesPerRow(pixelBuffer), rgbColorSpace, (CGBitmapInfo) kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    return pixelBuffer;
    
}

-(void)imagesFromAlbum:(NSString *)album completion:(void (^)(NSArray *images))completion {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:false]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d || mediaType == %d", PHAssetMediaTypeVideo, PHAssetMediaTypeImage];
    
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [output addObject:obj];
        
    }];
    
    completion(output);
    
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
        [output addObject:obj];
        
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

-(NSInteger)imageOrentation:(UIImageOrientation)orentation {
    if (orentation == UIImageOrientationUp) return 1;
    else if (orentation == UIImageOrientationDown) return 3;
    else if (orentation == UIImageOrientationLeft) return 8;
    else if (orentation == UIImageOrientationRight) return 6;
    else if (orentation == UIImageOrientationUpMirrored) return 2;
    else if (orentation == UIImageOrientationDownMirrored) return 4;
    else if (orentation == UIImageOrientationLeftMirrored) return 5;
    else return 7;
    
}

@end
