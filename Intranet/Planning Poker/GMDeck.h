//
//  GMDeck.h
//
//  Created by Dawid Żakowski on 19/03/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"

@interface GMDeck : GMModel

extern NSString* const kGMDeckId;
extern NSString* const kGMDeckName;
extern NSString* const kGMDeckCards;

@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *cards;

@end
