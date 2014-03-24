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

- (void)teamsWithStart:(void (^)(NSDictionary *params))startActions
                   end:(void (^)(NSDictionary *params))endActions
               success:(void (^)(NSArray *teams))success
               failure:(void (^)(NSDictionary *data))failure;

- (void)downloadTeamsWithStart:(void (^)(NSDictionary *params))startActions
                           end:(void (^)(NSDictionary *params))endActions
                       success:(void (^)(NSArray *teams))success
                       failure:(void (^)(NSDictionary *data))failure;

@end
