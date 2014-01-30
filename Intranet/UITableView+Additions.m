//
//  UITableView+Additions.m
//  PeoPay
//
//  Created by Adam on 16.07.2013.
//  Copyright (c) 2013 Softax. All rights reserved.
//

#import "UITableView+Additions.h"

@implementation UITableView (Additions)

- (void)hideEmptySeparators
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    [self setTableFooterView:v];
}

- (void)reloadDataAnimated:(BOOL)animated
{
    [self reloadData];
    
    if (animated)
    {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:.3];
        [[self layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];   
    }
}

@end
