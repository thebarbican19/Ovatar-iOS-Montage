//
//  OTickerLabel.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 29/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OTickerLabel.h"
#import "OConstants.h"

@implementation OTickerLabel

-(void)setup:(NSString *)format {
    if (![self.subviews containsObject:self.container]) {
        self.container = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 100.0, self.bounds.size.height)];
        self.container.backgroundColor = [UIColor clearColor];
        self.container.clipsToBounds = false;
        [self addSubview:self.container];
        
    }
    
    if (![format isEqualToString:self.text]) {
        [self animate:false];
        
    }

    float cwidth = 0.0;
    float cheight = 0.0;
    unichar buffer[format.length + 1];
    [format getCharacters:buffer range:NSMakeRange(0, format.length)];
    for(int i = 0; i < format.length; i++) {
        UIFont *fount = [UIFont fontWithName:@"Avenir-Heavy" size:17];
        NSString *content =  [NSString stringWithFormat:@"%C", buffer[i]];
        CGRect labelsize = [content boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.container.bounds.size.height)
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{NSFontAttributeName:fount}
                                                     context:nil];
        UILabel *character = [[UILabel alloc] initWithFrame:CGRectMake(cwidth, self.animate?(-labelsize.size.height):0.0, labelsize.size.width, labelsize.size.height)];
        character.textAlignment = NSTextAlignmentCenter;
        character.font = fount;
        character.backgroundColor = [UIColor clearColor];
        character.text = content.lowercaseString;
        character.tag = [self tag:content];
        character.textColor = UIColorFromRGB(0xAAAAB8);
        character.alpha = self.animate?0.0:1.0;
        [self.container addSubview:character];
        
        cwidth += labelsize.size.width;
        if (labelsize.size.height > cheight) cheight = labelsize.size.height;

    }
    
    [self.container setFrame:CGRectMake((self.bounds.size.width / 2) - (cwidth / 2), (self.bounds.size.height / 2) - ((cheight + 8.0) / 2), cwidth, cheight + 8.0)];
    
    if (self.animate) [self animate:true];
    
    self.text = format.lowercaseString;
    
}

-(int)tag:(NSString *)character {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSMutableCharacterSet *number = [NSMutableCharacterSet characterSetWithCharactersInString:@"0123456789."];

    if ([[character stringByTrimmingCharactersInSet:whitespace] isEqualToString:@""]) return 0;
    else if ([[character stringByTrimmingCharactersInSet:number] isEqualToString:@""]) return 2;
    else return 1;

}

-(void)update:(NSString *)value {
    int character = 0;
    int delay = 0;
    self.isanimating = false;
    for (UIView *subview in self.container.subviews) {
        if (subview.tag == 2) {
            UILabel *label = (UILabel *)subview;
            unichar buffer[value.length + 1];
            [value getCharacters:buffer range:NSMakeRange(0, value.length)];

            NSString *content = [NSString stringWithFormat:@"%C", buffer[character]];
            label.text = content.lowercaseString;
            label.alpha = 1.0;
            label.frame = CGRectMake(label.frame.origin.x, 0.0, label.bounds.size.width, label.bounds.size.height);

            /*
            if (![content isEqualToString:self.text] && !self.isanimating) {
                [UIView animateWithDuration:0.2 delay:0.0 + (0.04 * delay) options:UIViewAnimationOptionCurveEaseOut animations:^{
                    //label.frame = CGRectMake(label.frame.origin.x, 4.0, label.bounds.size.width, label.bounds.size.height);
                    //label.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    label.text = content;
                    //label.frame = CGRectMake(label.frame.origin.x, -4.0, label.bounds.size.width, label.bounds.size.height);
                    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                        //label.frame = CGRectMake(label.frame.origin.x, 0.0, label.bounds.size.width, label.bounds.size.height);
                        //label.alpha = 1.0;
                        
                    } completion:^(BOOL finished) {
                         self.isanimating = false;
                        
                    }];
                    
                }];
                
                self.isanimating = true;
                self.text = content;
                
            }
            */
            
            delay ++;
            character ++;
            
        }
        
    }
    
}

-(void)animate:(BOOL)reveal {
    int delay = 0;
    bool directionup = false;
    
    for (UIView *subview in self.container.subviews) {
        if (subview.tag == 1) {
            if (((arc4random() % 30) +1) % 2 == 0) directionup = true;
            else directionup = false;
            
            UILabel *label = (UILabel *)subview;
            label.frame = CGRectMake(label.frame.origin.x, directionup?(label.bounds.size.height + 2.0):(label.frame.origin.y - 2.0), label.bounds.size.width, label.bounds.size.height);

            [UIView animateWithDuration:0.2 delay:0.0 + (0.04 * delay) options:UIViewAnimationOptionCurveEaseOut animations:^{
                if (reveal) {
                    label.frame = CGRectMake(label.frame.origin.x, 0.0, label.bounds.size.width, label.bounds.size.height);
                    label.backgroundColor = [UIColor clearColor];
                    label.alpha = 1.0;
                    
                }
                else {
                    label.frame = CGRectMake(label.frame.origin.x, directionup?(-self.bounds.size.height):self.bounds.size.height, label.bounds.size.width, label.bounds.size.height);
                    label.backgroundColor = [UIColor clearColor];
                    label.alpha = 0.0;
                    
                }
                
            } completion:^(BOOL finished) {
                if (!reveal) [label removeFromSuperview];
                
            }];
           
            delay ++;
            
        }
        
    }
    
    self.revealing = reveal;
    
}

-(BOOL)animating {
    UILabel *label = (UILabel *)self.container.subviews.lastObject;
    if (self.revealing) {
        if (label.alpha == 1.0) return false;
        else return true;
        
    }
    else {
        if (label.alpha == 0.0) return false;
        else return true;
        
    }

}

@end
