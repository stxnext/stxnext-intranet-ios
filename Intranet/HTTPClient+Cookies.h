//
//  HTTPClient+Cookies.h
//  Intranet
//
//  Created by MK_STX on 31/10/13.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "HTTPClient.h"

@interface HTTPClient (Cookies)

- (BOOL)authCookiesPresent;
- (BOOL)addAuthCookiesToRequest:(NSMutableURLRequest *)request;
- (void)saveCookies:(NSArray *)cookies;
- (NSArray *)loadCookies;
- (void)deleteCookies;

@end
