//
//  OPresentationController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 26/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "OLoaderView.h"
#import "OPaymentObject.h"

@interface OPresentationController : UIViewController

@property (nonatomic, strong) AVPlayerViewController *viewPlayer;
@property (nonatomic, strong) UILabel *viewStatus;
@property (nonatomic, strong) OLoaderView *viewLoader;

-(void)viewPresentLoader:(NSArray *)assets;
-(void)viewPresentOutput:(NSURL *)file;

@end
