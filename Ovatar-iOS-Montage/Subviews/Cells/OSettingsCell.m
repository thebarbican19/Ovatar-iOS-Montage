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
        self.cellIcon.contentMode = UIViewContentModeCenter;
        self.cellIcon.userInteractionEnabled = false;
        self.cellIcon.alpha = 0.4;
        self.cellIcon.transform = CGAffineTransformMakeScale(0.8, 0.8);
        [self.contentView addSubview:self.cellIcon];

        self.cellTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.cellIcon.bounds.size.width + 20.0, 20.0, (self.bounds.size.width / 2) - 20.0, 18.0)];
        self.cellTitle.text = @"Title";
        self.cellTitle.clipsToBounds = true;
        self.cellTitle.textColor = UIColorFromRGB(0x464655);
        self.cellTitle.font = [UIFont fontWithName:@"Avenir-Black" size:12];
        self.cellTitle.userInteractionEnabled = false;
        [self.contentView addSubview:self.cellTitle];
        
        self.cellSubtitle = [[UILabel alloc] initWithFrame:self.cellTitle.frame];
        self.cellSubtitle.hidden = true;
        self.cellSubtitle.text = @"Subtitle";
        self.cellSubtitle.clipsToBounds = true;
        self.cellSubtitle.textColor = [UIColorFromRGB(0x464655) colorWithAlphaComponent:0.5];
        self.cellSubtitle.font = [UIFont fontWithName:@"Avenir-Light" size:10];
        self.cellSubtitle.userInteractionEnabled = false;
        [self.contentView addSubview:self.cellSubtitle];
        
        self.cellInput = [[UITextField alloc] initWithFrame:CGRectMake(self.cellIcon.bounds.size.width + 20.0, 20.0, (self.bounds.size.width / 2) - 20.0, 18.0)];
        self.cellInput.text = @"Title";
        self.cellTitle.clipsToBounds = true;
        self.cellInput.textColor = UIColorFromRGB(0x464655);
        self.cellInput.font = [UIFont fontWithName:@"Avenir-Black" size:12];
        self.cellInput.clipsToBounds = true;
        self.cellInput.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.cellInput.returnKeyType = UIReturnKeyDone;
        self.cellInput.keyboardType = UIKeyboardTypeDefault;
        [self.contentView addSubview:self.cellInput];
        
        self.cellAccessory = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width - 58.0, 20.0, 51.0, self.bounds.size.height - 30.0)];
        self.cellAccessory.contentMode = UIViewContentModeCenter;
        self.cellAccessory.userInteractionEnabled = false;
        self.cellAccessory.alpha = 1.0;
        self.cellAccessory.image = [UIImage imageNamed:@"settings_accsessory"];
        [self.contentView addSubview:self.cellAccessory];
        
        self.cellToggled = [[OToggleIcon alloc] initWithFrame:CGRectMake(self.bounds.size.width - 58.0, (self.bounds.size.height / 2), 16.0, 16.0)];
        self.cellToggled.backgroundColor = [UIColor clearColor];
        self.cellToggled.toggled = false;
        [self.contentView addSubview:self.cellToggled];

    }
    
    return self;
    
}

@end
