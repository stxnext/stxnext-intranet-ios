//
//  NSObject+JSONCast.m
//  Intranet
//
//  Created by Dawid Żakowski on 20/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "NSObject+JSONCast.h"

@implementation NSObject (JSONCast)

- (id)extractJson
{
    if ([self isKindOfClass:[NSDictionary class]])
        return self;
    else if ([self isKindOfClass:[NSArray class]])
        return self;
    else if ([self isKindOfClass:[NSData class]])
    {
        NSData* data = (NSData*)self;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return json;
    }
    else if ([self isKindOfClass:[NSString class]])
    {
        NSString* string = (NSString*)self;
        NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        return json;
    }
    
    return nil;
}

- (id)extractJson:(NSString*)key
{
    id json = [self extractJson];
    return [json isKindOfClass:[NSDictionary class]] ? [json objectForKey:key] : nil;
}

@end
