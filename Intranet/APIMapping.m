//
//  APIMapping.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "APIMapping.h"

@implementation APIMapping

+ (NSDictionary*)mapping
{
    return nil;
}

+ (NSDictionary*)inverseMapping
{
    NSMutableDictionary* inverseMapping = [NSMutableDictionary dictionary];
    NSDictionary* mapping = [self mapping];
    
    for (NSString* key in mapping)
    {
        NSString* value = mapping[key];
        inverseMapping[value] = key;
    }
    
    return inverseMapping;
}

+ (APIMapping*)mapFromJSON:(NSDictionary*)json
{
    APIMapping* instance = [[self class] new];
    NSDictionary* mapping = [self inverseMapping];
    
    for (NSString* property in mapping)
    {
        NSString* jsonPath = mapping[property];
        id jsonValue = json[jsonPath];
        [instance setValue:jsonValue forKey:property];
    }
    
    return instance;
}

- (NSDictionary*)mapToJSON:(NSDictionary*)json
{
    return nil;
}

@end

@implementation RMUser

+ (NSDictionary*)mapping
{
    return @{
             @"id":                    @"id",
             @"name":                  @"name",
             @"img":                   @"imageURL",
             @"avatar_url":            @"avatarURL",
             @"location":              @"location",
             @"freelancer":            @"isFreelancer",
             @"is_client":             @"isClient",
             @"is_active":             @"isActive",
             @"start_work":            @"startWork",
             @"start_full_time_work":  @"startFullTimeWork",
             @"stop_work":             @"stopWork",
             @"phone":                 @"phone",
             @"phone_on_desk":         @"phoneDesk",
             @"skype":                 @"skype",
             @"irc":                   @"irc",
             @"email":                 @"email",
             @"tasks_link":            @"tasksLink",
             @"availability_link":     @"availabilityLink",
             @"roles":                 @"roles",
             @"groups":                @"groups",
             };
}

@end