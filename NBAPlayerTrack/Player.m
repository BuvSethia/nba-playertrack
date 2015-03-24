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
            player.updateDate = @"0";
            [playerArray addObject:player];
            NSLog(@"%@,%@,%@", player.ID, player.name, player.webLink);
        }
        
        return playerArray;
    }

}

#pragma mark NSCoding
-(id)initWithCoder:(NSCoder*)decoder{
    if ((self = [super init])) {
        self.ID = [decoder decodeObjectForKey:@"ID"];
        self.name = [decoder decodeObjectForKey:@"Name"];
        self.webLink = [decoder decodeObjectForKey:@"webLink"];
        self.updateDate = [decoder decodeObjectForKey:@"updateDate"];
        self.DOB = [decoder decodeObjectForKey:@"DOB"];
        self.position = [decoder decodeObjectForKey:@"Position"];
        self.height = [decoder decodeObjectForKey:@"Height"];
        self.weight = [decoder decodeObjectForKey:@"Weight"];
        self.yearsPro = [decoder decodeObjectForKey:@"yearsPro"];
        self.team = [decoder decodeObjectForKey:@"Team"];
        self.jNumber = [decoder decodeObjectForKey:@"jNumber"];
        self.perGameStats = [decoder decodeObjectForKey:@"perGame"];
        self.per36Stats = [decoder decodeObjectForKey:@"per36"];
        self.advancedStats = [decoder decodeObjectForKey:@"Advanced"];
        self.careerPerGameStats = [decoder decodeObjectForKey:@"careerPer"];
        self.careerAdvancedStats = [decoder decodeObjectForKey:@"careerAdvanced"];
        self.articles = [decoder decodeObjectForKey:@"Articles"];
        self.twitterID = [decoder decodeObjectForKey:@"Twitter"];
    }
    return self;
}



-(void)encodeWithCoder:(NSCoder*)encoder{
    [encoder encodeObject:self.ID forKey:@"ID"];
    [encoder encodeObject:self.name forKey:@"Name"];
    [encoder encodeObject:self.webLink forKey:@"webLink"];
    [encoder encodeObject:self.updateDate forKey:@"updateDate"];
    [encoder encodeObject:self.DOB forKey:@"DOB"];
    [encoder encodeObject:self.position forKey:@"Position"];
    [encoder encodeObject:self.height forKey:@"Height"];
    [encoder encodeObject:self.weight forKey:@"Weight"];
    [encoder encodeObject:self.yearsPro forKey:@"yearsPro"];
    [encoder encodeObject:self.team forKey:@"Team"];
    [encoder encodeObject:self.jNumber forKey:@"jNumber"];
    [encoder encodeObject:self.perGameStats forKey:@"perGame"];
    [encoder encodeObject:self.per36Stats forKey:@"per36"];
    [encoder encodeObject:self.advancedStats forKey:@"Advanced"];
    [encoder encodeObject:self.careerPerGameStats forKey:@"careerPer"];
    [encoder encodeObject:self.careerAdvancedStats forKey:@"careerAdvanced"];
    [encoder encodeObject:self.articles forKey:@"Articles"];
    [encoder encodeObject:self.twitterID forKey:@"Twitter"];
    
}

@end
