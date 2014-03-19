//
//  PokerSessionManager.m
//  Intranet
//
//  Created by Adam on 19.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PokerSessionManager.h"

@interface PokerSessionManager ()

@property (nonatomic, strong) NSMutableArray *pokerSessionList;

@end

@implementation PokerSessionManager

- (void)addPokerSession:(PokerSession *)pokerSession
{
    [self.pokerSessionList addObject:pokerSession];
}

- (PokerSession *)pokerSessionAtIndex:(NSUInteger)index
{
    if (index < self.pokerSessionList.count)
    {
        return self.pokerSessionList[index];
    }
    
    return nil;
}

- (NSMutableArray *)pokerSessionList
{
    if (!_pokerSessionList)
    {
        _pokerSessionList = [NSMutableArray new];
    }
    
    return _pokerSessionList;
}

- (NSUInteger)count
{
    return self.pokerSessionList.count;
}

@end
