//
//  Users.h
//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "IGObject.h"

@interface Users : IGObject

+ (instancetype)singleton;

- (void)usersWithStart:(void (^)(void))startActions
                   end:(void (^)(void))endActions
               success:(void (^)(NSArray *users))success
               failure:(void (^)(NSArray *cachedUsers, FailureErrorType error))failure;

- (void)downloadUsersWithStart:(void (^)(void))startActions
                           end:(void (^)(void))endActions
                       success:(void (^)(NSArray *users))success
                       failure:(void (^)(NSArray *cachedUsers, FailureErrorType error))failure;

@end
