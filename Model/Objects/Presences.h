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

- (void)presencesWithStart:(void (^)(void))startActions
                       end:(void (^)(void))endActions
                   success:(void (^)(NSArray *presences))success
                   failure:(void (^)(NSArray *cachedPresences, FailureErrorType error))failure;

- (void)downloadPresencesWithStart:(void (^)(void))startActions
                               end:(void (^)(void))endActions
                           success:(void (^)(NSArray *presences))success
                           failure:(void (^)(NSArray *cachedPresences, FailureErrorType error))failure;

@end
