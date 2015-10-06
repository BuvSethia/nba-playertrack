//
//  WikipediaViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 10/5/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WikipediaViewController : UIViewController <UIWebViewDelegate>

@property NSString *url;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
