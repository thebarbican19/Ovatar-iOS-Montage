//
//  OStoriesLayout.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 15/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OStoriesLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat previousOffset;
@property (nonatomic, assign) NSInteger currentPage;

@end
