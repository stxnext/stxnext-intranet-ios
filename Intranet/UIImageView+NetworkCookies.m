//
//  UIImageView+NetworkCookies.m
//  Intranet
//
//  Created by Dawid Żakowski on 31/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "UIImageView+NetworkCookies.h"

@implementation UIImageView (NetworkCookies)

- (void)setImageUsingCookiesWithURL:(NSURL*)url
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [[HTTPClient sharedClient] addAuthCookiesToRequest:request];
    [self setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"tabbar_icon_me_big"] success:nil failure:nil];
}

@end
