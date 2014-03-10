//
//  PFRound.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PFRound.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFRound

@dynamic index, startDate, endDate, timeout, votes;

+ (NSString *)parseClassName
{
    return @"Round";
}

@end
