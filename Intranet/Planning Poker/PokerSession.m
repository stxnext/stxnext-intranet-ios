//
//  PokerSession.m
//  Intranet
//
//  Created by Adam on 11.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PokerSession.h"

@implementation PokerSession

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.title = @"";
        self.summary = @"";
        
        self.cardValuesTitle = @"";
        self.cardValues = @[];
        
        self.teamTitle = @"";
        self.teamUsersIDs = @[];
        
        self.tickets = [NSMutableArray new];
        
        self.date = nil;
    }
    
    return self;
}

- (void)fillWithTestData
{
    self.title = @"Test title";
    self.summary = @"Test summary";
    
    self.cardValuesTitle = @"Custom";
    self.cardValues = @[@"ticket 1", @"ticket 2", @"ticket 3"];
    
    self.teamTitle = @"Test team";
    self.teamUsersIDs = @[@141, @176, @170, @195, @208];
    
    self.tickets = [NSMutableArray arrayWithArray:@[@"ticket 1", @"ticket 2", @"ticket 3"]];
    
    self.date = [NSDate date];
    
}

@end
