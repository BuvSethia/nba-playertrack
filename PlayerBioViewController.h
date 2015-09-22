//
//  PlayerBioViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/21/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerBioViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *bioTextField;
@property NSDictionary *playerBio;

- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController;

@end
