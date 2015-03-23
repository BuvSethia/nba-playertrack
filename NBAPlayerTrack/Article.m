//
//  Article.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/19/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "Article.h"

@implementation Article

#pragma mark NSCoding
-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if(self)
    {
        self.title = [decoder decodeObjectForKey:@"Title"];
        self.url = [decoder decodeObjectForKey:@"URL"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:@"Title"];
    [encoder encodeObject:self.url forKey:@"URL"];
}

@end
