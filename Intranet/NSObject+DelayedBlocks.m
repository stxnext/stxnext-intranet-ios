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

- (void)performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay
{
    [self performBlockInCurrentThread:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), block);
    } afterDelay:delay];
    
}
@end
