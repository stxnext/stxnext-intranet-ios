//
//  AppDelegate.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+SplitControllerDelegate.h"
#import "AppDelegate+Parse.h"
#import "AppDelegate+RESideMenu.h"

#import "TeamManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Assign RESide menu
    #warning Removing below line makes right side menu to load its table view contents only after 2nd try
    UIViewController* rightMenu = [[UIStoryboard storyboardWithName:@"PGPokerStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"PGPlayerListViewController"]; // THIS IS HACK
    RESideMenu* menu = [self assignRESideMenuWithLeftMenuViewController:nil rightMenuViewController:rightMenu];
    menu.menuPreferredStatusBarStyle = UIStatusBarStyleLightContent;
    menu.contentViewShadowColor = [UIColor blackColor];
    menu.contentViewShadowOffset = CGSizeMake(0, 0);
    menu.contentViewShadowOpacity = 1.0;
    menu.contentViewShadowRadius = 8.0;
    menu.contentViewShadowEnabled = YES;
    menu.contentViewInPortraitOffsetCenterX = INTERFACE_IS_PHONE_SMALL_SCREEN ? -104.0 : -102.0;
    menu.contentViewScaleValue = ([UIScreen mainScreen].bounds.size.height - STATUS_BAR_HEIGHT) / [UIScreen mainScreen].bounds.size.height;
    menu.contentViewInOffsetCenterDeltaY = STATUS_BAR_HEIGHT / 2.0;
    menu.panGestureEnabled = NO;
    menu.parallaxEnabled = NO;
    menu.backgroundImage = [UIImage imageNamed:@"SideMenuBackground"];
    
    // Reachability
    [ReachabilityManager sharedManager];
    
    self.window.tintColor = MAIN_APP_COLOR;
    
    [self setupParseWithOptions:launchOptions];
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    // Disable hiding split controller children on iPad
    if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]])
    {
        // Were on iPad and application base is split view controller
        UISplitViewController* splitController = (UISplitViewController*)self.window.rootViewController;
        splitController.delegate = self;
    }
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[DatabaseManager sharedManager] saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[DatabaseManager sharedManager] saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[DatabaseManager sharedManager] saveContext];
}

@end
