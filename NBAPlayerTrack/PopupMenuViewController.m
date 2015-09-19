//
//  MenuViewController.m
//  PopupWindowTest
//
//  Created by Buv Sethia on 8/19/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "PopupMenuViewController.h"

@interface PopupMenuViewController ()

@end

@implementation PopupMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //Add tap gesture recognizer to view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(onSingleTap:)];
    [tap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tap];
}

//If view is tapped outside of the table view, dismiss it
-(void)onSingleTap:(UITapGestureRecognizer *)sender
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

#pragma mark - TableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableMenuItems.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PopupCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = self.tableMenuItems[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Notify the delegate if it exists.
    if (self.delegate != nil) {
        [self.delegate selectedMenuItem:indexPath.row calledBy:self.menuCaller];
    }
    [self dismissViewControllerAnimated:YES completion:Nil];
}

//Sets it so that the modal segues does not put a black screen behind the view
- (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

@end
