//
//  IGConcreteObject.m
//  MVC
//
//  Created by Adam on 20.03.2014.
//  Copyright (c) 2014 IntelliGents s.c. All rights reserved.
//

#import "IGConcreteObject.h"

@implementation IGConcreteObject

#pragma mark - Accessors methods

- (void)objectWithParams:(NSDictionary *)params
                   start:(void (^)(NSDictionary *params))startActions
                     end:(void (^)(NSDictionary *params))endActions
                 success:(void (^)(IGObject *object))success
                 failure:(void (^)(NSDictionary *data))failure
{
    // logic goes here:
    NSLog(@"geting concrete object");
}

- (void)setObject:(IGObject *)object
            start:(void (^)(NSDictionary *params))startActions
              end:(void (^)(NSDictionary *params))endActions
          success:(void (^)(NSDictionary *data))success
          failure:(void (^)(NSDictionary *data))failure
{
    // logic goes here:
    NSLog(@"seting concrete object");
}

@end
