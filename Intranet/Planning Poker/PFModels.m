//
//  PFModels.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PFModels.h"

@implementation PFModels

+ (instancetype)singleton
{
    static id obj = nil;
    return obj ?: (obj = [[self class] new]);
}

- (void)registerSubclasses
{
    [PFGame registerSubclass];
    [PFTicket registerSubclass];
    [PFRound registerSubclass];
    [PFVote registerSubclass];
    [PFPerson registerSubclass];
}

@end
