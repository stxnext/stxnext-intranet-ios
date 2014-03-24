//
//  Users.h
//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "IGObject.h"

typedef NS_ENUM(NSUInteger, UserErrorType)
{
    UserErrorTypeDefault,
    UserErrorTypeReloginRequired
};

@interface Users : IGObject

+ (instancetype)singleton;

- (void)usersWithStart:(void (^)(NSDictionary *params))startActions
                   end:(void (^)(NSDictionary *params))endActions
               success:(void (^)(NSArray *users))success
               failure:(void (^)(UserErrorType error))failure;

- (void)downloadUsersWithStart:(void (^)(NSDictionary *params))startActions
                           end:(void (^)(NSDictionary *params))endActions
                       success:(void (^)(NSArray *users))success
                       failure:(void (^)(UserErrorType error))failure;

@end
