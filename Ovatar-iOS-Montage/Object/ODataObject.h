//
//  ODataObject.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 31/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AVAssetTrack+Transform.h"
#import "ODataModel+CoreDataModel.h"
#import "OImageObject.h"

@protocol ODataDelegate;
@interface ODataObject : NSObject

@property (nonatomic, strong) id <ODataDelegate> delegate;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSPersistentContainer *persistancecont;
@property (nonatomic, strong) NSEntityDescription *stories;
@property (nonatomic, strong) NSEntityDescription *entry;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) NSMutableArray *importlist;

-(void)storyCreateWithData:(NSDictionary *)data completion:(void (^)(NSString *key, NSError *error))completion;
-(NSDictionary *)storyWithIdentifyer:(NSString *)key;
-(NSDictionary *)storyLatest;
-(NSString *)storyLatestKey;
-(NSDictionary *)storyActive;
-(NSString *)storyActiveKey;
-(NSArray *)storyEntries:(NSString *)key;
-(int)storyEntriesWithAssets:(NSString *)key;
-(NSArray *)storyEntriesPreviews:(NSString *)key;
-(int)storyExports;
-(void)storyDestoryWithKey:(NSString *)key;
-(void)storySetActive:(NSString *)story;
-(void)storyCreateVideo:(NSString *)story completion:(void (^)(NSString *file, NSError *error))completion;

-(void)entryCreate:(NSString *)story completion:(void (^)(NSError *error, NSString *key))completion;
-(void)entryAppendWithImageData:(PHAsset *)asset animated:(BOOL)animated orentation:(NSInteger)orentation entry:(NSString *)entry completion:(void (^)(NSError *error))completion;
-(void)entryExport:(NSString *)entry completion:(void (^)(NSError *error, NSURL *file))completion;
-(NSDictionary *)entryWithKey:(NSString *)key;
-(void)entryDestoryWithKey:(NSString *)key;

@end

@protocol ODataDelegate <NSObject>

@optional

-(void)dataImportUpdatedWithProgress:(float)progress;
-(void)dataImportCompleteWithError:(NSError *)error;

@end

