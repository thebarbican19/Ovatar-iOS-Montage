//
//  OPermissionsController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 31/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OActionButton.h"
#import "OImageObject.h"

@protocol OPermissionsViewDelegate;
@interface OPermissionsController : UIViewController <OActionDelegate>

@property (nonatomic, strong) id <OPermissionsViewDelegate> delegate;
@property (nonatomic, strong) OActionButton *viewAction;
@property (nonatomic, strong) UILabel *viewLabel;

@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, assign) float padding;

@end

@protocol OPermissionsViewDelegate <NSObject>

@optional

-(void)viewPresentSubviewWithIndex:(int)index animate:(BOOL)animate;
-(void)viewStorySetup;

@end
