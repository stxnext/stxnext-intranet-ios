//
//  PGSessionLobbyViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 02/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGSessionLobbyViewController.h"
#import "UITableSection.h"

#import "UserListCell.h"
#import "TeamManager.h"
#import "Model.h"
#import "CurrentUser.h"
#import "APIRequest.h"
#import "UserDetailsTableViewController.h"
#import "PGSessionGameplayViewController.h"

#import "JBBarChartViewController.h"

typedef enum TableSection {
    TableSectionSession = 0,
    TableSectionOwner,
    TableSectionPlayers,
    TableSectionsCount
} TableSection;

@implementation PGSessionLobbyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserListCell cellId]];
    
    [self reloadTableSections];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem.title = [GameManager defaultManager].activeSession.isOwnedByCurrentUser ? @"Begin" : @"Join";
    
    [self fetchSessionInfo];
}

#pragma mark - User action

- (IBAction)pushViewController:(id)sender
{
    NSString* segueIdentifier = [GameManager defaultManager].activeSession.isOwnedByCurrentUser ? @"BeginSessionSegue" : @"JoinSessionSegue";
    [self performSegueWithIdentifier:segueIdentifier sender:sender];
}

#pragma mark - Navigation segue

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
#warning mockup
    [self.navigationController pushViewController:[JBBarChartViewController new] animated:YES];
    
    return NO;
    
    if ([[GameManager defaultManager].activeSession.startTime.mapToDate timeIntervalSinceNow] > 60 * 15)
    {
        [UIAlertView showWithTitle:@"Session problem" message:@"Session is not ready yet. Please come back up to 15 minutes before planning time." handler:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - Table source dynamic accessors

- (void)fetchSessionInfo
{
    [[GameManager defaultManager] fetchActiveSessionUsersWithCompletionHandler:^(GameManager *manager, NSError *error) {
        if (error)
        {
            [UIAlertView showWithTitle:@"Server problem" message:@"Could not load poker session from game server." handler:nil];
            return;
        }
        
        #warning Use regular reloadTableSections without animation instead of reloadAllRowsWithRowAnimation if session on game server has MUTABLE players array
        if (manager.activeSession.players > 0)
            [self.tableView reloadAllRowsWithRowAnimation:UITableViewRowAnimationAutomatic];
        else
            [self reloadTableSections];
    }];
}

- (void)reloadTableSections
{
    [[Users singleton] usersWithStart:nil end:nil success:^(NSArray *users) {
        NSArray* players = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id IN %@", [[GameManager defaultManager].activeSession.players valueForKey:@"externalId"]]];
        players = [players sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        RMUser* owner = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"id = %@", [GameManager defaultManager].activeSession.owner.externalId]].firstObject;
        
        NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
        dateFormater.dateFormat = @"dd/MM/YYYY HH:mm";
        NSString* date = [dateFormater stringFromDate:[GameManager defaultManager].activeSession.startTime.mapToDate];
        
        NSArray* sections = @[ [UITableSection sectionWithName:@"SESSION"
                                                       withTag:TableSectionSession
                                                      withRows:@[ [UITableTextRow rowWithName:@"Name" withValue:[GameManager defaultManager].activeSession.name],
                                                                  [UITableTextRow rowWithName:@"Deck" withValue:[GameManager defaultManager].activeSession.deck.name],
                                                                  [UITableTextRow rowWithName:@"Date" withValue:date ] ]],
                               
                               [UITableSection sectionWithName:@"OWNER"
                                                       withTag:TableSectionOwner
                                                      withRows:@[ owner ]],
                               
                               [UITableSection sectionWithName:@"PLAYERS"
                                                       withTag:TableSectionPlayers
                                                      withRows:players] ];
        
        
        _tableSections = [UITableSection sectionsWithoutEmpty:sections];
        
        [self.tableView reloadData];
    } failure:^(NSArray *cachedUsers, FailureErrorType error) {
        [UIAlertView showWithTitle:@"Server problem" message:@"Could not load users from users server." handler:nil];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _tableSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    UITableSection* tableSection = _tableSections[section];
    return tableSection.rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    UITableSection* tableSection = _tableSections[section];
    return tableSection.name;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if (section != TableSectionSession)
        return;
    
    [tableView rebuildSectionHeaderButtonWithTitle:@"REFRESH"
                                     forHeaderView:view inSection:section withTouchHandler:^{
                                         [self fetchSessionInfo];
                                     }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableSection* section = [UITableSection sectionAtIndexPath:indexPath inSectionsArray:_tableSections];
    
    switch ((TableSection)section.tag)
    {
        case TableSectionSession: return tableView.rowHeight;
            
        case TableSectionOwner:
        case TableSectionPlayers: return 95;
            
        default: return UITableViewAutomaticDimension;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableSection* section = [UITableSection sectionAtIndexPath:indexPath inSectionsArray:_tableSections];
    
    static NSString* textCellIdentifier = @"textCellIdentifier";
    
    UITableViewCell* cell = nil;
    
    switch ((TableSection)section.tag)
    {
        case TableSectionSession:
        {
            UITableTextRow* row = [UITableSection rowAtIndexPath:indexPath inSectionsArray:_tableSections];
            
            cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier] ?:
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
            
            cell.textLabel.text = row.name;
            cell.detailTextLabel.text = row.value;
            
            break;
        }
        
        case TableSectionOwner:
        case TableSectionPlayers:
        {
            RMUser* user = [UITableSection rowAtIndexPath:indexPath inSectionsArray:_tableSections];
            GMUser* gameUser = [[GameManager defaultManager].activeSession personFromExternalUser:user];
            
            UserListCell* userCell = [tableView dequeueReusableCellWithIdentifier:[UserListCell cellId]] ?:
            [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UserListCell cellId]];
            
            userCell.displayAbsences = NO;
            userCell.user = user;
            userCell.markerOverlay.hidden = !gameUser.active;
            
            cell = userCell;
            
            break;
        }
        
        default: break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableSection* section = [UITableSection sectionAtIndexPath:indexPath inSectionsArray:_tableSections];
    
    switch ((TableSection)section.tag)
    {
        case TableSectionSession: break;
            
        case TableSectionOwner:
        case TableSectionPlayers:
        {
            RMUser* user = [UITableSection rowAtIndexPath:indexPath inSectionsArray:_tableSections];
            
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
            UserDetailsTableViewController* userController = [storyboard instantiateViewControllerWithIdentifier:@"UserDetailsTableViewControllerId"];
            userController.user = user;
            
            [self.navigationController pushViewController:userController animated:YES];
            
            break;
        }
            
        default: break;
    }
}

@end
