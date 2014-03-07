//
//  RMUser+CurrentUser.h
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "RMUser.h"

@interface RMUser (CurrentUser)

+ (RMUser*)loadCurrentUserFromDatabase;
+ (void)loadCurrentUserWithCompletionHandler:(void (^)(RMUser* user, NSError* error))completionBlock;

@end
