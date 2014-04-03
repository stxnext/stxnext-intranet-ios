//
//  GameManager.h
//  Intranet
//
//  Created by Dawid Żakowski on 27/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GameClient.h"

#define kGameManagerDefaultServerHostName @"10.93.1.193"
//#define kGameManagerDefaultServerHostName @"planing-poker.bolt.stxnext.pl"
#define kGameManagerDefaultServerPort 9999

#define kGameManagerUnusedClientDisconnectTimeout 15.0

@class GameManager;

typedef void (^ManagerCallback)(GameManager* manager, NSError* error);

@interface GameManager : NSObject
{
    NSInteger _clientRetainCount;
}

@property (nonatomic, strong, readonly) NSString* serverHostName;
@property (nonatomic, readonly) NSInteger serverPort;
@property (nonatomic, readonly, getter = isGameInfoFetched) BOOL gameInfoFetched;
@property (nonatomic, strong, readonly) GMUser* user;
@property (nonatomic, strong, readonly) NSArray* availableSessions;
@property (nonatomic, strong) GMSession* activeSession;
@property (nonatomic, strong, readonly) NSArray* decks;
@property (nonatomic, strong, readonly) GameClient* client;
@property (nonatomic, strong, readonly) GameListener* listener;

- (id)initWithHostName:(NSString*)hostName withPort:(NSInteger)port;

- (void)fetchGameInfoForExternalUser:(RMUser*)user withCompletionHandler:(ManagerCallback)completionBlock;
- (void)fetchActiveSessionUsersWithCompletionHandler:(ManagerCallback)completionBlock;
- (void)joinActiveSessionWithCompletionHandler:(ManagerCallback)completionBlock withDisconnectHandler:(ManagerCallback)disconnectBlock;
- (void)leaveActiveSession;

- (void)connectedClientWithCompletionHandler:(void (^)(GameClient* client, NSError* error, dispatch_block_t disconnectCallback))completionBlock;

- (NSArray*)ownerSessions;
- (NSArray*)playerSessions;

+ (instancetype)defaultManager;

@end

@interface GMSession (LocalFetch)

- (GMDeck*)deck;
- (NSArray*)people;
- (GMUser*)personFromExternalUser:(RMUser*)user;

@end