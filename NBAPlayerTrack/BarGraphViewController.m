//
//  BarGraphViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/10/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "BarGraphViewController.h"

@interface BarGraphViewController ()

@end

@implementation BarGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Set the orientation of the view as landscape to use space better
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

@end
