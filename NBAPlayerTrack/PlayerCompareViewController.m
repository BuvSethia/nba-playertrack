//
//  PlayerCompareViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 8/21/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerCompareViewController.h"
#import "SWRevealViewController.h"

@interface PlayerCompareViewController ()

@end

@implementation PlayerCompareViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Reveal view pan gesture enabling
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //Reveal view
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
    
    //Initializing variables
    self.playerList = Nil;
    [self loadPlayerList];
    
    self.selectedPlayerOne = Nil;
    self.selectedPlayerTwo = Nil;
    self.statTypeToDisplay = Undecided;
    
    //Get rid of extra horizontal lines from table view
    self.statCompareTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    PopupMenuViewController *dest = (PopupMenuViewController*) segue.destinationViewController;
    dest.delegate = self;
    //Based on iOS version, make it so that the modal segue does not place a black screen behind the presented view.
    [dest setPresentationStyleForSelfController:self presentingController:dest];
    
    //If the sender is either of the player select buttons
    if(sender == self.playerOneButton || sender == self.playerTwoButton)
    {
        NSMutableArray *playerNames = [[NSMutableArray alloc] init];
        for(Player *p in self.playerList)
        {
            [playerNames addObject:p.name];
        }
        NSArray *playerNamesArray = [playerNames copy];
        dest.tableMenuItems = playerNamesArray;
        dest.menuCaller = sender;
    }
    //If the sender is the stat type select button
    else if (sender == self.statTypeSelectButton)
    {
        NSArray *statTypeArray = [[NSArray alloc] initWithObjects:@"Per Game", @"Per 36", @"Advanced", @"Per Game Career", @"Advanced Career", nil];
        dest.tableMenuItems = statTypeArray;
        dest.menuCaller = sender;
    }
    //Should never be reached, unless something goes wrong
    else
    {
        NSLog(@"Player compare view unexpected segue");
    }
}

-(void)loadPlayerList
{
    if(self.playerList == Nil && [[NSFileManager defaultManager] fileExistsAtPath:[self userPlayersFilePath]])
    {
        
        self.playerList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self userPlayersFilePath]];
        NSLog(@"Loading players from file");

    }
    else
    {
        NSLog(@"userPlayersFile DNE");
    }
}

-(NSString*)userPlayersFilePath
{
    NSArray *initPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [initPath objectAtIndex:0];
    NSString *path = [documentFolder stringByAppendingFormat:@"/userPlayers.plist"];
    return path;
}

#pragma mark - Table View
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = @"PlayerCompareCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
    
    UILabel *playerOneStatLabel = (UILabel*) [cell viewWithTag:100];
    UILabel *playerTwoStatLabel = (UILabel*) [cell viewWithTag:102];
    UILabel *statName = (UILabel*) [cell viewWithTag:101];
    
    //Determine label text based on stat type requested
    if(self.statTypeToDisplay == PerGame)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.perGameStats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.perGameStats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.perGameStats allKeys][indexPath.row];
    }
    else if(self.statTypeToDisplay == Per36)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.per36Stats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.per36Stats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.per36Stats allKeys][indexPath.row];
    }
    else if(self.statTypeToDisplay == Advanced)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.advancedStats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.advancedStats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.advancedStats allKeys][indexPath.row];
    }
    else if(self.statTypeToDisplay == PerGameCareer)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.careerPerGameStats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.careerPerGameStats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.careerPerGameStats allKeys][indexPath.row];
    }
    else if(self.statTypeToDisplay == AdvancedCareer)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.careerAdvancedStats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.careerAdvancedStats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.careerAdvancedStats allKeys][indexPath.row];
    }
    //Something went horribly wrong if we reach this case
    else
    {
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //If not all required fields are filled, there are no rows
    if(self.selectedPlayerOne == nil || self.selectedPlayerTwo == nil || self.statTypeToDisplay == Undecided)
    {
        return 0;
    }
    //If all required fields are filled, return a count corresponding to the stat type to be displayed. Only have to check one player because all players have the same stats stored.
    else
    {
        if(self.statTypeToDisplay == PerGame)
        {
            return self.selectedPlayerOne.perGameStats.count;
        }
        else if(self.statTypeToDisplay == Per36)
        {
            return self.selectedPlayerOne.per36Stats.count;
        }
        else if(self.statTypeToDisplay == Advanced)
        {
            return self.selectedPlayerOne.advancedStats.count;
        }
        else if(self.statTypeToDisplay == PerGameCareer)
        {
            return self.selectedPlayerOne.careerPerGameStats.count;
        }
        else if(self.statTypeToDisplay == AdvancedCareer)
        {
            return self.selectedPlayerOne.careerAdvancedStats.count;
        }
        //Something went horribly wrong if we reach this case
        else
        {
            return 0;
        }
    }
}

#pragma mark - PopupMenuViewController
-(void)selectedMenuItem:(NSInteger)newItem calledBy:(id)sender
{
    NSLog(@"Popup menu delegate called from player compare");
    if(sender == self.playerOneButton)
    {
        self.selectedPlayerOne = self.playerList[newItem];
        [self.playerOneButton setTitle:self.selectedPlayerOne.name forState:UIControlStateNormal];
        self.playerOneImageView.image = [[UIImage alloc] initWithData:self.selectedPlayerOne.playerImage];
        
    }
    else if(sender == self.playerTwoButton)
    {
        self.selectedPlayerTwo = self.playerList[newItem];
        [self.playerTwoButton setTitle:self.selectedPlayerTwo.name forState:UIControlStateNormal];
        self.playerTwoImageView.image = [[UIImage alloc] initWithData:self.selectedPlayerTwo.playerImage];
    }
    else if(sender == self.statTypeSelectButton)
    {
        self.statTypeToDisplay = (StatType)(newItem + 1);
        NSArray *statTypeArray = [[NSArray alloc] initWithObjects:@"Per Game Season", @"Per 36 Season", @"Advanced", @"Per Game Career", @"Advanced Career", nil];
        [self.statTypeSelectButton setTitle:statTypeArray[newItem] forState:UIControlStateNormal];
    }
    //Should never reach this
    else
    {
       NSLog(@"Unexpected caller of popup menu");
    }
    
    [self.statCompareTableView reloadData];
}

@end
