//
//  NSObject+SingleDispatch.m
//  Intranet
//
//  Created by Dawid Żakowski on 15/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "NSObject+SingleDispatch.h"

@implementation NSObject (SingleDispatch)

- (NSMutableArray*)dispatchTokens
{
    if (!objc_getAssociatedObject(self, @selector(dispatchTokens)))
    {
        NSMutableArray* dispatchTokens = [NSMutableArray array];
        
        objc_setAssociatedObject(self, @selector(dispatchTokens), dispatchTokens, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return objc_getAssociatedObject(self, @selector(dispatchTokens));
}

- (BOOL)dispatchSingleUsingTag:(id)tag withBlock:(void (^)(dispatch_block_t callback))block
{
    @synchronized (self.dispatchTokens)
    {
        if ([self.dispatchTokens containsObject:tag])
            return NO;
        
        [self.dispatchTokens addObject:tag];
    }
    
    block(^{
        @synchronized (self.dispatchTokens)
        {
            [self.dispatchTokens removeObject:tag];
        }
    });
    
    return YES;
}

@end
