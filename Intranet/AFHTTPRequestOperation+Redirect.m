//
//  AFHTTPRequestOperation+Redirect.m
//  Intranet
//
//  Created by Dawid Żakowski on 30/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "AFHTTPRequestOperation+Redirect.h"

#define kLocationHeader @"Location"

#define kRedirectionUrlLogoutView @"intranet.stxnext.pl/auth/logout_view"

@implementation AFHTTPRequestOperation (Redirect)

- (void)blockRedirections
{
    [self setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse) {
        return (!redirectResponse) ? request : nil;
    }];
}

- (BOOL)redirectToLoginView
{
    if (self.response.statusCode == 302)
    {
        NSString *header = [self.response.allHeaderFields objectForKey:kLocationHeader];
        
        if ([header rangeOfString:kRedirectionUrlLogoutView].location != NSNotFound)
        {
            return YES;
        }
    }
    
    return NO;
}

@end
