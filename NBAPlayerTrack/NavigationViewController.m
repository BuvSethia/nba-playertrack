//
//  NavigationViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/2/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "NavigationViewController.h"

@implementation NavigationViewController

-(void)viewDidLoad
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.menuItems = [[NSArray alloc] initWithObjects:@"Main Menu", @"Around the NBA", @"Player Compare", @"Options", @"References", nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell"];
    cell.textLabel.text = self.menuItems[indexPath.row];
    
    return cell;
}

@end
