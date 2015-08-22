//
//  MenuViewController.h
//  PopupWindowTest
//
//  Created by Buv Sethia on 8/19/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuDelegate <NSObject>
@required
-(void)selectedMenuItem:(NSInteger)newItem calledBy: (id)sender;
@end

@interface PopupMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSArray *tableMenuItems;
@property (nonatomic, weak) id<MenuDelegate> delegate;
@property id menuCaller;

- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController;

@end
