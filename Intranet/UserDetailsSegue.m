//
//  UserDetailsSegue.m
//  Intranet
//
//  Created by Dawid Żakowski on 13/11/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UserDetailsSegue.h"

#import "UsersSplitViewController.h"

@implementation UserDetailsSegue

- (void)perform
{
//    UIViewController* detailController = ((UIViewController*)self.sourceViewController).splitViewController.viewControllers.lastObject;
    UsersSplitViewController *splitController = (UsersSplitViewController *)((UIViewController*)self.sourceViewController).splitViewController;
    
    [splitController showDetailViewController:self.destinationViewController sender:self];
//    .viewControllers = @[ self.destinationViewController ];
//    if (![detailController isKindOfClass:[UINavigationController class]])
//        return;
    
//    UINavigationController* navigationController = (UINavigationController*)detailController;
//    [navigationController setViewControllers:@[ self.destinationViewController ]];
}

@end
