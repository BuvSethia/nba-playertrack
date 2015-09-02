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

@interface PlayerStatsViewController ()

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
    self.currentlyDisplayedStats = self.player.perGameStats;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        self.navigationItem.leftBarButtonItem = self.tabBarController.navigationItem.leftBarButtonItem;
        [self.tabBarController.navigationItem.leftBarButtonItem setTarget: self.revealViewController];
        [self.tabBarController.navigationItem.leftBarButtonItem setAction: @selector( revealToggle: )];
    }
    
    //This is a slightly hacky line of code necessary to make the Twitter tab's title appear properly, because of issues with implementing stacked tab bars
    [[[self.tabBarController.viewControllers objectAtIndex:2] tabBarItem] setTitle:@"Twitter"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Player Menu" style:UIBarButtonItemStylePlain target:self action:@selector(playerMenuPressed)];
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
}

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
    
    return cell;
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

@end
