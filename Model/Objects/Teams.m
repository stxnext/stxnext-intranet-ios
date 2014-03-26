//
//  Teams.m
//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "Teams.h"
#import "APIRequest.h"
#import "CurrentUser.h"

@implementation Teams

#pragma mark - Creation

+ (instancetype)singleton
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    
    return sharedInstance;
}

- (void)teamsWithStart:(void (^)(void))startActions
                   end:(void (^)(void))endActions
               success:(void (^)(NSArray *teams))success
               failure:(void (^)(NSArray *cachedTeams, FailureErrorType error))failure
{
        DDLogInfo(@"Loading Teams from: Database");
    
    NSArray *teams = [self getTeamsFromDatabase];
    
    if (teams.count)
    {
        if (success)
        {
            success(teams);
        }
        
        if (endActions)
        {
            endActions();
        }
    }
    else
    {
        [self downloadTeamsWithStart:startActions
                                 end:endActions
                             success:success
                             failure:failure];
    }
}

- (void)downloadTeamsWithStart:(void (^)(void))startActions
                           end:(void (^)(void))endActions
                       success:(void (^)(NSArray *teams))success
                       failure:(void (^)(NSArray *cachedTeams, FailureErrorType error))failure
{
    DDLogInfo(@"Loading Teams from: API");
    
//    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    if ([ReachabilityManager isUnreachable])
    {
        DDLogError(@"Teams - no Internet");
        
        if (success)
        {
            if (success)
            {
                success([self getTeamsFromDatabase]);
            }
            
            if (endActions)
            {
                endActions();
            }
        }
        
        return;
    }
    
    if (startActions)
    {
        startActions();
    }
    
    [[HTTPClient sharedClient] startOperation:[[CurrentUser singleton] userLoginType] == UserLoginTypeTrue ? [APIRequest getTeams] : [APIRequest getFalseTeams] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Delete from database
        @synchronized (self)
        {
            [JSONSerializationHelper deleteObjectsWithClass:[RMTeam class]
                                           inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
        }
        
        // Add to database
        
        for (id team in responseObject[@"teams"])
        {
            [RMTeam mapFromJSON:team];
        }
        
        // Save database
        [[DatabaseManager sharedManager] saveContext];
        
        DDLogInfo(@"Loaded: teams");
        
        if (success)
        {
            success([self getTeamsFromDatabase]);
        }
        
        if (endActions)
        {
            endActions();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"Teams - failure ");
        
        if (failure)
        {
            failure([self getTeamsFromDatabase], FailureErrorTypeDefault);
        }
        
        if (endActions)
        {
            endActions();
        }
    }];
}

- (NSArray *)getTeamsFromDatabase
{
    return [JSONSerializationHelper objectsWithClass:[RMTeam class]
                                  withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                   ascending:YES
                                                                                    selector:@selector(localizedCompare:)]
                                       withPredicate:nil
                                    inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
}

@end
