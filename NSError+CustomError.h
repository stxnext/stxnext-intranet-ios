//
//  NSError+CustomError.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (CustomError)

+ (NSError*)errorWithDomain:(NSString*)domain localizedDescription:(NSString*)description code:(NSInteger)code;

@end
