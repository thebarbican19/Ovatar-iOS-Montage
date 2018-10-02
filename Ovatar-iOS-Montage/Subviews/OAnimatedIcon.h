//
//  OAnimatedIcon.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "OLoaderView.h"
#import "ODataObject.h"
#import "OImageObject.h"

typedef enum {
    OAnimatedIconTypeError,
    OAnimatedIconTypeComplete,
    OAnimatedIconTypePush,
    OAnimatedIconTypeLoading,
    OAnimatedIconTypeRender,
    OAnimatedIconTypeOvatar
    
} OAnimatedIconType;

@interface OAnimatedIcon : UIView

@property (nonatomic, strong) AVPlayerViewController *player;
@property (nonatomic, assign) BOOL loopvid;
@property (nonatomic, assign) OAnimatedIconType type;
@property (strong, nonatomic) OLoaderView *loader;
@property (strong, nonatomic) ODataObject *dataobj;
@property (strong, nonatomic) OImageObject *imageobj;

@end
