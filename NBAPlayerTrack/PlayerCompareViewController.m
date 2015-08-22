//
//  PlayerCompareViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 8/21/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerCompareViewController.h"

@interface PlayerCompareViewController ()

@end

@implementation PlayerCompareViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.selectedPlayerOne = nil;
    self.selectedPlayerTwo = nil;
    self.statTypeToDisplay = Undecided;
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    PopupMenuViewController *dest = (PopupMenuViewController*) segue.destinationViewController;
    //Based on iOS version, make it so that the modal segue does not place a black screen behind the presented view.
    [dest setPresentationStyleForSelfController:self presentingController:dest];
    
    //If the sender is either of the player select buttons
    if(sender == self.playerOneButton || sender == self.playerTwoButton)
    {
        
    }
}


#pragma mark - Table View
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellType = @"PlayerCompareCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
    
    UILabel *playerOneStatLabel = (UILabel*) [cell viewWithTag:100];
    UILabel *playerTwoStatLabel = (UILabel*) [cell viewWithTag:102];
    UILabel *statName = (UILabel*) [cell viewWithTag:101];
    
    //Determine label text based on stat type requested
    if(self.statTypeToDisplay == PerGame)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.perGameStats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.perGameStats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.perGameStats allKeys][indexPath.row];
    }
    else if(self.statTypeToDisplay == Per36)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.per36Stats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.per36Stats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.per36Stats allKeys][indexPath.row];
    }
    else if(self.statTypeToDisplay == Advanced)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.advancedStats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.advancedStats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.advancedStats allKeys][indexPath.row];
    }
    else if(self.statTypeToDisplay == PerGameCareer)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.careerPerGameStats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.careerPerGameStats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.careerPerGameStats allKeys][indexPath.row];
    }
    else if(self.statTypeToDisplay == AdvancedCareer)
    {
        playerOneStatLabel.text = [self.selectedPlayerOne.careerAdvancedStats allValues][indexPath.row];
        playerTwoStatLabel.text = [self.selectedPlayerTwo.careerAdvancedStats allValues][indexPath.row];
        statName.text = [self.selectedPlayerOne.careerAdvancedStats allKeys][indexPath.row];
    }
    //Something went horribly wrong if we reach this case
    else
    {
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //If not all required fields are filled, there are no rows
    if(self.selectedPlayerOne == nil || self.selectedPlayerTwo == nil || self.statTypeToDisplay == Undecided)
    {
        return 0;
    }
    //If all required fields are filled, return a count corresponding to the stat type to be displayed. Only have to check one player because all players have the same stats stored.
    else
    {
        if(self.statTypeToDisplay == PerGame)
        {
            return self.selectedPlayerOne.perGameStats.count;
        }
        else if(self.statTypeToDisplay == Per36)
        {
            return self.selectedPlayerOne.per36Stats.count;
        }
        else if(self.statTypeToDisplay == Advanced)
        {
            return self.selectedPlayerOne.advancedStats.count;
        }
        else if(self.statTypeToDisplay == PerGameCareer)
        {
            return self.selectedPlayerOne.careerPerGameStats.count;
        }
        else if(self.statTypeToDisplay == AdvancedCareer)
        {
            return self.selectedPlayerOne.careerAdvancedStats.count;
        }
        //Something went horribly wrong if we reach this case
        else
        {
            return 0;
        }
    }
}

#pragma mark - PopupMenuViewController
-(void)selectedMenuItem:(NSInteger)newItem calledBy:(id)sender
{
    
}

@end
