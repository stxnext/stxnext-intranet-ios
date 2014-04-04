//
//  AppDelegate+RESideMenu.h
//  Intranet
//
//  Created by Dawid Żakowski on 04/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (RESideMenu)

- (RESideMenu*)assignRESideMenuWithLeftMenuViewController:(UIViewController*)leftMenuViewController rightMenuViewController:(UIViewController*)rightMenuViewController;

@end
