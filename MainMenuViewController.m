//
//  MainMenuViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/2/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SWRevealViewController.h"
#import "Player.h"

@implementation MainMenuViewController

static NSMutableArray *userPlayers = nil;

-(void)viewDidLoad
{
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
}

+(NSMutableArray*)userPlayers
{
    if (userPlayers == nil) userPlayers = [[NSMutableArray alloc] init];
    return userPlayers;
}

#pragma Table View Controller
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userPlayers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlayerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Create a new Player Object
    Player *player = [userPlayers objectAtIndex:indexPath.row];
    UILabel *aLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    aLabel.text = player.name;
    
    NSDictionary *stats = player.perGameStats;
    aLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    aLabel.text = [stats objectForKey:@"PTS"];
    aLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    aLabel.text = [stats objectForKey:@"TRB"];
    aLabel = (UILabel *)[cell.contentView viewWithTag:1006];
    aLabel.text = [stats objectForKey:@"AST"];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

@end
