//
//  UsefulLinksTableViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 10/16/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "UsefulLinksTableViewController.h"
#import "SWRevealViewController.h"

@interface UsefulLinksTableViewController ()

@property NSMutableDictionary *usefulLinks;

@end

@implementation UsefulLinksTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usefulLinks = [[NSMutableDictionary alloc] init];
    [self.usefulLinks setValue:@"http://www.nba.com/" forKey:@"NBA Official Website"];
    [self.usefulLinks setValue:@"http://basketball.realgm.com/nba" forKey:@"RealGM Basketball"];
    [self.usefulLinks setValue:@"http://bleacherreport.com/nba" forKey:@"Bleacher Report NBA"];
    [self.usefulLinks setValue:@"https://www.reddit.com/r/nba" forKey:@"Reddit NBA"];
    
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.navigationItem.leftBarButtonItem setTarget: self.revealViewController];
        [self.navigationItem.leftBarButtonItem setAction: @selector( revealToggle: )];
    }
    
    //Remove extra cell separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.usefulLinks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkCell" forIndexPath:indexPath];
    cell.textLabel.text = [[self.usefulLinks allKeys] objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [[NSURL alloc] initWithString:[self.usefulLinks objectForKey:[self.usefulLinks.allKeys objectAtIndex:indexPath.row]]];
    [[UIApplication sharedApplication] openURL:url];
}

@end
