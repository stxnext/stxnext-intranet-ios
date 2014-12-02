//
//  NSString+MyRegex.m
//  Intranet
//
//  Created by Adam on 22.08.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "NSString+MyRegex.h"

@implementation NSString (MyRegex)

- (NSString *)firstMatchWithRegex:(NSString *)regex error:(NSError **)e
{
    NSError *error = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:1024 error:&error];
    
    if (re == nil)
    {
        if (e)
            *e = error;
        
        return nil;
    }
    
    NSArray *matches = [re matchesInString:self options:0 range:NSMakeRange(0, [self length])];
    
    if ([matches count] == 0)
    {
        NSString *errorDescription = [NSString stringWithFormat:@"Can't find a match for regex: %@", regex];
        NSError *error = [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{NSLocalizedDescriptionKey : errorDescription}];
        
        if (e)
            *e = error;
        
        return nil;
    }
    
    NSTextCheckingResult *match = [matches lastObject];
    NSRange matchRange = [match rangeAtIndex:1];
    
    return [self substringWithRange:matchRange];
}

@end
