//
//  AppDelegate+Settings.h
//  Intranet
//
//  Created by Adam on 12.02.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "AppDelegate.h"

typedef enum
{
    UserLoginTypeNO = 0,
    UserLoginTypeTrue = 1,
    UserLoginTypeFalse = 2,
    UserLoginTypeError = 3
    
}UserLoginType;

@interface AppDelegate (Settings)

- (void)setUserLoggedType:(UserLoginType)userLoggedType;
- (UserLoginType)userLoggedType;

- (void)setMyUserId:(NSString *)userId;
- (NSString *)myUserId;
- (void)myUserIdWithSuccess:(void (^)(NSString *userId))success
                         failure:(void (^)(void))failure;

@end
