//
//  Users.m
//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "Users.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "APIRequest.h"
#import "CurrentUser.h"

@implementation Users

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

- (void)usersWithStart:(void (^)(NSDictionary *params))startActions
                   end:(void (^)(NSDictionary *params))endActions
               success:(void (^)(NSArray *users))success
               failure:(void (^)(UserErrorType error))failure;
{
    DDLogInfo(@"Loading users from: Database");
    
    NSArray *users = [self getUsersFromDatabase];
    
    if (users.count)
    {
        if (success)
        {
            success(users);
        }
        
        if (endActions)
        {
            endActions(nil);
        }
    }
    else
    {
        [self downloadUsersWithStart:startActions
                                 end:endActions
                             success:success
                             failure:failure];
    }
}

- (void)downloadUsersWithStart:(void (^)(NSDictionary *params))startActions
                           end:(void (^)(NSDictionary *params))endActions
                       success:(void (^)(NSArray *users))success
                       failure:(void (^)(UserErrorType error))failure;
{
    DDLogInfo(@"Loading users from: API");
    
//    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    if ([ReachabilityManager isUnreachable])
    {
        DDLogError(@"Users - no Internet");
        
        if (success)
        {
            if (success)
            {
                success([self getUsersFromDatabase]);
            }
            
            if (endActions)
            {
                endActions(nil);
            }
        }
        
        return;
    }
    
    if (startActions)
    {
        startActions(nil);
    }
    
    [[HTTPClient sharedClient] startOperation:[[CurrentUser singleton] userLoginType] == UserLoginTypeTrue ? [APIRequest getUsers] : [APIRequest getFalseUsers]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Delete from database
        @synchronized (self)
        {
            [JSONSerializationHelper deleteObjectsWithClass:[RMUser class]
                                           inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
        }
        
        // Add to database
        for (id user in responseObject[@"users"])
        {
            [RMUser mapFromJSON:user];
        }
        
        DDLogInfo(@"Loaded From API: %lu users", (unsigned long)[responseObject[@"users"] count]);
        
        // Save database
        [[DatabaseManager sharedManager] saveContext];
        
        if (success)
        {
            success([self getUsersFromDatabase]);
        }
        
        if (endActions)
        {
            endActions(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        DDLogError(@"Users - failure ");
        
        DDLogError(@"Users API Loading Error");
        
        if ([operation redirectToLoginView])
        {
            if (failure)
            {
                failure(UserErrorTypeReloginRequired);
            }
        }
        else
        {
            if (failure)
            {
                failure(UserErrorTypeDefault);
            }
        }
        
        if (endActions)
        {
            endActions(nil);
        }
    }];
}

- (NSArray *)getUsersFromDatabase
{
    return [JSONSerializationHelper objectsWithClass:[RMUser class]
                                  withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                   ascending:YES
                                                                                    selector:@selector(localizedCompare:)]
                                       withPredicate:[NSPredicate predicateWithFormat:@"isActive = YES"]
                                    inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
}

@end
