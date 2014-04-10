//
//  GameManager.m
//  Intranet
//
//  Created by Dawid Żakowski on 27/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GameManager.h"

@implementation GameManager

- (id)initWithHostName:(NSString*)hostName withPort:(NSInteger)port
{
    self = [super init];
    
    if (self)
    {
        _serverHostName = hostName;
        _serverPort = port;
        _gameInfoFetched = NO;
    }
    
    return self;
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
                           [[NSNotificationCenter defaultCenter] postNotificationName:kGameManagerNotificationSessionPeopleDidChange object:changedPeople];
                       
                       completionBlock(self, nil);
                   }];
    }];
}

- (void)joinActiveSessionWithCompletionHandler:(ManagerCallback)completionBlock withDisconnectHandler:(ManagerCallback)disconnectBlock
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
                [_listener disconnect];
                
                completionBlock(self, error);
                return;
            }
            
            [_listener startListeningNotificationsWithPriority:ListenerPriorityDefault withCompletionHandler:^(GameMessage *notification, NSError *error) {
                if (error)
                {
                    [_listener disconnect];
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
                        [[NSNotificationCenter defaultCenter] postNotificationName:kGameManagerNotificationSessionPeopleDidChange object:@[ sessionUser ]];
                    }
                }
            }];
            
            completionBlock(self, nil);
        }];
    } withDisconnectHandler:^(NSError *error) {
        _listener = nil;
        
        disconnectBlock(self, error);
    }];
}

- (void)voteWithCard:(GMCard*)card inCurrentTicketWithCompletionHandler:(ManagerCallback)completionBlock
{
    if (!_listener)
    {
        completionBlock(self, [TCPClient abstractError]);
        return;
    }
    
    [_listener newVoteWithCard:card ticket:_activeSession.tickets.firstObject session:_activeSession user:_user completionHandler:^(GMVote *vote, NSError *error) {
        if (error)
        {
            completionBlock(self, [TCPClient abstractError]);
            return;
        }
        
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

@end
