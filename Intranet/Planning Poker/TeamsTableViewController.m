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
    int currentSelectedSection;
}




@property (nonatomic, strong) NSArray *teamsInfos;
@property (nonatomic, strong) NSArray *teamsMembers;

@end

@implementation TeamsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.teamsInfos = [NSArray new];
    self.teamsMembers = [NSArray new];

    [TeamManager downloadTeamsWithSuccess:^(NSArray *teamsInfos, NSArray *teamsMembers) {
        self.teamsInfos = teamsInfos;
        self.teamsMembers = teamsMembers;
        
        BOOL isFirstTeam = YES;
        
        currentSelectedSection = 0;
        
        int tempSelectedSection = 0;
        int teamCounter = 0;
        
        for (NSArray *teams in self.teamsMembers)
        {
            for (TeamMember *teamMember in teams)
            {
                NSNumber *teamId = ((TeamInfo *)self.teamsInfos[teamCounter]).teamId;
                
                if (self.previousSelectedUsers.count)
                {
                    if (self.previousSelectedTeamId.intValue == teamId.intValue)
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
            }
            
            tempSelectedSection++;
            isFirstTeam = NO;
            teamCounter++;
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
