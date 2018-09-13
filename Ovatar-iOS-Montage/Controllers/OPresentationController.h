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
#import <AudioToolbox/AudioServices.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CoreMedia/CoreMedia.h>

#import "OLoaderView.h"
#import "OPaymentObject.h"
#import "OActionButton.h"
#import "OTabbarView.h"
#import "ODataObject.h"

#import "SAMLabel.h"

@protocol OPresentationDelegate;
@interface OPresentationController : UIViewController <OActionDelegate, OTabbarDelegate, ODataDelegate, MPMediaPickerControllerDelegate>

@property (nonatomic, strong) id <OPresentationDelegate> delegate;
@property (nonatomic, strong) AVPlayerViewController *viewPlayer;
@property (nonatomic, strong) UILabel *viewElapsed;
@property (nonatomic, strong) SAMLabel *viewStatus;
@property (nonatomic, strong) UIImageView *viewTick;
@property (nonatomic, strong) OActionButton *viewShare;
@property (nonatomic, strong) OActionButton *viewRestart;
@property (nonatomic, strong) OActionButton *viewPurchase;

@property (nonatomic, strong) OTabbarView *viewTabbar;

@property (nonatomic, strong) ODataObject *dataobj;
@property (nonatomic, strong) MPMediaItem *song;
@property (nonatomic, strong) AVURLAsset *soundtrack;

@property (nonatomic, strong) NSURL *exported;
@property (nonatomic) SystemSoundID complete;
@property (nonatomic, assign) CGSize videosize;

-(void)viewReset;
-(void)viewPresentOutput:(NSURL *)file;
-(void)viewExportSucsessful;

@end

@protocol OPresentationDelegate <NSObject>

@optional

-(void)viewPresentError:(NSString *)text;
-(void)viewExportWithSize:(CGSize)size;
-(void)viewPresentLoader:(BOOL)present text:(NSString *)text;
-(void)viewPresentSubviewWithIndex:(int)index animate:(BOOL)animate;
-(void)viewPurchaseInitialiseWithIdentifyer:(NSString *)identifyer;

@end
