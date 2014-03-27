//
//  RMUser+GMUserMapping.m
//  Intranet
//
//  Created by Dawid Żakowski on 20/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "RMUser+GMUserMapping.h"

@implementation RMUser (GMUserMapping)

- (GMUser*)mapToGMUser
{
    GMUser* user = [GMUser new];
    user.email = self.email;
    user.externalId = self.id;
    user.name = self.name;
    user.imageURL = self.imageURL;
    
    return user;
}

@end
