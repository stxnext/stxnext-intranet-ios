//
//  PFModels.h
//  Intranet
//
//  Created by Dawid Żakowski on 07/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFGame.h"
#import "PFTicket.h"
#import "PFRound.h"
#import "PFVote.h"
#import "PFPerson.h"

@interface PFModels : NSObject

+ (instancetype)singleton;
- (void)registerSubclasses;

@end
