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

//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation
//{
//    return [GPPURLHandler handleURL:url
//                  sourceApplication:sourceApplication
//                         annotation:annotation];
//}

@end
