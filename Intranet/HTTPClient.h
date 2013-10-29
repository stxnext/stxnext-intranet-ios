//
//  HTTPClient.h
//  Intranet
//
//  Created by Dawid Żakowski on 29/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPClient : NSObject

+ (void)loadURLString:(NSString*)urlString
     withSuccessBlock:(void (^)(NSHTTPURLResponse* response, NSData* data))successBlock
     withFailureBlock:(void (^)(NSHTTPURLResponse* response, NSError* error))failureBlock;

@end
