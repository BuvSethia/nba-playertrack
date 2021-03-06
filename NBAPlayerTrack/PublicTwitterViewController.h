//
//  PublicTwitterViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/24/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TwitterKit/TwitterKit.h>
#import "Player.h"

@interface PublicTwitterViewController : UITableViewController <TWTRTweetViewDelegate>

@property (nonatomic, strong) NSArray *tweets; // Hold all the loaded tweets
@property (nonatomic, strong) Player *player;

-(NSString*)playerTwitterFilePath;
-(bool)saveTwitter;

@end
