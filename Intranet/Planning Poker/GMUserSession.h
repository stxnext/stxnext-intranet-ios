//
//  GMUserSession.h
//  Intranet
//
//  Created by Dawid Żakowski on 21/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"

@interface GMUserSession : GMModel

extern NSString* const kGUserSessionPlayerIdentifier;
extern NSString* const kGUserSessionSessionIdentifier;
extern NSString* const kGUserSessionSessionSubject;

@property (nonatomic, strong) NSNumber* playerIdentifier;
@property (nonatomic, strong) NSNumber* sessionIdentifier;
@property (nonatomic, strong) id sessionSubject;

@end
