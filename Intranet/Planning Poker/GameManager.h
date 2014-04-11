//
//  GameManager.h
//  Intranet
//
//  Created by Dawid Żakowski on 27/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GameClient.h"

#pragma mark Notification keys
#define kGameManagerNotificationSessionPeopleDidChange @"kGameManagerNotificationSessionPeopleDidChange"
#define kGameManagerNotificationEstimationRoundDidStart @"kGameManagerNotificationEstimationRoundDidStart"
#define kGameManagerNotificationTicketVoteReceived @"kGameManagerNotificationTicketVoteReceived"
#define kGameManagerNotificationEstimationRoundDidEnd @"kGameManagerNotificationEstimationRoundDidEnd"
#define kGameManagerNotificationSessionDidDisconnect @"kGameManagerNotificationSessionDidDisconnect"
#define kGameManagerNotificationSessionDidClose @"kGameManagerNotificationSessionDidClose"


#pragma mark Default server properties
#define kGameManagerDefaultServerHostName @"planing-poker.bolt.stxnext.pl"
#define kGameManagerDefaultServerPort 9999

#define kGameManagerUnusedClientDisconnectTimeout 15.0

#pragma mark Interfaces
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
@property (nonatomic, strong, readonly) GMTicket* activeTicket;
@property (nonatomic, strong, readonly) NSArray* decks;
@property (nonatomic, strong, readonly) GameClient* client;
@property (nonatomic, strong, readonly) GameListener* listener;

- (id)initWithHostName:(NSString*)hostName withPort:(NSInteger)port;

- (void)fetchGameInfoForExternalUser:(RMUser*)user withCompletionHandler:(ManagerCallback)completionBlock;
- (void)fetchActiveSessionUsersWithCompletionHandler:(ManagerCallback)completionBlock;
- (void)joinActiveSessionWithCompletionHandler:(ManagerCallback)completionBlock;
- (void)voteWithCard:(GMCard*)card inCurrentTicketWithCompletionHandler:(ManagerCallback)completionBlock;
- (void)startRoundWithTicket:(GMTicket*)ticket inActiveSessionWithCompletionHandler:(ManagerCallback)completionBlock;
- (void)stopRoundWithCompletionHandler:(ManagerCallback)completionBlock;
- (void)finishActiveSessionWithCompletionHandler:(ManagerCallback)completionBlock;
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
- (BOOL)isOwnedByCurrentUser;

@end

@interface GMTicket (LocalFetch)

- (NSDictionary*)votesDistribution;

@end