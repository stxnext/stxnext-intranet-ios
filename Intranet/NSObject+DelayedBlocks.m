//
//  NSObject+DelayedBlocks.m
//  eventapp
//
//  Created by Adam on 12.07.2013.
//  Copyright (c) 2013 Softax. All rights reserved.
//


#import "NSObject+DelayedBlocks.h"

@implementation NSObject (DelayedBlocks)

- (void)performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    int64_t delta = (int64_t)(1.0e9 * delay);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_main_queue(), block);
}

- (void)performBlockInCurrentThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    int64_t delta = (int64_t)(1.0e9 * delay);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delta), dispatch_get_current_queue(), block);
}

@end
