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
#import "ArticleViewController.h"
#import "Article.h"

@implementation PlayerNewsViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    PlayerTabBarController *tabController = (PlayerTabBarController*)self.tabBarController;
    self.articles = tabController.player.articles;
    [self.tableView reloadData];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.tabBarController.navigationItem.leftBarButtonItem setTarget: self.revealViewController];
        [self.tabBarController.navigationItem.leftBarButtonItem setAction: @selector( revealToggle: )];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Player Menu" style:UIBarButtonItemStylePlain target:self action:@selector(playerMenuPressed)];
    
    //Navigation item coloring
    self.tabBarController.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    self.tabBarController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
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
    Article *article = (Article*)self.articles[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = article.title;
    return cell;
}
 -(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)playerMenuPressed{
    [self.tabBarController.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    Article *article = [self.articles objectAtIndex:selectedIndexPath.row];
    ArticleViewController *dest = (ArticleViewController*)segue.destinationViewController;
    dest.url = article.url;
    
}

@end
