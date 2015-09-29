//
//  SinglePlayerTrendGraphViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/28/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "Player.h"

@interface SinglePlayerTrendGraphViewController : UIViewController <CPTPlotDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;
@property (weak, nonatomic) IBOutlet UIImageView *graphImageView;
@property (weak, nonatomic) IBOutlet UIImageView *legendImageView;
@property (weak, nonatomic) IBOutlet UIView *presentedImagesView;

@property NSDictionary *statsToGraph;
@property Player *playerBeingGraphed;
@property NSArray *monthsBeingGraphed;

@end
