//
//  NSObject+DelayedBlocks.h
//  eventapp
//
//  Created by Adam on 12.07.2013.
//  Copyright (c) 2013 Softax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (DelayedBlocks)

- (void)performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)performBlockInCurrentThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)performBlockInBackground:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end
