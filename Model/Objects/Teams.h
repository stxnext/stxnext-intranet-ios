//
//  Teams.h
//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "IGObject.h"

@interface Teams : IGObject

+ (instancetype)singleton;

- (void)teamsWithStart:(void (^)(void))startActions
                   end:(void (^)(void))endActions
               success:(void (^)(NSArray *teams))success
               failure:(void (^)(NSArray *cachedTeams, FailureErrorType error))failure;

- (void)downloadTeamsWithStart:(void (^)(void))startActions
                           end:(void (^)(void))endActions
                       success:(void (^)(NSArray *teams))success
                       failure:(void (^)(NSArray *cachedTeams, FailureErrorType error))failure;

@end
