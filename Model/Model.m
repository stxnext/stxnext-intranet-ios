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

- (void)updateModelWithStart:(void (^)(NSDictionary *params))startActions
                         end:(void (^)(NSDictionary *params))endActions
                     success:(void (^)(NSArray *users, NSArray *presences, NSArray *teams))success
                     failure:(void (^)(NSArray *users, NSArray *presences, NSArray *teams , ModelErrorType error))failure
{
    __block int operationsCount = 0;
    __block int failureCount = 0;
    
    __block NSArray *newUsers;
    __block NSArray *newPresences;
    __block NSArray *newTeams;
    __block ModelErrorType error = ModelErrorTypeDefault;
    
    if (startActions)
    {
        startActions(nil);
    }
    
    [[Users singleton] downloadUsersWithStart:nil end:^(NSDictionary *params) {
        [[Presences singleton] downloadPresencesWithStart:nil end:^(NSDictionary *params) {
            
        } success:^(NSArray *presences) {
            
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
                    endActions(nil);
                }
            }
        } failure:^(NSDictionary *data) {
            
            failureCount++;
            operationsCount++;
            
            if (operationsCount == 3)
            {
                if (failure)
                {
                    failure(newUsers, newPresences, newTeams, error);
                }
                
                if (endActions)
                {
                    endActions(nil);
                }
            }
        }];
        
        [[Teams singleton] downloadTeamsWithStart:nil end:^(NSDictionary *params) {
            
        } success:^(NSArray *teams) {
            
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
                    endActions(nil);
                }
            }
        } failure:^(NSDictionary *data) {
            
            failureCount++;
            operationsCount++;
            
            if (operationsCount == 3)
            {
                if (failure)
                {
                    failure(newUsers, newPresences, newTeams, error);
                }
                
                if (endActions)
                {
                    endActions(nil);
                }
            }
        }];
    } success:^(NSArray *users) {
        
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
                endActions(nil);
            }
        }
    } failure:^(UserErrorType err) {
        
        if (err == UserErrorTypeReloginRequired)
        {
            error = ModelErrorTypeLoginRequired;
        }
        
        failureCount++;
        operationsCount++;
        
        if (operationsCount == 3)
        {
            if (failure)
            {
                failure(newUsers, newPresences, newTeams, error);
            }
            
            if (endActions)
            {
                endActions(nil);
            }
        }
    }];
}

@end
