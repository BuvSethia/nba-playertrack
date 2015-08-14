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

-(void)viewDidLoad
{
    PlayerTabBarController *tabController = (PlayerTabBarController*)self.tabBarController;
    
    self.player = tabController.player;
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        self.navigationItem.leftBarButtonItem = self.tabBarController.navigationItem.leftBarButtonItem;
        [self.tabBarController.navigationItem.leftBarButtonItem setTarget: self.revealViewController];
        [self.tabBarController.navigationItem.leftBarButtonItem setAction: @selector( revealToggle: )];
    }
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
    return self.player.perGameStats.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    UILabel *statName = (UILabel *)[cell viewWithTag:100];
    statName.text = [self.player.perGameStats.allKeys objectAtIndex:indexPath.row];
    
    UILabel *statValue = (UILabel *)[cell viewWithTag:101];
    statValue.text = [self.player.perGameStats.allValues objectAtIndex:indexPath.row];
    
    return cell;
}

@end
