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
    self.articles = nil;
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        revealViewController.navigationItem.rightBarButtonItem = self.playerMenuButton;
        [revealViewController.navigationItem.leftBarButtonItem setTarget: self.revealViewController];
        [revealViewController.navigationItem.leftBarButtonItem setAction: @selector( revealToggle: )];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.articles.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlayerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
}

- (IBAction)playerMenuButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //[self.navigationController pushViewController:[[MainMenuViewController alloc] init] animated:YES];
}

@end
