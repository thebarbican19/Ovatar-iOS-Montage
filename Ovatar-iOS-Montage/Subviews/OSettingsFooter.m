//
//  OSettingsHeader.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 14/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OSettingsFooter.h"
#import "OConstants.h"

@implementation OSettingsFooter

-(void)drawRect:(CGRect)rect {
    if (![self.subviews containsObject:self.viewLogo]) {
        self.viewLogo =  [[OAnimatedIcon alloc] initWithFrame:CGRectMake((self.bounds.size.width * 0.5) - 110.0, 4.0, 220.0, 220.0)];
        self.viewLogo.backgroundColor = [UIColor clearColor];
        self.viewLogo.loopvid = true;
        self.viewLogo.type = OAnimatedIconTypeOvatar;
        [self addSubview:self.viewLogo];
        
        self.viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(30.0, 174.0, self.bounds.size.width - 60.0, self.bounds.size.height - 190.0)];
        self.viewLabel.textAlignment = NSTextAlignmentCenter;
        self.viewLabel.textColor = UIColorFromRGB(0xAAAAB8);
        self.viewLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:15];
        self.viewLabel.attributedText = [self format];
        self.viewLabel.numberOfLines = 3;
        [self addSubview:self.viewLabel];
        
    }
    
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
