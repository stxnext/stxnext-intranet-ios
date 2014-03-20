//
//  CurrentUser.m
//  Intranet
//
//  Created by Adam on 20.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "CurrentUser.h"
#import "APIRequest.h"

@interface CurrentUser ()

- (NSString *)userId;

@end

@implementation CurrentUser

- (void)setLoginType:(UserLoginType)userLoginType
{
    [[NSUserDefaults standardUserDefaults] setInteger:userLoginType forKey:@"userLoggedType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UserLoginType)userLoginType
{
    return (NSUInteger)[[NSUserDefaults standardUserDefaults] integerForKey:@"userLoggedType"];
}

- (NSString *)userId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"myUserId"]; //dla testów @"54" to Konrad
}

- (void)userIdWithStart:(void (^)(NSDictionary *params))startActions
                    end:(void (^)(NSDictionary *params))endActions
                success:(void (^)(NSString *userId))success
                failure:(void (^)(NSDictionary *data))failure
{
    if ([self userId])
    {
        success([self userId]);
    }
    else
    {
        startActions(nil);
        
        [[HTTPClient sharedClient] startOperation:[APIRequest user]
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              // error, we expect 302
                                              
                                              failure(nil);
                                              endActions(nil);
                                          }
                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                              
                                              NSString *html = operation.responseString;
                                              NSArray *htmlArray = [html componentsSeparatedByString:@"\n"];
                                              
                                              NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"id: [0-9]+,"];
                                              NSString *userID ;
                                              
                                              for (NSString *line in htmlArray)
                                              {
                                                  userID = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                                  
                                                  if ([predicate evaluateWithObject:userID])
                                                  {
                                                      userID = [[userID stringByReplacingOccurrencesOfString:@"id: " withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""];
                                                      
                                                      [self setUserId:userID];
                                                      
                                                      break;
                                                  }
                                              }
                                              
                                              success([self userId]);
                                              endActions(nil);
                                          }];
    }
}

- (void)setUserId:(NSString *)userId
{
    [self setUserId:userId start:nil end:nil success:nil failure:nil];
}

- (void)setUserId:(NSString *)userId
            start:(void (^)(NSDictionary *params))startActions
              end:(void (^)(NSDictionary *params))endActions
          success:(void (^)(NSDictionary *data))success
          failure:(void (^)(NSDictionary *data))failure
{
    startActions(nil);
    
    if (userId)
    {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"myUserId"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"myUserId"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    success(nil);
    endActions(nil);
}

- (void)userWithStart:(void (^)(NSDictionary *params))startActions
                  end:(void (^)(NSDictionary *params))endActions
              success:(void (^)(RMUser *user))success
              failure:(void (^)(NSDictionary *data))failure
{
    startActions(nil);
    
    [self userIdWithStart:startActions end:endActions success:^(NSString *userId) {
        
        success((RMUser *)[[JSONSerializationHelper objectsWithClass:[RMUser class] withSortDescriptor:nil
                                                       withPredicate:[NSPredicate predicateWithFormat:@"id = %@", userId]
                                                    inManagedContext:[DatabaseManager sharedManager].managedObjectContext] firstObject]);
        endActions(nil);
        
    } failure:^(NSDictionary *data) {
        
        failure(nil);
        endActions(nil);
    }];
}

@end
