//
//  GameClient.h
//  Intranet
//
//  Created by Dawid Żakowski on 17/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "TCPClient.h"
#import "GMHeader.h"
#import "NSObject+JSONCast.h"

#pragma mark Communication message and its serialization
@protocol SerializationInterface <NSObject>

@required
- (NSData*)serialize;
+ (instancetype)deserialize:(NSData*)data;

@end

@interface GameMessage : NSObject <SerializationInterface>

typedef NSString* MessageType;
extern const MessageType MessageRequest;
extern const MessageType MessageResponse;
extern const MessageType MessageNotification;

typedef NSString* MessageAction;
extern const MessageAction ActionCardDecks;

@property (nonatomic, strong) MessageType type;
@property (nonatomic, strong) MessageAction action;
@property (nonatomic, strong) id payload;

- (BOOL)isValidResponse:(GameMessage*)responseCandidate;

@end

typedef void (^MessageCallback)(GameMessage* message, NSError* error);

@interface GameMessage ()

@property (nonatomic, strong) MessageType expectedResponseType;
@property (nonatomic, strong) MessageType expectedResponseAction;

@end

#pragma mark Message payload model
@interface GMModel (SerializationAdapter) <SerializationInterface>
@end

#pragma mark Network client
@interface GameClient : TCPClient
@end

#pragma mark Network client - requests
@interface GameClient (Requests)

- (void)getCardDecksWithCompletionHandler:(void (^)(NSArray* decks, NSError* error))completionBlock;

- (void)createUserWithEmail:(NSString*)email
                       name:(NSString*)name
                 externalId:(NSNumber*)externalId
          completionHandler:(void (^)(GMUser* user, NSError* error))completionBlock;

- (void)createSessionWithDeck:(GMDeck*)deck
                      players:(NSArray*)players
                        owner:(GMUser*)owner
                    startDate:(NSDate*)startDate
            completionHandler:(void (^)(GMSession* session, NSError* error))completionBlock;

- (void)getSessionsForUser:(GMUser*)user
         completionHandler:(void (^)(NSArray* sessions, NSError* error))completionBlock;

- (void)getPlayersForSession:(GMSession*)session
                        user:(GMUser*)user
           completionHandler:(void (^)(NSArray* players, NSError* error))completionBlock;

@end

#pragma mark Network listener
typedef NSInteger ListenerTag;
typedef NSInteger ListenerPriority;

const static ListenerPriority ListenerPriorityLow     = -100;
const static ListenerPriority ListenerPriorityDefault = 0;
const static ListenerPriority ListenerPriorityHigh    = 100;

@interface GameListener : TCPClient
{
    NSMutableDictionary* _listeningBlocks;
    ListenerTag _listeningCounter;
}

@property (nonatomic, readonly) BOOL isListeningForNotifications;

@end

@interface GameMessage ()

@property (nonatomic) BOOL isDoneExplicityHandling;

@end

#pragma mark Network listener - requests
@interface GameListener (Requests)

- (void)joinSession:(GMSession*)session
               user:(GMUser*)user
  completionHandler:(void (^)(GMUser* user, NSError* error))completionBlock;

- (void)newRoundWithTicketValue:(NSString*)ticketValue
                        session:(GMSession*)session
                           user:(GMUser*)user
              completionHandler:(void (^)(GMTicket* ticket, NSError* error))completionBlock;

- (void)newVoteWithCard:(GMCard*)card
                 ticket:(GMTicket*)ticket
                session:(GMSession*)session
                   user:(GMUser*)user
      completionHandler:(void (^)(GMVote* vote, NSError* error))completionBlock;

- (void)revealVotesForSession:(GMSession*)session
                         user:(GMUser*)user
            completionHandler:(void (^)(GMTicket* ticket, NSError* error))completionBlock;

- (void)finishSession:(GMSession*)session
                 user:(GMUser*)user
    completionHandler:(void (^)(GMSession* session, NSError* error))completionBlock;

- (ListenerTag)startListeningNotificationsWithPriority:(ListenerPriority)priority withCompletionHandler:(MessageCallback)completionBlock;

- (void)stopListeningNotificationsForTag:(ListenerTag)tag;

@end