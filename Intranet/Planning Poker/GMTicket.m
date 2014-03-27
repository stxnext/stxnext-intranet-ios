//
//  GMTicket.m
//  Intranet
//
//  Created by Dawid Żakowski on 21/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GMHeader.h"

NSString* const kGMTicketIdentifier = @"id";
NSString* const kGMTicketDisplayValue = @"display_value";
NSString* const kGMTicketVotes = @"votes";
NSString* const kGMTicketSessionIdentifier = @"session_id";

@implementation GMTicket

@synthesize identifier = _identifier;
@synthesize displayValue = _displayValue;
@synthesize votes = _votes;
@synthesize sessionIdentifier = _sessionIdentifier;

+ (GMTicket *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GMTicket *instance = [[GMTicket alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]])
    {
        NSObject *receivedGMVotes = dict[kGMTicketVotes];
        NSMutableArray *parsedGMVotes = [NSMutableArray array];
        
        if ([receivedGMVotes isKindOfClass:[NSArray class]])
        {
            for (NSDictionary *item in (NSArray *)receivedGMVotes)
            {
                if ([item isKindOfClass:[NSDictionary class]])
                    [parsedGMVotes addObject:[GMVote modelObjectWithDictionary:item]];
            }
        }
        else if ([receivedGMVotes isKindOfClass:[NSDictionary class]])
            [parsedGMVotes addObject:[GMVote modelObjectWithDictionary:(NSDictionary *)receivedGMVotes]];
        
        self.identifier = [dict[kGMTicketIdentifier] validNumber];
        self.displayValue = dict[kGMTicketDisplayValue];
        self.votes = parsedGMVotes;
        self.sessionIdentifier = [dict[kGMTicketSessionIdentifier] validNumber];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.identifier forKey:kGMTicketIdentifier];
    [mutableDict setValue:self.displayValue forKey:kGMTicketDisplayValue];
    [mutableDict setValue:self.votes forKey:kGMTicketVotes];
    [mutableDict setValue:self.sessionIdentifier forKey:kGMTicketSessionIdentifier];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.identifier = [aDecoder decodeObjectForKey:kGMTicketIdentifier];
    self.displayValue = [aDecoder decodeObjectForKey:kGMTicketDisplayValue];
    self.votes = [aDecoder decodeObjectForKey:kGMTicketVotes];
    self.sessionIdentifier = [aDecoder decodeObjectForKey:kGMTicketSessionIdentifier];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_identifier forKey:kGMTicketIdentifier];
    [aCoder encodeObject:_displayValue forKey:kGMTicketDisplayValue];
    [aCoder encodeObject:_votes forKey:kGMTicketVotes];
    [aCoder encodeObject:_sessionIdentifier forKey:kGMTicketSessionIdentifier];
}

@end
