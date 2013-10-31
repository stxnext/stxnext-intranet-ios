//
//  APIRequest.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "APIRequest.h"
#import "HTTPClient.h"
#import "AFHTTPRequestOperation+Redirect.h"

@implementation APIRequest

+ (AFHTTPRequestOperation*)loginWithCode:(NSString*)code
{
    AFHTTPRequestOperation* request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodHEAD
                                                                                     action:[NSString stringWithFormat:@"auth/callback?code=%@", code]
                                                                                 parameters:nil];
    
    [request blockRedirections];
    
    return request;
}

+ (AFHTTPRequestOperation*)getUsers
{
    AFHTTPRequestOperation* request = [[HTTPClient sharedClient] requestOperationWithMethod:HTTPMethodGET
                                                                                     action:@"api/users?full=1&inactive=1"
                                                                                 parameters:nil];
    [request blockRedirections];
    
    return request;
}

@end
