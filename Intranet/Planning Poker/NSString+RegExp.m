//
//  NSString+RegExp.m
//  Intranet
//
//  Created by Dawid Żakowski on 01/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "NSString+RegExp.h"

@implementation NSString (RegExp)

- (NSString*)substringWithRegexpPattern:(NSString*)pattern withAtomPath:(NSIndexPath*)atomPath
{
    NSRegularExpression* regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray* matches = [regexp matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    
    if (atomPath.match >= matches.count)
        return nil;
    
    NSTextCheckingResult* result = matches[atomPath.match];
    
    if (atomPath.range >= result.numberOfRanges)
        return nil;
    
    NSRange range = [result rangeAtIndex:atomPath.range];
    NSString* match = [self substringWithRange:range];
    
    return match;
}

@end

@implementation NSIndexPath (RegExp)

+ (NSIndexPath*)indexPathForFirstMatchWithRange:(NSInteger)range
{
    return [NSIndexPath indexPathForRange:range inMatch:0];
}

+ (NSIndexPath *)indexPathForRange:(NSInteger)range inMatch:(NSInteger)match
{
    return [NSIndexPath indexPathForRow:range inSection:match];
}

- (NSInteger)match
{
    return self.section;
}

- (NSInteger)range
{
    return self.row;
}

@end