//
//  HTTPClient+Cookies.m
//  Intranet
//
//  Created by MK_STX on 31/10/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "HTTPClient+Cookies.h"

#define kIntranetCookies @"intranetCookies"

@implementation HTTPClient (Cookies)

- (BOOL)authCookiesPresent
{
    return [self loadCookies].count > 0;
}

- (BOOL)addAuthCookiesToRequest:(NSMutableURLRequest *)request
{
    NSArray *cookies = [self loadCookies];
    
    if ([self authCookiesPresent])
    {
        NSDictionary *cookieHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
        NSString *key = [[cookieHeader allKeys] lastObject]; // key is @"Cookie"
        
        if (key != nil)
        {
            [request addValue:cookieHeader[key] forHTTPHeaderField:key];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)saveCookies:(NSArray *)cookies
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *cookiesProperties = [[NSMutableArray alloc] initWithCapacity:cookies.count];
    
    for (int i = 0; i < cookies.count; i++)
    {
        id cookie = cookies[i];
        if ([cookie isKindOfClass:[NSHTTPCookie class]])
        {
            NSDictionary *properties = ((NSHTTPCookie *)cookie).properties;
            if (properties != nil)
            {
                [cookiesProperties addObject:properties];
            }
        }
    }
    
    if (cookiesProperties.count > 0)
    {
        [defaults setObject:cookiesProperties forKey:kIntranetCookies];
        [defaults synchronize];
    }
}

- (NSArray *)loadCookies
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *cookiesPreferences = [defaults objectForKey:kIntranetCookies];
    NSMutableArray *cookies = nil;
    
    if (cookiesPreferences.count > 0)
    {
        cookies = [[NSMutableArray alloc] initWithCapacity:cookiesPreferences.count];
        
        for (NSDictionary *cookiePreferences in cookiesPreferences)
        {
            NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookiePreferences];
            [cookies addObject:cookie];
        }
    }
    
    return cookies;
}

- (void)deleteCookies
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:kIntranetCookies];
    [defaults synchronize];
}

@end
