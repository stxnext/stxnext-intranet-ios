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
        
        self.teamIDsTitle = @"";
        self.teamIDs = @[];
        
        self.tickets = @[];
        
        self.date = nil;
    }
    
    return self;
}

@end
