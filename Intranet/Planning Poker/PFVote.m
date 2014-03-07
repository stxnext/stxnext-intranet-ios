//
//  PFVote.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PFVote.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFVote

@dynamic value, author;

+ (NSString *)parseClassName
{
    return @"Vote";
}

@end
