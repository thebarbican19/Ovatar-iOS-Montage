//
//  OAlertPlaceholder.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SAMLabel.h"
#import "OAnimatedIcon.h"

@interface OAlertPlaceholder : UIView

@property (nonatomic, strong) SAMLabel *viewContent;
@property (nonatomic, strong) OAnimatedIcon *viewIcon;

-(void)setup:(NSString *)title subtitle:(NSString *)subtitle icon:(OAnimatedIconType)icon animate:(BOOL)animate;
-(NSMutableAttributedString *)format:(NSString *)title subtitle:(NSString *)subtitle;

@end
