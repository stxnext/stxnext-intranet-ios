//
//  NSAsyncRequest.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CallbackType)(NSData *data, NSError *error);

@interface NSAsyncRequest : NSURLConnection<NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    BOOL hasStarted;
    BOOL operationFinished;
    BOOL allowRedirections;
	NSString *expectedType;
    NSMutableData *receivedData;
    NSHTTPURLResponse *serverResponse;
    CallbackType responseCallback;
}

+ (CallbackType)dataCallback:(void (^)(NSData *data, NSError *error))callback;

- (id)initWithRequest:(NSURLRequest *)request responseCallback:(CallbackType)completionBlock expectedType:(NSString*)type allowRedirections:(BOOL)redirect;
- (NSHTTPURLResponse*)serverResponse;

@end
