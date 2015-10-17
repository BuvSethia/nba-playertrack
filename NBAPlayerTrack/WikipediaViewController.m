//
//  WikipediaViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 10/5/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "WikipediaViewController.h"
#import "Utility.h"

@interface WikipediaViewController ()

@property UIActivityIndicatorView *loadArticlesIndicator;

@end

@implementation WikipediaViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *urlU = [NSURL URLWithString:[self.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@", urlU);
    NSURLRequest *request = [NSURLRequest requestWithURL:urlU];
    if(request)
    {
        if([Utility haveInternet])
        {
            self.webView.delegate = self;
            [self.webView loadRequest:request];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error connecting to the internet. Please check that either wifi or data is on." delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error loading the player's extended bio. Please try again later" delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
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

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error loading this page. Please try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}

@end
