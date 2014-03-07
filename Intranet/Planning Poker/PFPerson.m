//
//  PFPerson.m
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "PFPerson.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFPerson

@dynamic email, revision;

+ (NSString *)parseClassName
{
    return @"Person";
}

@end
