//
//  PlayerStatsViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 7/12/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerStatsViewController.h"
#import "PlayerTabBarController.h"
#import "SWRevealViewController.h"
#import "PlayerInfoViewController.h"
#import "ArticleViewController.h"

@interface PlayerStatsViewController ()

@property NSDictionary *statAcronyms;

@end

@implementation PlayerStatsViewController

bool perGameper36 = YES; //perGame = YES, per36 = NO
bool basicAdvanced = YES; //Basic = YES, Advanced = NO
bool seasonCareer = YES; //Season = YES, Career = NO

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    PlayerTabBarController *tabController = (PlayerTabBarController*)self.tabBarController;
    self.player = tabController.player;
    
    //Setting up tab bar icons. We have to do this here because of issues with using a double tab bar for displaying twitter info
    CGSize size = CGSizeMake(30, 30);
    UIImage *image = [UIImage imageWithData:self.player.playerImage];
    [[[tabController.viewControllers objectAtIndex:0] tabBarItem] setImage:[self resizeImage:image imageSize:size]];
    image = [UIImage imageNamed:@"NewspaperIcon.png"];
    [[[tabController.viewControllers objectAtIndex:1] tabBarItem] setImage:[self resizeImage:image imageSize:size]];
    //Twitter logo is smaller because it looks HUGE in app for some reason
    size = CGSizeMake(25, 25);
    image = [UIImage imageNamed:@"TwitterBird.png"];
    [[[tabController.viewControllers objectAtIndex:2] tabBarItem] setImage:[self resizeImage:image imageSize:size]];
    
    //This is a slightly hacky line of code necessary to make the Twitter tab's title appear properly, because of issues with implementing stacked tab bars
    [[[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem] setTitle:@"Twitter"];
    
    self.currentlyDisplayedStats = self.player.perGameStats;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.tabBarController.navigationItem.leftBarButtonItem setTarget: self.revealViewController];
        [self.tabBarController.navigationItem.leftBarButtonItem setAction: @selector( revealToggle: )];
    }
    
    //Navigation item coloring
    self.tabBarController.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.tabBarController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    //Stat acronyms
    self.statAcronyms = [self createStatsAcronymDictionary];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Player Menu" style:UIBarButtonItemStylePlain target:self action:@selector(playerMenuPressed)];
    self.tabBarController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)playerMenuPressed{
    [self.tabBarController.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *seguename = segue.identifier;
    if([seguename isEqualToString:@"infoSegue"])
    {
        NSLog(@"Hello from segue");
        PlayerInfoViewController *dest = segue.destinationViewController;
        PlayerTabBarController *tabController = (PlayerTabBarController*)self.tabBarController;
        dest.player = tabController.player;
    }
    else if([seguename isEqualToString:@"moreStatsSegue"])
    {
        ArticleViewController *dest = (ArticleViewController*)segue.destinationViewController;
        dest.url = self.player.webLink;
    }
}

#pragma mark - Collection View
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentlyDisplayedStats.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *statName = (UILabel *)[cell viewWithTag:100];
    statName.text = [self.currentlyDisplayedStats.allKeys objectAtIndex:indexPath.row];
    
    UILabel *statValue = (UILabel *)[cell viewWithTag:101];
    statValue.text = [self.currentlyDisplayedStats.allValues objectAtIndex:indexPath.row];
    
    //Cell shadow
    cell.layer.masksToBounds = NO;
    cell.layer.shadowOffset = CGSizeMake(1, 0);
    cell.layer.shadowColor = [[UIColor blackColor] CGColor];
    cell.layer.shadowRadius = 10;
    cell.layer.shadowOpacity = .50;
    CGRect shadowFrame = cell.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    cell.layer.shadowPath = shadowPath;
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *statName = (UILabel *)[[collectionView cellForItemAtIndexPath:indexPath] viewWithTag:100];
    UIAlertView *statDesc = [[UIAlertView alloc] initWithTitle:statName.text message:[self.statAcronyms objectForKey:statName.text] delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [statDesc show];
    
}

#pragma mark - Collection View Flow Layout
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 3.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2.0f, 3.0f, 2.0f, 3.0f);
}

- (IBAction)perGameper36TogglePressed:(id)sender {
    perGameper36 = !perGameper36;
    [self updateUIForToggleChanges];
    [self updateCollectionViewForToggleChanges];
}

- (IBAction)basicAdvancedStatsTogglePressed:(id)sender {
    basicAdvanced = !basicAdvanced;
    [self updateUIForToggleChanges];
    [self updateCollectionViewForToggleChanges];
}

- (IBAction)seasonCareerTogglePressed:(id)sender {
    seasonCareer = !seasonCareer;
    [self updateUIForToggleChanges];
    [self updateCollectionViewForToggleChanges];
}

-(void)updateUIForToggleChanges
{
    //Determine button titles based on what stats are currently being shown
    //Also disables certain buttons based on what stats are currently being shown, to remove the idea that options that DON'T exist do exist
    if(perGameper36 == YES)
    {
        [self.perGameper36Button setTitle:@"Per 36" forState:UIControlStateNormal];
        self.seasonCareerButton.enabled = YES;
    }
    else
    {
        [self.perGameper36Button setTitle:@"Per Game" forState:UIControlStateNormal];
        self.seasonCareerButton.enabled = NO;
    }
    
    if(basicAdvanced == YES)
    {
        [self.basicAdvancedButton setTitle:@"Advanced" forState:UIControlStateNormal];
        self.perGameper36Button.enabled = YES;
        self.seasonCareerButton.enabled = YES;
    }
    else
    {
        [self.basicAdvancedButton setTitle:@"Basic" forState:UIControlStateNormal];
        self.perGameper36Button.enabled = NO;
        self.seasonCareerButton.enabled = YES;
    }
    
    if(seasonCareer == YES)
    {
        [self.seasonCareerButton setTitle:@"Career" forState:UIControlStateNormal];
    }
    else
    {
        [self.seasonCareerButton setTitle:@"Season" forState:UIControlStateNormal];
        perGameper36 = YES;
        [self.perGameper36Button setTitle:@"Per 36" forState:UIControlStateNormal];
    }
    
    //Determine stats description label based on what stats are currently being shown
    if(perGameper36 && basicAdvanced && seasonCareer)
    {
        self.statsTypeLabel.text = @"Per Game Basic Stats - Season";
    }
    else if(perGameper36 && basicAdvanced && !seasonCareer)
    {
        self.statsTypeLabel.text = @"Per Game Basic Stats - Career";
    }
    else if (!perGameper36 && basicAdvanced)
    {
        self.statsTypeLabel.text = @"Per 36 Stats - Season";
    }
    else if (!basicAdvanced && seasonCareer)
    {
        self.statsTypeLabel.text = @"Per Game Advanced Stats - Season";
    }
    else if (!basicAdvanced && !seasonCareer)
    {
        self.statsTypeLabel.text = @"Per Game Advanced Stats - Career";
    }
}

//Reload displayed stats based on presses of the toggle buttons
-(void)updateCollectionViewForToggleChanges
{
    if(perGameper36 && basicAdvanced && seasonCareer)
    {
        self.currentlyDisplayedStats = self.player.perGameStats;
    }
    else if(perGameper36 && basicAdvanced && !seasonCareer)
    {
        self.currentlyDisplayedStats = self.player.careerPerGameStats;
    }
    else if (!perGameper36 && basicAdvanced)
    {
        self.currentlyDisplayedStats = self.player.per36Stats;
    }
    else if (!basicAdvanced && seasonCareer)
    {
        self.currentlyDisplayedStats = self.player.advancedStats;
    }
    else if (!basicAdvanced && !seasonCareer)
    {
        self.currentlyDisplayedStats = self.player.careerAdvancedStats;
    }
    
    [self.collectionView reloadData];
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

//What each stat acronym stands for
-(NSMutableDictionary*)createStatsAcronymDictionary
{
    NSMutableDictionary *statsAcronyms = [[NSMutableDictionary alloc] init];
    [statsAcronyms setValue:@"PTS" forKey:@"Points - The number of points a player scores per game."];
    [statsAcronyms setValue:@"FGA" forKey:@"Field Goal Attempts - The number of shots a player attempts per game."];
    [statsAcronyms setValue:@"BLK" forKey:@"Blocks - The number of shots a player blocks per game."];
    [statsAcronyms setValue:@"MP" forKey:@"Minutes Played - The number of minutes a player plays per game (48 minutes in a game excluding overtime)."];
    [statsAcronyms setValue:@"3PA" forKey:@"3-Point Attempts - The number of 3-point shots a player attempts per game."];
    [statsAcronyms setValue:@"3PPCT" forKey:@"3-Point % -  The percent of his 3-point attempts a player makes."];
    [statsAcronyms setValue:@"STL" forKey:@"Steals - The number of steals a player gets per game"];
    [statsAcronyms setValue:@"FT" forKey:@"Free Throws - The number of free throws a player makes per game."];
    [statsAcronyms setValue:@"G" forKey:@"Games - The number of games a player has played."];
    [statsAcronyms setValue:@"2PA" forKey:@"2-Point Attempts - The number of 2-point shots a player attempts per game."];
    [statsAcronyms setValue:@"2PPCT" forKey:@"2-Point % - The percent of his 2-point attempts a player makes."];
    [statsAcronyms setValue:@"FG" forKey:@"Field Goals - The number of shots a player makes per game."];
    [statsAcronyms setValue:@"FTPCT" forKey:@"Free Throw % - The percent of his free throw attempts a player makes."];
    [statsAcronyms setValue:@"TRB" forKey:@"Total Rebounds - The number of rebounds a player grabs per game (both offensive and defensive)."];
    [statsAcronyms setValue:@"FGPCT" forKey:@"Field Goal % - The percent of his shots a player makes."];
    [statsAcronyms setValue:@"DRB" forKey:@"Defensive Rebounds - The number of defensive rebounds a player grabs per game."];
    [statsAcronyms setValue:@"TOV" forKey:@"Turnovers - The number of turnovers a player commits per game."];
    [statsAcronyms setValue:@"ORB" forKey:@"Offensive Rebounds - The number of offensive rebounds a player grabs per game."];
    [statsAcronyms setValue:@"2P" forKey:@"2-Pointers - The number of 2-point shots a player makes per game."];
    [statsAcronyms setValue:@"PF" forKey:@"Personal Fouls - The number of fouls a player commits per game."];
    [statsAcronyms setValue:@"3P" forKey:@"3-Pointers - The number of 3-point shots a player makes per game."];
    [statsAcronyms setValue:@"Season" forKey:@"The current season."];
    [statsAcronyms setValue:@"AST" forKey:@"Assists - The number of assists a player gets per game (an assist is received when a player makes a pass to a teammate resulting in a score)."];
    [statsAcronyms setValue:@"FTA" forKey:@"Free Throw Attempts - The number of free throws a player attempts per game."];
    [statsAcronyms setValue:@"STLPCT" forKey:@"Steal % - The percentage of opponent possessions that end with a steal by the player while he is on the floor."];
    [statsAcronyms setValue:@"DRBPCT" forKey:@"Defensive Rebound % - The percentage of available defensive rebounds a player grabs while he is on the floor."];
    [statsAcronyms setValue:@"WS48" forKey:@"Win Shares per 48 Minutes - The number of win shares a player receives per 48 minutes played (normalizing to 48 minutes attempts to account for the fact that not all players get the same playing time)."];
    [statsAcronyms setValue:@"3PAr" forKey:@"3-Point Attempt Rate - The percentage of a player's shots that are 3-point shots."];
    [statsAcronyms setValue:@"TRBPCT" forKey:@"Total Rebound % - The percentage of all available rebounds a player grabs while he is on the floor."];
    [statsAcronyms setValue:@"ASTPCT" forKey:@"Assist % - The percentage of teammate field goals a player assisted while he is on the floor."];
    [statsAcronyms setValue:@"DWS" forKey:@"Defensive Win Shares - The number of win shares a player accumulates on the defensive end."];
    [statsAcronyms setValue:@"PER" forKey:@"Player Efficiency Rating - A measure of per minute production for a player standardized such that the league average is always 15.00"];
    [statsAcronyms setValue:@"OWS" forKey:@"Offensive Win Shares - The number of win shares a player accumulates on the offensive end."];
    [statsAcronyms setValue:@"BLKPCT" forKey:@"Block % - The percentage of opponent 2-point attempts a player blocks while he is on the floor"];
    [statsAcronyms setValue:@"ORBPCT" forKey:@"Offensive Rebound % - The percentage of available offensive rebounds a player grabs while he is on the floor."];
    [statsAcronyms setValue:@"OBPM" forKey:@"Offensive Box Plus/Minus - How many more points per 100 possessions a player contributes on the offensive end compared to a league-average player, translated to an average team."];
    [statsAcronyms setValue:@"WS" forKey:@"Win Shares - How many wins a player contributes to his teams."];
    [statsAcronyms setValue:@"TOVPCT" forKey:@"Turnover % - How many turnovers a player commits per 100 plays."];
    [statsAcronyms setValue:@"USGPCT" forKey:@"Usage % - The percent of his team's possessions a player uses while a player is on the floor (possession defined as a play ending in a shot attempt, free throws, or a turnover)."];
    [statsAcronyms setValue:@"DBPM" forKey:@"Defensive Box Plus/Minus - How many more points per 100 possessions a player contributes on the defensive end compared to a league-average player, translated to an average team."];
    [statsAcronyms setValue:@"TSPCT" forKey:@"True Shooting % - A measure of shooting efficiency that takes into account the value of 3-point shots and free throws."];
    [statsAcronyms setValue:@"FTr" forKey:@"Free Throw Rate - The number of free throws a player attempts per field goal attempt."];
    
    //Because I'm an idiot and too lazy to switch all keys and values manually
    for (NSString *key in [statsAcronyms allKeys]) {
        statsAcronyms[statsAcronyms[key]] = key;
        [statsAcronyms removeObjectForKey:key];
    }
    
    return statsAcronyms;
}

@end
