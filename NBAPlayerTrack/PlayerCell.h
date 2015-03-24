//
//  PlayerCell.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/24/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *rebLabel;
@property (weak, nonatomic) IBOutlet UILabel *astLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end
