//
//  AppDelegate+Modals.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate.h"

#define kStoryboardName(name)  [NSString stringWithFormat:@"%@_%@", name, INTERFACE_IS_PAD ? @"iPad" : @"iPhone"]
#define kMainStoryboardName    kStoryboardName(@"Main")

#define kStoryboardLoginIdentifier @"LoginViewController"

@interface AppDelegate (Modals)

+ (void)presentViewControllerWithIdentifier:(NSString*)identifier
                          inStoryboardNamed:(NSString*)storyboardName
                    withControllerDecorator:(void (^)(UIViewController* viewController))decoratorblock;

@end