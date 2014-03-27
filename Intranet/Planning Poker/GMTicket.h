//
//  GMTicket.h
//  Intranet
//
//  Created by Dawid Żakowski on 21/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"

@interface GMTicket : GMModel

extern NSString* const kGMTicketIdentifier;
extern NSString* const kGMTicketDisplayValue;
extern NSString* const kGMTicketVotes;
extern NSString* const kGMTicketSessionIdentifier;

@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, strong) NSString* displayValue;
@property (nonatomic, strong) NSArray* votes;
@property (nonatomic, strong) NSNumber* sessionIdentifier;

@end
