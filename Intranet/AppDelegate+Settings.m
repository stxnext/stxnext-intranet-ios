//
//  AppDelegate+Settings.m
//  Intranet
//
//  Created by Adam on 12.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AppDelegate+Settings.h"

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
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"myUserId"];
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
