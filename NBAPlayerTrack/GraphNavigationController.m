//
//  GraphNavigationController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/19/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "GraphNavigationController.h"
#import "GraphMenuViewController.h"

@interface GraphNavigationController ()

@end

@implementation GraphNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"Determining supported interface orientations");
    return [self.visibleViewController supportedInterfaceOrientations];
}

-(BOOL)shouldAutorotate
{
    return [self.visibleViewController supportedInterfaceOrientations];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}



@end
