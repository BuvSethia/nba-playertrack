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

@property NSDictionary *statAcronyms;

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
    
    //Stat acronyms
    self.statAcronyms = [self createStatsAcronymDictionary];
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
        NSArray *statTypeArray = [[NSArray alloc] initWithObjects:@"Per Game Season", @"Per 36 Season", @"Advanced Season", @"Per Game Career", @"Advanced Career", nil];
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
    
    //Determine which player's stat is better to highlight it green (and the lesser one red)
    if([statName.text containsString:@"playerID"] || [statName.text containsString:@"Season"])
    {
        playerOneStatLabel.textColor = [UIColor blackColor];
        playerTwoStatLabel.textColor = [UIColor blackColor];
    }
    else if([self isMinimizeStat:statName.text])
    {
        if([playerOneStatLabel.text doubleValue] < [playerTwoStatLabel.text doubleValue])
        {
            playerOneStatLabel.textColor = [UIColor greenColor];
            playerTwoStatLabel.textColor = [UIColor redColor];
        }
        else if([playerOneStatLabel.text doubleValue] > [playerTwoStatLabel.text doubleValue])
        {
            playerOneStatLabel.textColor = [UIColor redColor];
            playerTwoStatLabel.textColor = [UIColor greenColor];
        }
        else
        {
            playerOneStatLabel.textColor = [UIColor greenColor];
            playerTwoStatLabel.textColor = [UIColor greenColor];
        }
    }
    else
    {
        if([playerOneStatLabel.text doubleValue] > [playerTwoStatLabel.text doubleValue])
        {
            playerOneStatLabel.textColor = [UIColor greenColor];
            playerTwoStatLabel.textColor = [UIColor redColor];
        }
        else if([playerOneStatLabel.text doubleValue] < [playerTwoStatLabel.text doubleValue])
        {
            playerOneStatLabel.textColor = [UIColor redColor];
            playerTwoStatLabel.textColor = [UIColor greenColor];
        }
        else
        {
            playerOneStatLabel.textColor = [UIColor greenColor];
            playerTwoStatLabel.textColor = [UIColor greenColor];
        }
    }
    
    return cell;
}

-(bool)isMinimizeStat:(NSString*)statType
{
    return [statType isEqualToString:@"TOV"] || [statType isEqualToString:@"PF"] || [statType isEqualToString:@"TOVPCT"];
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell selected");
    UILabel *statName = (UILabel*) [[tableView cellForRowAtIndexPath:indexPath] viewWithTag:101];
    UIAlertView *statDesc = [[UIAlertView alloc] initWithTitle:statName.text message:[self.statAcronyms objectForKey:statName.text] delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [statDesc show];
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
        NSArray *statTypeArray = [[NSArray alloc] initWithObjects:@"Per Game Season", @"Per 36 Season", @"Advanced Season", @"Per Game Career", @"Advanced Career", nil];
        [self.statTypeSelectButton setTitle:statTypeArray[newItem] forState:UIControlStateNormal];
    }
    //Should never reach this
    else
    {
       NSLog(@"Unexpected caller of popup menu");
    }
    
    [self.statCompareTableView reloadData];
}

//What each stat acronym stands for
-(NSMutableDictionary*)createStatsAcronymDictionary
{
    NSMutableDictionary *statsAcronyms = [[NSMutableDictionary alloc] init];
    [statsAcronyms setValue:@"PTS" forKey:@"Points - The number of points a player scores per game."];
    [statsAcronyms setValue:@"FGA" forKey:@"Field Goal Attempts - The number of shots a player attempts per game."];
    [statsAcronyms setValue:@"BLK" forKey:@"Blocks - The number of shots a player blocks per game."];
    [statsAcronyms setValue:@"MP" forKey:@"Minutes Played - The number of minutes a player plays per game (48 minutes in a game excluding overtime)."];
    [statsAcronyms setValue:@"3PA" forKey:@"3-Point Attempts - The number of 3-point shots a player attempts per game."];
    [statsAcronyms setValue:@"3PPCT" forKey:@"3-Point % -  The percent of his 3-point attempts a player makes."];
    [statsAcronyms setValue:@"STL" forKey:@"Steals - The number of steals a player gets per game"];
    [statsAcronyms setValue:@"FT" forKey:@"Free Throws - The number of free throws a player makes per game."];
    [statsAcronyms setValue:@"G" forKey:@"Games - The number of games a player has played."];
    [statsAcronyms setValue:@"2PA" forKey:@"2-Point Attempts - The number of 2-point shots a player attempts per game."];
    [statsAcronyms setValue:@"2PPCT" forKey:@"2-Point % - The percent of his 2-point attempts a player makes."];
    [statsAcronyms setValue:@"FG" forKey:@"Field Goals - The number of shots a player makes per game."];
    [statsAcronyms setValue:@"FTPCT" forKey:@"Free Throw % - The percent of his free throw attempts a player makes."];
    [statsAcronyms setValue:@"TRB" forKey:@"Total Rebounds - The number of rebounds a player grabs per game (both offensive and defensive)."];
    [statsAcronyms setValue:@"FGPCT" forKey:@"Field Goal % - The percent of his shots a player makes."];
    [statsAcronyms setValue:@"DRB" forKey:@"Defensive Rebounds - The number of defensive rebounds a player grabs per game."];
    [statsAcronyms setValue:@"TOV" forKey:@"Turnovers - The number of turnovers a player commits per game."];
    [statsAcronyms setValue:@"ORB" forKey:@"Offensive Rebounds - The number of offensive rebounds a player grabs per game."];
    [statsAcronyms setValue:@"2P" forKey:@"2-Pointers - The number of 2-point shots a player makes per game."];
    [statsAcronyms setValue:@"PF" forKey:@"Personal Fouls - The number of fouls a player commits per game."];
    [statsAcronyms setValue:@"3P" forKey:@"3-Pointers - The number of 3-point shots a player makes per game."];
    [statsAcronyms setValue:@"Season" forKey:@"The current season."];
    [statsAcronyms setValue:@"AST" forKey:@"Assists - The number of assists a player gets per game (an assist is received when a player makes a pass to a teammate resulting in a score)."];
    [statsAcronyms setValue:@"FTA" forKey:@"Free Throw Attempts - The number of free throws a player attempts per game."];
    [statsAcronyms setValue:@"STLPCT" forKey:@"Steal % - The percentage of opponent possessions that end with a steal by the player while he is on the floor."];
    [statsAcronyms setValue:@"DRBPCT" forKey:@"Defensive Rebound % - The percentage of available defensive rebounds a player grabs while he is on the floor."];
    [statsAcronyms setValue:@"WS48" forKey:@"Win Shares per 48 Minutes - The number of win shares a player receives per 48 minutes played (normalizing to 48 minutes attempts to account for the fact that not all players get the same playing time)."];
    [statsAcronyms setValue:@"3PAr" forKey:@"3-Point Attempt Rate - The percentage of a player's shots that are 3-point shots."];
    [statsAcronyms setValue:@"TRBPCT" forKey:@"Total Rebound % - The percentage of all available rebounds a player grabs while he is on the floor."];
    [statsAcronyms setValue:@"ASTPCT" forKey:@"Assist % - The percentage of teammate field goals a player assisted while he is on the floor."];
    [statsAcronyms setValue:@"DWS" forKey:@"Defensive Win Shares - The number of win shares a player accumulates on the defensive end."];
    [statsAcronyms setValue:@"PER" forKey:@"Player Efficiency Rating - A measure of per minute production for a player standardized such that the league average is always 15.00"];
    [statsAcronyms setValue:@"OWS" forKey:@"Offensive Win Shares - The number of win shares a player accumulates on the offensive end."];
    [statsAcronyms setValue:@"BLKPCT" forKey:@"Block % - The percentage of opponent 2-point attempts a player blocks while he is on the floor"];
    [statsAcronyms setValue:@"ORBPCT" forKey:@"Offensive Rebound % - The percentage of available offensive rebounds a player grabs while he is on the floor."];
    [statsAcronyms setValue:@"OBPM" forKey:@"Offensive Box Plus/Minus - How many more points per 100 possessions a player contributes on the offensive end compared to a league-average player, translated to an average team."];
    [statsAcronyms setValue:@"WS" forKey:@"Win Shares - How many wins a player contributes to his teams."];
    [statsAcronyms setValue:@"TOVPCT" forKey:@"Turnover % - How many turnovers a player commits per 100 plays."];
    [statsAcronyms setValue:@"USGPCT" forKey:@"Usage % - The percent of his team's possessions a player uses while a player is on the floor (possession defined as a play ending in a shot attempt, free throws, or a turnover)."];
    [statsAcronyms setValue:@"DBPM" forKey:@"Defensive Box Plus/Minus - How many more points per 100 possessions a player contributes on the defensive end compared to a league-average player, translated to an average team."];
    [statsAcronyms setValue:@"TSPCT" forKey:@"True Shooting % - A measure of shooting efficiency that takes into account the value of 3-point shots and free throws."];
    [statsAcronyms setValue:@"FTr" forKey:@"Free Throw Rate - The number of free throws a player attempts per field goal attempt."];
    
    //Because I'm an idiot and too lazy to switch all keys and values manually
    for (NSString *key in [statsAcronyms allKeys]) {
        statsAcronyms[statsAcronyms[key]] = key;
        [statsAcronyms removeObjectForKey:key];
    }
    
    return statsAcronyms;
}

@end
