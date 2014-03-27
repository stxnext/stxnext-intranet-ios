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

- (void)fetchGameInfoForExternalUser:(RMUser*)user withCompletionHandler:(ManagerCallback)completionBlock
{
    __block ManagerCallback callback = completionBlock;
    
    _client = [[GameClient alloc] initWithHostName:_serverHostName withPort:_serverPort];
    _listener = [[GameListener alloc] initWithHostName:_serverHostName withPort:_serverPort];
    
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

#pragma mark Singleton
+ (instancetype)defaultManager
{
    static id _singleton = nil;
    return _singleton ?: (_singleton = [[GameManager alloc] initWithHostName:kGameManagerDefaultServerHostName withPort:kGameManagerDefaultServerPort]);
}

@end
