//
//  GMCard.h
//
//  Created by Dawid Żakowski on 19/03/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"

@interface GMCard : GMModel

extern NSString* const kGMCardId;
extern NSString* const kGMCardDisplayValue;

@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, strong) NSString *displayValue;

@end
