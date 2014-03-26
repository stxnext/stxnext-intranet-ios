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
            start:(void (^)(void))startActions
              end:(void (^)(void))endActions
          success:(void (^)(void))success
          failure:(void (^)(FailureErrorType error))failure;

- (void)userIdWithStart:(void (^)(void))startActions
                    end:(void (^)(void))endActions
                success:(void (^)(NSString *userId))success
                failure:(void (^)(FailureErrorType error))failure;

- (void)userWithStart:(void (^)(void))startActions
                  end:(void (^)(void))endActions
              success:(void (^)(RMUser *user))success
              failure:(void (^)(RMUser *cachedUser, FailureErrorType error))failure;


- (void)loginUserWithStart:(void (^)(void))startActions
                       end:(void (^)(void))endActions
                   success:(void (^)(void))success
                   failure:(void (^)(FailureErrorType error))failure;

- (void)logoutUserWithStart:(void (^)(void))startActions
                        end:(void (^)(void))endActions
                    success:(void (^)(void))success
                    failure:(void (^)(FailureErrorType error))failure;

@end
