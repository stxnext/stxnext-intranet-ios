//
//  RMUser+Additions.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RMUser+Additions.h"

@implementation RMUser (Additions)

#pragma mark Mapping

const NSString* MapKeyUserId = @"id";
const NSString* MapKeyUserName = @"name";
const NSString* MapKeyUserImageURL = @"img";
const NSString* MapKeyUserAvatarURL = @"avatar_url";
const NSString* MapKeyUserLocation = @"location";
const NSString* MapKeyUserIsFreelancer = @"freelancer";
const NSString* MapKeyUserIsClient = @"is_client";
const NSString* MapKeyUserIsActive = @"is_active";
const NSString* MapKeyUserStartWork = @"start_work";
const NSString* MapKeyUserStartFullTimeWork = @"start_full_time_work";
const NSString* MapKeyUserStopWork = @"stop_work";
const NSString* MapKeyUserPhone = @"phone";
const NSString* MapKeyUserPhoneDesk = @"phone_on_desk";
const NSString* MapKeyUserSkype = @"skype";
const NSString* MapKeyUserIrc = @"irc";
const NSString* MapKeyUserEmail = @"email";
const NSString* MapKeyUserTasksLink = @"tasks_link";
const NSString* MapKeyUserAvailabilityLink = @"availability_link";
const NSString* MapKeyUserRoles = @"roles";
const NSString* MapKeyUserGroups = @"groups";

#pragma mark Serialization

+ (NSString*)coreDataEntityName
{
    return @"User";
}

+ (NSManagedObject<JSONMapping>*)mapFromJSON:(id)json
{
//    DDLogVerbose(@"%@", json);
    
    return [JSONSerializationHelper objectWithClass:[self class]
                                             withId:json[MapKeyUserId]
                                   inManagedContext:[DatabaseManager sharedManager].managedObjectContext
                                      withDecorator:^(NSManagedObject<JSONMapping>* object) {
                                          RMUser *user = (RMUser *)object;
                                          
                                          user.name = [json[MapKeyUserName] validObject];
                                          user.imageURL = [json[MapKeyUserImageURL] validObject];
                                          user.avatarURL = [json[MapKeyUserAvatarURL] validObject];
                                          user.location = [json[MapKeyUserLocation][1] validObject];
                                          user.isFreelancer = [json[MapKeyUserIsFreelancer] validObject];
                                          user.isClient = [json[MapKeyUserIsClient] validObject];
                                          user.isActive = [json[MapKeyUserIsActive] validObject];
                                          
                                          user.startWork = [JSONSerializationHelper dateFromJSONObject:[json[MapKeyUserStartWork] validObject]
                                                                                        withDateFormat:@"yyyy-MM-dd"];
                                          
                                          user.startFullTimeWork = [JSONSerializationHelper dateFromJSONObject:[json[MapKeyUserStartFullTimeWork] validObject]
                                                                                                withDateFormat:@"yyyy-MM-dd"];
                                          
                                          user.stopWork = [JSONSerializationHelper dateFromJSONObject:[json[MapKeyUserStopWork] validObject]
                                                                                       withDateFormat:@"yyyy-MM-dd"];
                                          
                                          user.phone = [json[MapKeyUserPhone] validObject];
                                          user.phoneDesk = [json[MapKeyUserPhoneDesk] validObject];
                                          user.skype = [json[MapKeyUserSkype] validObject];
                                          user.irc = [json[MapKeyUserIrc] validObject];
                                          user.email = [json[MapKeyUserEmail] validObject];
                                          user.tasksLink = [json[MapKeyUserTasksLink] validObject];
                                          user.availabilityLink = [json[MapKeyUserAvailabilityLink] validObject];
                                          
                                          NSMutableArray *_tempRoleArray = [[NSMutableArray alloc] init];
                                          NSMutableArray *_tempGroupArray = [[NSMutableArray alloc] init];
                                          
                                          for (NSString *role in [json[MapKeyUserRoles] validObject])
                                          {
                                              [_tempRoleArray addObject:[self formatRole:role]];
                                          }
                                          
                                          user.roles = _tempRoleArray;
                                          
                                          for (NSString *group in [json[MapKeyUserGroups] validObject])
                                          {
                                              [_tempGroupArray addObject:[self formatGroup:group]];
                                          }
                                          
                                          user.groups = _tempGroupArray;

//                                          user.roles = [json[MapKeyUserRoles] validObject];
//                                          user.groups = [json[MapKeyUserGroups] validObject];
                                      }];
}

+ (NSString *)formatRole:(NSString *)role
{
    if ([role isEqualToString:@"ACCOUNTANT"] || [role isEqualToString:@"ADMIN"] || [role isEqualToString:@"OFFICE MANAGER"] || [role isEqualToString:@"PROGRAMMER"] || [role isEqualToString:@"RECRUITER"] || [role isEqualToString:@"TESTER"] || [role isEqualToString:@"TECH LEAD"])
    {
        return [role capitalizedString];
    }
    
    if ([role isEqualToString:@"BUSINESS DEV"])
    {
        return @"Business Development";
    }
    
    if ([role isEqualToString:@"CEO A"])
    {
        return @"CEO's Assistant";
    }
    
    if ([role isEqualToString:@"MARKETING SPEC"])
    {
        return @"Marketing Specialist";
    }
    
    if ([role isEqualToString:@"QA LEAD"])
    {
        return @"QA Lead";
    }
    
    return role;
}

+ (NSString *)formatGroup:(NSString *)group
{
    if ([group isEqualToString:@"admin"] || [group isEqualToString:@"business"] || [group isEqualToString:@"coordinator"] || [group isEqualToString:@"employee"] || [group isEqualToString:@"scrum master"])
    {
        return [group capitalizedString];
    }
    
    
    if ([group isEqualToString:@"hr"])
    {
        return [group uppercaseString];
    }
    
    return group;
}


- (id)mapToJSON
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"Method %@ not implemented", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
