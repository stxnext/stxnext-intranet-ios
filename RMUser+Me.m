//
//  RMUser+Me.m
//  Intranet
//
//  Created by Adam on 05.12.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "RMUser+Me.h"
#import "APIRequest.h"
#import "AFHTTPRequestOperation+Redirect.h"
#import "NSString+MyRegex.h"

@implementation RMUser (Me)


+ (void)setUserLoggedType:(UserLoginType)userLoggedType
{
    [[NSUserDefaults standardUserDefaults] setInteger:userLoggedType forKey:@"userLoggedType"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (UserLoginType)userLoggedType
{
    return (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"userLoggedType"];
}

+ (NSString *)myUserId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"myUserId"];
}

+ (void)setMyUserId:(NSString *)userId
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

+ (void)loadMeUserId:(void (^)(void))endAction
{
    [[HTTPClient sharedClient] startOperation:[APIRequest user]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          // error
                                          // We expect 302
                                          if (endAction)
                                          {
                                              endAction();
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          NSString *html = operation.responseString;
                                          NSArray *htmlArray = [html componentsSeparatedByString:@"\n"];
                                          
                                          NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @".*\"id\": [0-9]+,.*"];
                                          NSString *userID ;
                                          
                                          for (NSString *line in htmlArray)
                                          {
                                              userID = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                              
                                              if ([predicate evaluateWithObject:userID])
                                              {
                                                  
                                                  userID = [userID firstMatchWithRegex:@"(\"id\": [0-9]+,)" error:nil];
                                                  userID = [[userID stringByReplacingOccurrencesOfString:@"\"id\": " withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@""];
                                                  
                                                  [self setMyUserId:userID];
                                                  
                                                  break;
                                              }
                                          }
                                          if (endAction)
                                          {
                                              endAction();
                                          }
                                      }];
}

+ (RMUser *)me
{
    NSString *userID = [self myUserId];
    
    return [[JSONSerializationHelper objectsWithClass:[RMUser class] withSortDescriptor:nil
                                              withPredicate:[NSPredicate predicateWithFormat:@"id = %@", userID]
                                           inManagedContext:[DatabaseManager sharedManager].managedObjectContext] firstObject];
}

@end
