//
//  OLoaderView.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 12/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OImageObject.h"

@interface OLoaderView : UIView

@property (nonatomic, strong) CALayer *viewMask;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIImageView *viewImages;

@property (nonatomic, assign) float speed;
@property (nonatomic, assign) float scale;
@property (nonatomic, assign) float animation;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) OImageObject *imageobj;

-(void)loaderPresentWithImages:(NSArray *)images animated:(BOOL)animated;

@end
