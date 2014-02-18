//
//  UIView+Additions.m
//  PeoPay
//
//  Created by Adam on 23.01.2014.
//  Copyright (c) 2014 Softax. All rights reserved.
//

#import "UIView+Additions.h"

@implementation UIView (Additions)

- (void)logViewHierarchy
{
    [self logViewHierarchy:0];
}

- (void)performBlockOnAllSubviews:(SubviewBlock)block
{
    block(self);
  
    for (UIView* view in [self subviews])
    {
        [view performBlockOnAllSubviews:block];
    }
}

- (void)performBlockOnAllSuperviews:(SuperviewBlock)block
{
    block(self);

    if (self.superview)
    {
        [self.superview performBlockOnAllSuperviews:block];
    }
}

#pragma mark - private

- (void)logViewHierarchy:(int)i
{
    NSString *tabs = @"";
    
    for (int x = 0; x < i; x++)
    {
        tabs = [tabs stringByAppendingString:@"\t"];
    }
    
    NSLog(@"%@%@", tabs, self);
    
    for (UIView *subview in self.subviews)
    {
        [subview logViewHierarchy:++i];
    }
    
}

@end
