//
//  IGObject.h
//  MVC
//
//  Created by Adam on 20.03.2014.
//  Copyright (c) 2014 IntelliGents s.c. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGObject : NSObject

#pragma mark - Creation

- (instancetype)initWithData:(NSDictionary *)data;

#pragma mark - Parse

- (instancetype)parseWithData:(id)data;

#pragma mark - Accessors

- (void)objectWithParams:(NSDictionary *)params
                   start:(void (^)(NSDictionary *params))startActions
                     end:(void (^)(NSDictionary *params))endActions
                 success:(void (^)(IGObject *object))success
                 failure:(void (^)(NSDictionary *data))failure;

- (void)setObject:(IGObject *)object
            start:(void (^)(NSDictionary *params))startActions
              end:(void (^)(NSDictionary *params))endActions
          success:(void (^)(NSDictionary *data))success
          failure:(void (^)(NSDictionary *data))failure;

@end
