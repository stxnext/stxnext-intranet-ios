//
//  NSObject+Reachability.h
//  Intranet
//
//  Created by Dawid Żakowski on 17/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

@protocol NetworkReachabilitySource <NSObject>

- (BOOL)isReachable;

@end

@protocol NetworkReachabilityReader <NSObject>

- (id<NetworkReachabilitySource>)reachability;
- (NSString*)reachabilityNotificationKey;

@end

@interface NSObject (Reachability) <NetworkReachabilityReader>

- (void)dispatchAsyncWhenReachable:(dispatch_block_t)dispatchBlock;
- (void)dispatchSingleAsyncWhenReachableUsingTag:(id)tag withBlock:(void (^)(void (^)(BOOL stop)))block;
- (void)clearReachabilityDispatches;

@end