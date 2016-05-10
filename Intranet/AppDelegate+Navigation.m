//
//  AppDelegate+Navigation.m
//  Intranet
//
//  Created by MK_STX on 12/11/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate+Navigation.h"

#import "MainVerticalTabBarViewController.h"
#import "ListTableViewController.h"

@implementation AppDelegate (Navigation)

- (void)goToTabAtIndex:(NSUInteger)index
{
    UITabBarController *controller = (UITabBarController *)self.window.rootViewController;
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
    MainVerticalTabBarViewController *controller = (MainVerticalTabBarViewController *)self.window.rootViewController;
    
    UISplitViewController *splitController = controller.embededTabBarController.viewControllers[0];
    ListTableViewController *listVC = splitController.viewControllers[0];
    
    [listVC showLoginScreen];
}

@end
