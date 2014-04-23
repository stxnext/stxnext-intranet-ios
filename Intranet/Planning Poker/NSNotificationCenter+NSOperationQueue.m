//
//  NSNotificationCenter+NSOperationQueue.m
//  Intranet
//
//  Created by Dawid Żakowski on 22/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "NSNotificationCenter+NSOperationQueue.h"

@implementation NSNotificationCenter (NSOperationQueue)

- (NSOperationQueue*)notificationQueue
{
    if (!objc_getAssociatedObject(self, @selector(notificationQueue)))
    {
        NSOperationQueue* notificationQueue = [NSOperationQueue new];
        
        objc_setAssociatedObject(self, @selector(notificationQueue), notificationQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objc_getAssociatedObject(self, @selector(notificationQueue));
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject usingQueue:(NSOperationQueue*)queue
{
    [queue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self postNotificationName:aName object:anObject];
        });
    }];
}

- (void)enqueueNotificationName:(NSString *)aName object:(id)anObject
{
    NSOperationQueue* queue = self.notificationQueue;
    [self postNotificationName:aName object:anObject usingQueue:queue];
}

@end
