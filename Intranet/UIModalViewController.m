//
//  UIModalViewController.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UIModalViewController.h"

@implementation UIModalViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect bounds = self.view.superview.bounds;
    bounds.size = self.contentSizeForViewInPopover;
    self.view.superview.bounds = bounds;
}

- (IBAction)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

+ (void)presentAfterSetupWithDecorator:(void (^)(UIModalViewController* controller))decoratorBlock
{
    [AppDelegate presentViewControllerWithIdentifier:[self viewControllerIdentifier]
                                   inStoryboardNamed:[self storyboardIdentifier]
                             withControllerDecorator:^(UIViewController *viewController) {
                                 if (decoratorBlock && [viewController isKindOfClass:[UIModalViewController class]])
                                     decoratorBlock((UIModalViewController*)viewController);
                             }];
}

+ (void)present
{
    [self presentAfterSetupWithDecorator:nil];
}

#pragma mark Modal delegate

+ (NSString*)storyboardIdentifier
{
    @throw [NSException exceptionWithName:@"Not implemented" reason:nil userInfo:nil];
}

+ (NSString*)viewControllerIdentifier
{
    @throw [NSException exceptionWithName:@"Not implemented" reason:nil userInfo:nil];
}

@end
