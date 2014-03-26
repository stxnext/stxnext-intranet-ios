//
//  Model.m
//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "Model.h"

@implementation Model

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

- (void)updateModelWithStart:(void (^)(void))startActions
                         end:(void (^)(void))endActions
                     success:(void (^)(NSArray *users, NSArray *presences, NSArray *teams))success
                     failure:(void (^)(NSArray *cachedUsers, NSArray *cachedPresences, NSArray *cachedTeams, FailureErrorType error))failure
{
    __block int operationsCount = 0;
    __block int failureCount = 0;
    
    __block NSArray *newUsers;
    __block NSArray *newPresences;
    __block NSArray *newTeams;
    __block FailureErrorType error = FailureErrorTypeDefault;
    
    //    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    
    if ([ReachabilityManager isUnreachable])
    {
        DDLogError(@"Model - no Internet");
        
        if (failure)
        {
            [[Users singleton] usersWithStart:nil end:nil success:^(NSArray *users) {
                newUsers = users;
            } failure:nil];
            
            [[Presences singleton] presencesWithStart:nil end:nil success:^(NSArray *presences) {
                newPresences = presences;
            } failure:nil];
            
            [[Teams singleton] teamsWithStart:nil end:nil success:^(NSArray *teams) {
                newTeams = teams;
            } failure:nil];
            
            failure(newUsers, newPresences, newTeams, error);
        }
        
        if (endActions)
        {
            endActions();
        }
        
        return;
    }
    
    
    if (startActions)
    {
        startActions();
    }
    
    [[Users singleton] downloadUsersWithStart:nil end:^{
        [[Presences singleton] downloadPresencesWithStart:nil end:^{
            
            DDLogInfo(@"Model-Presences - end");
            
        } success:^(NSArray *presences) {
            
            DDLogInfo(@"Model-Presences - success");
            newPresences = presences;
            operationsCount++;
            
            if (operationsCount == 3)
            {
                if (failureCount == 0)
                {
                    if (success)
                    {
                        success(newUsers, newPresences, newTeams);
                    }
                    
                }
                else
                {
                    if (failure)
                    {
                        failure(newUsers, newPresences, newTeams, error);
                    }
                }
                
                if (endActions)
                {
                    endActions();
                }
            }
        } failure:^(NSArray *cachedPresences, FailureErrorType err) {
            
            DDLogError(@"Model-Presences - failure ");
            failureCount++;
            operationsCount++;
            newPresences = cachedPresences;
            
            if (operationsCount == 3)
            {
                if (failure)
                {
                    failure(newUsers, newPresences, newTeams, error);
                }
                
                if (endActions)
                {
                    endActions();
                }
            }
        }];
        
        [[Teams singleton] downloadTeamsWithStart:nil end:^{
            
            DDLogInfo(@"Model-Teams - end");
            
        } success:^(NSArray *teams) {
            
            DDLogInfo(@"Model-Teams - success");
            newTeams = teams;
            operationsCount++;
            
            if (operationsCount == 3)
            {
                if (failureCount == 0)
                {
                    if (success)
                    {
                        success(newUsers, newPresences, newTeams);
                    }
                    
                }
                else
                {
                    if (failure)
                    {
                        failure(newUsers, newPresences, newTeams, error);
                    }
                }
                
                if (endActions)
                {
                    endActions();
                }
            }
        } failure:^(NSArray *cachedTeams, FailureErrorType err) {
            
            DDLogError(@"Model-Teams - failure ");
            
            failureCount++;
            operationsCount++;
            newTeams = cachedTeams;
            
            if (operationsCount == 3)
            {
                if (failure)
                {
                    failure(newUsers, newPresences, newTeams, error);
                }
                
                if (endActions)
                {
                    endActions();
                }
            }
        }];
    } success:^(NSArray *users) {
        
        DDLogInfo(@"Model - success ");
        newUsers = users;
        operationsCount++;
        
        if (operationsCount == 3)
        {
            if (failureCount == 0)
            {
                if (success)
                {
                    success(newUsers, newPresences, newTeams);
                }
                
            }
            else
            {
                if (failure)
                {
                    failure(newUsers, newPresences, newTeams, error);
                }
            }
            
            if (endActions)
            {
                endActions();
            }
        }
    } failure:^(NSArray *cachedUsers, FailureErrorType err) {
        
        DDLogError(@"Model - failure ");

        if (err == FailureErrorTypeLoginRequired)
        {
            error = FailureErrorTypeLoginRequired;
        }
        
        failureCount++;
        operationsCount++;
        newUsers = cachedUsers;
        
        if (operationsCount == 3)
        {
            if (failure)
            {
                failure(newUsers, newPresences, newTeams, error);
            }
            
            if (endActions)
            {
                endActions();
            }
        }
    }];
}

@end
