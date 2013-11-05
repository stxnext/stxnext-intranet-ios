//
//  APIRequest.h
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIRequest : NSObject

+ (AFHTTPRequestOperation*)loginWithCode:(NSString*)code;
+ (AFHTTPRequestOperation*)getUsers;
+ (AFHTTPRequestOperation*)getPresence;
+ (AFHTTPRequestOperation*)logout;

@end
