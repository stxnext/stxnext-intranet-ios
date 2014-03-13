//
//  TeamsTableViewController.m
//  Intranet
//
//  Created by Adam on 12.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "TeamsTableViewController.h"
#import "AppDelegate+Settings.h"
#import "UserListCell.h"

#import "APIRequest.h"

@interface TeamUser : NSObject

@property (nonatomic, strong) RMUser *user;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation TeamUser

@end

@interface TeamsTableViewController ()

@property (nonatomic, strong) NSMutableArray *teamsNames;
@property (nonatomic, strong) NSMutableArray *teamsUsers;

@end

@implementation TeamsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.teamsNames = [[NSMutableArray alloc] init];
    self.teamsUsers = [[NSMutableArray alloc] init];
    
    [APP_DELEGATE myUserIdWithBlockSuccess:^(NSString *userId) {
        [[HTTPClient sharedClient] startOperation:[APIRequest getTeams]
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              NSArray *teams = [responseObject objectForKey:@"teams"];
                                              NSLog(@"%@", teams);
                                              NSNumber *myId = [NSNumber numberWithInt:[[APP_DELEGATE myUserId] intValue]];
                                              
                                              for (NSDictionary *team in teams)
                                              {
                                                  NSString *teamName = [team objectForKey:@"name"];
                                                  NSArray *users = [team objectForKey:@"users"];
                                                  
                                                  if ([users containsObject:myId])
                                                  {
                                                      NSMutableArray *teamUsers = [[NSMutableArray alloc] init];
                                                      
                                                      NSLog(@"%@", teamName);
                                                      NSLog(@"%@", users);
                                                      
                                                      for (NSNumber *userId in users)
                                                      {
                                                          RMUser *user = [[JSONSerializationHelper objectsWithClass:[RMUser class]
                                                                                                 withSortDescriptor:nil
                                                                                                      withPredicate:[NSPredicate predicateWithFormat:@"id = %i", [userId intValue]]
                                                                                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext] firstObject];
                                                          

                                                          if ([user.isActive boolValue])
                                                          {
                                                              TeamUser *teamUser = [[TeamUser alloc] init];
                                                              teamUser.user = user;
                                                              teamUser.isSelected = NO;
                                                              
                                                              [teamUsers addObject:teamUser];
                                                          }
                                                      }
                                                      
                                                      if (teamUsers.count)
                                                      {
                                                          [self.teamsNames addObject:teamName];
                                                          [self.teamsUsers addObject:teamUsers];
                                                      }
                                                  }
                                              }
                                              
                                              [self.tableView reloadDataAnimated:YES];
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              
                                          }];
    } failure:^{
        
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserListCell cellId]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.teamsNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.teamsUsers[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserListCell cellId]];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UserListCell cellId]];
    }
    
    TeamUser *teamUser = self.teamsUsers[indexPath.section][indexPath.row];
    
    cell.user = teamUser.user;
    
    cell.accessoryType = teamUser.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.teamsNames[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamUser *teamUser = self.teamsUsers[indexPath.section][indexPath.row];
    teamUser.isSelected = !teamUser.isSelected;
    
    [self.tableView reloadDataAnimated:YES];
}

@end
