//
//  IGObject.m
//  MVC
//
//  Created by Adam on 20.03.2014.
//  Copyright (c) 2014 IntelliGents s.c. All rights reserved.
//

#import "IGObject.h"

@implementation IGObject

#pragma mark - Accessors

- (void)objectWithParams:(NSDictionary *)params
                   start:(void (^)(NSDictionary *params))startActions
                     end:(void (^)(NSDictionary *params))endActions
                 success:(void (^)(IGObject *object))success
                 failure:(void (^)(NSDictionary *data))failure
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

- (void)setObject:(IGObject *)object
            start:(void (^)(NSDictionary *params))startActions
              end:(void (^)(NSDictionary *params))endActions
          success:(void (^)(NSDictionary *data))success
          failure:(void (^)(NSDictionary *data))failure
{
    [NSException raise:NSInternalInconsistencyException
                format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}

#pragma mark - Parsing

@end
