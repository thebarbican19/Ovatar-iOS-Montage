//
//  OSettingsHeader.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 14/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OSettingsHeader.h"
#import "OConstants.h"

@implementation OSettingsHeader

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:self.viewLogo.view]) {
        self.viewLogo = [[AVPlayerViewController alloc] init];
        self.viewLogo.view.frame = CGRectMake((self.bounds.size.width * 0.5) - 80.0, 34.0, 160.0, 160.0);
        self.viewLogo.view.backgroundColor = [UIColor clearColor];
        self.viewLogo.showsPlaybackControls = false;
        self.viewLogo.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]  pathForResource:@"Montage-App-Loop" ofType:@"mov"]]];
        self.viewLogo.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.viewLogo.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.viewLogo.player.allowsExternalPlayback = false;
        self.viewLogo.allowsPictureInPicturePlayback = false;
        self.viewLogo.view.userInteractionEnabled = false;
        [self addSubview:self.viewLogo.view];
        
        self.viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 190.0, self.bounds.size.width - 60.0, self.bounds.size.height - 190.0)];
        self.viewLabel.textAlignment = NSTextAlignmentCenter;
        self.viewLabel.textColor = UIColorFromRGB(0xAAAAB8);
        self.viewLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:15];
        self.viewLabel.attributedText = [self format];
        self.viewLabel.numberOfLines = 3;
        [self addSubview:self.viewLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loop:)  name:AVPlayerItemDidPlayToEndTimeNotification object:self.viewLogo.player.currentItem];

    }
    
}

-(void)loop:(NSNotification *)notification {
    [self.viewLogo.player seekToTime:kCMTimeZero];
    [self.viewLogo.player play];
        
}

-(NSMutableAttributedString *)format {
    NSString *name = NSLocalizedString(@"Settings_About_Title", nil);
    NSString *subtitle = [NSString stringWithFormat:NSLocalizedString(@"Settings_About_Subtitle", nil), APP_VERSION, APP_BUILD];
    NSString *content = [NSString stringWithFormat:@"%@\n%@" ,name, subtitle];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:content];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
    NSArray *formatMatches = [regex matchesInString:name options:0 range:NSMakeRange(0, name.length)];
    for (NSTextCheckingResult *match in formatMatches) {
        [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:self.viewLabel.font.pointSize] range:NSMakeRange(match.range.location, match.range.length)];
        [attributed addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x7490FD) range:NSMakeRange(match.range.location, match.range.length)];
        
    }
    
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColorFromRGB(0xAAAAB8) colorWithAlphaComponent:0.5] range:NSMakeRange(name.length + 1, subtitle.length)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Medium" size:9] range:NSMakeRange(name.length + 1, subtitle.length)];

    [attributed.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributed.string.length)];
    [attributed.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributed.string.length)];
  
    return attributed;
    
}

@end
