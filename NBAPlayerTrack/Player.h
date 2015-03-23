//
//  Player.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//
//  This class will create a searchable list of all players existing in the database
//  to be used by the Search Menu
//

#import <Foundation/Foundation.h>

@interface Player : NSObject<NSCoding>

@property NSString *ID;
@property NSString *name;
@property NSString *webLink;
@property NSString *updateDate;
@property NSString *DOB;
@property NSString *position;
@property NSString *jNumber;
@property NSString *height;
@property NSString *weight;
@property NSString *yearsPro;
@property NSString *team;

@property NSDictionary *perGameStats;
@property NSDictionary *per36Stats;
@property NSDictionary *careerPerGameStats;
@property NSDictionary *advancedStats;
@property NSDictionary *careerAdvancedStats;

@property NSMutableArray *articles;


+ (id)generatePlayerList;

@end
