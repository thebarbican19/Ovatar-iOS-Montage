//
//  NSlackObject.h
//  Nifty
//
//  Created by Joe Barbour on 30/04/2018.
//  Copyright © 2018 Nifty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSlackObject : NSObject

typedef enum {
    NFeedbackTypeGeneral,
    NFeedbackTypeReport,
    
} NFeedbackType;

@property (nonatomic, assign) BOOL debug;

-(void)slackSend:(NSString *)message userdata:(NSDictionary *)userdata type:(NFeedbackType)type completion:(void (^)(NSError *error))completion;
-(void)slackCaptureScreenshot:(id)view;

@end
