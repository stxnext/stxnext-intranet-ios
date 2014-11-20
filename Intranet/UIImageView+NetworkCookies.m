//
//  UIImageView+NetworkCookies.m
//  Intranet
//
//  Created by Dawid Żakowski on 31/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//
#include <sys/xattr.h>
#import "UIImageView+NetworkCookies.h"

static NSString *documentDirectoryPath;
@implementation UIImageView (NetworkCookies)

+ (NSString *)documentDirectoryPath
{
    if (!documentDirectoryPath)
    {
        documentDirectoryPath = [NSString stringWithString:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    }

    return documentDirectoryPath;
}

- (void)setImageUsingCookiesWithURL:(NSURL*)url forceRefresh:(BOOL)refresh
{
    NSString *pathComponent = [NSString stringWithFormat:@"/%@.png", [url lastPathComponent]];
    NSString *imagePath = [[self.class documentDirectoryPath] stringByAppendingPathComponent:pathComponent];
    
    NSURL *imageURL = [NSURL fileURLWithPath:imagePath];
    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
    UIImage *image = imageData ? [UIImage imageWithData:imageData] : nil;

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
