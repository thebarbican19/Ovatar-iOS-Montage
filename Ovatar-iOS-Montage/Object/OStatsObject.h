//
//  OStatsObject.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 03/10/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "OImageObject.h"

#import "GoogLeNetPlaces.h"
#import "Food101.h"
#import "Inceptionv3.h"

@interface OStatsObject : NSObject

+(OStatsObject *)sharedInstance;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSEntityDescription *images;
@property (nonatomic, strong) NSPersistentContainer *persistancecont;
@property (nonatomic, strong) NSUserDefaults *data;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) GoogLeNetPlaces *places;
@property (nonatomic, strong) Food101 *foods;
@property (nonatomic, strong) Inceptionv3 *tags;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, assign) BOOL active;

-(void)initiate;
-(void)suspend;

-(NSArray *)visitedCountries;
-(NSArray *)vistedUnescoSites;
-(NSArray *)vistedAirports;

-(NSString *)favoritePlace;
-(NSString *)favoriteFood;

-(int)capturesTotal;
-(int)capturesThisMonth;
-(int)capturesLastMonth;

-(NSArray *)tagsFromAssetKeys:(NSArray *)tags;

@end
