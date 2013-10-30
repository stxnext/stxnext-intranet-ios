//
//  HTTPClient.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    HTTPMethodGET = 0,
    HTTPMethodHEAD,
    HTTPMethodPOST,
    HTTPMethodPUT,
    HTTPMethodPATCH,
    HTTPMethodDELETE,
} HTTPMethod;

@interface HTTPClient : AFHTTPRequestOperationManager

#pragma mark Client public methods

+ (HTTPClient*)sharedClient;

- (AFHTTPRequestOperation*)startOperation:(AFHTTPRequestOperation*)operation
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)requestOperationWithMethod:(HTTPMethod)method
                                                action:(NSString *)URLString
                                            parameters:(NSDictionary *)parameters;

- (AFHTTPRequestOperation *)requestOperationWithMethod:(HTTPMethod)method
                                                action:(NSString *)URLString
                                            parameters:(NSDictionary *)parameters
                             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block;

@end
