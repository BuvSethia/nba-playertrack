//
//  PlayerNewsViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/17/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerNewsViewController.h"
#import "SWRevealViewController.h"
#import "PlayerTabBarController.h"
#import "MainMenuViewController.h"

@implementation PlayerNewsViewController

-(void)viewDidLoad
{
    self.articles = [[NSMutableArray alloc] initWithArray:[[NSArray alloc] initWithObjects:@"hello", @"goodbye", nil]];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.articles.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ArticleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.articles[indexPath.row];
    return cell;
}

- (void)playerMenuPressed{
    [self.tabBarController.navigationController popViewControllerAnimated:YES];
}

@end
