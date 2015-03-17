//
//  PlayerTabBarController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/17/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerTabBarController.h"
#import "SWRevealViewController.h"

@implementation PlayerTabBarController

-(id)init
{
    NSLog(@"Hello from tab controller");
    self = [super init];
    if(self)
    {
        SWRevealViewController *revealViewController = self.revealViewController;
        if ( revealViewController )
        {
            [self.sidebarButton setTarget: self.revealViewController];
            [self.sidebarButton setAction: @selector( revealToggle: )];
            [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        }
    }
    
    return self;
    
}

- (IBAction)playerMenuPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
