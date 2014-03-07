//
//  AppDelegate+Parse.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AppDelegate+Parse.h"

@implementation AppDelegate (Parse)

- (void)setupParseWithOptions:(NSDictionary *)launchOptions
{
    NSString *applicationId = [NSBundle mainBundle].infoDictionary[@"ParseApplicationId"];
    NSString *clientKey = [NSBundle mainBundle].infoDictionary[@"ParseClientKey"];
    
    [[PFModels singleton] registerSubclasses];
    [Parse setApplicationId:applicationId clientKey:clientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

@end
