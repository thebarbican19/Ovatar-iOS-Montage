//
//  OAlbumSgment.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 08/10/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OAlbumSegmentDelegate;
@interface OAlbumSegment : UIView <UICollectionViewDelegate, UICollectionViewDataSource> {
    UIView *underline;
    UICollectionView *container;
    UICollectionViewFlowLayout *layout;
    
}

-(void)selected:(NSIndexPath *)index animated:(BOOL)animated;
-(void)reload;

@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIFont *fontselected;
@property (nonatomic, assign) float padding;
@property (nonatomic, assign) int index;
@property (nonatomic, strong) UIColor *background;
@property (nonatomic, strong) UIColor *textcolor;
@property (nonatomic, strong) UIColor *selecedtextcolor;

@end

@protocol SHSegmentDelegate <NSObject>

@optional

//-(void)segmentViewWasTapped:(SHSegmentControl *)segment index:(NSUInteger)index;

@end



