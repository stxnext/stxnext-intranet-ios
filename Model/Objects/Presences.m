//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "Presences.h"
#import "APIRequest.h"
#import "CurrentUser.h"

@implementation Presences

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

- (void)presencesWithStart:(void (^)(NSDictionary *params))startActions
                       end:(void (^)(NSDictionary *params))endActions
                   success:(void (^)(NSArray *presences))success
                   failure:(void (^)(NSDictionary *data))failure
{
    DDLogInfo(@"Loading Presences from: Database");
    
    NSArray *presences = [self getPresencesFromDatabase];
    
    if (presences.count)
    {
        if (success)
        {
            success(presences);
        }
        
        if (endActions)
        {
            endActions(nil);
        }
    }
    else
    {
        [self downloadPresencesWithStart:startActions
                                     end:endActions
                                 success:success
                                 failure:failure];
    }
}

- (void)downloadPresencesWithStart:(void (^)(NSDictionary *params))startActions
                               end:(void (^)(NSDictionary *params))endActions
                           success:(void (^)(NSArray *presences))success
                           failure:(void (^)(NSDictionary *data))failure
{
    DDLogInfo(@"Loading Presences from: API");
    
    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        if (success)
        {
            if (success)
            {
                success([self getPresencesFromDatabase]);
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
    
    [[HTTPClient sharedClient] startOperation:[[CurrentUser singleton] userLoginType] == UserLoginTypeTrue ? [APIRequest getPresence] : [APIRequest getFalsePresence]success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Delete from database
        @synchronized (self)
        {
            [JSONSerializationHelper deleteObjectsWithClass:[RMAbsence class]
                                           inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
            
            [JSONSerializationHelper deleteObjectsWithClass:[RMLate class]
                                           inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
        }
        
        int i = 0;
        for (id absence in responseObject[@"absences"])
        {
            i++;
            [RMAbsence mapFromJSON:absence];
        }
        
        for (id late in responseObject[@"lates"])
        {
            i++;
            [RMLate mapFromJSON:late];
        }
        
        [[DatabaseManager sharedManager] saveContext];
        
        DDLogInfo(@"Loaded: absences and lates %i", i);
        
        if (success)
        {
            success([self getPresencesFromDatabase]);
        }
        
        if (endActions)
        {
            endActions(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure)
        {
            failure(nil);
        }
        
        if (endActions)
        {
            endActions(nil);
        }
    }];
}

- (NSArray *)getPresencesFromDatabase
{
    NSMutableArray * _userList;
    NSArray *users = [JSONSerializationHelper objectsWithClass:[RMUser class]
                                            withSortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                                             ascending:YES
                                                                                              selector:@selector(localizedCompare:)]
                                                 withPredicate:[NSPredicate predicateWithFormat:@"isActive = YES"]
                                              inManagedContext:[DatabaseManager sharedManager].managedObjectContext];
    
    _userList = [[NSMutableArray alloc] init];
    
    [_userList addObject:[users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isClient = NO AND isFreelancer = NO && absences.@count > 0"]] ? : [[NSArray alloc] init]];
    
    [_userList addObject:[users filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        RMUser *user = (RMUser *)evaluatedObject;
        
        if ([user.isClient boolValue] == YES || [user.isFreelancer boolValue] == YES)
        {
            return NO;
        }
        
        if (user.lates.count)
        {
            for (RMLate *late in user.lates)
            {
                if ([late.isWorkingFromHome intValue] == 1)
                {
                    return YES;
                }
            }
        }
        
        return NO;
    }]] ? : [[NSArray alloc] init]];
    
    [_userList addObject:[users filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        
        RMUser *user = (RMUser *)evaluatedObject;
        
        if ([user.isClient boolValue] == YES || [user.isFreelancer boolValue] == YES)
        {
            return NO;
        }
        
        if (user.lates.count)
        {
            for (RMLate *late in user.lates)
            {
                if ([late.isWorkingFromHome intValue] == 0)
                {
                    return YES;
                }
            }
        }
        
        return NO;
    }]] ? : [[NSArray alloc] init]];
    
    return _userList;
}

@end
