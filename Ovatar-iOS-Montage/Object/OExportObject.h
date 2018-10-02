//
//  OExportObject.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 15/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import "OImageObject.h"
#import "ODataObject.h"

@interface OExportObject : NSObject

@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, strong) AVAssetExportSession *exporter;
@property (nonatomic, strong) NSTimer *exporttimer;
@property (nonatomic, strong) NSString *story;

@property (nonatomic, assign) CGSize videoresize;
@property (nonatomic, assign) float videoframes;
@property (nonatomic, assign) float videoseconds;

-(void)exportMontage:(NSString *)story completion:(void (^)(NSString *file, NSError *error))completion;
-(void)exportClipWithType:(id)image key:(NSString *)key completion:(void (^)(NSError* error))completion;
-(void)exportTerminate;

@end
