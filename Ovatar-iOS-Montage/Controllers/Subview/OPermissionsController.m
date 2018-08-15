//
//  OPermissionsController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 31/07/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OPermissionsController.h"
#import "OConstants.h"

@interface OPermissionsController ()

@end

@implementation OPermissionsController

-(void)viewWillLayoutSubviews {
    self.viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(38.0, 48.0, self.view.bounds.size.width - 120.0, 150.0)];
    self.viewLabel.textAlignment = NSTextAlignmentLeft;
    self.viewLabel.text = @"Montage first requires access to your photo library, because what are Montages without images or videos. ";
    self.viewLabel.numberOfLines = 8;
    self.viewLabel.textColor = UIColorFromRGB(0xA7ABAE);
    self.viewLabel.font = [UIFont fontWithName:@"Avenir-Light" size:20.0];
    [self.view addSubview:self.viewLabel];
    
    self.viewAction = [[OActionButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 220.0, self.view.bounds.size.height - 90.0, 210.0, 90.0)];
    self.viewAction.backgroundColor = [UIColor clearColor];
    self.viewAction.clipsToBounds = false;
    self.viewAction.delegate = self;
    self.viewAction.title = @"Allow Access";
    [self.view addSubview:self.viewAction];
    
}

-(void)viewDidLoad {
    [super viewDidLoad];

    self.imageobj = [OImageObject sharedInstance];

    self.view.backgroundColor = [UIColor clearColor];
    
}

-(void)viewActionTapped:(OActionButton *)action {
    [self.delegate viewPresentSubviewWithIndex:1 animate:true];
    [self.delegate viewStorySetup];
    
}

@end
