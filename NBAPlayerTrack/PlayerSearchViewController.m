//
//  PlayerSearchViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//
//  Major help from: https://developer.apple.com/library/ios/samplecode/TableSearch_UISearchController/Listings/TableSearch_TableSearch_APLMainTableViewController_m.html
//

#import "PlayerSearchViewController.h"
#import "Player.h"

@implementation PlayerSearchViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.playerArray = [NSArray arrayWithArray:[Player generatePlayerList]];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Initialize the filteredCandyArray with a capacity equal to the candyArray's capacity
    self.filteredPlayerArray = [NSMutableArray arrayWithCapacity:[self.playerArray count]];
    
    _resultsTableController = [[PlayerSearchResultsViewController alloc] init];
    _resultsTableController.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _searchController = [[UISearchController alloc] initWithSearchResultsController:self.resultsTableController];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    // we want to be the delegate for our filtered table so didSelectRowAtIndexPath is called for both tables
    self.resultsTableController.tableView.delegate = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self; // so we can monitor text changes + others
    
    // Search is now just presenting a view controller. As such, normal view controller
    // presentation semantics apply. Namely that presentation will walk up the view controller
    // hierarchy until it finds the root view controller or one that defines a presentation context.
    //
    self.definesPresentationContext = YES;  // know where you want UISearchController to be displayed
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
    // Create a new Player Object
    Player *player = nil;
    // Check to see whether the normal table or search results table is being displayed and set the Player object from the appropriate array
    player = [self.playerArray objectAtIndex:indexPath.row];
    // Configure the cell
    cell.textLabel.text = player.name;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%ld", (long)indexPath.row);
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
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
