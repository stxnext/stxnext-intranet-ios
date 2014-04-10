//
//  GMVote.m
//  Intranet
//
//  Created by Dawid Żakowski on 24/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GMHeader.h"

NSString* const kGMVoteIdentifier = @"id";
NSString* const kGMVoteCard = @"card";
NSString* const kGMVotePlayer = @"player";
NSString* const kGMVoteTicketIdentifier = @"ticket_id";

@implementation GMVote

@synthesize identifier = _identifier;
@synthesize card = _card;
@synthesize player = _player;
@synthesize ticketIdentifier = _ticketIdentifier;

+ (GMVote *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GMVote *instance = [[GMVote alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]])
    {
        self.identifier = [dict[kGMVoteIdentifier] validNumber];
        self.card = [GMCard modelObjectWithDictionary:dict[kGMVoteCard]];
        self.player = [GMUser modelObjectWithDictionary:dict[kGMVotePlayer]];
        self.ticketIdentifier = [dict[kGMVoteTicketIdentifier] validNumber];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.identifier forKey:kGMVoteIdentifier];
    [mutableDict setValue:[self.card dictionaryRepresentation] forKey:kGMVoteCard];
    [mutableDict setValue:[self.player dictionaryRepresentation] forKey:kGMVotePlayer];
    [mutableDict setValue:self.ticketIdentifier forKey:kGMVoteTicketIdentifier];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.identifier = [aDecoder decodeObjectForKey:kGMVoteIdentifier];
    self.card = [aDecoder decodeObjectForKey:kGMVoteCard];
    self.player = [aDecoder decodeObjectForKey:kGMVotePlayer];
    self.ticketIdentifier = [aDecoder decodeObjectForKey:kGMVoteTicketIdentifier];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:kGMVoteIdentifier];
    [aCoder encodeObject:_card forKey:kGMVoteCard];
    [aCoder encodeObject:_player forKey:kGMVotePlayer];
    [aCoder encodeObject:_ticketIdentifier forKey:kGMVoteTicketIdentifier];
}

#pragma mark - NSObject equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return [super isEqual:object];
    
    GMVote* other = object;
    return [self.identifier isEqualToNumber:other.identifier];
}

- (NSUInteger)hash
{
    return self.identifier.unsignedIntegerValue;
}

@end
