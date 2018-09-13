//
//  OTickerLabel.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 29/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OTickerLabel : UIView

@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, assign) BOOL animate;
@property (nonatomic, assign) BOOL revealing;
@property (nonatomic, assign) BOOL isanimating;

-(void)setup:(NSString *)format;
-(void)update:(NSString *)value;
-(void)animate:(BOOL)reveal;
-(BOOL)animating;

@end
