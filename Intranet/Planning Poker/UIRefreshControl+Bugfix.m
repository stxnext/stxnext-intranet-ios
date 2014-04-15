//
//  UIRefreshControl+Bugfix.m
//  Intranet
//
//  Created by Dawid Żakowski on 15/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "UIRefreshControl+Bugfix.h"

@implementation UIRefreshControl (Bugfix)

/*
 * Ref: http://stackoverflow.com/questions/19121276/uirefreshcontrol-incorrect-title-offset-during-first-run-and-sometimes-title-mis
 */
- (void)fixLabelOffset
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self endRefreshing];
    });
}

@end
