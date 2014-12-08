//
//  ControllableBlock.m
//  Intranet
//
//  Created by Adam on 08.12.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "ControllableBlock.h"

@interface ControllableBlock ()
{
    BOOL executing;
    BOOL finished;
}
@end

@implementation ControllableBlock

- (id)init
{
    self = [super init];
    
    if (self)
    {
        executing = NO;
        finished = NO;
    }
    
    return self;
}

- (void)start
{
    if ([self isCancelled])
    {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isExecuting
{
    return executing;
}

- (BOOL)isFinished
{
    return finished;
}

- (void)informIsFinished
{
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    executing = NO;
    finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
