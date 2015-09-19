//
//  BarGraphViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 9/10/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"

@interface BarGraphViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property NSArray *playersToGraph;
@property NSMutableDictionary *statsToGraph;
@property NSMutableDictionary *normalizedStatsToGraph;
@property NSArray *xAxisDescriptors;
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *hostView;

@end
