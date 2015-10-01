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
bool retriedTwitterLoadPlayer = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    retriedTwitterLoadPlayer = NO;
    PlayerTabBarController *tabController = (PlayerTabBarController*)self.tabBarController.tabBarController;
    self.player = tabController.player;
    // Setup tableview, as per instructions of Twitter Fabric API Docs
    self.tableView.estimatedRowHeight = 150;
    self.tableView.rowHeight = UITableViewAutomaticDimension; // Explicitly set on iOS 8 if using automatic row height calculation
    self.tableView.allowsSelection = NO;
    [self.tableView registerClass:[TWTRTweetTableViewCell class] forCellReuseIdentifier:TweetTableReuseIdentifier];
    if(self.tweets == Nil && [[NSFileManager defaultManager] fileExistsAtPath:[self playerTwitterFilePath]] && ![self updateTwitterFile])
    {
        NSLog(@"Loading tweets from file");
        // reading back in...
        NSInputStream *is = [[NSInputStream alloc] initWithFileAtPath:[self playerTwitterFilePath]];
        
        [is open];
        self.tweets = [NSJSONSerialization JSONObjectWithStream:is options:NSJSONReadingMutableLeaves error:nil];
        [is close];
        [self.tableView reloadData];
    }
    else
    {
        [self loadTweetsFromTwitter];
    }
    
    UIImage *image = [UIImage imageWithData:self.player.playerImage];
    CGSize size = CGSizeMake(30, 30);
    [[[self.tabBarController.viewControllers objectAtIndex:0] tabBarItem] setImage:[self resizeImage:image imageSize:size]];
    NSString *title = [NSString stringWithFormat:@"%@'s Twitter", self.player.name];
    [[[self.tabBarController.viewControllers objectAtIndex:0] tabBarItem] setTitle:title];
    NSString *title2 = [NSString stringWithFormat:@"Tweets about %@", self.player.name];
    [[[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem] setTitle:title2];
    UIImage *image2 = [UIImage imageNamed:@"Crowd.png" ];
    [[[self.tabBarController.viewControllers objectAtIndex:1] tabBarItem] setImage:[self resizeImage:image2 imageSize:size]];
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
                     [self saveTwitter];
                     [self.tableView reloadData];
                 }
                 else {
                     NSLog(@"Error: %@", connectionError);
                     if(!retriedTwitterLoadPlayer)
                     {
                         retriedTwitterLoadPlayer = YES;
                         [self loadTweetsFromTwitter];
                     }
                 }
             }];
        } else {
            NSLog(@"Unable to log in as guest: %@", [error localizedDescription]);
        }
    }];
    
    [self.tableView reloadData];
}

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
    NSString *fileName = [NSString stringWithFormat:@"/%@PlayerTwitter.dat", self.player.ID];
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
    NSLog(@"Time since player Twitter was updated is %ld", (long)timeDifference);
    if(timeDifference >= 1)
    {
        return YES;
    }
    
    return NO;
}

//http://stackoverflow.com/questions/12552785/resizing-image-to-fit-uiimageview
-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    //here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
    
}

@end
