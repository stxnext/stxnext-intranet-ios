//
//  GameManager.h
//  Intranet
//
//  Created by Dawid Żakowski on 27/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GameClient.h"

#define kGameManagerDefaultServerHostName @"bolt"
#define kGameManagerDefaultServerPort 9999

@class GameManager;

typedef void (^ManagerCallback)(GameManager* manager, NSError* error);

@interface GameManager : NSObject

@property (nonatomic, strong, readonly) NSString* serverHostName;
@property (nonatomic, readonly) NSInteger serverPort;
@property (nonatomic, readonly, getter = isGameInfoFetched) BOOL gameInfoFetched;
@property (nonatomic, strong, readonly) GMUser* user;
@property (nonatomic, strong, readonly) NSArray* availableSessions;
@property (nonatomic, strong, readonly) GMSession* activeSession;
@property (nonatomic, strong, readonly) NSArray* decks;
@property (nonatomic, strong, readonly) GameClient* client;
@property (nonatomic, strong, readonly) GameListener* listener;

- (id)initWithHostName:(NSString*)hostName withPort:(NSInteger)port;
- (void)fetchGameInfoForExternalUser:(RMUser*)user withCompletionHandler:(ManagerCallback)completionBlock;

+ (instancetype)defaultManager;

@end
