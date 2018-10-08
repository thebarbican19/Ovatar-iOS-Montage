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
        self.geocoder = [[CLGeocoder alloc] init];
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        self.persistancecont = [[NSPersistentContainer alloc] initWithName:@"ODataModel"];
        [self.persistancecont loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *description, NSError *error) {
            if (error != nil) NSLog(@"Couldn't load database: %@ - %@" ,error, description);
            
        }];
        
        self.context = self.persistancecont.viewContext;
        self.stories = [NSEntityDescription entityForName:@"Story" inManagedObjectContext:self.context];
        self.entry = [NSEntityDescription entityForName:@"Entry" inManagedObjectContext:self.context];
        self.music = [NSEntityDescription entityForName:@"Music" inManagedObjectContext:self.context];

    }
    
    return self;
    
}

-(void)storyDestoryWithKey:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,key];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    if (key != nil) fetch.predicate = predicate;
    
    for (Entry *entry in [self.context executeFetchRequest:fetch error:nil]) {
        [self.context deleteObject:entry];
        
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
        NSString *newkey = self.uniquekey;
        Story *newstory = [[Story alloc] initWithEntity:self.stories insertIntoManagedObjectContext:self.context];
        newstory.created = [NSDate date];
        newstory.name = [data objectForKey:@"name"];
        newstory.key = newkey;
        newstory.assetid = @"";
        newstory.speed = 0.8;
        newstory.watermark = @"watermark_default";

        NSError *saveerr;
        if ([self.context save:&saveerr]) {
            [self storySetActive:newkey];
            completion(newkey, [NSError errorWithDomain:@"Story saved" code:200 userInfo:nil]);

        }
        else completion(nil, saveerr);
        
    }
    
}

-(NSDictionary *)storyWithKey:(NSString *)key {
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
    return [self storyWithKey:self.storyActiveKey];
    
}

-(NSString *)storyActiveName {
    if ([self.storyActive objectForKey:@"name"] != nil) return [self.storyActive objectForKey:@"name"];
    else return [NSString stringWithFormat:NSLocalizedString(@"Default_Project_Name", nil), 1];
    
}

-(NSURL *)storyDirectory:(NSString *)story {
    return [NSURL fileURLWithPath:[APP_DOCUMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_export.mov", story]]];
    
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
    fetch.returnsDistinctResults = true;
    fetch.resultType = NSDictionaryResultType;

    NSArray *entrys = [self.context executeFetchRequest:fetch error:nil];
    for (NSDictionary *entry in entrys) {
        if ([[entry objectForKey:@"assetid"] length] > 0 || [entrys.lastObject isEqual:entry]) {
            NSMutableDictionary *formatted = [[NSMutableDictionary alloc] init];
            for (NSString *key in entry.allKeys) {
                if (![[entry objectForKey:key] isEqual:[NSNull null]]) {
                    [formatted setObject:[entry objectForKey:key] forKey:key];
                    
                }
                
            }
            
            [output addObject:formatted];
            
        }
        else {
            NSString *key = [NSString stringWithFormat:@"%@" ,[entry objectForKey:@"key"]];
            NSString *path = [APP_DOCUMENTS stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mov", key]];
            if ([self storyEntry:[entry objectForKey:@"key"]] != nil) {
                [self.context deleteObject:[self storyEntry:[entry objectForKey:@"key"]]];
                
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                    
                }
                
            }
            else if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [self.context deleteObject:[self storyEntry:[entry objectForKey:@"key"]]];

            }
            
        }
        
    }
    
    if ([[entrys.lastObject objectForKey:@"assetid"] length] > 0) {
        [self entryCreate:self.storyActiveKey assets:nil completion:^(NSError *error, NSArray *keys) {
            [output addObject:[self entryWithKey:keys.firstObject]];
            
        }];
        
    }
    
    return output;
    
}

-(NSArray *)storyAssetKeys:(NSString *)key {
    NSMutableArray *output = [[NSMutableArray alloc] init];
    for (NSDictionary *entry in [self storyEntries:key]) {
        [output addObject:[entry objectForKey:@"assetid"]];
        
    }
    
    return output;
    
}

-(int)storyEntriesWithAssets:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"story == %@ && assetid != %@" ,key, @""];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    
    return (int)[self.context countForFetchRequest:fetch error:nil];
            
}

-(BOOL)storyContainsAssets:(NSString *)key asset:(NSString *)asset {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"story == %@ && assetid == %@" ,key, asset];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
    fetch.returnsDistinctResults = true;
    
    if ([self.context countForFetchRequest:fetch error:nil] > 0) return true;
    else return false;
    
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
    
    PHFetchResult *result = [PHAsset fetchAssetsWithLocalIdentifiers:identifyers options:nil];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [output addObject:obj];
        
    }];

    return output;
    
}

-(void)storyExport:(NSString *)story completion:(void (^)(NSError *error))completion {
    CLLocation *location = [self storyCentralLocation:story];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,story];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    Story *astory = [[self.context executeFetchRequest:fetch error:nil] firstObject];
    id value = nil;
    if (astory.assetid.length == 0) value = [self storyDirectory:self.storyActiveKey];
    else value = astory.assetid;
    
    if (value != nil) {
        [self.imageobj imageExportWithValue:value location:location completion:^(NSError *error, NSString *asseid) {
            if (error == nil || error.code == 200) {
                astory.assetid = asseid;
                astory.exported = [NSDate date];
                
                [self.context save:nil];

                completion([NSError errorWithDomain:@"Exported" code:200 userInfo:nil]);

            }
            else {
                if (error.code == 404) {
                    [self.imageobj imageExportWithValue:[self storyDirectory:self.storyActiveKey] location:location completion:^(NSError *error, NSString *asseid) {
                        astory.assetid = asseid;
                        astory.exported = [NSDate date];
                        
                        [self.context save:nil];
                        
                        completion([NSError errorWithDomain:@"Exported" code:200 userInfo:nil]);
                        
                    }];
                    
                }
                else completion(error);
                
            }
            
        }];
        
    }
   
}

-(void)storyAppendSpeed:(NSString *)story speed:(float)speed completion:(void (^)(NSError *error))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,story];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    Story *astory = [[self.context executeFetchRequest:fetch error:nil] firstObject];
    astory.speed = speed;
    
    NSError *saveerr;
    if ([self.context save:&saveerr]) {
        completion([NSError errorWithDomain:@"Exported" code:200 userInfo:nil]);

    }
    else completion(saveerr);

}

-(void)storyAppendName:(NSString *)story name:(NSString *)name completion:(void (^)(NSError *error))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@ || name != %@" ,story ,name];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    if ([self.context countForFetchRequest:fetch error:nil] > 0) {
        Story *astory = [[self.context executeFetchRequest:fetch error:nil] firstObject];
        astory.name = name;
    
        NSError *saveerr;
        if ([self.context save:&saveerr]) {
            completion([NSError errorWithDomain:@"Updated" code:200 userInfo:nil]);
            
        }
        else completion(saveerr);
        
    }
    else completion([NSError errorWithDomain:@"story does not exits" code:404 userInfo:nil]);
   
}

-(void)storyAppendWatermark:(NSString *)story watermark:(NSString *)watermark completion:(void (^)(NSError *error))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,story];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    if ([self.context countForFetchRequest:fetch error:nil] > 0) {
        Story *astory = [[self.context executeFetchRequest:fetch error:nil] firstObject];
        astory.watermark = watermark;
        
        NSError *saveerr;
        if ([self.context save:&saveerr]) {
            completion([NSError errorWithDomain:@"Updated" code:200 userInfo:nil]);
            
        }
        else completion(saveerr);
        
    }
    else completion([NSError errorWithDomain:@"story does not exits" code:404 userInfo:nil]);
    
}

-(void)storyAppendMusic:(NSString *)story music:(NSString *)music completion:(void (^)(NSError *error))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,story];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    if ([self.context countForFetchRequest:fetch error:nil] > 0) {
        Story *astory = [[self.context executeFetchRequest:fetch error:nil] firstObject];
        astory.music = music;
        
        NSError *saveerr;
        if ([self.context save:&saveerr]) {
            completion([NSError errorWithDomain:@"Updated" code:200 userInfo:nil]);
            
        }
        else completion(saveerr);
        
    }
    else completion([NSError errorWithDomain:@"story does not exits" code:404 userInfo:nil]);
    
}

-(CLLocation *)storyCentralLocation:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"story == %@" ,key];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    fetch.resultType = NSDictionaryResultType;
  
    float maxLat = -200;
    float maxLong = -200;
    float minLat = MAXFLOAT;
    float minLong = MAXFLOAT;
    
    for (NSDictionary *entry in [self.context executeFetchRequest:fetch error:nil]) {
        float latitude = [[entry objectForKey:@"latitude"] floatValue];
        float longitude = [[entry objectForKey:@"longitude"] floatValue];
        
        if (latitude != 0 && longitude != 0) {
            if (latitude < minLat) minLat = latitude;
            if (longitude < minLong) minLong = longitude;
            if (latitude > maxLat) maxLat = latitude;
            if (longitude > maxLong) maxLong = longitude;
            
        }
        
    }
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((maxLat + minLat) * 0.5, (maxLong + minLong) * 0.5);
    return [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    
}

-(int)storyExports {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"exported != %@", nil];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    return (int)[self.context countForFetchRequest:fetch error:nil];
    
}

-(void)storySetActive:(NSString *)story {
    if (story == nil) [self.data removeObjectForKey:@"story_active_key"];
    else [self.data setObject:story forKey:@"story_active_key"];
    [self.data synchronize];
    
}

-(Entry *)storyEntry:(NSString *)key {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,key];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;
    
    return [[self.context executeFetchRequest:fetch error:nil] firstObject];
    
}

-(void)musicCreate:(NSString *)story music:(NSDictionary *)music type:(ODataMusicType)type completion:(void (^)(NSError *error))completion {
    NSString *file = [NSString stringWithFormat:@"%@" ,[music objectForKey:@"file"]];
    NSString *key = self.uniquekey;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"file == %@ && type == %@" ,file ,[self musicType:type]];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Music"];
    fetch.predicate = predicate;
    fetch.returnsDistinctResults = true;

    if ([self storyWithKey:story] != nil && music != nil) {
        if ([[self.context executeFetchRequest:fetch error:nil] count] > 0) {
            Music *newmusic = [[self.context executeFetchRequest:fetch error:nil] firstObject];
            newmusic.added = [NSDate date];
            newmusic.bpm = [[music objectForKey:@"bpm"] intValue];
            newmusic.name = [music objectForKey:@"title"];
            newmusic.artist = [music objectForKey:@"artist"];
            
            key = newmusic.key;

        }
        else {
            Music *newmusic = [[Music alloc] initWithEntity:self.music insertIntoManagedObjectContext:self.context];
            newmusic.key = key;
            newmusic.added = [NSDate date];
            newmusic.type = [self musicType:type];
            newmusic.file = file;;
            newmusic.name = [music objectForKey:@"title"];
            newmusic.artist = [music objectForKey:@"artist"];
            newmusic.bpm = [[music objectForKey:@"bpm"] intValue];
            
            NSLog(@"music type: %@" ,newmusic);
        }
        
        NSError *saveerr;
        if ([self.context save:&saveerr]) {
            [self storyAppendMusic:self.storyActiveKey music:key completion:^(NSError *error) {
                completion(error);

            }];
            
        }
        else completion(saveerr);
        
    }
    else completion([NSError errorWithDomain:@"Story does not exist" code:404 userInfo:nil]);
    
}

-(NSString *)musicType:(ODataMusicType)type {
    if (type == ODataMusicTypeIPod) return @"ipod";
    else if (type == ODataMusicTypeBundle) return @"bundle";
    else if (type == ODataMusicTypeFiles) return @"files";
    else return nil;
}

-(NSDictionary *)musicActive {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:true];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,[self.storyActive objectForKey:@"music"]];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Music"];
    fetch.resultType = NSDictionaryResultType;
    fetch.sortDescriptors = @[sort];
    fetch.returnsDistinctResults = true;
    fetch.predicate = predicate;
    fetch.fetchLimit = 1;

    return [[self.context executeFetchRequest:fetch error:nil] firstObject];

}

-(NSArray *)musicImported {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"added" ascending:true];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type != %@" ,[self musicType:ODataMusicTypeBundle]];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Music"];
    fetch.resultType = NSDictionaryResultType;
    fetch.sortDescriptors = @[sort];
    fetch.returnsDistinctResults = true;
    fetch.predicate = predicate;
    
    return [self.context executeFetchRequest:fetch error:nil];
    
}

-(void)entryCreate:(NSString *)story assets:(NSArray *)assets completion:(void (^)(NSError *error, NSArray *keys))completion {
    NSMutableArray *added = [[NSMutableArray alloc] init];
    int created = 0.0;
    if ([self storyWithKey:story] == nil) {
        completion([NSError errorWithDomain:@"Story does not exist" code:404 userInfo:nil], nil);

    }
    else {
        CLLocation *location = [self storyCentralLocation:story];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,story];
        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Story"];
        fetch.predicate = predicate;
        fetch.returnsDistinctResults = true;
        
        if ([[self.context executeFetchRequest:fetch error:nil] count] > 0) {
            Story *astory = [[self.context executeFetchRequest:fetch error:nil] firstObject];
            [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                CLPlacemark *placemark = placemarks.lastObject;
                astory.country = placemark.country;
                astory.updated = [NSDate date];
                
                if (placemark.subLocality != nil) astory.city = placemark.subLocality;
                else if (placemark.locality != nil) astory.city = placemark.locality;
                
                [self.context save:nil];
                
            }];
            
        }
    
        if (assets != nil) {
            for (PHAsset *asset in assets) {
                created += 1;
                Entry *newentry = [[Entry alloc] initWithEntity:self.entry insertIntoManagedObjectContext:self.context];
                newentry.story = story;
                newentry.key = self.uniquekey;
                newentry.export = @"";
                newentry.updated = [NSDate date];
                newentry.created = [NSDate dateWithTimeIntervalSinceNow:10 * created];
                newentry.assetid = asset.localIdentifier;
                newentry.animate = true;
                newentry.latitude = asset.location.coordinate.latitude;
                newentry.longitude = asset.location.coordinate.longitude;
                newentry.captured = asset.creationDate;
                newentry.duration = asset.duration;
                newentry.limitduration = ENTRY_LIMIT_DURATION;
                newentry.audio = false;
                newentry.filedirectory = @"";
                newentry.type = [self entryAssetType:asset];
                newentry.order = [[self storyEntries:self.storyActiveKey] count] + 1;
                
                [self.geocoder reverseGeocodeLocation:asset.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    CLPlacemark *placemark = placemarks.lastObject;
                    newentry.country = placemark.country;
                    
                    if (placemark.subLocality != nil) newentry.city = placemark.subLocality;
                    else if (placemark.locality != nil) newentry.city = placemark.locality;
                    
                }];

                [added addObject:newentry.key];
                
            }
            
            NSError *saveerr;
            if ([self.context save:&saveerr]) {
                completion([NSError errorWithDomain:@"Entry saved" code:200 userInfo:nil], added);
                
            }
            else completion(saveerr, nil);
                        
        }
        else {
            Entry *newentry = [[Entry alloc] initWithEntity:self.entry insertIntoManagedObjectContext:self.context];
            newentry.story = story;
            newentry.key = self.uniquekey;
            newentry.export = @"";
            newentry.updated = [NSDate date];
            newentry.created = [NSDate dateWithTimeIntervalSinceNow:10 * created];
            newentry.assetid = @"";
            
            [added addObject:newentry.key];

            NSError *saveerr;
            if ([self.context save:&saveerr]) {
                completion([NSError errorWithDomain:@"Entry saved" code:200 userInfo:nil], added);
                
            }
            else completion(saveerr, nil);
            
        }
    
    }
    
}

-(void)entryAppendWithImageData:(PHAsset *)asset animated:(BOOL)animated entry:(NSString *)entry completion:(void (^)(NSError *error))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,entry];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    
    if ([self.context countForFetchRequest:fetch error:nil] == 0) {
        [self.imageobj imageCreateEntryFromAsset:asset animate:animated key:entry completion:^(NSError *error, BOOL animated) {
            if (error.code == 200) {
                Entry *existing = [[self.context executeFetchRequest:fetch error:nil] firstObject];
                existing.assetid = asset.localIdentifier;
                existing.animate = animated;
                existing.latitude = asset.location.coordinate.latitude;
                existing.longitude = asset.location.coordinate.longitude;
                existing.captured = asset.creationDate;
                existing.duration = asset.duration;
                existing.limitduration = ENTRY_LIMIT_DURATION;
                existing.audio = false;
                existing.type = [self entryAssetType:asset];
                existing.filedirectory = @"";

                [self.context save:nil];
                
                completion([NSError errorWithDomain:@"Entry updated" code:200 userInfo:nil]);

            }
            else completion(error);
            
        }];
        
    }
    else {
        Entry *existing = [[self.context executeFetchRequest:fetch error:nil] firstObject];
        existing.assetid = asset.localIdentifier==nil?@"":asset.localIdentifier;
        existing.animate = animated;
        existing.latitude = asset.location.coordinate.latitude;
        existing.longitude = asset.location.coordinate.longitude;
        existing.captured = asset.creationDate;
        existing.duration = asset.duration;
        existing.limitduration = ENTRY_LIMIT_DURATION;
        existing.audio = false;
        existing.type = [self entryAssetType:asset];

        if ([self.context save:nil]) {
            completion([NSError errorWithDomain:@"Entry updated" code:200 userInfo:nil]);
        
        }
        else {
            completion([NSError errorWithDomain:@"Entry not updated" code:409 userInfo:nil]);

        }
        
    }

}

-(void)entryAppendOrderSource:(NSDictionary *)source replace:(NSDictionary *)replace {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,[source objectForKey:@"key"]];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    
    if ([self.context countForFetchRequest:fetch error:nil] > 0) {
        NSDate *timestamp = [replace objectForKey:@"created"];
        Entry *existing = [[self.context executeFetchRequest:fetch error:nil] firstObject];
        existing.created = [timestamp dateByAddingTimeInterval:2];
        existing.updated = [NSDate date];
        
        [self.context save:nil];
        
    }

}

-(void)entryAppendAnimation:(NSString *)entry asset:(PHAsset *)asset completion:(void (^)(NSError *error, BOOL enabled))completion {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"key == %@" ,entry];
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetch.predicate = predicate;
    
    if ([self.context countForFetchRequest:fetch error:nil] > 0) {
        Entry *existing = [[self.context executeFetchRequest:fetch error:nil] firstObject];
        [self.imageobj imageCreateEntryFromAsset:asset animate:!existing.animate key:entry completion:^(NSError *error, BOOL animated) {
            if (error.code == 200 || error == nil) {
                NSError *saveerror;
                existing.animate = animated;
                existing.updated = [NSDate date];
                
                if ([self.context save:&saveerror]) {
                    completion([NSError errorWithDomain:@"Entry updated" code:200 userInfo:nil], animated);
                    
                }
                else completion(saveerror, false);
                
            }
            else completion(error, false);
            
        }];
        
    }
    
}

-(NSString *)entryAssetType:(PHAsset *)asset {
    if (asset != nil) {
        if (asset.mediaType == PHAssetMediaTypeImage) {
            if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) return @"livephoto";
            else return @"image";
            
        }
        else return @"video";
        
    }
    else return @"";
    
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
        if (entry != nil) [self.context deleteObject:entry];
        
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
