//
//  OTabbarView.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 30/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OTabbarDelegate;
@interface OTabbarView : UIView

@property (nonatomic, strong) id <OTabbarDelegate> delegate;
@property (nonatomic ,strong) UIView *container;

@property (nonatomic ,strong) NSArray *buttons;

@end

@protocol OTabbarDelegate <NSObject>

@optional

-(void)tabbarAction:(UIButton *)button;

@end

