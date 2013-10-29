//
//  NSAsyncRequest.m
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "NSAsyncRequest.h"

@implementation NSAsyncRequest

+ (CallbackType)imageCallback:(void (^)(UIImage *image, NSError *error))callback
{
	return ^(NSData *data, NSError *error)
	{
		UIImage *image = nil;
		
		if (error == nil)
		{
			image = [UIImage imageWithData:data];
			error = (image != nil) ? nil : [NSError errorWithDomain:@"Resource"
											   localizedDescription:@"Response data invalid."
															   code:0];
		}
        
		return callback(image, error);
	};
}

+ (CallbackType)dataCallback:(void (^)(NSData *data, NSError *error))callback
{
	return ^(NSData *data, NSError *error)
	{
		return callback(data, error);
	};
}
- (id)initWithRequest:(NSURLRequest *)request responseCallback:(CallbackType)completionBlock expectedType:(NSString*)type allowRedirections:(BOOL)redirect
{
	self = [super initWithRequest:request delegate:self startImmediately:NO];
    
    if (self != nil)
    {
        hasStarted = NO;
        operationFinished = NO;
        allowRedirections = redirect;
        responseCallback = completionBlock;
		expectedType = type;
		receivedData = [NSMutableData data];
        
        [self scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    
    return self;
}

- (void)start
{
    [super start];
    
    hasStarted = YES;
}

- (void)cancel
{
    if (hasStarted)
        [super cancel];
    
    [self finishedWithData:nil andError:[NSError errorWithDomain:@"URL Connection"
                                            localizedDescription:@"Request cancelled."
                                                            code:0]];
}

- (NSHTTPURLResponse*)serverResponse
{
    return serverResponse;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self finishedWithData:nil andError:error];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response
{
    if (response)
        NSLog(@"Redirect from: %@\nRedirect to: %@", response.URL.absoluteString, request.URL.absoluteString);
    
    if (!response || allowRedirections)
        return request;
    
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    serverResponse = (NSHTTPURLResponse*)response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if ([serverResponse expectedContentLength] >= 0 && [receivedData length] != [serverResponse expectedContentLength])
        [self finishedWithData:receivedData andError:[NSError errorWithDomain:@"Remote resource"
														 localizedDescription:[NSString stringWithFormat:@"Invalid length (expected %d, received %d).", (int)serverResponse.expectedContentLength, receivedData.length]
																		 code:0]];
    
    else if (expectedType != nil && ![[serverResponse MIMEType] isEqualToString:expectedType])
        [self finishedWithData:receivedData andError:[NSError errorWithDomain:@"Remote resource"
														 localizedDescription:[NSString stringWithFormat:@"Invalid type (expected %@, received %@).", expectedType, serverResponse.MIMEType]
																		 code:0]];
	else
        [self finishedWithData:receivedData andError:nil];
}

- (void)finishedWithData:(NSData *)data andError:(NSError *)error
{
    @synchronized (self)
    {
        if (operationFinished)
            return;
        
        operationFinished = true;
    }
    
    responseCallback(data, error);
}

@end
