//
//  Presences.h
//  Intranet
//
//  Created by Adam on 21.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "IGObject.h"

@interface Presences : IGObject

+ (instancetype)singleton;

- (void)presencesWithStart:(void (^)(NSDictionary *params))startActions
                       end:(void (^)(NSDictionary *params))endActions
                   success:(void (^)(NSArray *presences))success
                   failure:(void (^)(NSDictionary *data))failure;

- (void)downloadPresencesWithStart:(void (^)(NSDictionary *params))startActions
                               end:(void (^)(NSDictionary *params))endActions
                           success:(void (^)(NSArray *presences))success
                           failure:(void (^)(NSDictionary *data))failure;

@end
