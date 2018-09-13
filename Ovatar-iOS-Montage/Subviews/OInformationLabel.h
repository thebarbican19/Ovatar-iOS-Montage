//
//  OInformationLabel.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 16/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OInformationLabel : UIView

@property (nonatomic, strong) UILabel *labelTimestamp;
@property (nonatomic, strong) UILabel *labelLocation;

-(void)timestamp:(NSString *)timestamp;
-(void)location:(NSString *)location;

@end
