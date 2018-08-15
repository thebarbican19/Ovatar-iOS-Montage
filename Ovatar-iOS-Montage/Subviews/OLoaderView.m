//
//  OLoaderView.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 12/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OLoaderView.h"
#import "OConstants.h"

@implementation OLoaderView

-(void)drawRect:(CGRect)rect {
    if (self.animation == 0) self.animation = 3.0;
    if (self.speed == 0) self.speed = 0.5;
    if (self.scale == 0) self.scale = 90.0;
    
    self.imageobj = [[OImageObject alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"logo_placeholder"];
    float imagescale = self.scale / image.size.width;
    float imageheight = image.size.height * imagescale;
    float imagewidth = image.size.width * imagescale;
    
    self.viewMask = [CALayer layer];
    self.viewMask.contents = (id)[[UIImage imageNamed:@"logo_placeholder"] CGImage];
    self.viewMask.frame = CGRectMake((self.bounds.size.width / 2) - (imagewidth / 2), (self.bounds.size.height / 2) - (imageheight / 2), imagewidth, imageheight);
    
    self.viewContainer = [[UIImageView alloc] initWithFrame:self.bounds];
    self.viewContainer.contentMode = UIViewContentModeScaleAspectFill;
    self.viewContainer.backgroundColor = UIColorFromRGB(0x7490FD);
    self.viewContainer.layer.mask = self.viewMask;
    self.viewContainer.layer.masksToBounds = true;
    [self addSubview:self.viewContainer];
    
}

-(void)loaderPresentWithImages:(NSArray *)images animated:(BOOL)animated {
    [self.timer invalidate];
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = self.animation;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:5.0f];
        animation.toValue = [NSNumber numberWithFloat:1.0f];
        
        [self.viewMask addAnimation:animation forKey:kCATransition];
        
    }
    
    self.images = [[NSArray alloc] initWithArray:images];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.speed target:self selector:@selector(loaderChangeImage) userInfo:nil repeats:true];

    [self loaderChangeImage];

}

-(void)loaderChangeImage {
    if (self.index >= (self.images.count - 1)) self.index = 0;
    else self.index += 1;
    
    if ([[self.images objectAtIndex:self.index] isKindOfClass:[UIImage class]]) {
        [self.viewContainer setImage:[self.images objectAtIndex:self.index]];
        
    }
    else if ([[self.images objectAtIndex:self.index] isKindOfClass:[PHAsset class]]) {
        [self.imageobj imagesFromAsset:[self.images objectAtIndex:self.index] thumbnail:false completion:^(NSDictionary *exifdata, NSData *image) {
            [self.viewContainer setImage:[UIImage imageWithData:image]];

        }];

    }
    
}

@end
