//
//  NSNotificationCenter+NSOperationQueue.h
//  Intranet
//
//  Created by Dawid Żakowski on 22/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNotificationCenter (NSOperationQueue)

- (NSOperationQueue*)notificationQueue;
- (void)postNotificationName:(NSString *)aName object:(id)anObject usingQueue:(NSOperationQueue*)queue;
- (void)enqueueNotificationName:(NSString *)aName object:(id)anObject;

@end