//
//  Model.h
//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Presences.h"
#import "Users.h"
#import "Teams.h"

@interface Model : IGObject

+ (instancetype)singleton;

- (void)updateModelWithStart:(void (^)(void))startActions
                         end:(void (^)(void))endActions
                     success:(void (^)(NSArray *users, NSArray *presences, NSArray *teams))success
                     failure:(void (^)(NSArray *cachedUsers, NSArray *cachedPresences, NSArray *cachedTeams, FailureErrorType error))failure;

@end
