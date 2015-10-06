//
//  PlayerBioViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/21/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerBioViewController.h"
#import "WikipediaViewController.h"

@interface PlayerBioViewController ()

@end

@implementation PlayerBioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bioTextField.text = [self.playerBio objectForKey:@"extract"];
}

- (IBAction)backToStatsPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//Sets it so that the modal segues does not put a black screen behind the view
- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    WikipediaViewController *dest = segue.destinationViewController;
    NSString *wikiPageTitle = [[self.playerBio objectForKey:@"title"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    dest.url = [NSString stringWithFormat:@"https://en.wikipedia.org/wiki/%@", wikiPageTitle];
    NSLog(@"%@", dest.url);
}

@end
