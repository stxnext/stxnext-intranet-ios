//
//  NSString+MyRegex.h
//  Intranet
//
//  Created by Adam on 22.08.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyRegex)

- (NSString *)firstMatchWithRegex:(NSString *)regex error:(NSError **)error;

@end
