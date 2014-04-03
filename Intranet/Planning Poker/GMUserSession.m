//
//  GMUserSession.m
//  Intranet
//
//  Created by Dawid Żakowski on 21/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GMUserSession.h"

@implementation GMUserSession

NSString* const kGUserSessionPlayerIdentifier = @"player_id";
NSString* const kGUserSessionSessionIdentifier = @"session_id";
NSString* const kGUserSessionSessionSubject = @"session_subject";

@synthesize playerIdentifier = _playerIdentifier;
@synthesize sessionIdentifier = _sessionIdentifier;
@synthesize sessionSubject = _sessionSubject;

+ (GMUserSession *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GMUserSession *instance = [[GMUserSession alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]])
    {
        self.playerIdentifier = [dict[kGUserSessionPlayerIdentifier] validNumber];
        self.sessionIdentifier = [dict[kGUserSessionSessionIdentifier] validNumber];
        self.sessionSubject = [dict[kGUserSessionSessionSubject] extractJson];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.playerIdentifier forKey:kGUserSessionPlayerIdentifier];
    [mutableDict setValue:self.sessionIdentifier forKey:kGUserSessionSessionIdentifier];
    [mutableDict setValue:self.sessionSubject forKey:kGUserSessionSessionSubject];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.playerIdentifier = [aDecoder decodeObjectForKey:kGUserSessionPlayerIdentifier];
    self.sessionIdentifier = [aDecoder decodeObjectForKey:kGUserSessionSessionIdentifier];
    self.sessionSubject = [aDecoder decodeObjectForKey:kGUserSessionSessionSubject];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_playerIdentifier forKey:kGUserSessionPlayerIdentifier];
    [aCoder encodeObject:_sessionIdentifier forKey:kGUserSessionSessionIdentifier];
    [aCoder encodeObject:_sessionSubject forKey:kGUserSessionSessionSubject];
}

#pragma mark - NSObject equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return [super isEqual:object];
    
    GMUserSession* other = object;
    return [self.playerIdentifier isEqualToNumber:other.playerIdentifier] && [self.sessionIdentifier isEqualToNumber:other.sessionIdentifier];
}

@end
