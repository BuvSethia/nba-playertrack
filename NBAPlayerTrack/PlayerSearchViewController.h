//
//  PlayerSearchViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerSearchResultsViewController.h"
#import "PopupMenuViewController.h"

@interface PlayerSearchViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIAlertViewDelegate,MenuDelegate>

@property NSArray *playerArray;
@property NSMutableDictionary *playerListDictionary;
@property NSMutableArray *filteredPlayerArray;
@property NSMutableDictionary *filteredPlayerDictionary;
@property NSMutableArray *selectedPlayers;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) PlayerSearchResultsViewController *resultsTableController;

@end
