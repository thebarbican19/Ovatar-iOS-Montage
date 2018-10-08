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
@property (nonatomic, strong) UIImageView *viewIcon;

@property (nonatomic, assign) int countdown;
@property (nonatomic, assign) float padding;
@property (nonatomic, assign) float fontsize;
@property (nonatomic, assign) BOOL grayscale;
@property (nonatomic, assign) BOOL modaldismiss;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UINotificationFeedbackGenerator *generator;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) UIImage *icon;

-(void)title:(NSString *)title;

@end

@protocol OActionDelegate <NSObject>

@optional

-(void)viewActionTapped:(OActionButton *)action;
-(void)viewActionCountdownComplete:(OActionButton *)action;

@end
