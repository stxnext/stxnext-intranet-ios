//
//  RKRequest.h
//  Intranet
//
//  Created by Dawid Żakowski on 28/10/2013.
//  Copyright (c) 2013 STXNext. All rights reserved.
//

#import "RKObjectRequestOperation.h"
#import "RestKitMappings.h"

@interface RKRequest : RKObjectRequestOperation

@property (nonatomic) RKRequestMethod HTTPType;
@property (nonatomic, strong) NSString* method;
@property (nonatomic, strong) RMGeneric* argument;
@property (nonatomic, strong) Class returnedClass;
@property (nonatomic, strong) NSString* collectionPath;

+ (RKRequest*)users;

@end
