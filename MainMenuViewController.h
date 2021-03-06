//
//  MainMenuViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/2/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainMenuViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
+(NSMutableArray*)userPlayers;
+(bool)containsPlayer:(NSString*)playerID;
+(NSString*)userPlayersFilePath;
+(bool)saveUserPlayers;
+(void)removePlayerFile;

@end
