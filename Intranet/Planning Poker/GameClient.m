//
//  GameClient.m
//  Intranet
//
//  Created by Dawid Żakowski on 17/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "GameClient.h"

@implementation GameMessage

#pragma mark Message descriptors
const NSString* MessageTypeField = @"type";
const NSString* MessageActionField = @"action";
const NSString* MessagePayloadField = @"payload";

const MessageType MessageRequest = @"request";
const MessageType MessageResponse = @"response";
const MessageType MessageNotification = @"notification";

const MessageAction ActionCardDecks = @"card_decks";
const MessageAction ActionCreateSession = @"create_session";
const MessageAction ActionDeleteSession = @"delete_session";
const MessageAction ActionPlayerHandshake = @"player_handshake";
const MessageAction ActionPlayerSessions = @"player_sessions";
const MessageAction ActionLivePlayers = @"player_in_live_session";
const MessageAction ActionJoinSession = @"join_session";
const MessageAction ActionNewTicketRound = @"new_ticket_round";
const MessageAction ActionSimpleVote = @"simple_vote";
const MessageAction ActionRevealVotes = @"reveal_votes";
const MessageAction ActionFinishSession = @"finish_session";

const MessageAction NotificationUserConnectionState = @"user_connection_state";
const MessageAction NotificationNextTicket = @"next_ticket";
const MessageAction NotificationUserVote = @"user_vote";
const MessageAction NotificationVotesRevealed = @"votes_revealed";
const MessageAction NotificationCloseSession = @"close_session";

#pragma mark Serialization
- (NSData*)serialize
{
    id payloadString = self.payload;
    
    NSMutableDictionary* messageDictionary = [NSMutableDictionary dictionary];
    [messageDictionary setValue:self.type forKey:@"type"];
    [messageDictionary setValue:self.action forKey:@"action"];
    [messageDictionary setValue:payloadString forKey:@"payload"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:nil];
    
    return jsonData;
}

+ (instancetype)deserialize:(NSData*)data
{
    id jsonObject = [data extractJson];
    
    if (!jsonObject)
        return nil;
    
    GameMessage* message = [GameMessage new];
    message.type = jsonObject[MessageTypeField];
    message.action = jsonObject[MessageActionField];
    message.payload = jsonObject[MessagePayloadField];
    
    return message;
}

- (BOOL)isValidResponse:(GameMessage*)responseCandidate
{
    MessageAction expectedAction = self.expectedResponseAction ?: self.action;
    MessageType expectedType = self.expectedResponseType ?: MessageResponse;
    
    if (![self.type isEqualToString:MessageRequest])
        return NO;
    
    if (![expectedType isEqualToString:responseCandidate.type])
        return NO;
    
    if (![expectedAction isEqualToString:responseCandidate.action])
        return NO;
    
    return YES;
}

@end

@implementation GMModel (SerializationAdapter)

- (NSData*)serialize
{
    NSDictionary* messageDictionary = [self dictionaryRepresentation];
    return [NSJSONSerialization dataWithJSONObject:messageDictionary options:0 error:nil];
}

+ (GMModel*)deserialize:(NSData*)data
{
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [self modelObjectWithDictionary:jsonObject];
}

@end

@implementation TCPClient (Requests)

- (void)sendRequest:(GameMessage*)request withCompletionHandler:(MessageCallback)completionBlock
{
    NSData* requestData = [request serialize];
    
    [self write:requestData withComplectionHandler:^(NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        [self readWithTimeoutWithCompletionHandler:^(NSData *data, NSError *error) {
            if (error)
            {
                completionBlock(nil, error);
                return;
            }
            
            GameMessage* response = [GameMessage deserialize:data];
            NSError* validationError = nil;
            
            if (![request isValidResponse:response])
                validationError = [TCPClient abstractError];
            
            completionBlock(response, validationError);
        }];
    }];
}

@end

@implementation GameClient

- (id)initWithHostName:(NSString *)hostName withPort:(unsigned int)port
{
    self = [super initWithHostName:hostName withPort:port];
    self.terminator = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    
    return self;
}

@end

@implementation GameClient (Requests)

- (void)getCardDecksWithCompletionHandler:(void (^)(NSArray* decks, NSError* error))completionBlock
{
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionCardDecks;
    request.payload = nil;
    
    [self sendRequest:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        NSArray* raw = [[response.payload extractJson:@"decks"] extractJson];
        NSArray* mapped = [raw mapToArrayOfModelsWithType:[GMDeck class]];
        
        completionBlock(mapped, nil);
    }];
}

- (void)createUserWithEmail:(NSString*)email
                       name:(NSString*)name
                 externalId:(NSNumber*)externalId
                   imageUrl:(NSString*)imageUrl
          completionHandler:(void (^)(GMUser* user, NSError* error))completionBlock
{
    GMUser* user = [GMUser new];
    user.email = email;
    user.name = name;
    user.externalId = externalId;
    user.imageURL = imageUrl;
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionPlayerHandshake;
    request.payload = @[ [user dictionaryRepresentation] ];
    
    [self sendRequest:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        GMUser* mapped = [raw mapToArrayOfModelsWithType:[GMUser class]].firstObject;
        
        completionBlock(mapped, nil);
    }];
}

- (void)createSessionWithName:(NSString*)name
                         deck:(GMDeck*)deck
                      players:(NSArray*)players
                        owner:(GMUser*)owner
                    startDate:(NSDate*)startDate
            completionHandler:(void (^)(GMSession* session, NSError* error))completionBlock
{
    GMSession* session = [GMSession new];
    session.name = name;
    session.startTime = [startDate mapToTime];
    session.players = players;
    session.owner = owner;
    session.deckId = deck.identifier;
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionCreateSession;
    request.payload = [session dictionaryRepresentation];
    
    [self sendRequest:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        GMSession* mapped = [raw mapToModelWithType:[GMSession class]];
        
        completionBlock(mapped, nil);
    }];
}

- (void)deleteSession:(GMSession*)session
                 user:(GMUser*)user
    completionHandler:(void (^)(NSError* error))completionBlock
{
    GMUserSession* userSession = [GMUserSession new];
    userSession.playerIdentifier = user.identifier;
    userSession.sessionIdentifier = session.identifier;
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionDeleteSession;
    request.payload = [userSession dictionaryRepresentation];
    
    [self sendRequest:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(error);
            return;
        }
        
        completionBlock(nil);
    }];
}

- (void)getSessionsForUser:(GMUser*)user
         completionHandler:(void (^)(NSArray* sessions, NSError* error))completionBlock
{
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionPlayerSessions;
    request.payload = [user dictionaryRepresentation];
    
    [self sendRequest:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        NSArray* mapped = [raw mapToArrayOfModelsWithType:[GMSession class]];
        
        completionBlock(mapped, nil);
    }];
}

- (void)getPlayersForSession:(GMSession*)session
                        user:(GMUser*)user
           completionHandler:(void (^)(NSArray* players, NSError* error))completionBlock
{
    GMUserSession* userSession = [GMUserSession new];
    userSession.playerIdentifier = user.identifier;
    userSession.sessionIdentifier = session.identifier;
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionLivePlayers;
    request.payload = [userSession dictionaryRepresentation];
    
    [self sendRequest:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        NSArray* mapped = [raw mapToArrayOfModelsWithType:[GMUser class]];
        
        completionBlock(mapped, nil);
    }];
}

@end

@implementation GameListener

- (id)initWithHostName:(NSString *)hostName withPort:(unsigned int)port
{
    self = [super initWithHostName:hostName withPort:port];
    
    if (self)
    {
        self.terminator = [@"\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        
        _listeningBlocks = [NSMutableDictionary dictionary];
        _listeningCounter = 0;
    }
    
    return self;
}

@end

@implementation GameListener (Notification)

- (void)sendNotification:(GameMessage*)notification withCompletionHandler:(MessageCallback)completionBlock
{
    NSData* notificationData = [notification serialize];
    
    [self write:notificationData withComplectionHandler:^(NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        __block BOOL done = NO;
        
        __block NSInteger listenerTag = [self startListeningNotificationsWithPriority:ListenerPriorityHigh withCompletionHandler:^(GameMessage *message, NSError *error) {
            if (done)
                return;
            
            if (error)
            {
                done = YES;
                
                completionBlock(nil, error);
                return;
            }
            
            if ([notification isValidResponse:message])
            {
                done = YES;
                
                [self stopListeningNotificationsForTag:listenerTag];
                completionBlock(message, nil);
            }
            
            message.isDoneExplicityHandling = YES;
        }];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.readingTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (done)
                return;
            
            done = YES;
            
            [self stopListeningNotificationsForTag:listenerTag];
            completionBlock(nil, [TCPClient timeoutError]);
        });
    }];
}

@end

@implementation GameListener (Requests)

- (void)joinSession:(GMSession*)session
               user:(GMUser*)user
  completionHandler:(void (^)(GMUser* user, NSError* error))completionBlock
{
    GMUserSession* userSession = [GMUserSession new];
    userSession.playerIdentifier = user.identifier;
    userSession.sessionIdentifier = session.identifier;
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionJoinSession;
    request.payload = [userSession dictionaryRepresentation];
    
    [self sendRequest:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
        GMUser* subject = [GMUser modelObjectWithDictionary:mapped.sessionSubject];
        
        completionBlock(subject, nil);
    }];
}

- (void)newRoundWithTicketValue:(NSString*)ticketValue
                        session:(GMSession*)session
                           user:(GMUser*)user
              completionHandler:(void (^)(GMTicket* ticket, NSError* error))completionBlock
{
    GMTicket* ticket = [GMTicket new];
    ticket.displayValue = ticketValue;
    ticket.sessionIdentifier = session.identifier;
    
    GMUserSession* userSession = [GMUserSession new];
    userSession.playerIdentifier = user.identifier;
    userSession.sessionIdentifier = session.identifier;
    userSession.sessionSubject = [ticket dictionaryRepresentation];
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionNewTicketRound;
    request.payload = [userSession dictionaryRepresentation];
    
    request.expectedResponseAction = NotificationNextTicket;
    request.expectedResponseType = MessageNotification;
    
    [self sendNotification:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
        GMTicket* subject = [GMTicket modelObjectWithDictionary:mapped.sessionSubject];
        
        completionBlock(subject, nil);
    }];
}

- (void)newVoteWithCard:(GMCard*)card
                 ticket:(GMTicket*)ticket
                session:(GMSession*)session
                   user:(GMUser*)user
      completionHandler:(void (^)(GMVote* vote, NSError* error))completionBlock
{
    GMVote* vote = [GMVote new];
    vote.card = card;
    vote.ticketIdentifier = ticket.identifier;
    
    GMUserSession* userSession = [GMUserSession new];
    userSession.playerIdentifier = user.identifier;
    userSession.sessionIdentifier = session.identifier;
    userSession.sessionSubject = [vote dictionaryRepresentation];
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionSimpleVote;
    request.payload = [userSession dictionaryRepresentation];
    
    request.expectedResponseAction = NotificationUserVote;
    request.expectedResponseType = MessageNotification;
    
    [self sendNotification:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
        GMVote* subject = [GMVote modelObjectWithDictionary:mapped.sessionSubject];
        
        completionBlock(subject, nil);
    }];
}

- (void)revealVotesForSession:(GMSession*)session
                       ticket:(GMTicket*)ticket
                         user:(GMUser*)user
            completionHandler:(void (^)(GMTicket* ticket, NSError* error))completionBlock
{
    GMUserSession* userSession = [GMUserSession new];
    userSession.playerIdentifier = user.identifier;
    userSession.sessionIdentifier = session.identifier;
    userSession.sessionSubject = ticket.identifier;
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionRevealVotes;
    request.payload = [userSession dictionaryRepresentation];
    
    request.expectedResponseAction = NotificationVotesRevealed;
    request.expectedResponseType = MessageNotification;
    
    [self sendNotification:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
        GMTicket* subject = [GMTicket modelObjectWithDictionary:mapped.sessionSubject];
        
        completionBlock(subject, nil);
    }];
}

- (void)finishSession:(GMSession*)session
                 user:(GMUser*)user
    completionHandler:(void (^)(GMSession* session, NSError* error))completionBlock
{
    GMUserSession* userSession = [GMUserSession new];
    userSession.playerIdentifier = user.identifier;
    userSession.sessionIdentifier = session.identifier;
    
    GameMessage* request = [GameMessage new];
    request.type = MessageRequest;
    request.action = ActionFinishSession;
    request.payload = [userSession dictionaryRepresentation];
    
    request.expectedResponseAction = NotificationCloseSession;
    request.expectedResponseType = MessageNotification;
    
    [self sendNotification:request withCompletionHandler:^(GameMessage *response, NSError *error) {
        if (error)
        {
            completionBlock(nil, error);
            return;
        }
        
        id raw = [response.payload extractJson];
        GMUserSession* mapped = [raw mapToModelWithType:[GMUserSession class]];
        GMSession* subject = [GMSession modelObjectWithDictionary:mapped.sessionSubject];
        
        completionBlock(subject, nil);
    }];
}

- (ListenerTag)startListeningNotificationsWithPriority:(ListenerPriority)priority withCompletionHandler:(MessageCallback)completionBlock
{
    ListenerTag listenerTag;
    
    @synchronized (self)
    {
        listenerTag = _listeningCounter++;
    }
    
    _listeningBlocks[@(listenerTag)] = @[ @( priority ), completionBlock ];
    
    NSComparator priorityComparator = ^NSComparisonResult(id obj1, id obj2) {
        if (![obj1 isKindOfClass:[NSArray class]] || ![obj2 isKindOfClass:[NSArray class]])
            return NSOrderedAscending;
        else
            return [obj2[0] compare:obj1[0]];
    };
    
    DataCallback readHandler;
    __block __weak DataCallback weakHandler;
    
    weakHandler = readHandler = ^(NSData *data, NSError *error) {
        if (error)
        {
            NSArray* blocks = [_listeningBlocks.allValues.copy sortedArrayUsingComparator:priorityComparator];
            
            for (NSArray* block in blocks)
            {
                MessageCallback callback = block[1];
                callback(nil, error);
            }
            
            [_listeningBlocks removeAllObjects];
            
            return;
        }
        
        [self readWithoutTimeoutWithCompletionHandler:weakHandler];
        
        GameMessage* response = [GameMessage deserialize:data];
        
        if (![response.type isEqualToString:MessageNotification])
            return;
        
        NSArray* blocks = [_listeningBlocks.allValues.copy sortedArrayUsingComparator:priorityComparator];
        
        for (NSArray* block in blocks)
        {
            MessageCallback callback = block[1];
            callback(response, nil);
            
            if (response.isDoneExplicityHandling)
                break;
        }
    };
    
    [self readWithoutTimeoutWithCompletionHandler:readHandler];
    
    return listenerTag;
}

- (void)stopListeningNotificationsForTag:(ListenerTag)tag
{
    [_listeningBlocks removeObjectForKey:@( tag )];
    
    if (_listeningBlocks.count == 0)
    {
        // We don't have any read handlers here, but read is still on. To end reading, one must close client's socket.
    }
}

@end
