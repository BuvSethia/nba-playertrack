//
//  PlayerInfoViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 7/12/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerInfoViewController.h"
#import "SWRevealViewController.h"
#import "Player.h"
#import "PlayerStatsViewController.h"
#import "PlayerBioViewController.h"

@interface PlayerInfoViewController ()

@end

@implementation PlayerInfoViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"Player: %@", self.player.name);
    
    self.playerImage.image = [UIImage imageWithData:self.player.playerImage];
    self.playerName.text = self.player.name;
    self.playerTeam.text = self.player.team;
    self.playerNumber.text = [NSString stringWithFormat:@"#%@", self.player.jNumber];
    self.playerPosition.text = [NSString stringWithFormat:@"Position: %@", self.player.position];
    self.playerAge.text = [NSString stringWithFormat:@"Age: %@", [self calculateAge:self.player.DOB]];
    self.playerYearsPro.text = [NSString stringWithFormat:@"Years Pro: %@", self.player.yearsPro];
    self.playerHeight.text = [NSString stringWithFormat:@"Height: %@", self.player.height];
    self.playerWeight.text = [NSString stringWithFormat:@"Weight: %@lbs", self.player.weight];

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (NSString *)calculateAge:(NSString *)birthday
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd-yy"];
    NSDate *birthDate = [formatter dateFromString:birthday];
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthDate
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    NSString *ageString = [NSString stringWithFormat:@"%ld", (long)age];
    
    return ageString;
    
}

- (IBAction)moreInfoPressed:(id)sender {
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Bio Segue");
    PlayerBioViewController *dest = segue.destinationViewController;
    dest.playerBio = self.player.shortBio;
}

@end
