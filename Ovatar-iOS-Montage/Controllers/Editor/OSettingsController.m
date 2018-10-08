//
//  ODocumentController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 22/09/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OSettingsController.h"
#import "OConstants.h"
#import "OSettingsCell.h"

@interface OSettingsController ()

@end

@implementation OSettingsController

#define MODAL_HEIGHT ([UIApplication sharedApplication].delegate.window.bounds.size.height - 180.0)

-(instancetype)init {
    self = [super init];
    if (self) {
        self.data = [[NSUserDefaults alloc] initWithSuiteName:APP_SAVE_DIRECTORY];
        
        self.generator = [[UINotificationFeedbackGenerator alloc] init];
        
        self.payment = [[OPaymentObject alloc] init];
        
        self.mixpanel = [Mixpanel sharedInstance];
        
        self.dataobj = [[ODataObject alloc] init];
        self.dataobj.delegate = self;
        
        self.imageobj = [OImageObject sharedInstance];
        
    }
    
    return self;
    
}

-(void)present:(OSettingsSubviewType)type {
    if (![[UIApplication sharedApplication].delegate.window.subviews containsObject:self.viewOverlay]) {
        self.viewOverlay = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].delegate.window.bounds];
        self.viewOverlay.backgroundColor = MAIN_MODAL_BACKGROUND;
        self.viewOverlay.alpha = 0.0;
        self.viewOverlay.userInteractionEnabled = true;
        
        self.viewRounded = [CAShapeLayer layer];
        self.viewRounded.path = [UIBezierPath bezierPathWithRoundedRect:self.viewOverlay.bounds byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight cornerRadii:CGSizeMake(MAIN_CORNER_EDGES, MAIN_CORNER_EDGES)].CGPath;
        
        self.viewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height, self.viewOverlay.bounds.size.width, MODAL_HEIGHT - self.padding)];
        self.viewContainer.backgroundColor = UIColorFromRGB(0xF4F6F8);
        self.viewContainer.layer.mask = self.viewRounded;
        
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        [[UIApplication sharedApplication].delegate.window addSubview:self.viewOverlay];
        [[UIApplication sharedApplication].delegate.window addSubview:self.viewContainer];
        
        self.viewGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gesture:)];
        self.viewGesture.delegate = self;
        self.viewGesture.enabled = true;
        [self.viewOverlay addGestureRecognizer:self.viewGesture];

        self.viewFooter = [[OSettingsFooter alloc] initWithFrame:CGRectMake(0.0, 0.0, self.viewContainer.bounds.size.width, 280.0 + self.padding)];
        self.viewFooter.backgroundColor = [UIColor clearColor];
        
        self.viewTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0, MAIN_HEADER_MODAL_HEIGHT, self.viewContainer.bounds.size.width, self.viewContainer.bounds.size.height - MAIN_HEADER_MODAL_HEIGHT)];
        self.viewTable.dataSource = self;
        self.viewTable.delegate = self;
        self.viewTable.separatorColor = [UIColor clearColor];
        self.viewTable.backgroundColor = [UIColor clearColor];
        self.viewTable.tableFooterView = self.viewFooter;
        [self.viewContainer addSubview:self.viewTable];
        [self.viewTable registerClass:[OSettingsCell class] forCellReuseIdentifier:@"cell"];
        
        self.viewSheet = [[GDActionSheet alloc] initWithFrame:super.bounds];
        self.viewSheet.viewColour = [UIColor whiteColor];
        self.viewSheet.delegate = self;
        self.viewSheet.cancelAction = false;
        self.viewSheet.presentAction = false;
        self.viewSheet.safearea = self.padding;

        self.viewHeader = [[OTitleView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.viewContainer.bounds.size.width, MAIN_HEADER_MODAL_HEIGHT)];
        self.viewHeader.backgroundColor = [UIColor clearColor];
        self.viewHeader.delegate = self;
        self.viewHeader.title = NSLocalizedString(@"Main_Settings_Title", nil);
        self.viewHeader.backbutton = false;
        [self.viewContainer addSubview:self.viewHeader];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.viewOverlay setAlpha:1.0];
            
        } completion:^(BOOL finished) {
            [self.generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            [self.generator prepare];
            
        }];
        
        [UIView animateWithDuration:0.7 delay:0.25 usingSpringWithDamping:0.6 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT + 80.0)];
            
        } completion:^(BOOL finished) {
            [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height - MODAL_HEIGHT, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
            
        }];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldShouldChangeCharacters:) name:UITextFieldTextDidChangeNotification object:nil];

    [self setup:type];
   
}

-(void)setup:(OSettingsSubviewType)type {
    self.sections = [[NSMutableArray alloc] init];
    self.document = [[NSMutableArray alloc] init];
    self.settings = [[NSMutableArray alloc] init];
    self.music = [[NSMutableArray alloc] init];
    self.imported = [[NSMutableArray alloc] init];;
    self.watermarks = [[NSMutableArray alloc] init];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEE d MMMM YYYY";
    formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSString *location = [NSString stringWithFormat:@"%@, %@" ,[self.dataobj.storyActive objectForKey:@"city"], [self.dataobj.storyActive objectForKey:@"country"]];
    
    if (type == OSettingsSubviewTypeMusic) {
        [self.music addObject:@{@"key":@"audio_empty",
                                @"title":NSLocalizedString(@"Settings_Music_None", nil),
                                @"file":@"",
                                @"type":@"selection",
                                @"pro":@(false)
                                }];
        
        [self.music addObject:@{@"key":@"audio_custom",
                                @"title":NSLocalizedString(@"Settings_Music_Custom", nil),
                                @"subtitle":NSLocalizedString(@"Settings_Music_Custom_Description", nil),
                                @"file":@"",
                                @"type":@"selection",
                                @"pro":@(true)
                                }];
        
        [self.music addObject:@{@"key":@"audio_1",
                                @"title":NSLocalizedString(@"Settings_Music_Country", nil),
                                @"file":@"ES_Barefoot_Summer_24_Stefan_Netsman",
                                @"subtitle":@"Stefan Netsman",
                                @"bpm":@(149),
                                @"type":@"selection",
                                @"source":@"bundle",
                                @"pro":@(false)
                                }];
        
        [self.music addObject:@{@"key":@"audio_2",
                                @"title":NSLocalizedString(@"Settings_Music_Epic", nil),
                                @"file":@"ES_Castle_In_The_Sky_Johannes_Bornlöf",
                                @"subtitle":@"Johannes Bornlöf",
                                @"bpm":@(136),
                                @"type":@"selection",
                                @"source":@"bundle",
                                @"pro":@(false)
                                }];
        
        [self.music addObject:@{@"key":@"audio_3",
                                @"title":NSLocalizedString(@"Settings_Music_Dance", nil),
                                @"file":@"ES_Green_Summer_Waves_Qeeo",
                                @"subtitle":@"Qeeo",
                                @"bpm":@(101),
                                @"type":@"selection",
                                @"source":@"bundle",
                                @"pro":@(false)
                                }];
        
        [self.music addObject:@{@"key":@"audio_4",
                                @"title":NSLocalizedString(@"Settings_Music_HipHop", nil),
                                @"file":@"ES_Generation_Z_APOLLO",
                                @"subtitle":@"A P O L L O",
                                @"bpm":@(134),
                                @"type":@"selection",
                                @"source":@"bundle",
                                @"pro":@(false)
                                }];
        
        for (NSDictionary *song in self.dataobj.musicImported) {
            [self.music addObject:@{@"key":[song objectForKey:@"key"],
                                    @"title":[song objectForKey:@"name"],
                                    @"file":[song objectForKey:@"file"],
                                    @"subtitle":[song objectForKey:@"artist"],
                                    @"type":@"selection",
                                    @"source":[song objectForKey:@"type"],
                                    @"pro":@(true)
                                    }];
            
        }
        
        [self.sections addObject:@{@"key":@"music", @"title":NSLocalizedString(@"Main_Project_Title", nil), @"items":self.music}];
        
        [self.viewHeader setTitle:NSLocalizedString(@"Document_Music_Title", nil)];
        [self.viewHeader setBackbutton:true];
        [self.viewHeader setup:@[] animate:true];
        [self.viewFooter setHidden:true];
        [self.viewTable reloadData];

    }
    else if (type == OSettingsSubviewTypeWatermark) {
       
        
        [self.watermarks addObject:@{@"key":@"watermark_default",
                                    @"title":NSLocalizedString(@"Settings_Watermark_Default", nil),
                                    @"example":@"ovatar.io/montage",
                                    @"type":@"selection",
                                    @"subtitle":@"ovatar.io/montage",
                                    @"pro":@(false)
                                    }];
        
        [self.watermarks addObject:@{@"key":@"watermark_title",
                                     @"title":NSLocalizedString(@"Settings_Watermark_Title", nil),
                                     @"example":@"",
                                     @"type":@"selection",
                                     @"subtitle":self.dataobj.storyActiveName,
                                     @"pro":@(true)
                                     }];
        
        [self.watermarks addObject:@{@"key":@"watermark_timetamp",
                                     @"title":NSLocalizedString(@"Settings_Watermark_Timestamp", nil),
                                     @"example":@"",
                                     @"type":@"selection",
                                     @"subtitle":[formatter stringFromDate:[NSDate date]],
                                     @"pro":@(true)
                                     }];
        
        [self.watermarks addObject:@{@"key":@"watermark_location",
                                     @"title":NSLocalizedString(@"Settings_Watermark_Location", nil),
                                     @"example":@"",
                                     @"type":@"selection",
                                     @"subtitle":location,
                                     @"pro":@(true)
                                     }];
        
        [self.watermarks addObject:@{@"key":@"watermark_none",
                                    @"title":NSLocalizedString(@"Settings_Watermark_None", nil),
                                    @"example":@"",
                                    @"type":@"selection",
                                    @"pro":@(true)
                                    }];
        
        [self.sections addObject:@{@"key":@"watermark", @"title":NSLocalizedString(@"Main_Project_Title", nil), @"items":self.watermarks}];
        
        [self.viewHeader setTitle:NSLocalizedString(@"Document_Watermark_Title", nil)];
        [self.viewHeader setBackbutton:true];
        [self.viewHeader setup:@[] animate:true];
        [self.viewFooter setHidden:true];
        [self.viewTable reloadData];
        
    }
    else {
        NSString *watermark = nil;
        NSString *music = nil;
        if (self.dataobj.musicActive != nil) {
            if (![[self.dataobj.musicActive objectForKey:@"type"] isEqualToString:@"ipod"])
                music = [NSString stringWithFormat:@"%@" ,[self.dataobj.musicActive objectForKey:@"name"]];
            else
                music = [NSString stringWithFormat:@"%@ - %@" ,[self.dataobj.musicActive objectForKey:@"name"], [self.dataobj.musicActive objectForKey:@"artist"]];
            
        }
        else music = NSLocalizedString(@"Settings_Music_None", nil);
        
        if ([[self.dataobj.storyActive objectForKey:@"watermark"] isEqualToString:@"watermark_default"])
            watermark = @"ovatar.io/montage";
        else if ([[self.dataobj.storyActive objectForKey:@"watermark"] isEqualToString:@"watermark_title"])
            watermark = self.dataobj.storyActiveName;
        else if ([[self.dataobj.storyActive objectForKey:@"watermark"] isEqualToString:@"watermark_timestamp"])
            watermark = [formatter stringFromDate:[NSDate date]];
        else if ([[self.dataobj.storyActive objectForKey:@"watermark"] isEqualToString:@"watermark_location"])
            watermark = location;
        else
            watermark = NSLocalizedString(@"Settings_Watermark_None", nil);

        NSLog(@"self.dataobj.storyActiveName %@ %@" ,self.dataobj.storyActiveName, self.dataobj.storyActive);
        [self.document addObject:@{@"key":@"name",
                                   @"title":NSLocalizedString(@"Document_StoryName_Title", nil),
                                   @"type":@"input",
                                   @"placeholder":self.dataobj.storyActiveName,
                                   @"subtitle":NSLocalizedString(@"Settings_Subtitle_Title", nil),
                                   @"icon":@"settings_title"
                                   }];
        /*
        [self.document addObject:@{@"key":@"speed",
                                   @"title":NSLocalizedString(@"Document_Speed_Title", nil),
                                   @"type":@"slider",
                                   @"icon":@"settings_speed"
                                   }];
        */
        [self.document addObject:@{@"key":@"music",
                                   @"title":NSLocalizedString(@"Document_Music_Title", nil),
                                   @"subtitle":music,
                                   @"type":@"action",
                                   @"icon":@"settings_music"
                                   }];
        
        [self.document addObject:@{@"key":@"watermark",
                                   @"title":NSLocalizedString(@"Document_Watermark_Title", nil),
                                   @"subtitle":watermark,
                                   @"type":@"action",
                                   @"icon":@"settings_watermark"
                                   }];
        
        [self.settings addObject:@{@"key":@"share",
                                   @"title":NSLocalizedString(@"Settings_Item_Share", nil),
                                   @"type":@"action",
                                   @"icon":@"settings_share"
                                   }];
        
        [self.settings addObject:@{@"key":@"support",
                                   @"title":NSLocalizedString(@"Settings_Item_Support", nil),
                                   @"type":@"action",
                                   @"icon":@"settings_support"
                                   }];
        
        [self.settings addObject:@{@"key":@"ovatar",
                                   @"title":NSLocalizedString(@"Settings_Item_Ovatar", nil),
                                   @"type":@"action",
                                   @"icon":@"settings_ovatar"
                                   }];
        
        [self.settings addObject:@{@"key":@"legal",
                                   @"title":NSLocalizedString(@"Settings_Item_Legal", nil),
                                   @"type":@"action",
                                   @"icon":@"settings_legal"
                                   }];
        
        [self.settings addObject:@{@"key":@"purchases",
                                   @"title":NSLocalizedString(@"Settings_Item_Purchases", nil),
                                   @"type":@"action",
                                   @"icon":@"settings_purchases"
                                   }];
        
        [self.sections addObject:@{@"key":@"main", @"title":NSLocalizedString(@"Main_Settings_Title", nil), @"items":self.document}];
        [self.sections addObject:@{@"key":@"main", @"title":NSLocalizedString(@"Main_Settings_Title", nil), @"items":self.settings}];
        
        [self.viewHeader setTitle:NSLocalizedString(@"Main_Settings_Title", nil)];
        [self.viewHeader setBackbutton:false];
        [self.viewHeader setup:@[@"navigation_close"] animate:true];
        [self.viewFooter setHidden:false];
        [self.viewTable reloadData];

    }
    
    self.type = type;

}

-(void)titleNavigationBackTapped:(UIButton *)button {
    [self tableViewReloadContent:OSettingsSubviewTypeMain];
    
}

-(void)titleNavigationButtonTapped:(OTitleButtonType)button {
    if (button == OTitleButtonTypeClose) {
        [self dismiss:^(BOOL dismissed) {
            
        }];
        
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self.sections objectAtIndex:section] objectForKey:@"items"] count];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65.0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSettingsCell *cell = (OSettingsCell *)[self.viewTable dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *item = [[[self.sections objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    NSString *title = [item objectForKey:@"title"];
    NSString *placeholder = [item objectForKey:@"placeholder"];
    NSString *type = [item objectForKey:@"type"];
    NSString *icon = [item objectForKey:@"icon"];
    NSString *key = [item objectForKey:@"key"];
    NSString *file = [item objectForKey:@"file"];
    NSString *subtitle = [item objectForKey:@"subtitle"];
    BOOL pro = false;

    if ([self.payment paymentPurchasedItemWithProducts:@[@"montage.monthly", @"montage.yearly"]]) pro = false;
    else pro = [[item objectForKey:@"pro"] boolValue];
    
    [cell setIndex:indexPath];
    
    if ([type isEqualToString:@"action"]) {
        [cell.cellTitle setHidden:false];
        [cell.cellInput setHidden:true];
        [cell.cellInput setEnabled:false];
        [cell.cellAccessory setHidden:false];
        [cell.cellToggled setHidden:true];
        [cell.cellIcon setHidden:false];

    }
    else if ([type isEqualToString:@"selection"]) {
        [cell.cellTitle setHidden:false];
        [cell.cellInput setHidden:true];
        [cell.cellInput setEnabled:false];
        [cell.cellAccessory setHidden:true];
        [cell.cellToggled setHidden:false];
        [cell.cellIcon setHidden:true];

        if (self.type == OSettingsSubviewTypeMusic) {
            if ([self.dataobj musicActive] != nil) {
                if ([[self.dataobj.musicActive objectForKey:@"file"] containsString:file]) [cell.cellToggled setToggled:true];
                else [cell.cellToggled setToggled:false];
                
            }
            else {
                if ([key isEqualToString:@"audio_empty"]) [cell.cellToggled setToggled:true];
                else [cell.cellToggled setToggled:false];
                
            }
            
        }
        else if (self.type == OSettingsSubviewTypeWatermark) {
            NSString *watermark = [self.dataobj.storyActive objectForKey:@"watermark"];
            if ([watermark isEqualToString:key]) [cell.cellToggled setToggled:true];
            else [cell.cellToggled setToggled:false];
        
        }

    }
    else if ([type isEqualToString:@"slider"]) {
        [cell.cellTitle setHidden:true];
        [cell.cellInput setHidden:true];
        [cell.cellInput setEnabled:false];
        [cell.cellAccessory setHidden:true];
        [cell.cellToggled setHidden:true];
        [cell.cellIcon setHidden:false];

    }
    else if ([type isEqualToString:@"input"]) {
        [cell.cellTitle setHidden:true];
        [cell.cellInput setHidden:false];
        [cell.cellInput setText:placeholder];
        [cell.cellInput setDelegate:self];
        [cell.cellInput setEnabled:true];
        [cell.cellAccessory setHidden:true];
        [cell.cellToggled setHidden:true];
        [cell.cellIcon setHidden:false];

    }
    
    if ([subtitle length] > 1) {
        [cell.cellSubtitle setHidden:false];
        if (self.type == OSettingsSubviewTypeMusic) {
            [cell.cellSubtitle setText:[NSString stringWithFormat:NSLocalizedString(@"Settings_Music_Artist", nil), subtitle]];
             
        }
        else [cell.cellSubtitle setText:subtitle];

    }
    else {
        [cell.cellSubtitle setHidden:true];
        [cell.cellSubtitle setText:nil];

    }
    
    if ([icon length] > 1) {
        [cell.cellIcon setImage:[UIImage imageNamed:icon]];
        [cell.cellIcon setTransform:CGAffineTransformMakeScale(0.7, 0.7)];
        [cell.cellIcon setAlpha:0.3];

    }
    else {
        [cell.cellIcon setImage:[UIImage imageNamed:icon]];
        [cell.cellIcon setAlpha:0.0];

    }
    
    [cell.cellTitle setText:title];
    [cell.cellBadge setHidden:!pro];
    
    [cell.contentView setBackgroundColor:UIColorFromRGB(0xF4F6F8)];
    [cell setBackgroundColor:[UIColorFromRGB(0xAAAAB8) colorWithAlphaComponent:0.2]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [[[self.sections objectAtIndex:indexPath.section] objectForKey:@"items"] objectAtIndex:indexPath.row];
    NSString *key = [item objectForKey:@"key"];
    NSString *section = [[self.sections objectAtIndex:indexPath.section] objectForKey:@"key"];

    if ([section isEqualToString:@"main"]) {
        if ([key isEqualToString:@"music"]) {
            [self tableViewReloadContent:OSettingsSubviewTypeMusic];
            
        }
        
        if ([key isEqualToString:@"watermark"]) {
            [self tableViewReloadContent:OSettingsSubviewTypeWatermark];

        }
        
        if ([key isEqualToString:@"share"]) {
            [self dismiss:^(BOOL dismissed) {
                [self.delegate modalAlertCallActivityController:@[NSLocalizedString(@"Settings_Share_Text", nil), [NSURL URLWithString:@"https://ovatar.io/montage"]]];
                
            }];

        }
        
        if ([key isEqualToString:@"support"]) {
            [self dismiss:^(BOOL dismissed) {
                [self.delegate modalAlertCallFeedbackSubview];

            }];
            
        }
        
        if ([key isEqualToString:@"legal"]) {
            [self.delegate modalAlertCallActionSheet:@[
                                                       @{@"key":@"subscription", @"title":NSLocalizedString(@"Terms_Subscription_Title", nil)},
                                                       @{@"key":@"terms", @"title":NSLocalizedString(@"Settings_ActionSheet_Privacy", nil)}]
                                                 key:@"legal"];
            
        }
        
        if ([key isEqualToString:@"ovatar"]) {
            [self.delegate modalAlertCallActionSheet:@[
                        @{@"key":@"instagram", @"title":NSLocalizedString(@"Settings_ActionSheet_Instagram", nil)},
                        @{@"key":@"website", @"title":NSLocalizedString(@"Settings_ActionSheet_Website", nil)}]
                                                 key:@"ovatar"];
            
        }
        
        if ([key isEqualToString:@"purchases"]) {
            [self dismiss:^(BOOL dismissed) {
                [self.delegate viewRestorePurchases];
                
            }];
            
        }
        
    }
    else if ([section isEqualToString:@"watermark"]) {
        if (![key isEqualToString:@"watermark_default"]) {
            if (![self.payment paymentPurchasedItemWithProducts:@[@"montage.monthly", @"montage.yearly", @"montage_watermark"]]) {
                [self dismiss:^(BOOL dismissed) {
                    [self.delegate modalAlertCallPurchaseSubview:0];
                    
                }];
                
                return ;

            }
            
        }
        
        [self tableViewSelected:item index:indexPath];
        [self.dataobj storyAppendWatermark:self.dataobj.storyActiveKey watermark:[item objectForKey:@"key"] completion:^(NSError *error) {
            if (error.code != 200) [self tableViewSelected:nil index:indexPath];

        }];
        
    }
    else if ([section isEqualToString:@"music"]) {
        if ([key isEqualToString:@"audio_empty"]) {
            [self tableViewSelected:item index:indexPath];
            [self.dataobj storyAppendMusic:self.dataobj.storyActiveKey music:@"" completion:^(NSError *error) {
                if (error.code != 200) [self tableViewSelected:nil index:indexPath];

            }];
            
        }
        else {
            if ([key isEqualToString:@"audio_custom"]) {
                if (![self.payment paymentPurchasedItemWithProducts:@[@"montage.monthly", @"montage.yearly", @"montage_watermark"]]) {
                    [self dismiss:^(BOOL dismissed) {
                        [self.delegate modalAlertCallPurchaseSubview:0];
                     
                    }];

                }
                else {
                    [self dismiss:^(BOOL dismissed) {
                        [self.delegate modalAlertCallMusicController];
                        
                    }];
                    
                }
                
            }
            else {
                ODataMusicType type = ODataMusicTypeBundle;
                NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
                if ([[item objectForKey:@"source"] isEqualToString:@"bundle"]) {
                    [data addEntriesFromDictionary:item];
                    [data setObject:[item objectForKey:@"subtitle"] forKey:@"artist"];

                    type = ODataMusicTypeBundle;
                
                }
                else if ([[item objectForKey:@"source"] isEqualToString:@"ipod"]) {
                    [data addEntriesFromDictionary:item];
                    [data setObject:[item objectForKey:@"subtitle"] forKey:@"artist"];

                    type = ODataMusicTypeIPod;

                }
                
                [self tableViewSelected:item index:indexPath];
                [self.dataobj musicCreate:self.dataobj.storyActiveKey music:data type:type completion:^(NSError *error) {
                    if (error.code != 200) [self tableViewSelected:nil index:indexPath];

                }];
                
            }
            
        }
        
    }
    
    [self.viewTable deselectRowAtIndexPath:indexPath animated:true];

}

-(void)tableViewSelected:(NSDictionary *)item index:(NSIndexPath *)index {
    if (self.selected != item && item != nil) self.selected = item;
    
    for (OSettingsCell *cell in self.viewTable.visibleCells) {
        if (index == cell.index && self.selected != nil) [cell.cellToggled toggled:true animated:true];
        else [cell.cellToggled toggled:false animated:true];
        
    }
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(OSettingsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    float iconwidth = 0.0;
    float iconpadding = 0.0;

    if (cell.cellIcon.hidden) {
        iconwidth = 0.0;
        iconpadding = 8.0;
        
    }
    else {
        iconwidth = 16.0;
        iconpadding = 28.0;
        
    }
    
    [cell.cellIcon setFrame:CGRectMake(iconpadding, (cell.contentView.bounds.size.height * 0.5) - 8.0, iconwidth, iconwidth)];
    if ([cell.cellSubtitle isHidden]) {
        [cell.cellTitle setFrame:CGRectMake(cell.cellIcon.bounds.size.width + iconpadding + 26.0, 4.0, cell.contentView.bounds.size.width - (cell.cellIcon.bounds.size.width + 20.0), cell.contentView.bounds.size.height - 8.0)];
        [cell.cellSubtitle setFrame:CGRectMake(cell.cellIcon.bounds.size.width + iconpadding + 26.0, 4.0, cell.contentView.bounds.size.width - (cell.cellIcon.bounds.size.width + 20.0), cell.contentView.bounds.size.height - 8.0)];
        
    }
    else {
        [cell.cellTitle setFrame:CGRectMake(cell.cellIcon.bounds.size.width + iconpadding + 26.0, 2.0, cell.contentView.bounds.size.width - (cell.cellIcon.bounds.size.width + 20.0), cell.contentView.bounds.size.height - 18.0)];
        [cell.cellSubtitle setFrame:CGRectMake(cell.cellIcon.bounds.size.width + iconpadding + 26.0, 20.0, cell.contentView.bounds.size.width - (cell.cellIcon.bounds.size.width + 20.0), cell.contentView.bounds.size.height - 18.0)];
        
    }

    [cell.cellInput setFrame:cell.cellTitle.frame];
    [cell.cellAccessory setFrame:CGRectMake(cell.contentView.bounds.size.width - 58.0, 24.0, 51.0, cell.contentView.bounds.size.height - 48.0)];
    [cell.cellToggled setFrame:CGRectMake(cell.contentView.bounds.size.width - 58.0, 19.0, cell.contentView.bounds.size.height - 38.0, cell.contentView.bounds.size.height - 38.0)];
    [cell.cellBadge setFrame:CGRectMake(cell.contentView.bounds.size.width - 98.0, 19.0, cell.contentView.bounds.size.height - 38.0, cell.contentView.bounds.size.height - 38.0)];

}

-(void)tableViewReloadContent:(OSettingsSubviewType)content {
    float __block delay = 0.0;
    for (OSettingsCell *cell in self.viewTable.visibleCells) {
        [UIView animateWithDuration:0.08 delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
            [cell setAlpha:0.0];
            [cell setFrame:CGRectMake(cell.frame.origin.x + 22.0, cell.frame.origin.y, cell.bounds.size.width, cell.bounds.size.height)];
            
        } completion:^(BOOL finished) {
            if (cell == self.viewTable.visibleCells.lastObject) {
                [self setup:content];
                
                delay = 0.0;
                for (OSettingsCell *subcell in self.viewTable.visibleCells) {
                    [subcell setAlpha:0.0];
                    [subcell setFrame:CGRectMake(subcell.frame.origin.x + 22.0, subcell.frame.origin.y, subcell.bounds.size.width, subcell.bounds.size.height)];
                    
                    [UIView animateWithDuration:0.08 delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
                        [subcell setAlpha:1.0];
                        [subcell setFrame:CGRectMake(0.0, subcell.frame.origin.y, subcell.bounds.size.width, subcell.bounds.size.height)];
                        
                    } completion:nil];
                    
                    delay += 0.02;

                }
                
            }

        }];
        
        delay += 0.02;
    
    }
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.viewHeader shadow:scrollView.contentOffset.y];

}

-(void)gesture:(UITapGestureRecognizer *)gesture {
    [self dismiss:^(BOOL dismissed) {
        
    }];
 
}

-(void)dismiss:(void (^)(BOOL dismissed))completion {
    [UIView animateWithDuration:0.2 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.viewOverlay setAlpha:0.0];
        [self.viewContainer setFrame:CGRectMake(0.0, self.viewOverlay.bounds.size.height, self.viewOverlay.bounds.size.width, MODAL_HEIGHT)];
        
    } completion:^(BOOL finished) {
        [self.viewTable endEditing:true];
        [self.viewOverlay removeFromSuperview];
        [self.viewContainer removeFromSuperview];
        
        [self.delegate modalAlertDismissed:self];

        [[UIApplication sharedApplication].delegate.window removeFromSuperview];
        [[UIApplication sharedApplication].delegate.window setWindowLevel:UIWindowLevelNormal];
        
        completion(true);
        
    }];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.viewTable endEditing:true];
    return true;
    
}

-(void)textFieldDidShow:(NSNotification*)notification {
    OSettingsCell *cell = (OSettingsCell *)[self.viewTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    self.keyboard = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.viewTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
        [self.viewTable setFrame:CGRectMake(0.0, MAIN_HEADER_MODAL_HEIGHT, self.viewTable.bounds.size.width, self.viewTable.bounds.size.height - (self.keyboard.size.height + self.padding))];
        
        [cell.cellInput setFrame:CGRectMake(cell.cellTitle.frame.origin.x, 4.0, cell.cellTitle.bounds.size.width, cell.contentView.bounds.size.height - 8.0)];
        [cell.cellSubtitle setAlpha:0.0];
        
    } completion:nil];
    
}

-(void)textFieldDidHide:(NSNotification*)notification {
    OSettingsCell *cell = (OSettingsCell *)[self.viewTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.viewTable setFrame:CGRectMake(0.0, MAIN_HEADER_MODAL_HEIGHT, self.viewTable.bounds.size.width, self.viewContainer.bounds.size.height - MAIN_HEADER_MODAL_HEIGHT)];
        
        [cell.cellInput setFrame:CGRectMake(cell.cellTitle.frame.origin.x, 2.0, cell.cellTitle.bounds.size.width, cell.contentView.bounds.size.height - 18.0)];
        [cell.cellSubtitle setAlpha:1.0];
        
    } completion:nil];
    
}

-(void)textFieldShouldChangeCharacters:(NSNotification*)notification {
    UITextField *field = (UITextField *)notification.object;
    NSString *key = [[self.document objectAtIndex:field.tag] objectForKey:@"key"];
    
    if ([key isEqualToString:@"name"] && [field.text length] > 2) {
        [self.dataobj storyAppendName:self.dataobj.storyActiveKey name:field.text completion:^(NSError *error) {
            
        }];
        
    }
    
}

@end
