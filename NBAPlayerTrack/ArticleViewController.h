//
//  ArticleViewController.h
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/18/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property NSString *url;

@end
