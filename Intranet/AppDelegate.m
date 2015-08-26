//
//  AppDelegate.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+SplitControllerDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // Disable hiding split controller children on iPad
    if ([self.window.rootViewController isKindOfClass:[UISplitViewController class]])
    {
        // Were on iPad and application base is split view controller
        UISplitViewController* splitController = (UISplitViewController*)self.window.rootViewController;
        splitController.delegate = self;
    }
    
//    [[[UIWindow keyWindow] rootViewController] performSelector:@selector(recursiveDescription) withObject:nil];
    
    // Stylize tab bar + navigation bar on iPhone
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        // Status bar
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        UIView *statusBarSubview = [[UIView alloc] init];
        statusBarSubview.frame = CGRectMake(0, 0, self.window.rootViewController.view.frame.size.width, 20);
        statusBarSubview.backgroundColor = [Branding stxDarkGreen];
        [self.window.rootViewController.view addSubview:statusBarSubview];
        
        // Navigation bar
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[Branding stxGreen]] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTranslucent:NO];
        [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        
        // Tab bar item
        [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        
        // Tab bar
        [[UITabBar appearance] setTintColor:[Branding stxLightGreen]];
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[Branding stxDarkGreen]]];
        [[UITabBar appearance] setTranslucent:NO];
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


//@implementation NSURLRequest(DataController)
//+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
//{
//    return YES;
//}
//@end