//
//  OTitleView.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 06/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    OTitleButtonTypeExport,
    OTitleButtonTypeSettings,
    OTitleButtonTypePreview,
    OTitleButtonTypeSelect,
    
} OTitleButtonType;

@protocol OTitleViewDelegate;
@interface OTitleView : UIView

@property (nonatomic, strong) id <OTitleViewDelegate> delegate;
@property (nonatomic, strong) UILabel *viewTitle;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) CAGradientLayer *viewGradient;
@property (nonatomic, strong) UIButton *viewBack;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL backbutton;
@property (nonatomic, strong) NSMutableArray *buttons;

-(void)setup:(NSArray *)actions animate:(BOOL)animate;
-(void)title:(NSString *)text animate:(BOOL)animate;

@end

@protocol OTitleViewDelegate <NSObject>

@optional

-(void)titleNavigationBackTapped:(UIButton *)button;
-(void)titleNavigationButtonTapped:(OTitleButtonType)button;

@end

