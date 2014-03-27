//
//  GMUser.h
//
//  Created by Dawid Żakowski on 19/03/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"

@interface GMUser : GMModel

extern NSString* const kGMUserEmail;
extern NSString* const kGMUserId;
extern NSString* const kGMUserExternalId;
extern NSString* const kGMUserActive;
extern NSString* const kGMUserName;
extern NSString* const kGMUserTeamId;
extern NSString* const kGMUserImageUrl;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, strong) NSNumber* externalId;
@property (nonatomic, assign) BOOL active;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber* teamId;
@property (nonatomic, strong) NSString* imageURL;

- (BOOL)isSynchronized;

@end
