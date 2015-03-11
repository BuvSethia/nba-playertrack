//
//  PlayerSearchResultsViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerSearchResultsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property NSArray *filteredPlayerArray;

@end
