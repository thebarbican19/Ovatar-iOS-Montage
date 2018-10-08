//
//  OSettingsCell.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 12/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OToggleIcon.h"

@interface OSettingsCell : UITableViewCell

@property (nonatomic, strong) UIImageView *cellIcon;
@property (nonatomic, strong) UILabel *cellTitle;
@property (nonatomic, strong) UILabel *cellSubtitle;
@property (nonatomic, strong) UITextField *cellInput;
@property (nonatomic, strong) UISwitch *cellSwitch;
@property (nonatomic, strong) UIImageView *cellAccessory;
@property (nonatomic, strong) OToggleIcon *cellToggled;
@property (nonatomic, strong) UIImageView *cellBadge;

@property (nonatomic ,strong) NSIndexPath *index;

@end
