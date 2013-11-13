//
//  AppDelegate+SplitControllerDelegate.m
//  Intranet
//
//  Created by Dawid Żakowski on 13/11/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate+SplitControllerDelegate.h"

@implementation AppDelegate (SplitControllerDelegate)

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation NS_AVAILABLE_IOS(5_0);
{
    return NO;
}

@end
