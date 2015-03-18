//
//  PlayerNewsViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/17/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerNewsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *articles;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playerMenuButton;

@end
