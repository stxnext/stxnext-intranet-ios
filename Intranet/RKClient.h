//
//  RKClient.h
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RestKitMappings.h"
#import "RKRequest.h"

@interface RKClient : NSObject

+ (void)performRequest:(RKRequest*)request
      withSuccessBlock:(void (^)(NSArray* result))successBlock
      withFailureBlock:(void (^)(NSError* error))failureBlock;

@end
