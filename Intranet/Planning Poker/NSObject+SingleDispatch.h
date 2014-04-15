//
//  NSObject+SingleDispatch.h
//  Intranet
//
//  Created by Dawid Żakowski on 15/04/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SingleDispatch)

- (BOOL)dispatchSingleUsingTag:(id)tag withBlock:(void (^)(dispatch_block_t callback))block;

@end
