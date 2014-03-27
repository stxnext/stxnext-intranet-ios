//
//  CurrentUser.m
//  Intranet
//
//  Created by Adam on 20.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "CurrentUser.h"
#import "APIRequest.h"
#import "AFHTTPRequestOperation+Redirect.h"

@interface CurrentUser ()

- (NSString *)userId;

@end

@implementation CurrentUser

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

#pragma mark - Accesors

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

- (void)userIdWithStart:(void (^)(void))startActions
                    end:(void (^)(void))endActions
                success:(void (^)(NSString *userId))success
                failure:(void (^)(FailureErrorType error))failure
{
    if ([self userId])
    {
        if (success)
        {
            success([self userId]);
        }
    }
    else
    {
//        if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    if ([ReachabilityManager isUnreachable])
        {
            if (failure)
            {
                failure(FailureErrorTypeNoInternetConnection);
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
        
        [[HTTPClient sharedClient] startOperation:[APIRequest user] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            // error, we expect 302
            if (failure)
            {
                failure(FailureErrorTypeNet);
            }
            
            if (endActions)
            {
                endActions();
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
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
            
            if (success)
            {
                success([self userId]);
            }
            
            if (endActions)
            {
                endActions();
            }
        }];
    }
}

- (void)setUserId:(NSString *)userId
{
    [self setUserId:userId start:nil end:nil success:nil failure:nil];
}

- (void)setUserId:(NSString *)userId
            start:(void (^)(void))startActions
              end:(void (^)(void))endActions
          success:(void (^)(void))success
          failure:(void (^)(FailureErrorType error))failure
{
    if (startActions)
    {
        startActions();
    }
    
    if (userId)
    {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"myUserId"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"myUserId"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (success)
    {
        success();
    }
    
    if (endActions)
    {
        endActions();
    }
}

- (void)userWithStart:(void (^)(void))startActions
                  end:(void (^)(void))endActions
              success:(void (^)(RMUser *user))success
              failure:(void (^)(RMUser *cachedUser, FailureErrorType error))failure
{
//    if (![[AFNetworkReachabilityManager sharedManager] isReachable])
    if ([ReachabilityManager isUnreachable])
    {
        if ([self userId])
        {
            if (success)
            {
                success((RMUser *)[[JSONSerializationHelper objectsWithClass:[RMUser class] withSortDescriptor:nil
                                                               withPredicate:[NSPredicate predicateWithFormat:@"id = %@", [self userId]]
                                                            inManagedContext:[DatabaseManager sharedManager].managedObjectContext] firstObject]);
            }
        }
        else if (failure)
        {
            failure(nil, FailureErrorTypeNoInternetConnection);
        }
        
        if (endActions)
        {
            endActions();
        }
        
        return;
    }

    
    [self userIdWithStart:startActions end:endActions success:^(NSString *userId) {
        
        if (success)
        {
            success((RMUser *)[[JSONSerializationHelper objectsWithClass:[RMUser class] withSortDescriptor:nil
                                                           withPredicate:[NSPredicate predicateWithFormat:@"id = %@", userId]
                                                        inManagedContext:[DatabaseManager sharedManager].managedObjectContext] firstObject]);
        }
        
        if (endActions)
        {
            endActions();
        }
        
    } failure:^(FailureErrorType error) {
        
        if (failure)
        {
            failure(nil, error);
        }
        
        if (endActions)
        {
            endActions();
        }
    }];
}

#pragma mark - Login and Logout

- (void)loginUserWithStart:(void (^)(void))startActions
                       end:(void (^)(void))endActions
                   success:(void (^)(void))success
                   failure:(void (^)(FailureErrorType error))failure
{
    
}

- (void)logoutUserWithStart:(void (^)(void))startActions
                        end:(void (^)(void))endActions
                    success:(void (^)(void))success
                    failure:(void (^)(FailureErrorType error))failure
{
    if (startActions)
    {
        startActions();
    }
    
    if ([[CurrentUser singleton] userLoginType] == UserLoginTypeFalse)
    {
        [[HTTPClient sharedClient] deleteCookies];
        
        // delete all cookies (to remove Google login cookies)
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        
        for (NSHTTPCookie *cookie in storage.cookies)
        {
            [storage deleteCookie:cookie];
        }
        
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        [self setLoginType:UserLoginTypeNO];
        
        if (success)
        {
            success();
        }
        
        if (endActions)
        {
            endActions();
        }
    }
    else
    {
        [[HTTPClient sharedClient] startOperation:[APIRequest logout] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // logout error
            if (failure)
            {
                failure(FailureErrorTypeNet);
            }
            
            if (endActions)
            {
                endActions();
            }
        }  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            if ([operation redirectToLoginView])
            {
                [[HTTPClient sharedClient] deleteCookies];
                
                // delete all cookies (to remove Google login cookies)
                
                NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                
                for (NSHTTPCookie *cookie in storage.cookies)
                {
                    [storage deleteCookie:cookie];
                }
                
                [[NSURLCache sharedURLCache] removeAllCachedResponses];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [self setUserId:nil start:nil end:nil success:nil failure:nil];
                
                [self setLoginType:UserLoginTypeNO];
                
                if (success)
                {
                    success();
                }
                
                if (endActions)
                {
                    endActions();
                }
            }
            else
            {
                
            }
        }];
    }
}

- (void)freeDaysWithStart:(void (^)(void))startActions
                      end:(void (^)(void))endActions
                  success:(void (^)(NSString *freeDays))success
                  failure:(void (^)(FailureErrorType error))failure
{
    if (startActions)
    {
        startActions();
    }
    
    [[HTTPClient sharedClient] startOperation:[APIRequest getFreeDays] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success)
        {
            success([NSString stringWithFormat:@"%@", [responseObject objectForKey:@"left"]]);
        }

        if (endActions)
        {
            endActions();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        if (failure)
        {
            failure(FailureErrorTypeDefault);
        }
        
        if (endActions)
        {
            endActions();
        }
    }];
}

- (void)sendAbsence:(NSDictionary *)absence
          withStart:(void (^)(void))startActions
                end:(void (^)(void))endActions
            success:(void (^)(void))success
            failure:(void (^)(FailureErrorType error))failure
{
    if (startActions)
    {
        startActions();
    }
    
    [[HTTPClient sharedClient] startOperation:[APIRequest sendAbsence:absence] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success)
        {
            success();
        }
        
        if (endActions)
        {
            endActions();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure)
        {
            failure(FailureErrorTypeDefault);
        }
        
        if (endActions)
        {
            endActions();
        }
    }];
}

- (void)sendLateness:(NSDictionary *)lateness
           withStart:(void (^)(void))startActions
                 end:(void (^)(void))endActions
             success:(void (^)(void))success
             failure:(void (^)(FailureErrorType error))failure
{
    if (startActions)
    {
        startActions();
    }
    
    [[HTTPClient sharedClient] startOperation:[APIRequest sendLateness:lateness] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (success)
        {
            success();
        }
        
        if (endActions)
        {
            endActions();
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if (failure)
        {
            failure(FailureErrorTypeDefault);
        }
        
        if (endActions)
        {
            endActions();
        }
    }];
}

@end
