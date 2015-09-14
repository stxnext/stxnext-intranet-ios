//
//  RMUser+Me.h
//  Intranet
//
//  Created by Adam on 05.12.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "RMUser.h"

typedef enum
{
    UserLoginTypeNO = 0,
    UserLoginTypeTrue = 1,
    UserLoginTypeFalse = 2,
    UserLoginTypeError = 3
    
} UserLoginType;

@interface RMUser (Me)

+ (void)setUserLoggedType:(UserLoginType)userLoggedType;
+ (UserLoginType)userLoggedType;

+ (NSString *)myUserId;
+ (void)setMyUserId:(NSString *)userId;
+ (void)loadMeUserId:(void (^)(void))endAction;
+ (RMUser *)me;

@end
