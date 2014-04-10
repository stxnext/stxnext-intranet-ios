//
//  PGPlayerPickerViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 31/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PGPlayerPickerViewController.h"
#import "UITableSection.h"

#import "UserListCell.h"
#import "TeamManager.h"
#import "Model.h"
#import "CurrentUser.h"
#import "APIRequest.h"

@implementation PGPlayerPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserListCell cellId]];
    
    _tableFilter = PlayerFilterOwnTeams;
    _selectedPlayers = _selectedPlayers ?: [NSSet set];
    
    [self reloadTableSections];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(playerPickerViewController:didFinishWithPlayers:)])
        [self.delegate playerPickerViewController:self didFinishWithPlayers:_selectedPlayers];
    
    [super viewWillDisappear:animated];
}

#pragma mark - User actions

- (IBAction)changeFilter:(UIBarButtonItem*)sender
{
    UIActionSheet* actionSheet = [UIActionSheet bk_actionSheetWithTitle:@"Which teams would you like to display?"];
    
    [actionSheet bk_addButtonWithTitle:@"My teams only" handler:^{
        _tableFilter = PlayerFilterOwnTeams;
        [self reloadTableSections];
    }];
    
    [actionSheet bk_addButtonWithTitle:@"All teams" handler:^{
        _tableFilter = PlayerFilterAllTeams;
        [self reloadTableSections];
    }];
    
    [actionSheet bk_setCancelButtonWithTitle:@"Cancel" handler:nil];
    
    [actionSheet showFromBarButtonItem:sender animated:YES];
}

#pragma mark - Table source dynamic accessors

- (void)reloadTableSections
{
    [[Teams singleton] teamsWithStart:nil end:nil
                              success:^(NSArray *teams) {
                                  [[CurrentUser singleton] userIdWithStart:nil end:nil success:^(NSString *userId) {
                                      NSMutableArray* sections = [NSMutableArray array];
                                      
                                      switch (_tableFilter)
                                      {
                                          case PlayerFilterOwnTeams:
                                          {
                                              for (RMTeam* team in teams)
                                              {
                                                  if ([team.users filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"id = %@", @( userId.integerValue )]].count == 0)
                                                      continue;
                                                  
                                                  NSArray* sortedUsers = [team.users sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                                                  
                                                  UITableSection* section = [UITableSection sectionWithName:team.name withTag:team.id.integerValue withRows:sortedUsers];
                                                  [sections addObject:section];
                                              }
                                              
                                              break;
                                          }
                                        
                                          case PlayerFilterAllTeams:
                                          {
                                              for (RMTeam* team in teams)
                                              {
                                                  NSArray* sortedUsers = [team.users sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                                                  
                                                  UITableSection* section = [UITableSection sectionWithName:team.name withTag:team.id.integerValue withRows:sortedUsers];
                                                  [sections addObject:section];
                                              }
                                              
                                              break;
                                          }
                                              
                                          default: break;
                                      }
                                      
                                      _tableSections = [UITableSection sectionsWithoutEmpty:sections];
                                      
                                      [self.tableView reloadData];
                                  } failure:^(FailureErrorType error) {
                                      [UIAlertView showWithTitle:@"Server problem" message:@"Could not load current user from users server." handler:nil];
                                  }];
                              } failure:^(NSArray *cachedTeams, FailureErrorType error) {
                                  [UIAlertView showWithTitle:@"Server problem" message:@"Could not load teams from users server." handler:nil];
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
    [tableView rebuildSectionHeaderButtonWithTitle:@"SELECT ALL"
                                     forHeaderView:view inSection:section withTouchHandler:^{
                                         UITableSection* tableSection = [UITableSection sectionAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] inSectionsArray:_tableSections];
                                         
                                         NSSet* tableSet = [NSSet setWithArray:tableSection.rows];
                                         NSMutableSet* selectedSet = _selectedPlayers.mutableCopy;
                                         [selectedSet intersectSet:tableSet];
                                         BOOL isEntireSectionSelected = [selectedSet isEqualToSet:tableSet];
                                         
                                         if (isEntireSectionSelected)
                                             _selectedPlayers = [_selectedPlayers filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF IN %@)", tableSection.rows]];
                                         else
                                         {
                                             NSMutableSet* newSelected = _selectedPlayers.mutableCopy;
                                             [newSelected unionSet:tableSet];
                                             _selectedPlayers = newSelected;
                                         }
                                         
                                         [tableView reloadAllRowsWithRowAnimation:UITableViewRowAnimationAutomatic];
                                     }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMUser* user = [UITableSection rowAtIndexPath:indexPath inSectionsArray:_tableSections];
    
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserListCell cellId]]
    ?: [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UserListCell cellId]];
    
    cell.displayAbsences = NO;
    cell.user = user;
    cell.markerOverlay.hidden = ![_selectedPlayers containsObject:user];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RMUser* selectedUser = [UITableSection rowAtIndexPath:indexPath inSectionsArray:_tableSections];
    
    if ([[GameManager defaultManager].user.externalId isEqualToNumber:selectedUser.id])
    {
        [UIAlertView showWithTitle:@"Validation failed" message:@"Adding session owner as a player is not currently supported." handler:nil];
        return;
    }
    
    NSMutableSet* selectedSet = _selectedPlayers.mutableCopy;
    
    if ([selectedSet containsObject:selectedUser])
        [selectedSet removeObject:selectedUser];
    else
        [selectedSet addObject:selectedUser];
    
    _selectedPlayers = selectedSet;
    
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
