//
//  AppDelegate+Settings.m
//  Intranet
//
//  Created by Adam on 12.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AppDelegate+Settings.h"
#import "APIRequest.h"

@implementation AppDelegate (Settings)

- (void)setUserLoggedType:(UserLoginType)userLoggedType
{
    [[NSUserDefaults standardUserDefaults] setInteger:userLoggedType forKey:@"userLoggedType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UserLoginType)userLoggedType
{
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"userLoggedType"];
}

- (NSString *)myUserId
{
    return @"54";[[NSUserDefaults standardUserDefaults] stringForKey:@"myUserId"];
}
//213,
//54, Konrad
//167

- (void)myUserIdWithBlockSuccess:(void (^)(NSString *userId))success
                         failure:(void (^)(void))failure

{
    if ([self myUserId])
    {
        success([self myUserId]);
    }
    else
    {
        [[HTTPClient sharedClient] startOperation:[APIRequest user]
                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                              // error
                                              // We expect 302
                                              
                                              failure();
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
                                                      
                                                      [APP_DELEGATE setMyUserId:userID];
                                                      
                                                      break;
                                                  }
                                              }
                                              success([APP_DELEGATE myUserId]);
                                          }];
    }
}


- (void)setMyUserId:(NSString *)userId
{
    if (userId)
    {
        [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"myUserId"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"myUserId"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
