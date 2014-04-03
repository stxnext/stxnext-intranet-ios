//
//  NSString+RegExp.h
//  Intranet
//
//  Created by Dawid Żakowski on 01/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RegExp)

- (NSString*)substringWithRegexpPattern:(NSString*)pattern withAtomPath:(NSIndexPath*)atomPath;

@end

@interface NSIndexPath (RegExp)

+ (NSIndexPath*)indexPathForFirstMatchWithRange:(NSInteger)range;
+ (NSIndexPath*)indexPathForRange:(NSInteger)range inMatch:(NSInteger)match;

@property(nonatomic, readonly) NSInteger match;
@property(nonatomic, readonly) NSInteger range;

@end