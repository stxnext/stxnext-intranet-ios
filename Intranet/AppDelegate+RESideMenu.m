//
//  AppDelegate+RESideMenu.m
//  Intranet
//
//  Created by Dawid Żakowski on 04/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AppDelegate+RESideMenu.h"

@implementation AppDelegate (RESideMenu)

- (RESideMenu*)assignRESideMenuWithLeftMenuViewController:(UIViewController*)leftMenuViewController rightMenuViewController:(UIViewController*)rightMenuViewController
{
    RESideMenu* menu =  [[RESideMenu alloc] initWithContentViewController:self.window.rootViewController
                                                   leftMenuViewController:leftMenuViewController
                                                  rightMenuViewController:rightMenuViewController];
    
    self.window.rootViewController = menu;
    
    return menu;
}

@end
