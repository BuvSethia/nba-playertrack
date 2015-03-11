//
//  PlayerSearchViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerSearchResultsViewController.h"

@interface PlayerSearchViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property NSArray *playerArray;
@property (strong,nonatomic) NSMutableArray *filteredPlayerArray;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) PlayerSearchResultsViewController *resultsTableController;

@end
