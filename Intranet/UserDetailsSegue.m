//
//  UserDetailsSegue.m
//  Intranet
//
//  Created by Dawid Żakowski on 13/11/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserDetailsSegue.h"

@implementation UserDetailsSegue

- (void)perform
{
    UIViewController* detailController = ((UIViewController*)self.sourceViewController).splitViewController.viewControllers.lastObject;
    
    if (![detailController isKindOfClass:[UINavigationController class]])
        return;
    
    UINavigationController* navigationController = (UINavigationController*)detailController;
    [navigationController setViewControllers:@[ self.destinationViewController ]];
}

@end
