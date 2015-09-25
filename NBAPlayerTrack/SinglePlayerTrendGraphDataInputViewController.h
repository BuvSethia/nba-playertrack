//
//  SingePlayerTrendGraphDataInputViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/25/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupMenuViewController.h"

@interface SinglePlayerTrendGraphDataInputViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate,MenuDelegate>

@property (weak, nonatomic) IBOutlet UIButton *selectPlayerButton;
@property (weak, nonatomic) IBOutlet UIButton *statsButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end
