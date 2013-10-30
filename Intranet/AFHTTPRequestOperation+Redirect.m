//
//  AFHTTPRequestOperation+Redirect.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AFHTTPRequestOperation+Redirect.h"

@implementation AFHTTPRequestOperation (Redirect)

- (void)blockRedirections
{
    [self setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        return (!redirectResponse) ? request : nil;
    }];
}

@end
