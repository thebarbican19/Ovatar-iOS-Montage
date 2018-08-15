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

    self.payment = [[OPaymentObject alloc] init];
    
    self.imageobj = [OImageObject sharedInstance];
    
    self.viewHeader = [[OLoaderView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 280.0)];
    self.viewHeader.backgroundColor = [UIColor clearColor];
    
    [self.tableView setTableHeaderView:self.viewHeader];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65.0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSettingsCell *cell = (OSettingsCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    
    
    return cell;
    
}

@end
