//
//  TeamsTableViewController.m
//  Intranet
//
//  Created by Adam on 12.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "TeamsTableViewController.h"
#import "UserListCell.h"
#import "TeamManager.h"



#import "AppDelegate+Settings.h"
#import "APIRequest.h"



@interface TeamsTableViewController ()
{
    NSInteger currentSelectedSection;
}

@property (nonatomic, strong) NSMutableArray *teamsInfos;
@property (nonatomic, strong) NSMutableArray *teamsMembers;

@end

@implementation TeamsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.teamsInfos = [NSMutableArray new];
    self.teamsMembers = [NSMutableArray new];

    
    [APP_DELEGATE myUserIdWithBlockSuccess:^(NSString *userId) {
        
        NSArray *teams = [JSONSerializationHelper objectsWithClass:[RMTeam class]
                                                withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                                 ascending:YES
                                                                                                  selector:@selector(localizedCompare:)]
                                                     withPredicate:nil
                                                  inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
        
        NSNumber *myId = [NSNumber numberWithInt:[userId intValue]];
        
        BOOL isFirstTeam = YES;
        
        currentSelectedSection = 0;
        
        int tempSelectedSection = 0;
        int teamCounter = 0;
        
        for (RMTeam *team in teams)
        {
            for (RMUser *user in team.users)
            {
                if (user.id.intValue == myId.intValue)
                {
                    TeamInfo *teamInfo = [TeamInfo new];
                    teamInfo.teamName = team.name;
                    teamInfo.teamId = team.id;
                    
                    [self.teamsInfos addObject:teamInfo];
                    
                    NSMutableArray *tempMembers = [NSMutableArray new];
                    
                    for (RMUser *user in team.users)
                    {
                        TeamMember *teamMember = [TeamMember new];
                        teamMember.user = user;
                        
                        if (self.previousSelectedUsers.count)
                        {
                            if (self.previousSelectedTeamId.intValue == team.id.intValue)
                            {
                                teamMember.isSelected = [self.previousSelectedUsers containsObject:teamMember.user.id];
                                currentSelectedSection = tempSelectedSection;
                            }
                            else
                            {
                                teamMember.isSelected = NO;
                            }
                        }
                        else
                        {
                            teamMember.isSelected = isFirstTeam;
                        }
                        
                        [tempMembers addObject:teamMember];
                    }
                    [self.teamsMembers addObject:tempMembers];
                    
                    tempSelectedSection++;
                    isFirstTeam = NO;
                    teamCounter++;
                    
                    break;
                }
            }
        }
        
        [self.tableView reloadDataAnimated:YES];
        
    } failure:^{
        
    }];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"UserListCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[UserListCell cellId]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if ([self.delegate respondsToSelector:@selector(teamsTableViewController:didFinishWithIDs:teamTitle:teamId:)] && self.teamsMembers.count)
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

- (void)setCurrentSelectedSection:(NSInteger)newSelectedSection
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
