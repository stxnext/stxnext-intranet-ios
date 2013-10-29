//
//  RKClient.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RKClient.h"

#define kApiBaseURL @"https://intranet.stxnext.pl/"

@implementation RKClient

+ (void)performRequest:(RKRequest*)request
      withSuccessBlock:(void (^)(NSArray* result))successBlock
      withFailureBlock:(void (^)(NSError* error))failureBlock
{
    // Prepare and send call
    NSURL* baseUrl = [NSURL URLWithString:kApiBaseURL];
    RKObjectManager* manager = [RKObjectManager managerWithBaseURL:baseUrl];
    
    if (request.argument)
    {
        [manager addRequestDescriptor:[RKRequestDescriptor requestDescriptorWithMapping:request.argument.requestMapping
                                                                            objectClass:request.argument.class
                                                                            rootKeyPath:nil
                                                                                 method:RKRequestMethodAny]];
    }
    
    if (request.returnedClass)
    {
        [manager addResponseDescriptor:[RKResponseDescriptor responseDescriptorWithMapping:[RMGeneric responseMappingForClass:request.returnedClass]
                                                                                    method:RKRequestMethodAny
                                                                               pathPattern:nil
                                                                                   keyPath:request.collectionPath
                                                                               statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)]];
    }
    
    void (^successDispatchBlock)(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) = ^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
    {
        if (successBlock)
            successBlock([mappingResult array]);
    };
    
    void (^failureDispatchBlock)(RKObjectRequestOperation *operation, NSError *error) = ^(RKObjectRequestOperation *operation, NSError *error)
    {
        if (failureBlock)
            failureBlock(error);
    };
    
    if (request.collectionPath)
    {
        switch (request.HTTPType)
        {
            case RKRequestMethodGET:  [manager getObjectsAtPath:request.method parameters:nil success:successDispatchBlock failure:failureDispatchBlock]; break;
        }
    }
    else
    {
        switch (request.HTTPType)
        {
            case RKRequestMethodGET:  [manager getObject:request.argument path:request.method parameters:nil success:successDispatchBlock failure:failureDispatchBlock]; break;
            case RKRequestMethodPOST: [manager postObject:request.argument path:request.method parameters:nil success:successDispatchBlock failure:failureDispatchBlock]; break;
        }
    }
}

@end
