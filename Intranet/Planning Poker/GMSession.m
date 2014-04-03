//
//  GMSession.m
//
//  Created by Dawid Żakowski on 19/03/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "GMHeader.h"

NSString* const kGMSessionExpired = @"expired";
NSString* const kGMSessionEndTime = @"end_time";
NSString* const kGMSessionDeckId = @"deck_id";
NSString* const kGMSessionId = @"id";
NSString* const kGMSessionOwner = @"owner";
NSString* const kGMSessionPlayers = @"players";
NSString* const kGMSessionStartTime = @"start_time";
NSString* const kGMSessionName = @"name";
NSString* const kGMSessionTickets = @"tickets";

@implementation GMSession

@synthesize expired = _expired;
@synthesize endTime = _endTime;
@synthesize deckId = _deckId;
@synthesize identifier = _identifier;
@synthesize owner = _owner;
@synthesize players = _players;
@synthesize startTime = _startTime;
@synthesize name = _name;
@synthesize tickets = _tickets;

+ (GMSession *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GMSession *instance = [[GMSession alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]])
    {
        NSObject *receivedGMPlayers = [dict objectForKey:kGMSessionPlayers];
        NSMutableArray *parsedGMPlayers = [NSMutableArray array];
        
        if ([receivedGMPlayers isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *item in (NSArray *)receivedGMPlayers)
            {
                if ([item isKindOfClass:[NSDictionary class]])
                    [parsedGMPlayers addObject:[GMUser modelObjectWithDictionary:item]];
            }
        }
        else if ([receivedGMPlayers isKindOfClass:[NSDictionary class]])
            [parsedGMPlayers addObject:[GMUser modelObjectWithDictionary:(NSDictionary *)receivedGMPlayers]];
        
        NSObject *receivedGMTickets = [dict objectForKey:kGMSessionTickets];
        NSMutableArray *parsedGMTickets = [NSMutableArray array];
        
        if ([receivedGMTickets isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *item in (NSArray *)receivedGMTickets)
            {
                if ([item isKindOfClass:[NSDictionary class]])
                    [parsedGMTickets addObject:[GMTicket modelObjectWithDictionary:item]];
            }
        }
        else if ([receivedGMTickets isKindOfClass:[NSDictionary class]])
            [parsedGMTickets addObject:[GMTicket modelObjectWithDictionary:(NSDictionary *)receivedGMTickets]];
        
        self.expired = [[dict[kGMSessionExpired] validObject] boolValue];
        self.endTime = [dict[kGMSessionEndTime] validNumber];
        self.deckId = [dict[kGMSessionDeckId] validNumber];
        self.identifier = [dict[kGMSessionId] validNumber];
        self.owner = [GMUser modelObjectWithDictionary:dict[kGMSessionOwner]];
        self.players = parsedGMPlayers;
        self.startTime = [dict[kGMSessionStartTime] validNumber];
        self.name = dict[kGMDeckName];
        self.tickets = parsedGMTickets;
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableArray *tempArrayForPlayers = [NSMutableArray array];
    
    for (NSObject *subArrayObject in self.players)
    {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)])
            [tempArrayForPlayers addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        else
            [tempArrayForPlayers addObject:subArrayObject];
    }
    
    NSMutableArray *tempArrayForTickets = [NSMutableArray array];
    
    for (NSObject *subArrayObject in self.tickets)
    {
        if ([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)])
            [tempArrayForTickets addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        else
            [tempArrayForTickets addObject:subArrayObject];
    }
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:@(self.expired) forKey:kGMSessionExpired];
    [mutableDict setValue:self.endTime forKey:kGMSessionEndTime];
    [mutableDict setValue:self.deckId forKey:kGMSessionDeckId];
    [mutableDict setValue:self.identifier forKey:kGMSessionId];
    [mutableDict setValue:[self.owner dictionaryRepresentation] forKey:kGMSessionOwner];
    [mutableDict setValue:tempArrayForPlayers forKey:kGMSessionPlayers];
    [mutableDict setValue:self.startTime forKey:kGMSessionStartTime];
    [mutableDict setValue:self.name forKey:kGMDeckName];
    [mutableDict setValue:tempArrayForTickets forKey:kGMSessionTickets];

    return mutableDict;
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.expired = [aDecoder decodeBoolForKey:kGMSessionExpired];
    self.endTime = [aDecoder decodeObjectForKey:kGMSessionEndTime];
    self.deckId = [aDecoder decodeObjectForKey:kGMSessionDeckId];
    self.identifier = [aDecoder decodeObjectForKey:kGMSessionId];
    self.owner = [aDecoder decodeObjectForKey:kGMSessionOwner];
    self.players = [aDecoder decodeObjectForKey:kGMSessionPlayers];
    self.startTime = [aDecoder decodeObjectForKey:kGMSessionStartTime];
    self.name = [aDecoder decodeObjectForKey:kGMDeckName];
    self.tickets = [aDecoder decodeObjectForKey:kGMSessionTickets];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:_expired forKey:kGMSessionExpired];
    [aCoder encodeObject:_endTime forKey:kGMSessionEndTime];
    [aCoder encodeObject:_deckId forKey:kGMSessionDeckId];
    [aCoder encodeObject:_identifier forKey:kGMSessionId];
    [aCoder encodeObject:_owner forKey:kGMSessionOwner];
    [aCoder encodeObject:_players forKey:kGMSessionPlayers];
    [aCoder encodeObject:_startTime forKey:kGMSessionStartTime];
    [aCoder encodeObject:_name forKey:kGMDeckName];
    [aCoder encodeObject:_tickets forKey:kGMSessionTickets];
}

#pragma mark - NSObject equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return [super isEqual:object];
    
    GMSession* other = object;
    return [self.identifier isEqualToNumber:other.identifier];
}

@end
