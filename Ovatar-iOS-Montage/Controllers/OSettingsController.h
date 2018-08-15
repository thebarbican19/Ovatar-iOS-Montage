//
//  OSettingsController.h
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 06/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OLoaderView.h"
#import "OImageObject.h"
#import "OPaymentObject.h"

@interface OSettingsController : UITableViewController <UITableViewDelegate>

@property (nonatomic, strong) OLoaderView *viewHeader;

@property (nonatomic, strong) OPaymentObject *payment;
@property (nonatomic, strong) OImageObject *imageobj;
@property (nonatomic, strong) NSMutableArray *settings;

-(void)viewAnimateHeader;

@end
