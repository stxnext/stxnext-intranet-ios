//
//  GMUser.m
//
//  Created by Dawid Żakowski on 19/03/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "GMHeader.h"

NSString* const kGMUserEmail = @"email";
NSString* const kGMUserId = @"id";
NSString* const kGMUserExternalId = @"external_id";
NSString* const kGMUserActive = @"active";
NSString* const kGMUserName = @"name";
NSString* const kGMUserTeamId = @"team_id";
NSString* const kGMUserImageUrl = @"image_url";

@implementation GMUser

@synthesize email = _email;
@synthesize identifier = _identifier;
@synthesize externalId = _externalId;
@synthesize active = _active;
@synthesize name = _name;
@synthesize teamId = _teamId;
@synthesize imageURL = _imageURL;

+ (GMUser *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GMUser *instance = [[GMUser alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    if (self && [dict isKindOfClass:[NSDictionary class]])
    {
        self.email = dict[kGMUserEmail];
        self.identifier = [dict[kGMUserId] validNumber];
        self.externalId = [dict[kGMUserExternalId] validNumber];
        self.active = [dict[kGMUserActive] boolValue];
        self.name = dict[kGMUserName];
        self.teamId = [dict[kGMUserTeamId] validNumber];
        self.imageURL = dict[kGMUserImageUrl];
    }
    
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.email forKey:kGMUserEmail];
    [mutableDict setValue:self.identifier forKey:kGMUserId];
    [mutableDict setValue:self.externalId forKey:kGMUserExternalId];
    [mutableDict setValue:@(self.active) forKey:kGMUserActive];
    [mutableDict setValue:self.name forKey:kGMUserName];
    [mutableDict setValue:self.teamId forKey:kGMUserTeamId];
    [mutableDict setValue:self.imageURL forKey:kGMUserImageUrl];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.email = [aDecoder decodeObjectForKey:kGMUserEmail];
    self.identifier = [aDecoder decodeObjectForKey:kGMUserId];
    self.externalId = [aDecoder decodeObjectForKey:kGMUserExternalId];
    self.active = [aDecoder decodeBoolForKey:kGMUserActive];
    self.name = [aDecoder decodeObjectForKey:kGMUserName];
    self.teamId = [aDecoder decodeObjectForKey:kGMUserTeamId];
    self.imageURL = [aDecoder decodeObjectForKey:kGMUserImageUrl];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_email forKey:kGMUserEmail];
    [aCoder encodeObject:_identifier forKey:kGMUserId];
    [aCoder encodeObject:_externalId forKey:kGMUserExternalId];
    [aCoder encodeBool:_active forKey:kGMUserActive];
    [aCoder encodeObject:_name forKey:kGMUserName];
    [aCoder encodeObject:_teamId forKey:kGMUserTeamId];
    [aCoder encodeObject:_imageURL forKey:kGMUserImageUrl];
}

#pragma mark Custom public methods

- (BOOL)isSynchronized
{
    return self.identifier != nil;
}

#pragma mark - NSObject equality

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]])
        return [super isEqual:object];
    
    GMUser* other = object;
    return [self.identifier isEqualToNumber:other.identifier];
}

@end
