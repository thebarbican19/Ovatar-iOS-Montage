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
    if (self.scale == 0) self.scale = 65.0;
    
    self.imageobj = [[OImageObject alloc] init];
    
    UIImage *image = [UIImage imageNamed:@"splash_icon"];
    float imagescale = self.scale / image.size.width;
    float imageheight = image.size.height * imagescale;
    float imagewidth = image.size.width * imagescale;
    
    self.viewMask = [CALayer layer];
    self.viewMask.contents = (id)[[UIImage imageNamed:@"splash_icon"] CGImage];
    self.viewMask.frame = CGRectMake((self.bounds.size.width / 2) - (imagewidth / 2), (self.bounds.size.height / 2) - (imageheight / 2), imagewidth, imageheight);
    
    self.viewContainer = [[UIImageView alloc] initWithFrame:self.bounds];
    self.viewContainer.backgroundColor = UIColorFromRGB(0x7490FD);
    self.viewContainer.layer.mask = self.viewMask;
    self.viewContainer.layer.masksToBounds = true;
    [self addSubview:self.viewContainer];
    
    self.viewImages = [[UIImageView alloc] initWithFrame:CGRectMake(self.viewMask.frame.origin.x - 5.0, self.viewMask.frame.origin.y - 5.0, self.viewMask.bounds.size.width + 5.0, self.viewMask.bounds.size.height + 5.0)];
    self.viewImages.contentMode = UIViewContentModeScaleAspectFill;
    self.viewImages.image = nil;
    [self.viewContainer addSubview:self.viewImages];
    
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
    
    if (self.images.count == 0) self.images = [[NSArray alloc] initWithArray:images];
    if (self.timer.valid == false) self.timer = [NSTimer scheduledTimerWithTimeInterval:self.speed target:self selector:@selector(loaderChangeImage) userInfo:nil repeats:true];

    [self loaderChangeImage];

}

-(void)loaderChangeImage {
    if (self.index >= (self.images.count - 1)) self.index = 0;
    else self.index += 1;
    
    if ([[self.images objectAtIndex:self.index] isKindOfClass:[UIImage class]]) {
        [UIView transitionWithView:self.viewImages duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.viewImages setImage:[self.images objectAtIndex:self.index]];
            
        } completion:nil];
        
    }
    else if ([[self.images objectAtIndex:self.index] isKindOfClass:[NSString class]]) {
        [UIView transitionWithView:self.viewImages duration:0.2 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [self.viewImages setImage:[UIImage imageNamed:[self.images objectAtIndex:self.index]]];
            
        } completion:nil];
        
    }
    else if ([[self.images objectAtIndex:self.index] isKindOfClass:[PHAsset class]]) {
        [self.imageobj imagesFromAsset:[self.images objectAtIndex:self.index] thumbnail:false completion:^(NSDictionary *exifdata, NSData *image) {
            [UIView transitionWithView:self.viewImages duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [self.viewImages setImage:[UIImage imageWithData:image]];
                
            } completion:nil];

        }];

    }
    
}

@end
