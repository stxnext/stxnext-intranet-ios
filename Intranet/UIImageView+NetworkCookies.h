//
//  UIImageView+NetworkCookies.h
//  Intranet
//
//  Created by Dawid Żakowski on 31/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (NetworkCookies)

- (void)setImageUsingCookiesWithURL:(NSURL*)url forceRefresh:(BOOL)refresh;
+ (NSMutableDictionary *)sharedCookies;

@end
