//
//  BarGraphDataInputViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/14/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "BarGraphDataInputViewController.h"
#import "Player.h"
#import "SWRevealViewController.h"
#import "BarGraphViewController.h"

@interface BarGraphDataInputViewController ()

@property NSMutableArray *playerList;
@property NSMutableArray *selectedPlayersToGraph;
@property NSMutableArray *selectedStatsToGraph;

@end

@implementation BarGraphDataInputViewController

//Max number of players and stats a user can select
const int MAX_PLAYERS = 3;
const int MAX_STATS = 5;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerList = nil;
    [self loadPlayerList];
    
    self.selectedPlayersToGraph = [[NSMutableArray alloc] init];
    self.selectedStatsToGraph = [[NSMutableArray alloc] init];
    
    //Removes horizontal lines from the table view
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //If the user has no players saved in the app, the user can't make graphs, so let them know that and return to graph selection menu
    if(self.playerList.count == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"You must have at least one player in your player list to use this feature." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    //Set the orientation of the view as landscape to use space better
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (IBAction)graphTypeButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectedPlayersToGraph.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PlayerNameCell"];
    Player *player = self.selectedPlayersToGraph[indexPath.row];
    cell.textLabel.text = player.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedPlayersToGraph removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

#pragma mark - Popup Menu
-(void)selectedMenuItem:(NSInteger)newItem calledBy:(id)sender
{
    if(sender == self.selectPlayerButton)
    {
        Player *p = self.playerList[newItem];
        bool alreadySelectedPlayer = NO;
        for(Player *player in self.selectedPlayersToGraph)
        {
            if([player.ID isEqualToString:p.ID])
            {
                alreadySelectedPlayer = YES;
                break;
            }
        }
        if(!alreadySelectedPlayer)
        {
            [self.selectedPlayersToGraph addObject:p];
            NSLog(@"Added player %@ to selected players to graph", p.ID);
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot select the same player twice" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        [self.tableView reloadData];
    }
    else if (sender == self.perGameSeasonButton)
    {
        Player *p = self.playerList[0];
        NSString *selectedStat = [NSString stringWithFormat:@"Per Game Season - %@", [[p.perGameStats allKeys] objectAtIndex:newItem]];
        bool alreadySelectedStat = NO;
        for(NSString *statType in self.selectedStatsToGraph)
        {
            if([statType isEqualToString:selectedStat])
            {
                alreadySelectedStat = YES;
                break;
            }
        }
        if(!alreadySelectedStat)
        {
            [self.selectedStatsToGraph addObject:selectedStat];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot select the same stat twice" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        
        [self.collectionView reloadData];
    }
    else if (sender == self.perGameCareerButton)
    {
        Player *p = self.playerList[0];
        NSString *selectedStat = [NSString stringWithFormat:@"Per Game Career - %@", [[p.careerPerGameStats allKeys] objectAtIndex:newItem]];
        
        bool alreadySelectedStat = NO;
        for(NSString *statType in self.selectedStatsToGraph)
        {
            if([statType isEqualToString:selectedStat])
            {
                alreadySelectedStat = YES;
                break;
            }
        }
        if(!alreadySelectedStat)
        {
            [self.selectedStatsToGraph addObject:selectedStat];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot select the same stat twice" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        
        [self.collectionView reloadData];
    }
    else if (sender == self.advancedSeasonButton)
    {
        Player *p = self.playerList[0];
        NSString *selectedStat = [NSString stringWithFormat:@"Advanced Season - %@", [[p.advancedStats allKeys] objectAtIndex:newItem]];
        
        bool alreadySelectedStat = NO;
        for(NSString *statType in self.selectedStatsToGraph)
        {
            if([statType isEqualToString:selectedStat])
            {
                alreadySelectedStat = YES;
                break;
            }
        }
        if(!alreadySelectedStat)
        {
            [self.selectedStatsToGraph addObject:selectedStat];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot select the same stat twice" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        
        [self.collectionView reloadData];
    }
    else if (sender == self.advancedCareerButton)
    {
        Player *p = self.playerList[0];
        NSString *selectedStat = [NSString stringWithFormat:@"Advanced Career - %@", [[p.careerAdvancedStats allKeys] objectAtIndex:newItem]];
        
        bool alreadySelectedStat = NO;
        for(NSString *statType in self.selectedStatsToGraph)
        {
            if([statType isEqualToString:selectedStat])
            {
                alreadySelectedStat = YES;
                break;
            }
        }
        if(!alreadySelectedStat)
        {
            [self.selectedStatsToGraph addObject:selectedStat];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot select the same stat twice" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        
        [self.collectionView reloadData];
    }
    else if (sender == self.per36Button)
    {
        Player *p = self.playerList[0];
        NSString *selectedStat = [NSString stringWithFormat:@"Per 36 Season - %@", [[p.per36Stats allKeys] objectAtIndex:newItem]];
        
        bool alreadySelectedStat = NO;
        for(NSString *statType in self.selectedStatsToGraph)
        {
            if([statType isEqualToString:selectedStat])
            {
                alreadySelectedStat = YES;
                break;
            }
        }
        if(!alreadySelectedStat)
        {
            [self.selectedStatsToGraph addObject:selectedStat];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot select the same stat twice" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        
        [self.collectionView reloadData];
    }
}

#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.selectedStatsToGraph.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"StatTypeCell" forIndexPath:indexPath];
    cell.layer.borderWidth = 0.5f;
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    
    UILabel *statName = (UILabel *)[cell viewWithTag:1];
    statName.text = self.selectedStatsToGraph[indexPath.row];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedStatsToGraph removeObjectAtIndex:indexPath.row];
    [self.collectionView reloadData];
}


#pragma mark - Navigation

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if(self.selectedPlayersToGraph.count > 0 && self. selectedPlayersToGraph.count <= MAX_PLAYERS && self.selectedStatsToGraph.count > 0 && self.selectedStatsToGraph.count <= MAX_STATS && [identifier isEqualToString:@"DisplayBarGraphSegue"])
    {
        return YES;
    }
    else if(self.selectedStatsToGraph.count < MAX_STATS && (sender == self.perGameSeasonButton || sender == self.perGameCareerButton || sender == self.advancedSeasonButton || sender == self.advancedCareerButton || sender == self.per36Button))
    {
        return YES;
    }
    else if(self.selectedPlayersToGraph.count < MAX_PLAYERS && sender == self.selectPlayerButton)
    {
        return YES;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The number of selected players must be between 1 and 3 and the number of selected stats must be between 1 and 5." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //If we are showing the bar graph
    if([segue.identifier isEqualToString:@"DisplayBarGraphSegue"])
    {
        BarGraphViewController *dest = (BarGraphViewController*) segue.destinationViewController;
        dest.playersToGraph = self.selectedPlayersToGraph;
        dest.xAxisDescriptors = self.selectedStatsToGraph;
        dest.statsToGraph = [self createDictionaryOfStatsToGraph];
        dest.normalizedStatsToGraph = [self createNormalizedDictionaryOfStatsToGraph:[self createDictionaryOfStatsToGraph]];
    }
    //If we are presenting data using the pop up menu
    else
    {
        PopupMenuViewController *dest = (PopupMenuViewController*) segue.destinationViewController;
        dest.delegate = self;
        //Based on iOS version, make it so that the modal segue does not place a black screen behind the presented view.
        [dest setPresentationStyleForSelfController:self presentingController:dest];
        dest.menuCaller = sender;
        
        if(sender == self.selectPlayerButton)
        {
            NSMutableArray *playerNames = [[NSMutableArray alloc] init];
            for(Player *p in self.playerList)
            {
                [playerNames addObject:p.name];
            }
            NSArray *playerNamesArray = [playerNames copy];
            dest.tableMenuItems = playerNamesArray;
        }
        else if (sender == self.perGameSeasonButton)
        {
            Player *p = self.playerList[0];
            dest.tableMenuItems = [p.perGameStats allKeys];
        }
        else if (sender == self.perGameCareerButton)
        {
            Player *p = self.playerList[0];
            dest.tableMenuItems = [p.careerPerGameStats allKeys];
        }
        else if (sender == self.advancedSeasonButton)
        {
            Player *p = self.playerList[0];
            dest.tableMenuItems = [p.advancedStats allKeys];
        }
        else if (sender == self.advancedCareerButton)
        {
            Player *p = self.playerList[0];
            dest.tableMenuItems = [p.careerAdvancedStats allKeys];
        }
        else if (sender == self.per36Button)
        {
            Player *p = self.playerList[0];
            dest.tableMenuItems = [p.per36Stats allKeys];
        }
        else
        {
            
        }
    }
}

-(NSMutableDictionary*)createDictionaryOfStatsToGraph
{
    NSMutableDictionary *statsToGraphDictionary = [[NSMutableDictionary alloc] init];
    
    for(NSString *stat in self.selectedStatsToGraph)
    {
        [statsToGraphDictionary setValue:[[NSMutableArray alloc] init] forKey:stat];
        
        NSString *statType = [[stat componentsSeparatedByString:@" - "] objectAtIndex:1];
        if([stat containsString:@"Per Game Season"])
        {
            for(Player *player in self.selectedPlayersToGraph)
            {
                [[statsToGraphDictionary objectForKey:stat] addObject:[player.perGameStats objectForKey:statType]];
            }
        }
        else if([stat containsString:@"Per Game Career"])
        {
            for(Player *player in self.selectedPlayersToGraph)
            {
                [[statsToGraphDictionary objectForKey:stat] addObject:[player.careerPerGameStats objectForKey:statType]];
            }
        }
        else if([stat containsString:@"Advanced Season"])
        {
            for(Player *player in self.selectedPlayersToGraph)
            {
                [[statsToGraphDictionary objectForKey:stat] addObject:[player.advancedStats objectForKey:statType]];
            }
        }
        else if([stat containsString:@"Advanced Career"])
        {
            for(Player *player in self.selectedPlayersToGraph)
            {
                [[statsToGraphDictionary objectForKey:stat] addObject:[player.careerAdvancedStats objectForKey:statType]];
            }
        }
        else if([stat containsString:@"Per 36 Season"])
        {
            for(Player *player in self.selectedPlayersToGraph)
            {
                [[statsToGraphDictionary objectForKey:stat] addObject:[player.per36Stats objectForKey:statType]];
            }
        }
    }
    
    NSLog(@"%@", statsToGraphDictionary);
    
    return statsToGraphDictionary;
}

-(NSMutableDictionary*)createNormalizedDictionaryOfStatsToGraph:(NSMutableDictionary*)statsDictionary
{
    NSMutableDictionary *normalizedStatsDictionary = [[NSMutableDictionary alloc] init];
    
    for(NSString *statType in self.selectedStatsToGraph)
    {
        NSMutableArray *normalizedStatsForStatType = [[NSMutableArray alloc] init];
        NSMutableArray *statsForStatType = [statsDictionary objectForKey:statType];
        int indexOfNonZeroStat = -1;
        for(int i = 0; i < statsForStatType.count; i++)
        {
            if([statsForStatType[i] doubleValue] != 0)
            {
                indexOfNonZeroStat = i;
                break;
            }
        }
        
        for(NSString *stat in statsForStatType)
        {
            if(indexOfNonZeroStat != -1)
            {
                double normalizedStat = [stat doubleValue]/[statsForStatType[indexOfNonZeroStat] doubleValue];
                [normalizedStatsForStatType addObject:[NSDecimalNumber numberWithDouble:normalizedStat]];
            }
            else
            {
                [normalizedStatsForStatType addObject:[NSDecimalNumber numberWithDouble:0.0]];
            }
        }
        
        [normalizedStatsDictionary setObject:normalizedStatsForStatType forKey:statType];
    }
    
    NSLog(@"%@", normalizedStatsDictionary);
    
    return normalizedStatsDictionary;
}

-(NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"Supported interface orientations of data input for bar graph");
    return UIInterfaceOrientationMaskPortrait;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}


@end
