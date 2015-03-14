//
//  Player.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/11/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "Player.h"

@implementation Player

+(id)generatePlayerList
{
    NSString *url = @"http://ec2-52-10-76-24.us-west-2.compute.amazonaws.com/Service.svc/GetPlayerList";
    NSData *request = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if(request == Nil)
    {
        NSLog(@"No data received");
        return nil;
    }
    else
    {
        //Convert request result into JSON dictionary
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:request
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        NSString *innerString = [dictionary objectForKey:@"GetPlayerListResult"];
        NSData *objectData = [innerString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *playerDictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        
        //Create a player object for each player and return it in an array
        NSMutableArray *playerArray = [[NSMutableArray alloc] init];
        for(id key in playerDictionary)
        {
            Player *player = [[Player alloc] init];
            player.ID = key;
            NSDictionary *inner = [playerDictionary objectForKey:key];
            player.name = [inner objectForKey:@"PlayerName"];
            player.webLink = [inner objectForKey:@"WebLink"];
            player.updateDate = @"-1";
            [playerArray addObject:player];
            NSLog(@"%@,%@,%@", player.ID, player.name, player.webLink);
        }
        
        return playerArray;
    }

}

@end
