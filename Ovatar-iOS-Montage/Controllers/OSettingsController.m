//
//  OSettingsController.m
//  Ovatar-iOS-Montage
//
//  Created by Joe Barbour on 06/08/2018.
//  Copyright © 2018 Ovatar. All rights reserved.
//

#import "OSettingsController.h"
#import "OConstants.h"
#import "OSettingsCell.h"

@interface OSettingsController ()

@end

@implementation OSettingsController

-(void)viewDidLoad {
    [super viewDidLoad];

    self.imageobj = [OImageObject sharedInstance];
    
    self.settings = [[NSMutableArray alloc] init];
    
    self.viewHeader = [[OSettingsHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 280.0)];
    self.viewHeader.backgroundColor = [UIColor clearColor];
    
    [self.tableView setTableHeaderView:self.viewHeader];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView registerClass:[OSettingsCell class] forCellReuseIdentifier:@"cell"];
    
}

-(void)tableViewContent {
    [self.settings addObject:@{@"key":@"share", @"title":NSLocalizedString(@"Settings_Item_Share", nil), @"icon":@"settings_share"}];
    [self.settings addObject:@{@"key":@"support", @"title":NSLocalizedString(@"Settings_Item_Support", nil), @"icon":@"settings_support"}];
    [self.settings addObject:@{@"key":@"ovatar", @"title":NSLocalizedString(@"Settings_Item_Ovatar", nil), @"icon":@"settings_ovatar"}];
    [self.settings addObject:@{@"key":@"purchases", @"title":NSLocalizedString(@"Settings_Item_Purchases", nil), @"icon":@"settings_purchases"}];
    
    [self.tableView reloadData];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65.0;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.settings.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSettingsCell *cell = (OSettingsCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    NSDictionary *item = [self.settings objectAtIndex:indexPath.row];
    NSString *title = [item objectForKey:@"title"];
    NSString *icon = [item objectForKey:@"icon"];

    [cell setIndex:indexPath];

    [cell.cellTitle setText:title.uppercaseString];
    [cell.cellIcon setImage:[UIImage imageNamed:icon]];
    [cell.cellIcon setTransform:CGAffineTransformMakeScale(1.0, 1.0)];

    [cell.contentView setBackgroundColor:UIColorFromRGB(0xF4F6F8)];
    [cell setBackgroundColor:[UIColorFromRGB(0xAAAAB8) colorWithAlphaComponent:0.2]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(OSettingsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.cellIcon setFrame:CGRectMake(24.0, (cell.contentView.bounds.size.height * 0.5) - 15.0, 30.0, 30.0)];
    [cell.cellTitle setFrame:CGRectMake(cell.cellIcon.bounds.size.width + 40.0, 4.0, (cell.contentView.bounds.size.width / 2) - 20.0, cell.contentView.bounds.size.height - 8.0)];
    [cell.cellAccessory setFrame:CGRectMake(cell.contentView.bounds.size.width - 58.0, 24.0, 51.0, cell.contentView.bounds.size.height - 48.0)];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = [self.settings objectAtIndex:indexPath.row];
    NSString *key = [item objectForKey:@"key"];
    
    if ([key isEqualToString:@"share"]) {
        NSArray *shareitems = @[NSLocalizedString(@"Settings_Share_Text", nil), [NSURL URLWithString:@"https://ovatar.io/montage"]];
        UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:shareitems applicationActivities:nil];
        [super presentViewController:share animated:true completion:^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
            
        }];
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
        
    }
    
    if ([key isEqualToString:@"support"]) {
        [self.delegate viewInsertSubview:OSettingsSubviewFeedback];
        
    }
    
    if ([key isEqualToString:@"ovatar"]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@" ,@"ovatar.io"]] options:@{} completionHandler:^(BOOL success) {
                
            }];
            
        }
        else {
            self.safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"http://instagram.com/ovatar.io/"]];
            if (@available(iOS 11.0, *)) {
                self.safari.dismissButtonStyle = SFSafariViewControllerDismissButtonStyleDone;
                
            }
            self.safari.view.tintColor = UIColorFromRGB(0x140F26);
            self.safari.delegate = self;
            
            [self presentViewController:self.safari animated:true completion:^{
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
                
            }];
            
        }
            
    }
    
    if ([key isEqualToString:@"purchases"]) {
        [self.delegate viewRestorePurchases];
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];

}

@end
