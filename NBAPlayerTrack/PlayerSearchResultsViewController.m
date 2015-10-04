//
//  PlayerSearchResultsViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerSearchResultsViewController.h"
#import "Player.h"

@implementation PlayerSearchResultsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Navigation item coloring
    self.navigationItem.backBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.filteredPlayerDictionary allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.filteredPlayerDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.filteredPlayerDictionary valueForKey:[[[self.filteredPlayerDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self.filteredPlayerDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Create a new Player for the player at the current index, so we can set the cell's text to the player's name
    Player *player = [[self.filteredPlayerDictionary valueForKey:[[[self.filteredPlayerDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    // Configure the cell
    cell.textLabel.text = player.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView.hidden = YES;
    //If the player has already been selected (perhaps in the unfiltered table), put a checkmark in the cell
    for(Player *p in self.selectedPlayers)
    {
        if([player.ID isEqualToString:p.ID])
        {
            cell.accessoryView.hidden = NO;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            break;
        }
    }
    
    return cell;
}

//Allow the keyboard to be hidden
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
