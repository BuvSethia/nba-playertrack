//
//  PlayerCell.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/24/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PlayerCell.h"

@implementation PlayerCell

- (void)awakeFromNib {
    self.layer.shadowOffset = CGSizeMake(1, 0);
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 10;
    self.layer.shadowOpacity = .50;
    CGRect shadowFrame = self.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    self.layer.shadowPath = shadowPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

/*
- (void)setFrame:(CGRect)frame {
    CGFloat inset = 5.0f;
    frame.origin.x += inset;
    frame.size.width -= 2 * inset;
    [super setFrame:frame];
}
*/

@end
