//
//  RKRequest.m
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RKRequest.h"
#import "RestKitMappings.h"
#import <Foundation/NSJSONSerialization.h>

@implementation RKRequest

+ (RKRequest*)requestWithHTTPType:(RKRequestMethod)HTTPType
                       withMethod:(NSString*)method
                     withArgument:(RMGeneric*)argument
                withReturnedClass:(Class)returnedClass
            withCollectionPath:(NSString*)collectionPath
{
    RKRequest* request = [RKRequest new];
    
    request.HTTPType = HTTPType;
    request.method = method;
    request.argument = argument;
    request.returnedClass = returnedClass;
    request.collectionPath = collectionPath;
    
    return request;
}

+ (RKRequest*)users
{
    return [RKRequest requestWithHTTPType:RKRequestMethodGET
                               withMethod:@"api/users?full=1&inactive=1"
                             withArgument:nil
                        withReturnedClass:[RMUser class]
                       withCollectionPath:@"users"];
}

@end
