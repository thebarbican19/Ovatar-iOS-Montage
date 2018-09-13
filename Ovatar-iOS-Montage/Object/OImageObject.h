//
//  OImageObject.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

#import "ODataModel+CoreDataModel.h"

@protocol OImageDelegate;
@interface OImageObject : NSObject

@property (nonatomic, strong) id <OImageDelegate> delegate;

+(OImageObject *)sharedInstance;

-(void)imageAuthorization:(BOOL)request completion:(void (^)(PHAuthorizationStatus status))completion;
-(void)imagesFromAsset:(PHAsset *)asset thumbnail:(BOOL)thumbnail completion:(void (^)(NSDictionary *exifdata, NSData *image))completion;
-(void)imageReturnFromDay:(NSDate *)day completion:(void (^)(NSArray *images))completion;
-(void)imageCreateEntryFromAsset:(PHAsset *)asset animate:(BOOL)animate key:(NSString *)key completion:(void (^)(NSError* error, BOOL animated))completion;
-(void)imageExportWithValue:(id)value location:(CLLocation *)location completion:(void (^)(NSError* error, NSString *asseid))completion;
-(void)imageReturnFromAssetKey:(NSString *)key completion:(void (^)(PHAsset *asset))completion;

-(void)imagesFromAlbum:(NSString *)album limit:(int)limit completion:(void (^)(NSArray *images))completion;
-(void)imagesFromLocationRadius:(CLLocation *)location radius:(float)radius completion:(void (^)(NSArray *images))completion;
-(void)imagesFromFavorites:(void (^)(NSArray *images))completion;

@end

@protocol OImageDelegate <NSObject>

@optional

@end

