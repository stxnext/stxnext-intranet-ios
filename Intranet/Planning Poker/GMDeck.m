//
//  GMDeck.m
//
//  Created by Dawid Żakowski on 19/03/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "GMHeader.h"

NSString* const kGMDeckId = @"id";
NSString* const kGMDeckName = @"name";
NSString* const kGMDeckCards = @"cards";

@implementation GMDeck

@synthesize identifier = _identifier;
@synthesize name = _name;
@synthesize cards = _cards;

+ (GMDeck *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GMDeck *instance = [[GMDeck alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]])
    {
        NSObject *receivedGMCards = dict[kGMDeckCards];
        NSMutableArray *parsedGMCards = [NSMutableArray array];
        
        if ([receivedGMCards isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *item in (NSArray *)receivedGMCards)
            {
                if ([item isKindOfClass:[NSDictionary class]])
                    [parsedGMCards addObject:[GMCard modelObjectWithDictionary:item]];
            }
        }
        else if ([receivedGMCards isKindOfClass:[NSDictionary class]])
            [parsedGMCards addObject:[GMCard modelObjectWithDictionary:(NSDictionary *)receivedGMCards]];
        
        self.identifier = [dict[kGMDeckId] validNumber];
        self.name = dict[kGMDeckName];
        self.cards = parsedGMCards;
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableArray *tempArrayForCards = [NSMutableArray array];
    
    for (NSObject *subArrayObject in self.cards)
    {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)])
            [tempArrayForCards addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        else
            [tempArrayForCards addObject:subArrayObject];
    }
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.identifier forKey:kGMDeckId];
    [mutableDict setValue:self.name forKey:kGMDeckName];
    [mutableDict setValue:tempArrayForCards forKey:@"kGMDeckCards"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.identifier = [aDecoder decodeObjectForKey:kGMDeckId];
    self.name = [aDecoder decodeObjectForKey:kGMDeckName];
    self.cards = [aDecoder decodeObjectForKey:kGMDeckCards];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:kGMDeckId];
    [aCoder encodeObject:_name forKey:kGMDeckName];
    [aCoder encodeObject:_cards forKey:kGMDeckCards];
}

#pragma mark - NSObject equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return [super isEqual:object];
    
    GMDeck* other = object;
    return [self.identifier isEqualToNumber:other.identifier];
}

@end
