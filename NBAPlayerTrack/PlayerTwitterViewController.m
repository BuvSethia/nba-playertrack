//
//  PlayerTwitterViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/23/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerTwitterViewController.h"
#import "SWRevealViewController.h"
#import "PlayerTabBarController.h"
#import <TwitterKit/TwitterKit.h>

@implementation PlayerTwitterViewController

static NSString * const TweetTableReuseIdentifier = @"TweetCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PlayerTabBarController *tabController = (PlayerTabBarController*)self.tabBarController.tabBarController;
    self.player = tabController.player;
    // Setup tableview
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
    
    // Load tweets
    [TwitterKit logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        if (guestSession) {
            NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/statuses/user_timeline.json";
            NSDictionary *params = @{@"user_id" : self.player.twitterID};
            NSError *clientError;
            NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                                     URLRequestWithMethod:@"GET"
                                     URL:statusesShowEndpoint
                                     parameters:params
                                     error:&clientError];
            [[[Twitter sharedInstance] APIClient]
             sendTwitterRequest:request
             completion:^(NSURLResponse *response,
                          NSData *data,
                          NSError *connectionError) {
                 if (data) {
                     // handle the response data e.g.
                     NSLog(@"We got data");
                     self.tweets = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                     /*NSError *jsonError;
                     NSDictionary *json = [NSJSONSerialization
                                           JSONObjectWithData:data
                                           options:0
                                           error:&jsonError];
                     NSLog(@"%@", [json allValues]);
                     self.tweets = json;*/
                     [self.tableView reloadData];
                 }
                 else {
                     NSLog(@"Error: %@", connectionError);
                 }
             }];
        } else {
            NSLog(@"Unable to log in as guest: %@", [error localizedDescription]);
        }
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Player Menu" style:UIBarButtonItemStylePlain target:self action:@selector(playerMenuPressed)];
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

@end
