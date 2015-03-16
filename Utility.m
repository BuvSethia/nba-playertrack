//
//  Utility.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/13/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "Utility.h"
#import "Player.h"

@implementation Utility

+(Player*)generateObjectForPlayer:(Player*)player
{
    //Save ourselves a call to a service and the database and check in-app if stats for this player have already been updated today
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger playerDay = [player.updateDate integerValue];
    if(day == playerDay)
    {
        return player;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://ec2-52-10-76-24.us-west-2.compute.amazonaws.com/Service.svc/UpdateDBMethod/%@/%@", player.updateDate, player.ID];
    NSData *request = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if(request == Nil)
    {
        NSLog(@"No data received");
        return nil;
    }
    else
    {
        //Convert request result into JSON dictionary
        NSDictionary *update = [NSJSONSerialization JSONObjectWithData:request
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
        NSLog(@"Update type %@", update);
        NSString *updateTypeString = [update objectForKey:@"UpdateDBMethodResult"];
        int updateType = [updateTypeString intValue];
        
        //If everything is up to date, return the player we already have.
        if(updateType == 0)
        {
            NSLog(@"No change to player stats necessary");
            return player;
        }
        //If we just need to grab stats from the database
        else if(updateType == 1)
        {
            NSLog(@"Change to player stats via database");
            Player *newPlayer = [[Utility new] createPlayerFromDB:player.ID];
            return newPlayer;
        }
        //If we need to update the database AND grab stats from the database
        else if (updateType == 2)
        {
            NSLog(@"Change to player stats via internet and database");
            NSString *url = @"http://ec2-52-10-76-24.us-west-2.compute.amazonaws.com/Service.svc/UpdateDBForPlayer";
            NSString *playerData = [NSString stringWithFormat:@"{\"playerID\":\"%@\", \"html\":\"%@\"}", player.ID, player.webLink];
            [[Utility new] UpdateDBForPlayer:playerData url:url];
            Player *newPlayer = [[Utility new] createPlayerFromDB:player.ID];
            return newPlayer;
        }
        //Houston we have a problem
        else
        {
            return nil;
        }
        
    }
}

-(Player*)createPlayerFromDB:(NSString*)playerID
{
    NSString *url = [NSString stringWithFormat:@"http://ec2-52-10-76-24.us-west-2.compute.amazonaws.com/Service.svc/StatsFileGenerator/%@", playerID];
    NSData *request = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if(request == nil)
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
        NSString *innerString = [dictionary objectForKey:@"StatsFileGeneratorResult"];
        NSData *objectData = [innerString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *player = [NSJSONSerialization JSONObjectWithData:objectData
                                                                         options:NSJSONReadingMutableContainers
                                                                           error:nil];
        NSDictionary *playerInfo = [player objectForKey:playerID];
        NSLog(@"%@", playerInfo);
        Player *newPlayer = [[Player alloc] init];
        newPlayer.ID = playerID;
        newPlayer.name = [playerInfo objectForKey:@"PlayerName"];
        newPlayer.DOB = [playerInfo objectForKey:@"DOB"];
        newPlayer.webLink = [playerInfo objectForKey:@"WebLink"];
        newPlayer.position = [playerInfo objectForKey:@"Position"];
        newPlayer.jNumber = [playerInfo objectForKey:@"JNumber"];
        newPlayer.updateDate = [playerInfo objectForKey:@"Updated"];
        newPlayer.height = [playerInfo objectForKey:@"Height"];
        newPlayer.weight = [playerInfo objectForKey:@"Weight"];
        newPlayer.yearsPro = [playerInfo objectForKey:@"YearsPro"];
        newPlayer.team = [playerInfo objectForKey:@"TeamName"];
        newPlayer.perGameStats = [playerInfo objectForKey:@"PerGame"];
        newPlayer.per36Stats = [playerInfo objectForKey:@"Per36"];
        newPlayer.advancedStats = [playerInfo objectForKey:@"AdvancedStats"];
        newPlayer.careerPerGameStats = [playerInfo objectForKey:@"CareerStats"];
        newPlayer.careerAdvancedStats = [playerInfo objectForKey:@"CareerAdvancedStats"];
        
        return newPlayer;
        
    }
}

//Lifted from http://stackoverflow.com/questions/25335168/synchronous-https-post-request-ios
-(NSData *)UpdateDBForPlayer:(NSString *)postString url:(NSString*)urlString{
    
    //Response data object
    NSData *returnData = [[NSData alloc]init];
    
    //Build the Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postString length]] forHTTPHeaderField:@"Content-length"];
    [request setValue:[NSString stringWithFormat:@"application/json"] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    //Send the Request
    returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    
    //Get the Result of Request
    NSString *response = [[NSString alloc] initWithBytes:[returnData bytes] length:[returnData length] encoding:NSUTF8StringEncoding];
    
    bool debug = YES;
    
    if (debug && response) {
        NSLog(@"Response >>>> %@",response);
    }
    
    
    return returnData;
}

@end
