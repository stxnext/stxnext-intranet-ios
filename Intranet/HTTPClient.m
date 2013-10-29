//
//  HTTPClient.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "HTTPClient.h"
#import "NSAsyncRequest.h"

#define kHTTPClientRequestTimeout 60.0

@implementation HTTPClient

+ (void)loadURLString:(NSString*)urlString
     withSuccessBlock:(void (^)(NSHTTPURLResponse* response, NSData* data))successBlock
     withFailureBlock:(void (^)(NSHTTPURLResponse* response, NSError* error))failureBlock
{
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:url
                                                  cachePolicy:NSURLRequestReloadIgnoringCacheData
                                              timeoutInterval:kHTTPClientRequestTimeout];
    
    __block NSAsyncRequest* asyncRequest = [[NSAsyncRequest alloc] initWithRequest:request
                                                                  responseCallback:^(NSData *data, NSError *error) {
                                                                      //[self logResponse:asyncRequest.serverResponse withData:data];
                                                                      
                                                                      if (error)
                                                                      {
                                                                          if (failureBlock)
                                                                              failureBlock(asyncRequest.serverResponse, error);
                                                                          
                                                                          return;
                                                                      }
                                                                      
                                                                      if (successBlock)
                                                                          successBlock(asyncRequest.serverResponse, data);
                                                                  } expectedType:nil
                                                                 allowRedirections:NO];
    
    [asyncRequest start];
}

+ (void)logResponse:(NSHTTPURLResponse*)response withData:(NSData*)data
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    //NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]));
    NSString* responseString = [[NSString alloc] initWithData:data encoding:encoding];
    
    NSLog(@"Called URL: %@\nResponse code: %d\nResponse headers: %@\nResponse data: %@",
          response.URL,
          response.statusCode,
          response.allHeaderFields,
          responseString);
}

@end
