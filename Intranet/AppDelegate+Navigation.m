//
//  AppDelegate+Navigation.m
//  Intranet
//
//  Created by MK_STX on 12/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate+Navigation.h"

@implementation AppDelegate (Navigation)

- (void)goToTabAtIndex:(NSUInteger)index
{
    UITabBarController *controller = (UITabBarController*)ROOT_VIEW_CONTROLLER;
    if (index < controller.viewControllers.count)
    {
        controller.selectedIndex = index;
    }
    else
    {
        // error
    }
}

- (void)showLoginScreenForiPad
{
    UISplitViewController *controller = (UISplitViewController *)ROOT_VIEW_CONTROLLER;

    [ROOT_VIEW_CONTROLLER.view logViewHierarchy];
    
    if ([((UINavigationController *)controller.viewControllers[0]).viewControllers[0] respondsToSelector:@selector(showLoginScreen)])
    {
        [((UINavigationController *)controller.viewControllers[0]).viewControllers[0] performSelector:@selector(showLoginScreen)];
    }
}

@end