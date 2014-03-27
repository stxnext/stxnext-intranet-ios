//
//  GMCard.m
//
//  Created by Dawid Żakowski on 19/03/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "GMHeader.h"

NSString* const kGMCardId = @"id";
NSString* const kGMCardDisplayValue = @"display_value";

@implementation GMCard

@synthesize identifier = _identifier;
@synthesize displayValue = _displayValue;

+ (GMCard *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GMCard *instance = [[GMCard alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]])
    {
        self.identifier = [dict[kGMCardId] validNumber];
        self.displayValue = dict[kGMCardDisplayValue];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.identifier forKey:kGMCardId];
    [mutableDict setValue:self.displayValue forKey:kGMCardDisplayValue];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.identifier = [aDecoder decodeObjectForKey:kGMCardId];
    self.displayValue = [aDecoder decodeObjectForKey:kGMCardDisplayValue];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:kGMCardId];
    [aCoder encodeObject:_displayValue forKey:kGMCardDisplayValue];
}

@end
