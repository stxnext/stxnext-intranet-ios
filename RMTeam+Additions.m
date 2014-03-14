//
//  RMTeam+Additions.m
//  Intranet
//
//  Created by Adam on 14.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "RMTeam+Additions.h"

@implementation RMTeam (Additions)

#pragma mark Mapping

const NSString* MapKeyTeamId = @"id";
const NSString* MapKeyTeamName = @"name";
const NSString* MapKeyTeamUsers = @"users";

#pragma mark Serialization

+ (NSString* )coreDataEntityName
{
    return @"Team";
}


+ (NSManagedObject<JSONMapping>*)mapFromJSON:(id)json
{
//    DDLogVerbose(@"%@", json);
    
    return [JSONSerializationHelper objectWithClass:[self class]
                                             withId:json[MapKeyTeamId]
                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext
                                      withDecorator:^(NSManagedObject<JSONMapping>* object) {
                                          
                                          RMTeam *team = (RMTeam *)object;
                                          
                                          team.name = [json[MapKeyTeamName] validObject];
                                          team.id = [json[MapKeyTeamId] validObject];
                                          
                                          for (NSNumber *userID in [json[MapKeyTeamUsers] validObject])
                                          {

                                              
                                              RMUser *user = (RMUser *)[JSONSerializationHelper objectWithClass:[RMUser class]
                                                                                                         withId:[userID validObject]
                                                                                               inManagedContext:[DatabaseManager sharedManager].managedObjectContext
                                                                                                  withDecorator:^(NSManagedObject<JSONMapping> *object) {
                                                                                                      //                                                                                              RMUser* user = (RMUser*)object;
                                                                                                      //                                                                                              user.name = [json[MapKeyLateUserName] validObject];
                                                                                                  }];
                                              
                                              if (user.name)
                                              {
                                                  [team addUsersObject:user];
                                                  
                                                  if (team)
                                                  {
                                                      [user addTeamsObject:team];
                                                  }
                                              }
                                          }
                                      }];
}


- (id)mapToJSON
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Method %@ not implemented", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
