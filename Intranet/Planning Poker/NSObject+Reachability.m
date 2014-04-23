//
//  NSObject+Reachability.m
//  Intranet
//
//  Created by Dawid Żakowski on 17/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "NSObject+Reachability.h"
#import "NSObject+SingleDispatch.h"
#import "Reachability.h"

@implementation NSObject (Reachability)

- (void)setReachabilityObserver:(id)reachabilityObserver
{
    objc_setAssociatedObject(self, @selector(reachabilityObserver), reachabilityObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)reachabilityObserver
{
    return objc_getAssociatedObject(self, @selector(reachabilityObserver));
}

- (void)setReachabilityQueue:(NSOperationQueue*)reachabilityQueue
{
    objc_setAssociatedObject(self, @selector(reachabilityQueue), reachabilityQueue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSOperationQueue*)reachabilityQueue
{
    if (!objc_getAssociatedObject(self, @selector(reachabilityQueue)))
    {
        NSOperationQueue* reachabilityQueue = [NSOperationQueue new];
        [reachabilityQueue setSuspended:!self.reachability.isReachable];
        self.reachabilityQueue = reachabilityQueue;
        
        __weak NSOperationQueue* weakQueue = reachabilityQueue;
        
        self.reachabilityObserver = [[NSNotificationCenter defaultCenter] addObserverForName:self.reachabilityNotificationKey object:self.reachability queue:nil usingBlock:^(NSNotification *note) {
            id<NetworkReachabilitySource> reachability = note.object;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakQueue setSuspended:!reachability.isReachable];
            });
        }];
    }
    
    return objc_getAssociatedObject(self, @selector(reachabilityQueue));
}

- (void)dispatchAsyncWhenReachable:(dispatch_block_t)dispatchBlock
{
    [self.reachabilityQueue addOperationWithBlock:dispatchBlock];
}

- (void)dispatchSingleAsyncWhenReachableUsingTag:(id)tag withBlock:(void (^)(void (^)(BOOL stop)))block
{
    [self.reachabilityQueue addOperationWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dispatchSingleUsingTag:tag withBlock:^(dispatch_block_t callback) {
                block(^(BOOL stop){
                    callback();
                    
                    if (stop)
                        [self clearReachabilityDispatches];
                });
            }];
        });
    }];
}

- (void)clearReachabilityDispatches
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.reachabilityObserver name:self.reachabilityNotificationKey object:self.reachability];
    
    [self.reachabilityQueue cancelAllOperations];
    self.reachabilityQueue = nil;
}

@end

@implementation NSObject (ReachabilityDefaults)

- (id<NetworkReachabilitySource>)reachability
{
    static InternetReachability* reachability = nil;
    
    if (!reachability)
    {
        reachability = [InternetReachability reachabilityForInternetConnection];
        [reachability startNotifier];
    }
    
    return (id<NetworkReachabilitySource>)reachability;
}

- (NSString*)reachabilityNotificationKey
{
    return kInternetReachabilityChangedNotification;
}

@end