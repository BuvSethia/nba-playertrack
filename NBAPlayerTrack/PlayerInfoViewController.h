//
//  PlayerInfoViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 7/12/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface PlayerInfoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *playerImage;
@property (weak, nonatomic) IBOutlet UILabel *playerName;
@property (weak, nonatomic) IBOutlet UILabel *playerTeam;
@property (weak, nonatomic) IBOutlet UILabel *playerNumber;
@property (weak, nonatomic) IBOutlet UILabel *playerPosition;
@property (weak, nonatomic) IBOutlet UILabel *playerAge;
@property (weak, nonatomic) IBOutlet UILabel *playerHeight;
@property (weak, nonatomic) IBOutlet UILabel *playerWeight;
@property (weak, nonatomic) IBOutlet UILabel *playerYearsPro;
@property (weak, nonatomic) Player *player;

@end
