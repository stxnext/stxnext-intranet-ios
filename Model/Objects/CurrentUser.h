//
//  CurrentUser.h
//  Intranet
//
//  Created by Adam on 20.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "IGObject.h"

typedef NS_ENUM(NSUInteger, UserLoginType)
{
    UserLoginTypeNO = 0,
    UserLoginTypeTrue = 1,
    UserLoginTypeFalse = 2,
    UserLoginTypeError = 3
};

@interface CurrentUser : IGObject

+ (instancetype)singleton;

- (void)setLoginType:(UserLoginType)userLoginType;
- (UserLoginType)userLoginType;

- (void)setUserId:(NSString *)userId
            start:(void (^)(NSDictionary *params))startActions
              end:(void (^)(NSDictionary *params))endActions
          success:(void (^)(NSDictionary *data))success
          failure:(void (^)(NSDictionary *data))failure;

- (void)userIdWithStart:(void (^)(NSDictionary *params))startActions
                    end:(void (^)(NSDictionary *params))endActions
                success:(void (^)(NSString *userId))success
                failure:(void (^)(NSDictionary *data))failure;

- (void)userWithStart:(void (^)(NSDictionary *params))startActions
                  end:(void (^)(NSDictionary *params))endActions
              success:(void (^)(RMUser *user))success
              failure:(void (^)(NSDictionary *data))failure;


- (void)loginUserWithStart:(void (^)(NSDictionary *params))startActions
                       end:(void (^)(NSDictionary *params))endActions
                   success:(void (^)(NSDictionary *params))success
                   failure:(void (^)(NSDictionary *data))failure;

- (void)logoutUserWithStart:(void (^)(NSDictionary *params))startActions
                        end:(void (^)(NSDictionary *params))endActions
                    success:(void (^)(NSDictionary *params))success
                    failure:(void (^)(NSDictionary *data))failure;

@end
