//
//  ArticleViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/18/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "ArticleViewController.h"
#import "SWRevealViewController.h"

@implementation ArticleViewController

-(void)viewDidLoad
{
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        self.navigationItem.leftBarButtonItem = self.sidebarButton;
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(articlesMenuPressed)];
    
    NSURL *urlU = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlU];
    [self.webView loadRequest:request];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

- (void)articlesMenuPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
