//
//  PlayerCompareViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 8/21/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupMenuViewController.h"
#import "Player.h"

typedef enum {
    Undecided,
    PerGame,
    Per36,
    Advanced,
    PerGameCareer,
    AdvancedCareer
}StatType;

@interface PlayerCompareViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MenuDelegate>

@property NSMutableArray *playerList;
@property Player *selectedPlayerOne;
@property Player *selectedPlayerTwo;
@property StatType statTypeToDisplay;

@property (weak, nonatomic) IBOutlet UIImageView *playerOneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playerTwoImageView;
@property (weak, nonatomic) IBOutlet UIButton *playerOneButton;
@property (weak, nonatomic) IBOutlet UIButton *playerTwoButton;
@property (weak, nonatomic) IBOutlet UIButton *statTypeSelectButton;

@end
