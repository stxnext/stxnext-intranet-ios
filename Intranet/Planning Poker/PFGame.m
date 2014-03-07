//
//  PFGame.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PFGame.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFGame

@dynamic startDate, title, owner, deck, isFinished, players, tickets;

+ (NSString *)parseClassName
{
    return @"Game";
}

@end
