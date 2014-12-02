//
//  UIImageView+NetworkCookies.m
//  Intranet
//
//  Created by Dawid Żakowski on 31/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//
#include <sys/xattr.h>
#import "UIImageView+NetworkCookies.h"
#import "UIImageView+WebCache.h"

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

+ (NSMutableDictionary *)sharedCookies
{
    static NSMutableDictionary *_sharedCookies = nil;
    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        _sharedCookies = [[NSMutableDictionary alloc] init];
    });
    
    return _sharedCookies;
}

- (void)setImageUsingCookiesWithURL:(NSURL*)url forceRefresh:(BOOL)refresh
{
//    [self sd_setImageWithURL:[NSURL URLWithString:@"http://img1.wikia.nocookie.net/__cb20130611173955/4-fun/pl/images/8/8c/Kot_gladiator.jpg"]
//            placeholderImage:[UIImage imageNamed:@"tabbar_icon_me_big"]
//                     options:refresh ? SDWebImageRefreshCached : 0];
//    
//    return;
    
    
    NSString *pathComponent = [NSString stringWithFormat:@"/%@.png", [url lastPathComponent]];
    NSString *imagePath = [[self.class documentDirectoryPath] stringByAppendingPathComponent:pathComponent];
    
    NSURL *imageURL;
    UIImage *image = [[UIImageView sharedCookies] objectForKey:url];

    if (image)
    {
        [self performBlockOnMainThread:^{
            self.image = image;
        } afterDelay:0];
        return;
    }

    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath] )
    {
        imageURL = [NSURL fileURLWithPath:imagePath];
        image = [UIImage imageWithContentsOfFile:imagePath];
        [[UIImageView sharedCookies] setObject:image forKey:url];
    }
    
    if (image)
    {
        [self performBlockOnMainThread:^{
            self.image = image;
        } afterDelay:0];
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
            
            [[UIImageView sharedCookies] setObject:image forKey:url];
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
