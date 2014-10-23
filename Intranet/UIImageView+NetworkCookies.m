//
//  UIImageView+NetworkCookies.m
//  Intranet
//
//  Created by Dawid Żakowski on 31/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//
#include <sys/xattr.h>
#import "UIImageView+NetworkCookies.h"

@implementation UIImageView (NetworkCookies)

- (void)setImageUsingCookiesWithURL:(NSURL*)url forceRefresh:(BOOL)refresh
{
    NSString *imagePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png", [url lastPathComponent]]];
    
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
    
    if (image)
    {
        self.image = image;
    }
    
    if (!image || refresh)
    {
        __weak __typeof(self)weakSelf = self;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [[HTTPClient sharedClient] addAuthCookiesToRequest:request];
        
        [self setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"tabbar_icon_me_big"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);

            [imageData writeToFile:imagePath atomically:YES];
            [weakSelf.class addSkipBackupAttributeToItemAtURL:imageURL];

            weakSelf.image = image;
        } failure:nil];
    }
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)fileURL
{
    // First ensure the file actually exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]])
    {
        return NO;
    }
    
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    
    if ([currSysVer isEqualToString:@"5.0.1"])
    {
        const char* filePath = [[fileURL path] fileSystemRepresentation];
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        
        return result == 0;
    }
    else if (&NSURLIsExcludedFromBackupKey)
    {
        NSError *error = nil;
        BOOL result = [fileURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
        
        if (result == NO)
        {
            return NO;
        }
        else
        {
            return YES;
        }
    }
    else
    {
        return YES;
    }
}

@end
