//
//  AppDelegate+Modals.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AppDelegate+Modals.h"

@implementation AppDelegate (Modals)

+ (UIViewController*)viewController
{
    return [UIApplication sharedApplication].delegate.window.rootViewController;
}

+ (void)presentViewController:(UIViewController*)viewController
{
    if (INTERFACE_IS_PAD)
    {
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    else
    {
        viewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    dispatch_block_t presentBlock = ^{
        [[AppDelegate viewController] presentViewController:viewController animated:YES completion:nil];
    };
    
    if ([AppDelegate viewController].presentedViewController)
    {
        [[AppDelegate viewController] dismissViewControllerAnimated:YES
                                                         completion:presentBlock];
    }
    else
    {
        presentBlock();
    }
}

+ (void)presentViewControllerWithIdentifier:(NSString*)identifier
                          inStoryboardNamed:(NSString*)storyboardName
                    withControllerDecorator:(void (^)(UIViewController* viewController))decoratorblock
{
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:identifier];
    
    if (decoratorblock)
        decoratorblock(controller);
    
    [self presentViewController:controller];
}

@end
