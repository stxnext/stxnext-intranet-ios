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

@interface TeamMember : NSObject

@property (nonatomic, strong) RMUser *user;
@property (nonatomic, assign) BOOL isSelected;

@end

@implementation TeamMember
@end




@interface TeamInfo : NSObject

@property (nonatomic, strong) NSNumber *teamId;
@property (nonatomic, copy) NSString *teamName;

@end

@implementation TeamInfo
@end




@interface TeamsTableViewController ()
{
    int currentSelectedSection;
}




@property (nonatomic, strong) NSMutableArray *teamsInfos;
@property (nonatomic, strong) NSMutableArray *teamsMembers;

@end

@implementation TeamsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.teamsInfos = [[NSMutableArray alloc] init];
    self.teamsMembers = [[NSMutableArray alloc] init];
    
    [APP_DELEGATE myUserIdWithBlockSuccess:^(NSString *userId) {
        [[HTTPClient sharedClient] startOperation:[APIRequest getTeams]
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              
                                              NSArray *teams = [responseObject objectForKey:@"teams"];

                                              NSNumber *myId = [NSNumber numberWithInt:[userId intValue]];
                                              
                                              BOOL isFirstTeam = YES;
                                              
                                              currentSelectedSection = 0;
                                              
                                              int tempSelectedSection = 0;
                                              
                                              for (NSDictionary *team in teams)
                                              {
                                                  NSString *teamName = [team objectForKey:@"name"];
                                                  NSNumber *teamId = [team objectForKey:@"id"];
                                                  NSArray *users = [team objectForKey:@"users"];
                                                  
                                                  if ([users containsObject:myId])
                                                  {
                                                      NSMutableArray *teamUsers = [[NSMutableArray alloc] init];

                                                      for (NSNumber *userId in users)
                                                      {
                                                          RMUser *user = [[JSONSerializationHelper objectsWithClass:[RMUser class]
                                                                                                 withSortDescriptor:nil
                                                                                                      withPredicate:[NSPredicate predicateWithFormat:@"id = %i", [userId intValue]]
                                                                                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext] firstObject];
                                                          
                                                          if ([user.isActive boolValue])
                                                          {
                                                              TeamMember *teamUser = [[TeamMember alloc] init];
                                                              teamUser.user = user;
                                                              
                                                              if (self.previousSelectedUsers.count)
                                                              {
                                                                  if (self.previousSelectedTeamId.intValue == teamId.intValue)
                                                                  {
                                                                      teamUser.isSelected = [self.previousSelectedUsers containsObject:user.id];
                                                                      currentSelectedSection = tempSelectedSection;
                                                                  }
                                                                  else
                                                                  {
                                                                      teamUser.isSelected = NO;
                                                                  }
                                                              }
                                                              else
                                                              {
                                                                  teamUser.isSelected = isFirstTeam;
                                                              }
                                                              
                                                              [teamUsers addObject:teamUser];
                                                          }
                                                      }
                                                      
                                                      isFirstTeam = NO;
                                                      
                                                      if (teamUsers.count)
                                                      {
                                                          TeamInfo *teamInfo = [TeamInfo new];
                                                          teamInfo.teamName = teamName;
                                                          teamInfo.teamId = teamId;
                                                          
                                                          [self.teamsInfos addObject:teamInfo];
                                                          [self.teamsMembers addObject:teamUsers];
                                                          
                                                          tempSelectedSection++;
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

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(teamsTableViewController:didFinishWithIDs:teamTitle:teamId:)])
    {
        NSMutableArray *teamMembersIDs = [NSMutableArray new];
        
        for (TeamMember *teamMember in self.teamsMembers[currentSelectedSection])
        {
            if (teamMember.isSelected)
            {
                [teamMembersIDs addObject:teamMember.user.id];
            }

        }

        [self.delegate teamsTableViewController:self
                               didFinishWithIDs:teamMembersIDs
                                      teamTitle:((TeamInfo *)self.teamsInfos[currentSelectedSection]).teamName
                                         teamId:((TeamInfo *)self.teamsInfos[currentSelectedSection]).teamId];
    }
    
    [super viewWillDisappear:animated];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.teamsInfos.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.teamsMembers[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserListCell cellId]];
    
    if (!cell)
    {
        cell = [[UserListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UserListCell cellId]];
    }
    
    TeamMember *teamMember = self.teamsMembers[indexPath.section][indexPath.row];
    
    cell.user = teamMember.user;
    
    cell.accessoryType = teamMember.isSelected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ((TeamInfo *)self.teamsInfos[section]).teamName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TeamMember *teamMember = self.teamsMembers[indexPath.section][indexPath.row];
    teamMember.isSelected = !teamMember.isSelected;
 
    [self setCurrentSelectedSection:indexPath.section];;
    
    [self.tableView reloadDataAnimated:YES];
}

- (void)setCurrentSelectedSection:(int)newSelectedSection
{
    if (newSelectedSection != currentSelectedSection)
    {
        for (TeamMember *teamMember in self.teamsMembers[currentSelectedSection])
        {
            teamMember.isSelected = NO;
        }
        
        currentSelectedSection = newSelectedSection;
    }
}

@end
