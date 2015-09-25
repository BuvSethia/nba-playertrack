//
//  BarGraphDataInputViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/14/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupMenuViewController.h"

@interface BarGraphDataInputViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate, MenuDelegate>
@property (weak, nonatomic) IBOutlet UIButton *selectPlayerButton;
@property (weak, nonatomic) IBOutlet UIButton *perGameSeasonButton;
@property (weak, nonatomic) IBOutlet UIButton *perGameCareerButton;
@property (weak, nonatomic) IBOutlet UIButton *advancedSeasonButton;
@property (weak, nonatomic) IBOutlet UIButton *advancedCareerButton;
@property (weak, nonatomic) IBOutlet UIButton *per36Button;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
