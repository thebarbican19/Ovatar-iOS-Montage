//
//  OSettingsCell.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 12/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OSettingsCell.h"
#import "OConstants.h"

@implementation OSettingsCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20.0, (self.bounds.size.height * 0.5) - 10.0, 30.0, 30.0)];
        self.cellIcon.image = nil;
        self.cellIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.cellIcon];

        self.cellTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.cellIcon.bounds.size.width + 20.0, 20.0, (self.bounds.size.width / 2) - 20.0, 18.0)];
        self.cellTitle.text = @"Title";
        self.cellTitle.clipsToBounds = true;
        self.cellTitle.textColor = UIColorFromRGB(0x464655);
        self.cellTitle.font = [UIFont fontWithName:@"Avenir-Black" size:12];
        self.cellTitle.clipsToBounds = true;
        [self.contentView addSubview:self.cellTitle];
        
        self.cellAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 58.0, 20.0, 51.0, self.bounds.size.height - 30.0)];
        self.cellAccessory.contentMode = UIViewContentModeCenter;
        self.cellAccessory.userInteractionEnabled = false;
        self.cellAccessory.alpha = 1.0;
        self.cellAccessory.image = [UIImage imageNamed:@"settings_accsessory"];
        [self.contentView addSubview:self.cellAccessory];
        
    }
    
    return self;
    
}

@end
