//
//  OGalleryReusableView.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 11/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OGalleryReusableView.h"
#import "OConstants.h"

@implementation OGalleryReusableView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if (![self.subviews containsObject:self.viewLabel]) {
            self.viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 0.0, self.bounds.size.width - 40.0, self.bounds.size.height - 4.0)];
            self.viewLabel.textColor = UIColorFromRGB(0xAAAAB8);
            self.viewLabel.textAlignment = NSTextAlignmentLeft;
            self.viewLabel.font = [UIFont fontWithName:@"Avenir-Heavy" size:15];
            self.viewLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:self.viewLabel];
            
        }
        
    }
    
    return self;
    
}


@end
