//
//  NSObject+JSONCast.h
//  Intranet
//
//  Created by Dawid Żakowski on 20/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSONCast)

- (id)extractJson;
- (id)extractJson:(NSString*)key;

@end
