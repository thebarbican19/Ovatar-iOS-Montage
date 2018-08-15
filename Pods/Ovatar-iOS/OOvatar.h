//
//  OOvatar.h
//  Ovatar
//
//  Created by Joe Barbour on 13/01/2017.
//  Copyright © 2017 Ovatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define OVATAR_HOST @"https://ovatar.io/api/"
#define OVATAR_REGEX_PHONE @"(\\+)[0-9\\+\\-]{6,19}"
#define OVATAR_REGEX_EMAIL @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

@protocol OOvatarDelegate;
@interface OOvatar : NSObject <NSURLSessionTaskDelegate>
typedef NS_ENUM(NSInteger, OImageSize) {
    OImageSizeLarge,
    OImageSizeMedium,
    OImageSizeSmall

};

typedef NS_ENUM(NSInteger, OImageLoader) {
    OImageLoaderProgress,
    OImageLoaderDownloading
};


typedef NS_ENUM(NSInteger, OOutputType) {
    OOutputTypeJSON,
    OOutputType404,
    OOutputTypeDefault,
    
};



@property (weak, nonatomic) id <OOvatarDelegate> odelegate;
@property (nonatomic ,assign) OImageSize size;
@property (nonatomic ,assign) OOutputType output;
@property (nonatomic ,assign) UIImage *placeholder;

@property (nonatomic ,weak) NSString *okey;
@property (nonatomic ,weak) NSString *oquery;

+(OOvatar *)sharedInstance;
+(void)sharedInstanceWithAppKey:(NSString *)appKey;
//Must be added to the app delegate with application key which can be found at http://ovatar.io

-(void)setEmail:(NSString *)email;
-(void)setPhoneNumber:(NSString *)phone;
-(void)setKey:(NSString *)key;
-(void)setDebugging:(BOOL)enabled;
-(void)setPrivateArchive:(BOOL)enabled;
-(void)setGravatarFallback:(BOOL)enabled;
-(void)setCacheExpirySeconds:(int)seconds;

-(NSString *)ovatarEmail;
-(NSString *)ovatarPhoneNumber;
-(NSString *)ovatarKey;

-(NSDictionary *)ovatarAppInformation;

-(void)returnOvatarIconWithQuery:(NSString *)query completion:(void (^)(NSError *error, id output))completion;
-(void)returnOvatarIconWithKey:(NSString *)key completion:(void (^)(NSError *error, id output))completion;
-(void)returnOvatarAppInformation:(void (^)(NSDictionary *app, NSError *error))completion;

-(void)uploadOvatar:(NSData *)image metadata:(NSDictionary *)metadata user:(NSString *)user;

-(void)imageCacheDestroy;
-(void)imageSaveToCache:(UIImage *)image identifyer:(NSString *)identifyer;
-(UIImage *)imageFromCache:(NSString *)identifyer;
-(BOOL)imageDetectFace:(UIImage *)image;

@end

@protocol OOvatarDelegate <NSObject>

-(void)ovatarIconWasUpdatedSucsessfully:(NSDictionary *)output;
-(void)ovatarIconUploadFailedWithErrors:(NSError *)error;
-(void)ovatarIconUploadingWithProgress:(float)progress;

@end
