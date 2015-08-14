//
//  PlayerStatsViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 7/12/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface PlayerStatsViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) Player *player;

@end
