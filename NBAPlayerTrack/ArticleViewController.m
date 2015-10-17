//
//  ArticleViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/18/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "ArticleViewController.h"
#import "SWRevealViewController.h"
#import "Utility.h"

@interface ArticleViewController ()

//@property UIActivityIndicatorView *loadArticlesIndicator;

@end

@implementation ArticleViewController

-(void)viewDidLoad
{
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
    
    self.tabBarController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(articlesMenuPressed)];
    
    //Navigation item tint
    self.tabBarController.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    self.tabBarController.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    NSURL *urlU = [NSURL URLWithString:self.url];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error loading this article. Please try again later" delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }

}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Started article load");
    
    /*
    self.loadArticlesIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadArticlesIndicator.color = [UIColor blackColor];
    self.loadArticlesIndicator.center = self.view.center;
    [self.loadArticlesIndicator startAnimating];
    [self.view addSubview:self.loadArticlesIndicator];
    [self.view bringSubviewToFront:self.loadArticlesIndicator];
    */
    
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Finished article load");
    /*
    [self.loadArticlesIndicator stopAnimating];
    [self.loadArticlesIndicator removeFromSuperview];
    */
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"There was an error loading this page. Please try again later" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alert show];
}

- (void)articlesMenuPressed{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

@end
