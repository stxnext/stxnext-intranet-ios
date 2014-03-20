//
//  NSError+CustomError.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "NSError+CustomError.h"

@implementation NSError (CustomError)

+ (NSError *)errorWithDomain:(NSString *)domain localizedDescription:(NSString *)description code:(NSInteger)code
{
    return [NSError errorWithDomain:domain code:code userInfo:@{ NSLocalizedDescriptionKey : description }];
}

@end
