//
//  OAlertPlaceholder.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 23/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OAlertPlaceholder.h"
#import "OConstants.h"

@implementation OAlertPlaceholder

-(void)setup:(NSString *)title subtitle:(NSString *)subtitle icon:(OAnimatedIconType)icon animate:(BOOL)animate {
    if (![self.subviews containsObject:self.viewContent]) {
        self.viewIcon = [[OAnimatedIcon alloc] initWithFrame:CGRectMake((self.bounds.size.width / 2) - 40.0, 30.0, 80.0, 80.0)];
        self.viewIcon.backgroundColor = [UIColor clearColor];
        self.viewIcon.loopvid = true;
        [self addSubview:self.viewIcon];
        
        self.viewContent = [[SAMLabel alloc] initWithFrame:CGRectMake(30.0, 130.0, self.bounds.size.width - 60.0, 100.0)];
        self.viewContent.backgroundColor = [UIColor clearColor];
        self.viewContent.verticalTextAlignment = SAMLabelVerticalTextAlignmentTop;
        self.viewContent.textAlignment = NSTextAlignmentCenter;
        self.viewContent.numberOfLines = 3;
        [self addSubview:self.viewContent];
        
    }
    
    [self.viewIcon setType:icon];
    [self.viewIcon setNeedsDisplay];
    
    [self.viewContent setAttributedText:[self format:title subtitle:subtitle]];

}

-(NSMutableAttributedString *)format:(NSString *)title subtitle:(NSString *)subtitle {
    NSString *content = [NSString stringWithFormat:@"%@\n%@" ,title, subtitle];
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:content];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\*[^\\*]+\\*" options:0 error:nil];
    NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(title.length + 1, subtitle.length)];
    
    [attributed addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x464655) range:NSMakeRange(0, title.length)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Black" size:22] range:NSMakeRange(0, title.length)];
    
    [attributed addAttribute:NSForegroundColorAttributeName value:[UIColorFromRGB(0x757585) colorWithAlphaComponent:0.9] range:NSMakeRange(title.length + 1, subtitle.length)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Medium" size:14] range:NSMakeRange(title.length + 1, subtitle.length)];
    
    for (NSTextCheckingResult *match in matches) {
        [attributed addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:14] range:NSMakeRange(match.range.location, match.range.length)];
        [attributed addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x7490FD) range:NSMakeRange(match.range.location, match.range.length)];
        
    }
    
    [attributed.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributed.string.length)];
    [attributed.mutableString replaceOccurrencesOfString:@"*" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, attributed.string.length)];
    
    return attributed;
    
}

@end
