//
//  PlayerSearchViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//
//  Major help from: http://www.raywenderlich.com/16873/how-to-add-search-into-a-table-view
//

#import "PlayerSearchViewController.h"
#import "Player.h"
#import "Utility.h"
#import "MainMenuViewController.h"

@implementation PlayerSearchViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    //Reload the table data to show the alphabetized list
    [self.tableView reloadData];
    
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
    
    //For both the filtered table and the standard table of players, allow multiple select
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.playerArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Create a new Player for the player at the current index, so we can set the cell's text to the player's name
    Player *player = [self.playerArray objectAtIndex:indexPath.row];
    // Configure the cell
    cell.textLabel.text = player.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%ld", (long)indexPath.row);
    Player *player;
    if(tableView == self.tableView)
    {
        player = self.playerArray[indexPath.row];
        NSLog(@"Selecting from main table %@", player.ID);
    }
    else
    {
        player = self.filteredPlayerArray[indexPath.row];
        NSLog(@"Selecting from search table %@", player.ID);
    }
    
    if(![MainMenuViewController containsPlayer:player.ID])
    {
        Player *newPlayer = [Utility generateObjectForPlayer:player];
        [[MainMenuViewController userPlayers] addObject:newPlayer];
        [MainMenuViewController saveUserPlayers];
    }
    else
    {
        NSLog(@"Already following that player");
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
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    NSMutableArray *searchResults = [self.playerArray mutableCopy];
    
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",strippedString];
    searchResults = [NSMutableArray arrayWithArray:[self.playerArray filteredArrayUsingPredicate:predicate]];
    
    // hand over the filtered results to our search results table
    PlayerSearchResultsViewController *tableController = (PlayerSearchResultsViewController *)self.searchController.searchResultsController;
    tableController.filteredPlayerArray = searchResults;
    self.filteredPlayerArray = searchResults;
    [tableController.tableView reloadData];
}

//Allow the keyboard to be hidden
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

@end
