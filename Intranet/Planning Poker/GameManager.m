//
//  GameManager.m
//  Intranet
//
//  Created by Dawid Żakowski on 27/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GameManager.h"
#import "Reachability.h"
#import "NSNotificationCenter+NSOperationQueue.h"

@implementation GameManager

- (id)initWithHostName:(NSString*)hostName withPort:(NSInteger)port
{
    self = [super init];
    
    if (self)
    {
        _serverHostName = hostName;
        _serverPort = port;
        _gameInfoFetched = NO;
        
        // Reachability
        _reachability = [InternetReachability reachabilityWithHostName:hostName];
        [_reachability startNotifier];
    }
    
    return self;
}

#pragma mark - Notifications

- (void)setNotificationsSuspended:(BOOL)suspend
{
    [[NSNotificationCenter defaultCenter].notificationQueue setSuspended:suspend];
}

#pragma mark - Client strategy

- (void)fetchGameInfoForExternalUser:(RMUser*)user withCompletionHandler:(ManagerCallback)completionBlock
{
    __block ManagerCallback callback = completionBlock;
    
    _client = [[GameClient alloc] initWithHostName:_serverHostName withPort:_serverPort];
    
    [_client connectWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            return;
        }
        
        [_client createUserWithEmail:user.email name:user.name externalId:user.id imageUrl:user.imageURL completionHandler:^(GMUser *user, NSError *error) {
            if (error)
            {
                [_client disconnect];
                return;
            }
            
            _user = user;
            
            [_client getCardDecksWithCompletionHandler:^(NSArray *decks, NSError *error) {
                if (error)
                {
                    [_client disconnect];
                    return;
                }
                
                _decks = decks;
                
                [_client getSessionsForUser:_user completionHandler:^(NSArray *sessions, NSError *error) {
                    if (error)
                    {
                        [_client disconnect];
                        return;
                    }
                    
                    _availableSessions = sessions;
                    
                    if (callback)
                    {
                        ManagerCallback block = callback;
                        callback = nil;
                        
                        [_client disconnect];
                        _gameInfoFetched = YES;
                        
                        block(self, nil);
                    }
                }];
            }];
        }];
    } withDisconnectHandler:^(NSError *error) {
        if (callback)
        {
            ManagerCallback block = callback;
            callback = nil;
            
            _gameInfoFetched = NO;
            
            block(nil, error);
        }
    }];
}

- (void)fetchActiveSessionUsersWithCompletionHandler:(ManagerCallback)completionBlock
{
    [self connectedClientWithCompletionHandler:^(GameClient *client, NSError* error, dispatch_block_t disconnectCallback) {
        if (error)
        {
            completionBlock(self, error);
            return;
        }
        
        [client getPlayersForSession:_activeSession
                                user:_user
                   completionHandler:^(NSArray *players, NSError *error) {
                       disconnectCallback();
                       
                       if (error)
                       {
                           completionBlock(self, error);
                           return;
                       }
                       
                       NSMutableArray* changedPeople = [NSMutableArray array];
                       
                       for (GMUser* person in _activeSession.people)
                       {
                           BOOL newActive = [players containsObject:person];
                           
                           if (person.active != newActive)
                           {
                               person.active = [players containsObject:person];
                               [changedPeople addObject:person];
                           }
                       }
                       
                       if (changedPeople.count > 0)
                           [[NSNotificationCenter defaultCenter] enqueueNotificationName:kGameManagerNotificationSessionPeopleDidChange object:changedPeople];
                       
                       completionBlock(self, nil);
                   }];
    }];
}

- (void)joinActiveSessionWithCompletionHandler:(ManagerCallback)completionBlock
{
    if (_listener)
    {
        completionBlock(self, nil);
        return;
    }
    
    _listener = [[GameListener alloc] initWithHostName:_serverHostName withPort:_serverPort];
    
    [_listener connectWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            completionBlock(self, error);
            return;
        }
        
        [_listener joinSession:_activeSession user:_user completionHandler:^(GMUser* user, NSError *error) {
            if (error)
            {
                completionBlock(self, error);
                return;
            }
            
            [_listener startListeningNotificationsWithPriority:ListenerPriorityDefault withCompletionHandler:^(GameMessage *notification, NSError *error) {
                if (error)
                {
                    return;
                }
                
                if ([notification.action isEqualToString:NotificationUserConnectionState])
                {
                    id raw = [notification.payload extractJson];
                    GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
                    GMUser* subject = [GMUser modelObjectWithDictionary:mapped.sessionSubject];
                    
                    GMUser* sessionUser = [_activeSession.people filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", subject.identifier]].firstObject;
                    
                    if (sessionUser.active != subject.active)
                    {
                        sessionUser.active = subject.active;
                        [[NSNotificationCenter defaultCenter] enqueueNotificationName:kGameManagerNotificationSessionPeopleDidChange object:@[ sessionUser ]];
                    }
                }
                else if ([notification.action isEqualToString:NotificationNextTicket])
                {
                    id raw = [notification.payload extractJson];
                    GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
                    GMTicket* subject = [GMTicket modelObjectWithDictionary:mapped.sessionSubject];
                    
                    _activeTicket = subject;
                    
                    [[NSNotificationCenter defaultCenter] enqueueNotificationName:kGameManagerNotificationEstimationRoundDidStart object:subject];
                }
                else if ([notification.action isEqualToString:NotificationUserVote])
                {
                    id raw = [notification.payload extractJson];
                    GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
                    GMVote* subject = [GMVote modelObjectWithDictionary:mapped.sessionSubject];
                    
                    @synchronized (_activeTicket)
                    {
                        NSMutableArray* votes = _activeTicket.votes.mutableCopy;
                        
                        NSArray* existingVotes = [votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"player = %@", subject.player]];
                        [votes removeObjectsInArray:existingVotes];
                        
                        [votes addObject:subject];
                        
                        _activeTicket.votes = votes;
                    }
                    
                    [[NSNotificationCenter defaultCenter] enqueueNotificationName:kGameManagerNotificationTicketVoteReceived object:subject];
                }
                else if ([notification.action isEqualToString:NotificationVotesRevealed])
                {
                    id raw = [notification.payload extractJson];
                    GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
                    GMTicket* subject = [GMTicket modelObjectWithDictionary:mapped.sessionSubject];
                    
                    _activeTicket = subject;
                    
                    [[NSNotificationCenter defaultCenter] enqueueNotificationName:kGameManagerNotificationEstimationRoundDidEnd object:subject];
                }
                else if ([notification.action isEqualToString:NotificationCloseSession])
                {
                    id raw = [notification.payload extractJson];
                    GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
                    GMSession* subject = [GMSession modelObjectWithDictionary:mapped.sessionSubject];
                    
                    _activeSession = subject;
                    
                    [[NSNotificationCenter defaultCenter] enqueueNotificationName:kGameManagerNotificationSessionDidClose object:subject];
                }
            }];
            
            [self fetchActiveSessionUsersWithCompletionHandler:^(GameManager *manager, NSError *error) {
                if (error)
                {
                    [_listener terminateWithError:error];
                    
                    completionBlock(self, error);
                    return;
                }
                
                completionBlock(self, nil);
            }];
        }];
    } withDisconnectHandler:^(NSError *error) {
        _listener = nil;
        _activeTicket = nil;
        
        [[NSNotificationCenter defaultCenter] enqueueNotificationName:kGameManagerNotificationSessionDidDisconnect object:error];
    }];
}

- (void)voteWithCard:(GMCard*)card inCurrentTicketWithCompletionHandler:(ManagerCallback)completionBlock
{
    if (!_listener)
    {
        completionBlock(self, [TCPClient abstractError]);
        return;
    }
    
    [_listener newVoteWithCard:card ticket:_activeTicket session:_activeSession user:_user completionHandler:^(GMVote *vote, NSError *error) {
        if (error)
        {
            completionBlock(self, error);
            return;
        }
        
        completionBlock(self, nil);
    }];
}

- (void)startRoundWithTicket:(GMTicket*)ticket inActiveSessionWithCompletionHandler:(ManagerCallback)completionBlock
{
    if (!_listener)
    {
        completionBlock(self, [TCPClient abstractError]);
        return;
    }
    
    _activeTicket = ticket;
    
    [_listener newRoundWithTicketValue:ticket.displayValue session:_activeSession user:_user completionHandler:^(GMTicket *ticket, NSError *error) {
        if (error)
        {
            completionBlock(self, error);
            return;
        }
        
        _activeTicket = ticket;
        
        completionBlock(self, nil);
    }];
}

- (void)stopRoundWithCompletionHandler:(ManagerCallback)completionBlock
{
    if (!_listener)
    {
        completionBlock(self, [TCPClient abstractError]);
        return;
    }
    
    [_listener revealVotesForSession:_activeSession ticket:_activeTicket user:_user completionHandler:^(GMTicket *ticket, NSError *error) {
        if (error)
        {
            completionBlock(self, error);
            return;
        }
        
        _activeTicket = ticket;
        
        completionBlock(self, nil);
    }];
}

- (void)finishActiveSessionWithCompletionHandler:(ManagerCallback)completionBlock
{
    if (!_listener)
    {
        completionBlock(self, [TCPClient abstractError]);
        return;
    }
    
    [_listener finishSession:_activeSession user:_user completionHandler:^(GMSession *session, NSError *error) {
        if (error)
        {
            completionBlock(self, error);
            return;
        }
        
        [self leaveActiveSession];
        
        completionBlock(self, nil);
    }];
}

- (void)leaveActiveSession
{
    [_listener disconnect];
    _listener = nil;
}

#pragma mark Convenience methods
- (void)connectedClientWithCompletionHandler:(void (^)(GameClient* client, NSError* error, dispatch_block_t disconnectCallback))completionBlock
{
    dispatch_block_t disconnectCallback = ^{
        _clientRetainCount--;
        
        if (_clientRetainCount == 0)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kGameManagerUnusedClientDisconnectTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (_clientRetainCount == 0)
                    [_client disconnect];
            });
        }
    };
    
    if (_client.isConnected)
    {
        _clientRetainCount++;
        
        completionBlock(_client, nil, disconnectCallback);
        return;
    }
    
    [_client connectWithCompletionHandler:^(NSError *error) {
        _clientRetainCount = 0;
        
        if (error)
        {
            completionBlock(nil, error, disconnectCallback);
            return;
        }
        
        _clientRetainCount++;
        
        completionBlock(_client, nil, disconnectCallback);
    } withDisconnectHandler:^(NSError *error) {
        _clientRetainCount = 0;
    }];
}

- (NSArray*)ownerSessions
{
    return [[_availableSessions
             filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"owner.identifier == %@", self.user.identifier]]
            sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ]];
}

- (NSArray*)playerSessions
{
    return [[_availableSessions
            filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ANY players.identifier == %@ AND NOT (owner.identifier == %@)", self.user.identifier, self.user.identifier]]
sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES] ]];
}

#pragma mark Singleton
+ (instancetype)defaultManager
{
    static id _singleton = nil;
    return _singleton ?: (_singleton = [[GameManager alloc] initWithHostName:kGameManagerDefaultServerHostName withPort:kGameManagerDefaultServerPort]);
}

@end

@implementation GMSession (LocalFetch)

- (GMDeck*)deck
{
    return [[GameManager defaultManager].decks filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"identifier = %@", self.deckId]].firstObject;
}

- (NSArray*)people
{
    NSMutableArray* users = self.players.mutableCopy;
    
    if (![self.players containsObject:self.owner])
        [users addObject:self.owner];
    
    return [users sortedArrayUsingDescriptors:@[ [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
}

- (GMUser*)personFromExternalUser:(RMUser*)user
{
    return [self.people filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"externalId = %@", user.id]].firstObject;
}

- (BOOL)isOwnedByCurrentUser
{
    return [self.owner isEqual:[GameManager defaultManager].user];
}

@end

@implementation GMTicket (LocalFetch)

- (NSDictionary*)votesDistribution
{
    NSMutableDictionary* distribution = [NSMutableDictionary dictionary];
    
    NSArray* cards = [GameManager defaultManager].activeSession.deck.cards;
    NSArray* votes = self.votes;
    
    for (GMCard* card in cards)
        distribution[card] = [NSMutableArray array];
    
    for (GMVote* vote in votes)
    {
        distribution[vote.card] = distribution[vote.card] ?: [NSMutableArray array];
        [distribution[vote.card] addObject:vote.player];
    }
    
    return distribution;
}

@end
