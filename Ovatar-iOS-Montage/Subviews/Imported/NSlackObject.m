//
//  NSlackObject.m
//  Nifty
//
//  Created by Joe Barbour on 30/04/2018.
//  Copyright © 2018 Nifty. All rights reserved.
//

#import "NSlackObject.h"

@implementation NSlackObject

#define SLACK_CHANNEL @"CCDSXRN9F" //channel id
#define SLACK_TOKEN @"xoxp-423820767766-421761432752-421766321824-c8a7d3920282ad1821e460ce541971c2"
#define SLACK_WEBHOOK @"https://hooks.slack.com/services/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"
#define SLACK_FILENAME @"slack_screenshot.png"
#define SLACK_CHANNEL_NAME @"Ovatar"

#define APP_BUNDLE_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]
#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
#define APP_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define APP_DEVICE [[UIDevice currentDevice] systemVersion]
#define APP_LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0]
#define APP_BUILD [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]

-(void)slackCaptureScreenshot:(id)view {
    if ([view isKindOfClass:[UITextView class]]) {
        UITextView *textview = (UITextView *)view;
        CGRect frame = textview.frame;
        frame.size.height = textview.contentSize.height;
        textview.frame = frame;

        UIGraphicsBeginImageContext(textview.bounds.size);
        [textview.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();

        [[NSFileManager defaultManager] createFileAtPath:[APP_DIRECTORY stringByAppendingPathComponent:SLACK_FILENAME] contents:UIImagePNGRepresentation(image) attributes:nil];
        
        frame.size.height = textview.bounds.size.height;
        textview.frame = frame;
        
    }
    else if ([view isKindOfClass:[UIImage class]]) {
        [[NSFileManager defaultManager] createFileAtPath:[APP_DIRECTORY stringByAppendingPathComponent:SLACK_FILENAME] contents:UIImagePNGRepresentation(view) attributes:nil];

    }
    
}

-(NSData *)slackScreenshotData {
    return [[NSFileManager defaultManager] contentsAtPath:[APP_DIRECTORY stringByAppendingPathComponent:SLACK_FILENAME]];

}

-(void)slackScreenshotRemove {
    [[NSFileManager defaultManager] removeItemAtPath:[APP_DIRECTORY stringByAppendingPathComponent:SLACK_FILENAME] error:nil];
    
}

-(void)slackSend:(NSString *)message userdata:(NSDictionary *)userdata type:(NFeedbackType)type completion:(void (^)(NSError *error))completion {
    NSMutableString *body = [[NSMutableString alloc] init];
    if (userdata != nil) {
        for (NSString *key in userdata.allKeys) {
            [body appendString:[NSString stringWithFormat:@"%@: %@\n" ,[key capitalizedString], [userdata objectForKey:key]]];
            
        }
        
    }
    
    [body appendString:[NSString stringWithFormat:@"Language: %@\n" ,APP_LANGUAGE]];
    [body appendString:[NSString stringWithFormat:@"App Version: %@\n" ,APP_VERSION]];
    [body appendString:[NSString stringWithFormat:@"iOS Build: %@\n" ,APP_BUILD]];
    [body appendString:[NSString stringWithFormat:@"iOS Version: %@\n" ,APP_DEVICE]];

    NSMutableArray *attachement = [[NSMutableArray alloc] init];
    [attachement addObject:@{@"title":@"Message",
                             @"text":message,
                             @"color":@"#"}];
    [attachement addObject:@{@"title":@"User Information",
                             @"text":body,
                             @"color":@"#"}];
    
   
    NSString *title;
    if (type == NFeedbackTypeGeneral) {
        title = [NSString stringWithFormat:@"*%@* feedback received" ,APP_BUNDLE_NAME];
        
    }
    else {
        title = [NSString stringWithFormat:@"*%@* reported item received from" ,APP_BUNDLE_NAME];
        
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:SLACK_WEBHOOK]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *requet = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [requet setHTTPMethod:@"POST"];
    [requet setHTTPBody:[NSJSONSerialization dataWithJSONObject:@{@"channel":SLACK_CHANNEL, @"text":title, @"attachments":attachement, @"response_type":@"in_channel"} options:NSJSONWritingPrettyPrinted error:nil]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:requet completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data.length > 0 && [[NSString stringWithUTF8String:data.bytes] isEqualToString:@"ok"]) {
            if (type == NFeedbackTypeReport) [self slackFileUpload];
            
            completion([NSError errorWithDomain:@"no errors" code:200 userInfo:nil]);
            
        }
        else completion(error);
        
    }];
    
    [task resume];
    
}

-(void)slackFileUpload {
    NSDictionary *params = @{@"channels":SLACK_CHANNEL};
    NSMutableData *body = [NSMutableData data];
    for (NSString *name in params.allKeys) {
        [body appendData:[[NSString stringWithFormat:@"--%@%@", SLACK_CHANNEL_NAME, @"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", name] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@", [params objectForKey:name]] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    if (self.slackScreenshotData != nil) {
        [body appendData:[[NSString stringWithFormat:@"--%@%@", SLACK_CHANNEL_NAME, @"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"screenshot.png\"%@", @"file", @"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: text/plain"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@%@", @"\r\n", @"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:self.slackScreenshotData];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--", SLACK_CHANNEL_NAME] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://slack.com/api/files.upload?token=%@&pretty=1" ,SLACK_TOKEN]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:10];
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@" ,SLACK_CHANNEL_NAME] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:body];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (self.debug) {
            if (!error && data.length > 0 && [[NSString stringWithUTF8String:data.bytes] isEqualToString:@"ok"]) {
                [self slackScreenshotRemove];
                
            }
            
        }
        
    }];
    
    [task resume];

}

@end
