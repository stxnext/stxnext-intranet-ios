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

@implementation GMSession

@synthesize expired = _expired;
@synthesize endTime = _endTime;
@synthesize deckId = _deckId;
@synthesize identifier = _identifier;
@synthesize owner = _owner;
@synthesize players = _players;
@synthesize startTime = _startTime;

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
        
        self.expired = [[dict[kGMSessionExpired] validObject] boolValue];
        self.endTime = [dict[kGMSessionEndTime] validNumber];
        self.deckId = [dict[kGMSessionDeckId] validNumber];
        self.identifier = [dict[kGMSessionId] validNumber];
        self.owner = [GMUser modelObjectWithDictionary:dict[kGMSessionOwner]];
        self.players = parsedGMPlayers;
        self.startTime = [dict[kGMSessionStartTime] validNumber];
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
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:@(self.expired) forKey:kGMSessionExpired];
    [mutableDict setValue:self.endTime forKey:kGMSessionEndTime];
    [mutableDict setValue:self.deckId forKey:kGMSessionDeckId];
    [mutableDict setValue:self.identifier forKey:kGMSessionId];
    [mutableDict setValue:[self.owner dictionaryRepresentation] forKey:kGMSessionOwner];
    [mutableDict setValue:tempArrayForPlayers forKey:kGMSessionPlayers];
    [mutableDict setValue:self.startTime forKey:kGMSessionStartTime];

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
}

@end
