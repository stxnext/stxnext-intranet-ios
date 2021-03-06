//
//  HTTPClient.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "HTTPClient.h"

#define kConfigAPIBaseURL @"https://intranet.stxnext.pl/"
//#define kConfigAPIBaseURL @"http://intranet-staging.bolt.stxnext.pl/"
//#define kConfigAPIBaseURL @"http://mobileapp.splash.stxnext.local/"

@implementation HTTPClient

static HTTPClient *_sharedClient = nil;

+ (HTTPClient *)sharedClient
{
    if (_sharedClient)
    {
        return _sharedClient;
    }
    
    NSURL *baseUrl = [NSURL URLWithString:kConfigAPIBaseURL];
    _sharedClient = [[HTTPClient alloc] initWithBaseURL:baseUrl];

    
    _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    
    [_sharedClient.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status)
        {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [_sharedClient.operationQueue setSuspended:NO];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [_sharedClient.operationQueue setSuspended:YES];
                break;
        }
    }];
    
    return _sharedClient;
}

#pragma mark Utility private methods

+ (NSString *)nameForMethod:(HTTPMethod)method
{
    switch (method)
    {
        case HTTPMethodGET:
            return @"GET";
            
        case HTTPMethodHEAD:
            return @"HEAD";
            
        case HTTPMethodPOST:
            return @"POST";
            
        case HTTPMethodPUT:
            return @"PUT";
            
        case HTTPMethodPATCH:
            return @"PATCH";
            
        case HTTPMethodDELETE:
            return @"DELETE";
            
        default:
            return nil;
    }
}

#pragma mark Client public methods

- (AFHTTPRequestOperation *)startOperation:(AFHTTPRequestOperation *)operation
                                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [self.operationQueue addOperation:operation];
    
    return operation;
}

- (AFHTTPRequestOperation *)requestOperationWithMethod:(HTTPMethod)method
                                               action:(NSString *)URLString
                                           parameters:(NSDictionary *)parameters
{
    [self.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        NSData *postData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:error];
        
        return [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
    }];
        
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:[HTTPClient nameForMethod:method]
                                                                   URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]
                                                                  parameters:parameters];
    
    
    [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [self addAuthCookiesToRequest:request];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:nil
                                                                      failure:nil];
    return operation;
}

- (AFHTTPRequestOperation *)requestOperationWithMethod:(HTTPMethod)method
                                                action:(NSString *)URLString
                                            parameters:(NSDictionary *)parameters
                             constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
{
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:[HTTPClient nameForMethod:method]
                                                                                URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString]
                                                                               parameters:parameters
                                                                constructingBodyWithBlock:block];
    
    [self addAuthCookiesToRequest:request];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request
                                                                      success:nil
                                                                      failure:nil];
    return operation;
}

@end
