//
//  WikipediaViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 10/5/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "WikipediaViewController.h"

@interface WikipediaViewController ()

@property UIActivityIndicatorView *loadArticlesIndicator;

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

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Started article load");
    
    self.loadArticlesIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadArticlesIndicator.color = [UIColor blackColor];
    self.loadArticlesIndicator.center = self.view.center;
    [self.loadArticlesIndicator startAnimating];
    [self.view addSubview:self.loadArticlesIndicator];
    [self.view bringSubviewToFront:self.loadArticlesIndicator];
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Finished article load");
    [self.loadArticlesIndicator stopAnimating];
    [self.loadArticlesIndicator removeFromSuperview];
}

@end
