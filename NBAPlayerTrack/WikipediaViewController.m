//
//  WikipediaViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 10/5/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "WikipediaViewController.h"

@interface WikipediaViewController ()

@end

@implementation WikipediaViewController

-(void)viewDidLoad
{
    NSURL *urlU = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@", urlU);
    NSURLRequest *request = [NSURLRequest requestWithURL:urlU];
    [self.webView loadRequest:request];
    NSLog(@"Loaded Wikipedia page");
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
