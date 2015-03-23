//
//  MainMenuViewController.m
//  NBAPlayerTrack
//
//  Created by Buv Sethia on 3/2/15.
//  Copyright (c) 2015 ___Sethia___. All rights reserved.
//

#import "MainMenuViewController.h"
#import "SWRevealViewController.h"
#import "Player.h"
#import "Utility.h"
#import "PlayerTabBarController.h"

@implementation MainMenuViewController

//To make my life easy
NSInteger selectedCell = -1;

static NSMutableArray *userPlayers = nil;

-(void)viewDidAppear:(BOOL)animated
{
    if(self.revealViewController)
    {
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if(userPlayers == Nil && [[NSFileManager defaultManager] fileExistsAtPath:[MainMenuViewController userPlayersFilePath]])
    {
        
        userPlayers = [NSKeyedUnarchiver unarchiveObjectWithFile:[MainMenuViewController userPlayersFilePath]];
        NSLog(@"Loading players from file");
        for(int i = 0; i < userPlayers.count; i++)
        {
            userPlayers[i] = [Utility generateObjectForPlayer:userPlayers[i]];
        }
        
        //[MainMenuViewController removePlayerFile];
    }
    else
    {
        NSLog(@"userPlayersFile DNE");
    }
    
    
}

+(NSMutableArray*)userPlayers
{
    if (userPlayers == nil) userPlayers = [[NSMutableArray alloc] init];
    return userPlayers;
}

#pragma mark Table View Controller
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [userPlayers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"PlayerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Create a new Player Object
    Player *player = [userPlayers objectAtIndex:indexPath.row];
    UILabel *aLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    aLabel.text = player.name;
    
    NSDictionary *stats = player.perGameStats;
    aLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    aLabel.text = [stats objectForKey:@"PTS"];
    aLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    aLabel.text = [stats objectForKey:@"TRB"];
    aLabel = (UILabel *)[cell.contentView viewWithTag:1006];
    aLabel.text = [stats objectForKey:@"AST"];
    
    /*UIImage *image = [UIImage imageNamed:@"menu.png"];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:1000];
    CGSize imageSize = imageView.frame.size;
    UIImage *resized = [self resizeImage:image imageSize:imageSize];
    
    imageView.image = resized;*/
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedCell = indexPath.row;
}

//http://stackoverflow.com/questions/12552785/resizing-image-to-fit-uiimageview
-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    //here is the scaled image which has been changed to the size specified
    UIGraphicsEndImageContext();
    return newImage;
    
}

+(bool)containsPlayer:(NSString*)playerID
{
    for(Player *p in userPlayers)
    {
        if([playerID isEqualToString:p.ID])
        {
            return YES;
        }
    }
    
    return NO;
}

+(bool)saveUserPlayers
{
    [NSKeyedArchiver archiveRootObject:userPlayers toFile:[MainMenuViewController userPlayersFilePath]];
    if([[NSFileManager defaultManager] fileExistsAtPath:[MainMenuViewController userPlayersFilePath]])
    {
        NSLog(@"User players saved to file");
    }
    return YES;
}

+(NSString*)userPlayersFilePath
{
    NSArray *initPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentFolder = [initPath objectAtIndex:0];
    NSString *path = [documentFolder stringByAppendingFormat:@"/userPlayers.plist"];
    return path;
}

//Method used for debugging purposes only
+(void)removePlayerFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:[MainMenuViewController userPlayersFilePath] error:&error];
    if (success) {
        /*UIAlertView *removeSuccessFulAlert=[[UIAlertView alloc]initWithTitle:@"Congratulation:" message:@"Successfully removed" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [removeSuccessFulAlert show];*/
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"PlayerDetailSegue"])
    {
        PlayerTabBarController *dest = (PlayerTabBarController*)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        Player *p = [userPlayers objectAtIndex:selectedIndexPath.row];
        dest.player = p;
    }
}

@end
