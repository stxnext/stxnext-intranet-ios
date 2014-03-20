//
//  NSObject+DelayedBlocks.h
//

#import <Foundation/Foundation.h>

@interface NSObject (DelayedBlocks)

- (void)performBlockOnMainThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
- (void)performBlockInCurrentThread:(void (^)(void))block afterDelay:(NSTimeInterval)delay;

@end

