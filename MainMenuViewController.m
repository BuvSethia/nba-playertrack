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
#import "PlayerCell.h"

@implementation MainMenuViewController

static NSMutableArray *userPlayers = nil;

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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
    
    //Test
    //self.navigationController.navigationBar.barTintColor = [UIColor blueColor];
    
    //self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor lightGrayColor];
    //Removes horizontal lines from the table view
    //[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //Let the table view use Player Cells
    [self.tableView registerNib:[UINib nibWithNibName:@"PlayerCell" bundle:nil] forCellReuseIdentifier:@"menuCell"];
    
    if(userPlayers == Nil && [[NSFileManager defaultManager] fileExistsAtPath:[MainMenuViewController userPlayersFilePath]])
    {
        userPlayers = [NSKeyedUnarchiver unarchiveObjectWithFile:[MainMenuViewController userPlayersFilePath]];
        NSLog(@"Loading players from file");
        for(int i = 0; i < userPlayers.count; i++)
        {
            userPlayers[i] = [Utility generateObjectForPlayer:userPlayers[i]];

        }
        [MainMenuViewController saveUserPlayers];
        
    }
    else if(userPlayers != Nil)
    {
        NSLog(@"Players already loaded");
        //[self.tableView reloadData];
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
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [userPlayers count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"menuCell";
    PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"PlayerCell" bundle:nil] forCellReuseIdentifier:@"menuCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(PlayerCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create a new Player Object
    Player *player = [userPlayers objectAtIndex:indexPath.section];
    
    cell.image.image = [[UIImage alloc] initWithData:player.playerImage];
    cell.nameLabel.text = player.name;
    cell.pointsLabel.text = [player.perGameStats objectForKey:@"PTS"];
    cell.rebLabel.text = [player.perGameStats objectForKey:@"TRB"];
    cell.astLabel.text = [player.perGameStats objectForKey:@"AST"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"PlayerDetailSegue" sender:tableView];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [userPlayers removeObjectAtIndex:indexPath.section];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        [MainMenuViewController saveUserPlayers];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"menuCell"];
    return cell.bounds.size.height;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 2.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 2.0f;
}

//http://stackoverflow.com/questions/12552785/resizing-image-to-fit-uiimageview
-(UIImage*)resizeImage:(UIImage *)image imageSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
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
        Player *p = [userPlayers objectAtIndex:selectedIndexPath.section];
        dest.player = p;
    }
}

@end
