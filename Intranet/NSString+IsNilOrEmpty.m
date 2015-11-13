//
//  NSString+IsNilOrEmpty.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 13.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import "NSString+IsNilOrEmpty.h"

@implementation NSString (IsNilOrEmpty)

+ (BOOL)isNilOrEmpty:(NSString *)string {
    if(!string || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

@end
