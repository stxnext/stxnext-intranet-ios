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

typedef NS_ENUM(NSUInteger, ModelErrorType)
{
    ModelErrorTypeDefault,
    ModelErrorTypeLoginRequired
};

@interface Model : NSObject

+ (instancetype)singleton;

- (void)updateModelWithStart:(void (^)(NSDictionary *params))startActions
                         end:(void (^)(NSDictionary *params))endActions
                     success:(void (^)(NSArray *users, NSArray *presences, NSArray *teams))success
                     failure:(void (^)(NSArray *users, NSArray *presences, NSArray *teams, ModelErrorType error))failure;

@end
