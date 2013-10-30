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

@end
