//
//  AppDelegate+TabBar.m
//  Intranet
//
//  Created by Dawid Żakowski on 10/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AppDelegate+TabBar.h"

@implementation AppDelegate (TabBar)

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return viewController != tabBarController.selectedViewController;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    BOOL willDisplayPokerStack = tabBarController.selectedIndex == 3;
    [[GameManager defaultManager] setNotificationsSuspended:!willDisplayPokerStack];
}

@end
