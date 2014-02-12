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
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"userLoggedType"];
}

@end
