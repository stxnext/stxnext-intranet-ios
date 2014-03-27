//
//  GMSession.h
//
//  Created by Dawid Żakowski on 19/03/2014
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMModel.h"

@interface GMSession : GMModel

extern NSString* const kGMSessionExpired;
extern NSString* const kGMSessionEndTime;
extern NSString* const kGMSessionDeckId;
extern NSString* const kGMSessionId;
extern NSString* const kGMSessionOwner;
extern NSString* const kGMSessionPlayers;
extern NSString* const kGMSessionStartTime;
extern NSString* const kGMSessionName;

@property (nonatomic, assign) BOOL expired;
@property (nonatomic, strong) NSNumber* endTime;
@property (nonatomic, strong) NSNumber* deckId;
@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, strong) GMUser *owner;
@property (nonatomic, strong) NSArray *players;
@property (nonatomic, strong) NSNumber* startTime;
@property (nonatomic, strong) NSString* name;

@end
