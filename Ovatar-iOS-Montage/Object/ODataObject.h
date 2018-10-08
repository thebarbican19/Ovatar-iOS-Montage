//
//  ODataObject.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 31/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ODataModel+CoreDataModel.h"
#import "OImageObject.h"

typedef enum {
    ODataMusicTypeBundle,
    ODataMusicTypeIPod,
    ODataMusicTypeFiles
    
} ODataMusicType;

@protocol ODataDelegate;
@interface ODataObject : NSObject

@property (nonatomic, strong) id <ODataDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPersistentContainer *persistancecont;
@property (nonatomic, strong) NSEntityDescription *stories;
@property (nonatomic, strong) NSEntityDescription *entry;
@property (nonatomic, strong) NSEntityDescription *music;

@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) NSMutableArray *importlist;

-(void)storyCreateWithData:(NSDictionary *)data completion:(void (^)(NSString *key, NSError *error))completion;
-(NSDictionary *)storyWithKey:(NSString *)key;
-(NSDictionary *)storyLatest;
-(NSString *)storyLatestKey;
-(NSDictionary *)storyActive;
-(NSString *)storyActiveName;
-(NSString *)storyActiveKey;
-(NSURL *)storyDirectory:(NSString *)story;
-(NSArray *)storyEntries:(NSString *)key;
-(NSArray *)storyAssetKeys:(NSString *)key;
-(int)storyEntriesWithAssets:(NSString *)key;
-(BOOL)storyContainsAssets:(NSString *)key asset:(NSString *)asset;
-(NSArray *)storyEntriesPreviews:(NSString *)key;
-(CLLocation *)storyCentralLocation:(NSString *)key;
-(int)storyExports;
-(void)storyDestoryWithKey:(NSString *)key;
-(void)storySetActive:(NSString *)story;
-(void)storyExport:(NSString *)story completion:(void (^)(NSError *error))completion;
-(void)storyAppendSpeed:(NSString *)story speed:(float)speed completion:(void (^)(NSError *error))completion;
-(void)storyAppendName:(NSString *)story name:(NSString *)name completion:(void (^)(NSError *error))completion;
-(void)storyAppendWatermark:(NSString *)story watermark:(NSString *)watermark completion:(void (^)(NSError *error))completion;
-(void)storyAppendMusic:(NSString *)story music:(NSString *)music completion:(void (^)(NSError *error))completion;

-(void)musicCreate:(NSString *)story music:(NSDictionary *)music type:(ODataMusicType)type completion:(void (^)(NSError *error))completion;
-(NSDictionary *)musicActive;
-(NSArray *)musicImported;

-(void)entryCreate:(NSString *)story assets:(NSArray *)assets completion:(void (^)(NSError *error, NSArray *keys))completion;
-(void)entryAppendWithImageData:(PHAsset *)asset animated:(BOOL)animated entry:(NSString *)entry completion:(void (^)(NSError *error))completion;
-(void)entryAppendOrderSource:(NSDictionary *)source replace:(NSDictionary *)replace;
-(void)entryAppendAnimation:(NSString *)entry asset:(PHAsset *)asset completion:(void (^)(NSError *error, BOOL enabled))completion;
-(NSDictionary *)entryWithKey:(NSString *)key;
-(void)entryDestoryWithKey:(NSString *)key;

@end

@protocol ODataDelegate <NSObject>

@optional

-(void)dataImportUpdatedWithProgress:(float)progress;
-(void)dataImportCompleteWithError:(NSError *)error;

@end

