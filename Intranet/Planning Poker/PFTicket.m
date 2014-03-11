//
//  PFTicket.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PFTicket.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFTicket

@dynamic name, finalEstimate, rounds, description, startDate, endDate;

+ (NSString *)parseClassName
{
    return @"Ticket";
}

@end
