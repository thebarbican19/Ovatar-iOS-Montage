//
//  OToggleIcon.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 25/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OToggleDelegate;
@interface OToggleIcon : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) id <OToggleDelegate> delegate;
@property (nonatomic, strong) UIView *toggleContainer;
@property (nonatomic, strong) UIImageView *toggleIcon;
@property (nonatomic, strong) UITapGestureRecognizer *toggleGesture;

@property (nonatomic, assign) BOOL toggled;

-(void)toggled:(BOOL)toggled animated:(BOOL)animate;

@end

@protocol OToggleDelegate <NSObject>

@optional

@end


