//
//  RMUser+CurrentUser.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "RMUser+CurrentUser.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "APIRequest.h"
#import "AppDelegate+Settings.h"

@implementation RMUser (CurrentUser)

+ (NSString*)userId
{
    return [APP_DELEGATE myUserId];
}

+ (void)loadCurrentUserIdentifierFromAPIWithCompletionHandler:(void (^)(NSString* userId, NSError* error))completionBlock
{
    [[HTTPClient sharedClient] startOperation:[APIRequest user]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // error
                                          // We expect 302
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSString *html = operation.responseString;
                                          NSArray *htmlArray = [html componentsSeparatedByString:@"\n"];
                                          
                                          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"id: [0-9]+,"];
                                          NSString *userID = nil;
                                          
                                          for (NSString *line in htmlArray)
                                          {
                                              userID = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                              
                                              if ([predicate evaluateWithObject:userID])
                                              {
                                                  userID = [[userID stringByReplacingOccurrencesOfString:@"id: " withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""];
                                                  
                                                  [APP_DELEGATE setMyUserId:userID];
                                                  
                                                  break;
                                              }
                                          }
                                          
                                          if (completionBlock)
                                              completionBlock(userID, error);
                                      }];
}

+ (RMUser*)loadCurrentUserFromDatabase
{
    NSString* userId = [self userId];
    
    if (!userId)
        return nil;
    
    NSString *userID = [APP_DELEGATE myUserId];
    
    return [[JSONSerializationHelper objectsWithClass:[RMUser class] withSortDescriptor:nil
                                        withPredicate:[NSPredicate predicateWithFormat:@"id = %@", userID]
                                     inManagedContext:[DatabaseManager sharedManager].managedObjectContext] firstObject];
}

+ (void)loadCurrentUserWithCompletionHandler:(void (^)(RMUser* user, NSError* error))completionBlock
{
    RMUser* databaseUser = [self loadCurrentUserFromDatabase];
    
    // Current user was in database
    if (databaseUser)
    {
        if (completionBlock)
            completionBlock(databaseUser, nil);
        
        return;
    }
    
    [self loadCurrentUserIdentifierFromAPIWithCompletionHandler:^(NSString *userId, NSError *error) {
        RMUser* databaseUser = [self loadCurrentUserFromDatabase];
        
        // Current user's id was fetched from API, then user was loaded from database
        if (databaseUser)
        {
            if (completionBlock)
                completionBlock(databaseUser, nil);
            
            return;
        }
        
        // User id was not fetched or user doesn't exist in database
        if (completionBlock)
            completionBlock(nil, [NSError errorWithDomain:@"Current user" localizedDescription:@"Could not load current user." code:400]);
    }];
}

@end
