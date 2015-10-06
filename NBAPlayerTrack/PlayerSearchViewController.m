//
//  PlayerSearchViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//
//  Major help from: http://www.raywenderlich.com/16873/how-to-add-search-into-a-table-view
//  And: http://www.icodeblog.com/2010/12/10/implementing-uitableview-sections-from-an-nsarray-of-nsdictionary-objects/
//

#import "PlayerSearchViewController.h"
#import "Player.h"
#import "Utility.h"
#import "MainMenuViewController.h"

@implementation PlayerSearchViewController

NSArray *teamNamesArray;

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadPlayersToTable];
    
    self.selectedPlayers = [[NSMutableArray alloc] init];

    //Removes extra horizontal lines from the table view
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //SEARCH CONTROLLER STUFF
    // Initialize the filtered player array with a max size of the total number of players in the list
    self.filteredPlayerArray = [NSMutableArray arrayWithCapacity:[self.playerArray count]];
    self.resultsTableController = [[PlayerSearchResultsViewController alloc] init];
    //Removethe extra horizontal lines
    self.resultsTableController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //Initialize the search controller with reference to the view controller displaying the search results
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // We want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    //Don't hide nav bar when search is active
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    //For both the filtered table and the standard table of players, allow multiple select
    self.resultsTableController.tableView.allowsMultipleSelection = YES;
    self.tableView.allowsMultipleSelection = YES;
    
    [self loadTeamNameArray];
    
    //Navigation item coloring
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
}

- (IBAction)addPlayersButtonClicked:(id)sender {
    for(Player *player in self.selectedPlayers)
    {
        if(![MainMenuViewController containsPlayer:player.ID])
        {
            Player *newPlayer = [Utility generateObjectForPlayer:player];
            [[MainMenuViewController userPlayers] addObject:newPlayer];
            [MainMenuViewController saveUserPlayers];
            NSLog(@"Added player %@ to main menu", newPlayer.name);
        }
        else
        {
            NSLog(@"Already following that player");
        }
    }
    [self.selectedPlayers removeAllObjects];
    [self.tableView reloadData];
    UIAlertView *confirmation = [[UIAlertView alloc] initWithTitle:@"Players Added"
                                                               message:@"All selected players have been added to your player list."
                                                               delegate:nil
                                                     cancelButtonTitle:@"Okay"
                                                     otherButtonTitles:nil];
    [confirmation show];
}

#pragma mark - Table View methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.playerListDictionary allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.playerListDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.playerListDictionary valueForKey:[[[self.playerListDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:section]] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self.playerListDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Create a new Player for the player at the current index, so we can set the cell's text to the player's name
    Player *player = [[self.playerListDictionary valueForKey:[[[self.playerListDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    // Configure the cell
    cell.textLabel.text = player.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView.hidden = YES;
    cell.accessoryType = UITableViewCellAccessoryNone;
    //If the player has already been selected (perhaps in the filtered table), put a checkmark in the cell
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    if(tableViewCell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
    }
    else
    {
        tableViewCell.accessoryView.hidden = NO;
        tableViewCell.accessoryType = UITableViewCellAccessoryCheckmark;
        if(tableView == self.tableView)
        {
            Player *selectedPlayer = [[self.playerListDictionary valueForKey:[[[self.playerListDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            bool playerAlreadySelected = NO;
            for(Player *p in self.selectedPlayers)
            {
                if([p.ID isEqualToString:selectedPlayer.ID])
                {
                    playerAlreadySelected = YES;
                }
            }
            if(!playerAlreadySelected)
            {
                [self.selectedPlayers addObject:selectedPlayer];
                NSLog(@"Selected player %@ from unfiltered", selectedPlayer.name);
            }
        }
        else if(tableView == self.resultsTableController.tableView)
        {
            Player *selectedPlayer = [[self.filteredPlayerDictionary valueForKey:[[[self.filteredPlayerDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
            bool playerAlreadySelected = NO;
            for(Player *p in self.selectedPlayers)
            {
                if([p.ID isEqualToString:selectedPlayer.ID])
                {
                    playerAlreadySelected = YES;
                }
            }
            if(!playerAlreadySelected)
            {
                [self.selectedPlayers addObject:selectedPlayer];
                NSLog(@"Selected player %@ from filtered", selectedPlayer.name);
            }
        }
    }
    
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Deselecting player");
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    if(tableViewCell.accessoryType == UITableViewCellAccessoryNone)
    {
        [self tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    else
    {
        tableViewCell.accessoryView.hidden = YES;
        tableViewCell.accessoryType = UITableViewCellAccessoryNone;
        if(tableView == self.tableView)
        {
            Player *selectedPlayer = [[self.playerListDictionary valueForKey:[[[self.playerListDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

            NSLog(@"Attempting to remove %@ player from selected players", selectedPlayer.name);
            //Remove the deselected player from the selected player array
            for(int i = 0; i < self.selectedPlayers.count; i++)
            {
                Player *toCompare = self.selectedPlayers[i];
                NSLog(@"Comparing %@ to %@", selectedPlayer.ID, toCompare.ID);
                if([selectedPlayer.ID isEqualToString:toCompare.ID])
                {
                    [self.selectedPlayers removeObjectAtIndex:i];
                    NSLog(@"Removing %@ from selected players", selectedPlayer.ID);
                }
            }
        }
        else if(tableView == self.resultsTableController.tableView)
        {
            Player *selectedPlayer = [[self.filteredPlayerDictionary valueForKey:[[[self.filteredPlayerDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];

            NSLog(@"Attempting to remove %@ player from selected players", selectedPlayer.name);
            //Remove the deselected player from the selected player array
            for(int i = 0; i < self.selectedPlayers.count; i++)
            {
                Player *toCompare = self.selectedPlayers[i];
                NSLog(@"Comparing %@ to %@", selectedPlayer.ID, toCompare.ID);
                if([selectedPlayer.ID isEqualToString:toCompare.ID])
                {
                    [self.selectedPlayers removeObjectAtIndex:i];
                    NSLog(@"Removing %@ from selected players", selectedPlayer.ID);
                }
            }
        }
    }
}

#pragma mark - UISearchBarDelegate

//Resigns the search bar when the search button is clicked
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

//If the cancel button is clicked, resign the search bar and make all selected players selected in the non-filtered array as well.
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = nil;
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",strippedString];
    searchResults = [NSMutableArray arrayWithArray:[self.playerArray filteredArrayUsingPredicate:predicate]];
    
    self.filteredPlayerArray = searchResults;
    [self createDictionaryForFilteredArray];
    //Hand over the filtered results in dictionary form to our search results table
    PlayerSearchResultsViewController *tableController = (PlayerSearchResultsViewController *)self.searchController.searchResultsController;
    //Data from which cells are populated
    tableController.filteredPlayerDictionary = self.filteredPlayerDictionary;
    //Used to determine which players should already have checkmarks next to them
    tableController.selectedPlayers = self.selectedPlayers;
    [tableController.tableView reloadData];
}

//Allow the keyboard to be hidden
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    PopupMenuViewController *dest = (PopupMenuViewController*) segue.destinationViewController;
    dest.delegate = self;
    //Based on iOS version, make it so that the modal segue does not place a black screen behind the presented view.
    [dest setPresentationStyleForSelfController:self presentingController:dest];
    dest.tableMenuItems = teamNamesArray;
    dest.menuCaller = sender;
}

#pragma mark - PopupMenu Delegate
-(void)selectedMenuItem:(NSInteger)newItem calledBy:(id)sender
{
    //Confirm the selected team and ramifications with an alert view
    UIAlertView *confirmSelection = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                        message:@"All players associated with this team will be added to your player list."
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:@"Cancel", nil];
    confirmSelection.tag = newItem;
    
    [confirmSelection show];
}


#pragma mark - AlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //If the user confirms, add all the players playing for that team to the main player list.
    if(buttonIndex == 0)
    {
        for(Player *player in self.playerArray)
        {
            if([player.team isEqualToString:teamNamesArray[alertView.tag]])
            {
                if(![MainMenuViewController containsPlayer:player.ID])
                {
                    Player *newPlayer = [Utility generateObjectForPlayer:player];
                    [[MainMenuViewController userPlayers] addObject:newPlayer];
                    [MainMenuViewController saveUserPlayers];
                    NSLog(@"Added player %@ to main menu", newPlayer.name);
                }
                else
                {
                    NSLog(@"Already following that player");
                }
            }
        }
    }
    //If they cancel do nothing
    else if(buttonIndex == 1){}
}

#pragma mark - All players list caching and updating
-(NSString*)playerListFilePath
{
    NSArray *initPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [initPath objectAtIndex:0];
    NSString *path = [documentFolder stringByAppendingFormat:@"/AllPlayers.plist"];
    return path;
}

-(bool)updatePlayerListFile
{
    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[self playerListFilePath] error:nil];
    NSDate *result = [fileAttribs objectForKey:NSFileModificationDate];
    NSLog(@"%@", result);
    NSDate *now = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour
                                                                   fromDate:result
                                                                     toDate:now
                                                                    options:0];
    NSInteger timeDifference = [components hour];
    NSLog(@"Time since player list was updated is %ld", (long)timeDifference);
    if(timeDifference >= 24)
    {
        return YES;
    }
    
    return NO;
}

-(bool)savePlayerList
{
    [NSKeyedArchiver archiveRootObject:self.playerArray toFile:[self playerListFilePath]];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self playerListFilePath]])
    {
        NSLog(@"Player list saved to file");
        return YES;
    }
    
    return NO;
}

#pragma mark - Table view section creation
-(void)createSectionedDictionaryFromPlayerList
{
    BOOL sectionExists;
    
    self.playerListDictionary = [[NSMutableDictionary alloc] init];
    
    // Loop through the books and create our keys for each section
    for (Player *player in self.playerArray)
    {
        //The first letter of the player's name (to determine the section header)
        NSString *c = [player.name substringToIndex:1];
        
        sectionExists = NO;
        
        //Check if the section header already exists
        for (NSString *str in [self.playerListDictionary allKeys])
        {
            if ([str isEqualToString:c])
            {
                sectionExists = YES;
            }
        }
        
        //If it doesn't, create it and initizalize that section with a mutable array
        if (!sectionExists)
        {
            [self.playerListDictionary setValue:[[NSMutableArray alloc] init] forKey:c];
        }
    }
    
    //Populate the dictionary
    for (Player *player in self.playerArray)
    {
        [[self.playerListDictionary objectForKey:[player.name substringToIndex:1]] addObject:player];
    }
    
    //NSLog(@"Number of sections is %ld", [[self.playerListDictionary allKeys] count]);
    
    [self.tableView reloadData];
}

#pragma mark - Loading stuff
-(void)loadPlayersToTable
{
    //If an updated version of the player list is already saved as a file, load player list from file
    if(self.playerArray == Nil && [[NSFileManager defaultManager] fileExistsAtPath:[self playerListFilePath]] && ![self updatePlayerListFile])
    {
        NSLog(@"Loading player list from file");
        self.playerArray = [NSKeyedUnarchiver unarchiveObjectWithFile:[self playerListFilePath]];
        [self createSectionedDictionaryFromPlayerList];
    }
    //Otherwise, load it from the database.
    else
    {
        NSLog(@"Getting player list from database");
        //Pull a list of all players in the database to show to the user
        self.playerArray = [NSArray arrayWithArray:[Player generatePlayerList]];
        
        //Sort the list of players alphabetically by first name
        //http://stackoverflow.com/questions/805547/how-to-sort-an-nsmutablearray-with-custom-objects-in-it
        NSArray *sortedArray;
        sortedArray = [self.playerArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            NSString *first = [(Player*)a name];
            NSString *second = [(Player*)b name];
            return [first compare:second];
        }];
        self.playerArray = sortedArray;
        [self savePlayerList];
        [self createSectionedDictionaryFromPlayerList];
    }
}

-(void)createDictionaryForFilteredArray
{
    BOOL sectionExists;
    
    self.filteredPlayerDictionary = [[NSMutableDictionary alloc] init];
    
    // Loop through the books and create our keys for each section
    for (Player *player in self.filteredPlayerArray)
    {
        //The first letter of the player's name (to determine the section header)
        NSString *c = [player.name substringToIndex:1];
        
        sectionExists = NO;
        
        //Check if the section header already exists
        for (NSString *str in [self.filteredPlayerDictionary allKeys])
        {
            if ([str isEqualToString:c])
            {
                sectionExists = YES;
            }
        }
        
        //If it doesn't, create it and initizalize that section with a mutable array
        if (!sectionExists)
        {
            [self.filteredPlayerDictionary setValue:[[NSMutableArray alloc] init] forKey:c];
        }
    }
    
    //Populate the dictionary
    for (Player *player in self.filteredPlayerArray)
    {
        [[self.filteredPlayerDictionary objectForKey:[player.name substringToIndex:1]] addObject:player];
    }
    
    //NSLog(@"Number of sections is %ld", [[self.filteredPlayerDictionary allKeys] count]);
}

-(void)loadTeamNameArray
{
    //Arary of NBA team names
    teamNamesArray = [[NSArray alloc] initWithObjects:
                      @"Atlanta Hawks",
                      @"Boston Celtics",
                      @"Charlotte Bobcats",
                      @"Chicago Bulls",
                      @"Cleveland Cavaliers",
                      @"Dallas Mavericks",
                      @"Denver Nuggets",
                      @"Detroit Pistons",
                      @"Golden State Warriors",
                      @"Houston Rockets",
                      @"Indiana Pacers",
                      @"Los Angeles Clippers",
                      @"Los Angeles Lakers",
                      @"Memphis Grizzlies",
                      @"Miami Heat",
                      @"Milwaukee Bucks",
                      @"Minnesota Timberwolves",
                      @"New Jersey Nets",
                      @"New Orleans Hornets",
                      @"New York Knicks",
                      @"Oklahoma City Thunder",
                      @"Orlando Magic",
                      @"Philadelphia Sixers",
                      @"Phoenix Suns",
                      @"Portland Trail Blazers",
                      @"Sacramento Kings",
                      @"San Antonio Spurs",
                      @"Toronto Raptors",
                      @"Utah Jazz",
                      @"Washington Wizards", nil];
}

- (IBAction)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
