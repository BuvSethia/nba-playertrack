//
//  PublicTwitterViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/24/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PublicTwitterViewController.h"
#import "SWRevealViewController.h"
#import "PlayerTabBarController.h"
#import "Utility.h"
#import <TwitterKit/TwitterKit.h>

@implementation PublicTwitterViewController

static NSString * const TweetTableReuseIdentifier = @"TweetCell";
bool retriedTwitterLoad = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PlayerTabBarController *tabController = (PlayerTabBarController*)self.tabBarController.tabBarController;
    self.player = tabController.player;
    // Setup tableview
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
    
    //Navigation item coloring
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    if(self.tweets == Nil && [[NSFileManager defaultManager] fileExistsAtPath:[self playerTwitterFilePath]] && ![self updateTwitterFile])
    {
        NSLog(@"Loading tweets from file");
        NSInputStream *is = [[NSInputStream alloc] initWithFileAtPath:[self playerTwitterFilePath]];
        
        [is open];
        self.tweets = [NSJSONSerialization JSONObjectWithStream:is options:NSJSONReadingMutableLeaves error:nil];
        [is close];
        [self.tableView reloadData];
    }
    else
    {
        if([Utility haveInternet])
        {
            [self loadTweetsFromTwitter];
        }
        else
        {
            if([[NSFileManager defaultManager] fileExistsAtPath:[self playerTwitterFilePath]])
            {
                NSLog(@"Loading tweets from file");
                NSInputStream *is = [[NSInputStream alloc] initWithFileAtPath:[self playerTwitterFilePath]];
                
                [is open];
                self.tweets = [NSJSONSerialization JSONObjectWithStream:is options:NSJSONReadingMutableLeaves error:nil];
                [is close];
                [self.tableView reloadData];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error connecting to the internet, so the tweets may not be up to date. Please turn on wifi or data to update tweets" delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error connecting to the internet and no saved tweets were found. Please return to \"My Players\", turn on wifi or data, and come back here to get tweets." delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alert show];
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Player Menu" style:UIBarButtonItemStylePlain target:self action:@selector(playerMenuPressed)];
    //self.tabBarController.tabBar.barTintColor = [UIColor blueColor];
}

- (void)playerMenuPressed{
    [self.tabBarController.navigationController popViewControllerAnimated:YES];
}

# pragma mark - UITableViewDelegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tweets count];
}

- (TWTRTweetTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TWTRTweet *tweet = [[TWTRTweet alloc] initWithJSONDictionary:self.tweets[indexPath.row]];
    TWTRTweetTableViewCell *cell = (TWTRTweetTableViewCell *)[tableView dequeueReusableCellWithIdentifier:TweetTableReuseIdentifier];
    [cell configureWithTweet:tweet];
    cell.tweetView.delegate = self;
    
    return cell;
}

// Calculate the height of each row
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TWTRTweet *tweet = [[TWTRTweet alloc] initWithJSONDictionary:self.tweets[indexPath.row]];
    
    return [TWTRTweetTableViewCell heightForTweet:tweet width:CGRectGetWidth(self.view.bounds)];
}

-(void)loadTweetsFromTwitter
{
    // Load tweets
    [TwitterKit logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        if (guestSession) {
            NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/search/tweets.json";
            NSString *queryString = [NSString stringWithFormat:@"%@ -filter:retweets", self.player.name];
            NSDictionary *params = @{@"q" : queryString, @"count" : @"60"};
            NSError *clientError;
            NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                                     URLRequestWithMethod:@"GET"
                                     URL:statusesShowEndpoint
                                     parameters:params
                                     error:&clientError];
            NSLog(@"%@", request.URL);
            [[[Twitter sharedInstance] APIClient]
             sendTwitterRequest:request
             completion:^(NSURLResponse *response,
                          NSData *data,
                          NSError *connectionError) {
                 if (data) {
                     // handle the response data e.g.
                     NSLog(@"We got data");
                     NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                                            options:NSJSONReadingMutableContainers
                                                                              error:nil];
                     NSDictionary *tweets = [result objectForKey:@"statuses"];
                     NSData *tweetsData = [NSJSONSerialization dataWithJSONObject:tweets options:NSJSONWritingPrettyPrinted error:nil];
                     self.tweets = [NSJSONSerialization JSONObjectWithData:tweetsData options:NSJSONReadingMutableLeaves error:nil];
                     [self saveTwitter];
                     [self.tableView reloadData];
                 }
                 else {
                     NSLog(@"Error: %@", connectionError);
                     if(!retriedTwitterLoad)
                     {
                         retriedTwitterLoad = YES;
                         [self loadTweetsFromTwitter];
                     }
                 }
             }];
        } else {
            NSLog(@"Unable to log in as guest: %@", [error localizedDescription]);
        }
    }];
    
    if(!self.tweets && retriedTwitterLoad == YES)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error loading the public twitter feed. Please try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark Saving and loading tweet file
-(bool)saveTwitter
{
    NSOutputStream *os = [[NSOutputStream alloc] initToFileAtPath:[self playerTwitterFilePath] append:NO];
    
    [os open];
    [NSJSONSerialization writeJSONObject:self.tweets toStream:os options:0 error:nil];
    [os close];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self playerTwitterFilePath]])
    {
        NSLog(@"Twitter saved");
    }
    else
    {
        NSLog(@"Twitter not saved");
    }
    return YES;
}

-(NSString*)playerTwitterFilePath
{
    NSArray *initPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [initPath objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"/%@PublicTwitter.plist", self.player.ID];
    NSString *path = [documentFolder stringByAppendingFormat:fileName];
    return path;
}

-(bool)updateTwitterFile
{
    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:[self playerTwitterFilePath] error:nil];
    NSDate *result = [fileAttribs objectForKey:NSFileModificationDate]; //or NSFileModificationDate
    NSDate *now = [NSDate date];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour
                                                                   fromDate:result
                                                                     toDate:now
                                                                    options:0];
    NSInteger timeDifference = [components hour];
    if(timeDifference >= 1)
    {
        return YES;
    }
    
    return NO;
}

@end
