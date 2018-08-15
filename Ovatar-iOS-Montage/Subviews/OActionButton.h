//
//  OActionButton.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 02/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OActionDelegate;
@interface OActionButton : UIView {
    
}

@property (nonatomic, strong) id <OActionDelegate> delegate;
@property (nonatomic, strong) UIButton *viewButton;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic, strong) UILabel *viewLabel;
@property (nonatomic, strong) CAGradientLayer *viewGradient;

@property (nonatomic, assign) float padding;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;

@end

@protocol OActionDelegate <NSObject>

@optional

-(void)viewActionTapped:(OActionButton *)action;

@end
