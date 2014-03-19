//
//  PokerSessionManager.h
//  Intranet
//
//  Created by Adam on 19.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PokerSession.h"

@interface PokerSessionManager : NSObject

- (void)addPokerSession:(PokerSession *)pokerSession;
- (PokerSession *)pokerSessionAtIndex:(NSUInteger)index;
- (NSUInteger)count;

@end
