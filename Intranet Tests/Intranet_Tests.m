//
//  Intranet_Tests.m
//  Intranet Tests
//
//  Created by Dawid Żakowski on 14/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface Intranet_Tests : XCTestCase

@end

@implementation Intranet_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_001_gameClient
{
    NSString* hostName = @"bolt";
    unsigned int port = 9999;
    
    GameClient* client = [[GameClient alloc] initWithHostName:hostName withPort:port];
    GameListener* listener = [[GameListener alloc] initWithHostName:hostName withPort:port];
    
    [client connectWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            return;
        }
        
        [client createUserWithEmail:@"user@example.com" name:@"Test User" externalId:@(50) imageUrl:@"http://" completionHandler:^(GMUser *user, NSError *error) {
            if (error)
            {
                [client disconnect];
                return;
            }
            
            [client getCardDecksWithCompletionHandler:^(NSArray *decks, NSError *error) {
                if (error)
                {
                    [client disconnect];
                    return;
                }
                
                __block GMUser* currentUser = user;
                GMDeck* deck = decks.firstObject;
                GMUser* owner = user;
                NSArray* players = @[ user ];
                NSDate* date = [NSDate dateWithTimeIntervalSinceNow:60*60*5];
                
                [client createSessionWithName:@"Test Session" deck:deck players:players owner:owner startDate:date completionHandler:^(GMSession *session, NSError *error) {
                    if (error)
                    {
                        [client disconnect];
                        return;
                    }
                    
                    [client getSessionsForUser:currentUser completionHandler:^(NSArray *sessions, NSError *error) {
                        if (error)
                        {
                            [client disconnect];
                            return;
                        }
                        
                        GMSession* session = sessions.lastObject;
                        
                        [listener connectWithCompletionHandler:^(NSError *error) {
                            if (error)
                            {
                                return;
                            }
                            
                            [listener joinSession:session user:currentUser completionHandler:^(GMUser* user, NSError *error) {
                                if (error)
                                {
                                    [listener disconnect];
                                    return;
                                }
                                
                                [client getPlayersForSession:session user:user completionHandler:^(NSArray *players, NSError *error) {
                                    if (error)
                                    {
                                        [listener disconnect];
                                        return;
                                    }
                                    
                                    [listener startListeningNotificationsWithPriority:ListenerPriorityDefault withCompletionHandler:^(GameMessage *notification, NSError *error) {
                                        if (error)
                                        {
                                            [listener disconnect];
                                            return;
                                        }
                                    }];
                                    
                                    [listener newRoundWithTicketValue:@"Test Ticket" session:session user:currentUser completionHandler:^(GMTicket* ticket, NSError *error) {
                                        if (error)
                                        {
                                            [listener disconnect];
                                            return;
                                        }
                                        
                                        GMCard* card = deck.cards.firstObject;
                                        
                                        [listener newVoteWithCard:card ticket:ticket session:session user:currentUser completionHandler:^(GMVote *vote, NSError *error) {
                                            if (error)
                                            {
                                                [listener disconnect];
                                                return;
                                            }
                                            
                                            [listener revealVotesForSession:session user:currentUser completionHandler:^(GMTicket *ticket, NSError *error) {
                                                if (error)
                                                {
                                                    [listener disconnect];
                                                    return;
                                                }
                                                
                                                [listener finishSession:session user:currentUser completionHandler:^(GMSession *session, NSError *error) {
                                                    [listener disconnect];
                                                    
                                                    [self notify:XCTAsyncTestCaseStatusSucceeded];
                                                }];
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        } withDisconnectHandler:^(NSError *error) {
                            [client disconnect];
                        }];
                    }];
                }];
            }];
        }];
    } withDisconnectHandler:^(NSError *error) {
        [self notify:XCTAsyncTestCaseStatusFailed];
    }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:30.0];
}

@end
