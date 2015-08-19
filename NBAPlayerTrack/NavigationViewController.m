//
//  NavigationViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/2/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "NavigationViewController.h"
#import "MainMenuViewController.h"

@implementation NavigationViewController

-(void)viewDidLoad
{
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.menuItems = [[NSArray alloc] initWithObjects:@"Main Menu", @"Around the NBA", @"Player Compare", @"Graphs", @"Options", @"References", nil];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *selectedOption = self.menuItems[indexPath.row];
    
    if([selectedOption isEqualToString:@"Main Menu"])
    {
        [self performSegueWithIdentifier:@"MainMenuSegue" sender:self];
    }
    else if([selectedOption isEqualToString:@"Around the NBA"])
    {
        [self performSegueWithIdentifier:@"AroundTheNBASegue" sender:self];
    }
    else if([selectedOption isEqualToString:@"Player Compare"])
    {
        [self performSegueWithIdentifier:@"PlayerCompareSegue" sender:self];
    }
    else if([selectedOption isEqualToString:@"Graphs"])
    {
        [self performSegueWithIdentifier:@"GraphSegue" sender:self];
    }
    else if([selectedOption isEqualToString:@"Options"])
    {
        [self performSegueWithIdentifier:@"OptionsSegue" sender:self];
    }
    else if([selectedOption isEqualToString:@"References"])
    {
        [self performSegueWithIdentifier:@"ReferencesSegue" sender:self];
    }
}

@end
