//
//  OPlayerControls.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 30/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OControlsDelegate;
@interface OPlayerControls : UIView

@property (nonatomic, strong) id <OControlsDelegate> delegate;
@property (nonatomic, strong) UIView *playerContainer;
@property (nonatomic, strong) UIButton *playerRewind;
@property (nonatomic, strong) UIButton *playerPlay;
@property (nonatomic, strong) UIButton *playerForward;
@property (nonatomic, strong) UILabel *playerElapsed;

@end

@protocol OControlsDelegate <NSObject>

@optional

-(void)playbackToggle;
-(void)playbackRewind;
-(void)playbackForward;

@end

