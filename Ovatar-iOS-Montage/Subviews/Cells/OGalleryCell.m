//
//  OGalleryCell.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 29/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OGalleryCell.h"
#import "OConstants.h"

@implementation OGalleryCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.viewContainer = [[UIImageView alloc] initWithFrame:self.bounds];
        self.viewContainer.backgroundColor = [UIColor clearColor];
        self.viewContainer.contentMode = UIViewContentModeScaleAspectFill;
        self.viewContainer.image = nil;
        self.viewContainer.clipsToBounds = true;
        self.viewContainer.layer.cornerRadius = 4.0;
        [self.contentView addSubview:self.viewContainer];
        
        self.viewOverlay = [[UIImageView alloc] initWithFrame:self.bounds];
        self.viewOverlay.backgroundColor = [UIColorFromRGB(0x7490FD) colorWithAlphaComponent:0.7];
        self.viewOverlay.contentMode = UIViewContentModeCenter;
        self.viewOverlay.image = [UIImage imageNamed:@"gallery_select"];
        self.viewOverlay.alpha = 0.0;
        [self.viewContainer addSubview:self.viewOverlay];
        
        self.viewAnimated = [[UIImageView alloc] initWithFrame:CGRectMake(2.0, self.viewContainer.bounds.size.height - 22.0, 20.0, 20.0)];
        self.viewAnimated.backgroundColor = [UIColor clearColor];
        self.viewAnimated.contentMode = UIViewContentModeScaleAspectFit;
        self.viewAnimated.image = [UIImage imageNamed:@"entry_playback"];
        self.viewAnimated.alpha = 1.0;
        [self.viewContainer addSubview:self.viewAnimated];
        
    }
    
    return self;
    
}

@end
