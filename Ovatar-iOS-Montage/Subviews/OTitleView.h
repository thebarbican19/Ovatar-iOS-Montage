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
    OTitleButtonTypeClose

} OTitleButtonType;

@protocol OTitleViewDelegate;
@interface OTitleView : UIView <UIGestureRecognizerDelegate>

@property (nonatomic, strong) id <OTitleViewDelegate> delegate;
@property (nonatomic, strong) UILabel *viewTitle;
@property (nonatomic, strong) UIView *viewContainer;
@property (nonatomic, strong) UIButton *viewBack;
@property (nonatomic, strong) CAShapeLayer *viewRounded;
@property (nonatomic, strong) UIView *viewShadow;
@property (nonatomic, strong) UITapGestureRecognizer *viewGesture;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BOOL backbutton;
@property (nonatomic, assign) BOOL headergeature;
@property (nonatomic, assign) BOOL rounded;
@property (nonatomic, assign) BOOL dark;
@property (nonatomic, strong) NSMutableArray *buttons;

-(void)setup:(NSArray *)actions animate:(BOOL)animate;
-(void)title:(NSString *)text animate:(BOOL)animate;
-(void)shadow:(float)scrollpos;

@end

@protocol OTitleViewDelegate <NSObject>

@optional

-(void)titleNavigationBackTapped:(UIButton *)button;
-(void)titleNavigationButtonTapped:(OTitleButtonType)button;
-(void)titleNavigationHeaderTapped:(OTitleView *)view;

@end

