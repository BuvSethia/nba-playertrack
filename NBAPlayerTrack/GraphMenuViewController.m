//
//  GraphMenuViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/8/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "GraphMenuViewController.h"
#import "SWRevealViewController.h"
#import "BarGraphViewController.h"

@interface GraphMenuViewController ()

@property NSArray *graphTypeArray;

@end

@implementation GraphMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.graphTypeArray = [[NSArray alloc] initWithObjects:@"Player Compare Graph", @"Trend Graph", nil];
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

#pragma mark - Table View
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.graphTypeArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"GraphMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UIButton *infoButton = (UIButton*)[cell viewWithTag:1];
    infoButton.tag = indexPath.row;
    UILabel *graphTypeLabel = (UILabel*) [cell viewWithTag:2];
    graphTypeLabel.text = self.graphTypeArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //If Player Compare Graph
    if(indexPath.row == 0)
    {
        [self performSegueWithIdentifier:@"BarGraphSegue" sender:tableView];
    }
    //If Trend Graph
    else
    {
        
    }
    
}
#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

- (IBAction)cellInfoButtonPressed:(id)sender {
    UIButton *button = (UIButton*)sender;
    NSString *graphDescriptorString;
    if(button.tag == 0)
    {
        graphDescriptorString = @"A bar graph comparing up to 5 stats for up to 3 players.";
    }
    else if (button.tag == 1)
    {
        graphDescriptorString = @"A line graph depicting how the chosen stat for up to 3 players has changed over the season.";
    }
    else
    {
        graphDescriptorString = @"You've discovered a graph type that hasn't been programmed yet!";
    }
    
    UIAlertView *info = [[UIAlertView alloc] initWithTitle:self.graphTypeArray[button.tag] message:graphDescriptorString delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [info show];
}

@end
