//
//  SingePlayerTrendGraphDataInputViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/25/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "SinglePlayerTrendGraphDataInputViewController.h"
#import "SWRevealViewController.h"
#import "SinglePlayerTrendGraphViewController.h"
#import "Player.h"

@interface SinglePlayerTrendGraphDataInputViewController ()

@property NSMutableArray *playerList;
@property Player *selectedPlayerToGraph;
@property NSMutableArray *selectedStatsToGraph;
@property NSMutableDictionary *nbaAppStatLabelConversionDictionary;

@property NSInteger fromMonth;
@property NSInteger toMonth;
@property NSArray *listOfMonths;

@end

@implementation SinglePlayerTrendGraphDataInputViewController

//Max number of players and stats a user can select
const int STREND_MAX_STATS = 3;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.playerList = nil;
    [self loadPlayerList];
    
    self.selectedPlayerToGraph = Nil;
    self.selectedStatsToGraph = [[NSMutableArray alloc] init];
    [self loadLabelConversionDictionary];
    self.listOfMonths = [[NSArray alloc] initWithObjects:@"OCT", @"NOV", @"DEC", @"JAN", @"FEB", @"MAR", @"APR", nil];
    //Default the range to all games
    self.fromMonth = 0;
    self.toMonth = 6;
    
    //Removes horizontal lines from the table view
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
    
    //Labels for picker view component titles
    [self createLabelForComponent:0];
    [self createLabelForComponent:1];

}

//http://stackoverflow.com/questions/18999115/add-header-to-uipickerview
-(void)createLabelForComponent:(NSInteger)component
{
    NSString *title;
    if(component == 0)
    {
        title = @"From:";
    }
    else
    {
        title = @"To:";
    }
    float lblWidth = self.rangePicker.frame.size.width / self.rangePicker.numberOfComponents;
    float lblXposition = self.rangePicker.frame.origin.x;
    float lblYposition = (self.rangePicker.frame.origin.y);
    
    UILabel *lbl;
        
    lbl = [[UILabel alloc] initWithFrame:CGRectMake((lblXposition + component * lblWidth),
                                                              lblYposition,
                                                              lblWidth,
                                                              20)];
    
    
    [lbl setText:title];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setFont:[UIFont boldSystemFontOfSize:20.0f]];
    
    [self.view addSubview:lbl];
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

-(void)loadLabelConversionDictionary
{
    /*
     "FGM = FG",
     "FGA = FGA",
     "FG_PCT = FGPCT",
     "FG3M" = 3P,
     "FG3A" = 3PA,
     "FG3_PCT" = 3PPCT,
     "FTM" = FT,
     "FTA" = FTA,
     "FT_PCT" = FTPCT,
     "OREB" = ORB,
     "DREB" = DRB,
     "REB" = TRB,
     "AST" = AST,
     "STL" = STL,
     "BLK" = BLK,
     "TOV" = TOV,
     "PF" = PF,
     "PTS" = PTS
     */
    self.nbaAppStatLabelConversionDictionary = [[NSMutableDictionary alloc] init];
    [self.nbaAppStatLabelConversionDictionary setObject:@"PTS" forKey:@"PTS"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"PF" forKey:@"PF"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"TOV" forKey:@"TOV"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"BLK" forKey:@"BLK"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"STL" forKey:@"STL"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"AST" forKey:@"AST"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"REB" forKey:@"TRB"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"DREB" forKey:@"DRB"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"OREB" forKey:@"ORB"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FT_PCT" forKey:@"FTPCT"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FTA" forKey:@"FTA"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FTM" forKey:@"FT"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FG3_PCT" forKey:@"3PPCT"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FG3A" forKey:@"3PA"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FG3M" forKey:@"3P"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FG_PCT" forKey:@"FGPCT"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FGA" forKey:@"FGA"];
    [self.nbaAppStatLabelConversionDictionary setObject:@"FGM" forKey:@"FG"];
    
}

#pragma mark - Picker View
-(int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.listOfMonths.count;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
    {
        return self.listOfMonths[row];
    }
    //Backwards
    else
    {
        return self.listOfMonths[self.listOfMonths.count - 1 - row];
    }
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        self.fromMonth = row;
    }
    else
    {
        self.toMonth = self.listOfMonths.count - 1 - row;
    }
}

#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.selectedPlayerToGraph)
    {
        return 1;
    }
    
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PlayerNameCell"];
    cell.textLabel.text = self.selectedPlayerToGraph.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPlayerToGraph = Nil;
    [self.tableView reloadData];
}

#pragma mark - Popup Menu
-(void)selectedMenuItem:(NSInteger)newItem calledBy:(id)sender
{
    if(sender == self.selectPlayerButton)
    {
        Player *p = self.playerList[newItem];
        bool alreadySelectedPlayer = NO;
        if(self.selectedPlayerToGraph)
        {
            alreadySelectedPlayer = YES;
        }
        if(!alreadySelectedPlayer)
        {
            self.selectedPlayerToGraph = p;
            NSLog(@"Added player %@ to selected players to graph", p.ID);
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot select the same player twice" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
        }
        [self.tableView reloadData];
    }
    else if (sender == self.statsButton)
    {
        NSString *selectedStat = [[self.nbaAppStatLabelConversionDictionary allKeys] objectAtIndex:newItem];
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
    if(self.selectedPlayerToGraph && self.selectedStatsToGraph.count > 0 && self.selectedStatsToGraph.count <= STREND_MAX_STATS && [identifier isEqualToString:@"DisplaySinglePlayerTrendGraphSegue"])
    {
        return YES;
    }
    else if(self.selectedStatsToGraph.count < STREND_MAX_STATS && sender == self.statsButton)
    {
        return YES;
    }
    else if(!self.selectedPlayerToGraph && sender == self.selectPlayerButton)
    {
        return YES;
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"The number of selected players must be 1 and the number of selected stats must be between 1 and 3." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //If we are showing the bar graph
    if([segue.identifier isEqualToString:@"DisplaySinglePlayerTrendGraphSegue"])
    {
        SinglePlayerTrendGraphViewController *dest = segue.destinationViewController;
        dest.statsToGraph = [self generateStatsDictionary];
        dest.playerBeingGraphed = self.selectedPlayerToGraph;
        dest.monthsBeingGraphed = [self generateMonthsArray];
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
        else if (sender == self.statsButton)
        {
            dest.tableMenuItems = [self.nbaAppStatLabelConversionDictionary allKeys];
        }
        else
        {
            
        }
    }
}

#pragma mark - Stats to Graph
-(NSArray*)generateMonthsArray
{
    NSArray *gamelogHeaders = [self.selectedPlayerToGraph.gamelog objectForKey:@"headers"];
    NSMutableArray *months = [[NSMutableArray alloc] init];
    
    //An array of arrays containing game stat data for each game a player has played.
    NSArray *arrayOfGames = [self.selectedPlayerToGraph.gamelog objectForKey:@"rowSet"];
    //The position of the game date in each array of game data so we don't have to search for it over and over.
    NSInteger locationOfGameDateInHeaders = [gamelogHeaders indexOfObject:@"GAME_DATE"];
    NSLog(@"%d", locationOfGameDateInHeaders);
    
    for(NSArray *gameData in [arrayOfGames reverseObjectEnumerator])
    {
        NSString *gameDateString = [[gameData objectAtIndex:locationOfGameDateInHeaders] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *gameMonth = [[gameDateString componentsSeparatedByString:@" "] objectAtIndex:0];
        
        NSInteger gameMonthIndex = [self.listOfMonths indexOfObject:gameMonth];
        if(gameMonthIndex >= self.fromMonth && gameMonthIndex <= self.toMonth)
        {
            [months addObject:gameMonth];
        }
    }
    
    return  [months copy];
}

-(NSMutableDictionary*)generateStatsDictionary
{
    NSArray *gamelogHeaders = [self.selectedPlayerToGraph.gamelog objectForKey:@"headers"];
    //Location in the array of stats for each game's gamelog of each of the desired stats to graph, so we don't have to keep searching for them over and over later.
    NSInteger locationsOfSelectedStatsInStatList[self.selectedStatsToGraph.count];
    NSMutableDictionary *statsToGraphDictionary = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < self.selectedStatsToGraph.count; i++)
    {
        locationsOfSelectedStatsInStatList[i] = [gamelogHeaders indexOfObject:[self.nbaAppStatLabelConversionDictionary objectForKey:self.selectedStatsToGraph[i]]];
        [statsToGraphDictionary setObject:[[NSMutableArray alloc] init] forKey:self.selectedStatsToGraph[i]];
    }
    
    //An array of arrays containing game stat data for each game a player has played.
    NSArray *arrayOfGames = [self.selectedPlayerToGraph.gamelog objectForKey:@"rowSet"];
    //The position of the game date in each array of game data so we don't have to search for it over and over.
    NSInteger locationOfGameDateInHeaders = [gamelogHeaders indexOfObject:@"GAME_DATE"];
    NSLog(@"%d", locationOfGameDateInHeaders);
    
    for(NSArray *gameData in [arrayOfGames reverseObjectEnumerator])
    {
        NSString *gameDateString = [[gameData objectAtIndex:locationOfGameDateInHeaders] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *gameMonth = [[gameDateString componentsSeparatedByString:@" "] objectAtIndex:0];
        
        NSInteger gameMonthIndex = [self.listOfMonths indexOfObject:gameMonth];
        if(gameMonthIndex >= self.fromMonth && gameMonthIndex <= self.toMonth)
        {
            for(int i = 0; i < self.selectedStatsToGraph.count; i++)
            {
                [[statsToGraphDictionary objectForKey:self.selectedStatsToGraph[i]] addObject:gameData[locationsOfSelectedStatsInStatList[i]]];
            }
        }
    }
    
    NSLog(@"%@", statsToGraphDictionary);
    return statsToGraphDictionary;
}

@end
