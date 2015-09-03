//
//  AppDelegate.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+SplitControllerDelegate.h"
#import "UIImage+Color.h"

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
    
    // Appearance
    
    // Stylize tab bar + navigation bar on iPhone
    
    if (INTERFACE_IS_PHONE) {
        UIView *statusBarSubview = [[UIView alloc] init];
        statusBarSubview.frame = CGRectMake(0, 0, self.window.rootViewController.view.frame.size.width, 20);
        statusBarSubview.backgroundColor = [Branding stxDarkGreen];
        [self.window.rootViewController.view addSubview:statusBarSubview];
        
        
        // Tab bar item
        [[UITabBarItem appearance] setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        
        // Tab bar
        [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
        [[UITabBar appearance] setBackgroundImage:[UIImage imageWithColor:[Branding stxDarkGreen]]];
        
        UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
        for (UITabBarItem *item in tabBarController.tabBar.items) {
            UIImage *tabBarImg = item.image;
            item.image = [[tabBarImg imagePaintedWithColor:[Branding stxLightGreen]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [Branding stxLightGreen], NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:10.0]} forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    } else {
        [[UINavigationBar appearance]setBarTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    }
    
    // Status bar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Navigation bar
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[Branding stxGreen]] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
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