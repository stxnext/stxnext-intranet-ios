//
//  TeamManager.m
//  Intranet
//
//  Created by Adam on 13.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "TeamManager.h"
#import "AppDelegate+Settings.h"
#import "APIRequest.h"


@implementation TeamMember
@end

@implementation TeamInfo
@end


@implementation TeamManager
/*
+ (void)downloadTeamsWithSuccess:(void (^)(NSArray *teamsInfos, NSArray *teamsMembers))success
                         failure:(void (^)(void))failure
{
    NSMutableArray *teamsInfos = [NSMutableArray new];
    NSMutableArray *teamsMembers = [NSMutableArray new];
    
    [APP_DELEGATE myUserIdWithBlockSuccess:^(NSString *userId) {
        [[HTTPClient sharedClient] startOperation:[APIRequest getTeams]
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              
                                              NSArray *teams = [responseObject objectForKey:@"teams"];
                                              NSNumber *myId = [NSNumber numberWithInt:[userId intValue]];
                                              
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
                                                              teamUser.isSelected = NO;
                                                              
                                                              [teamUsers addObject:teamUser];
                                                          }
                                                      }
                                                      
                                                      if (teamUsers.count)
                                                      {
                                                          TeamInfo *teamInfo = [TeamInfo new];
                                                          teamInfo.teamName = teamName;
                                                          teamInfo.teamId = teamId;
                                                          
                                                          [teamsInfos addObject:teamInfo];
                                                          [teamsMembers addObject:teamUsers];
                                                      }
                                                  }
                                              }
                                              
                                              success(teamsInfos, teamsMembers);
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              failure();
                                          }];
    } failure:^{
        failure();
    }];
}
*/
@end
