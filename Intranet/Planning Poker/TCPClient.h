//
//  TCPClient.h
//  Intranet
//
//  Created by Dawid Żakowski on 14/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

static const NSTimeInterval TCPClientNoTimeout = -1;
static const NSTimeInterval TCPClientDefaultTimeout = 5.0;

typedef long NSCounter;
typedef void (^ErrorCallback)(NSError* error);
typedef void (^DataCallback)(NSData* data, NSError* error);
typedef void (^DisconnectCallback)(NSError* error);

@interface TCPClient : NSObject <AsyncSocketDelegate>
{
    NSString* _hostName;
    unsigned int _port;
    AsyncSocket* _socket;
    NSCounter _writeCounter;
    NSMutableDictionary* _writeCompletionBlocks;
    NSCounter _readCounter;
    NSMutableDictionary* _readCompletionBlocks;
    ErrorCallback _connectionCompletionBlock;
    DisconnectCallback _disconnectCompletionBlock;
}

- (id)initWithHostName:(NSString*)hostName withPort:(unsigned int)port;
- (void)connectWithCompletionHandler:(ErrorCallback)completionBlock withDisconnectHandler:(DisconnectCallback)disconnectBlock;
- (BOOL)isConnected;
- (NSString*)localAddress;
- (void)terminateWithError:(NSError*)error;
- (void)disconnect;
- (void)write:(NSData*)data withComplectionHandler:(ErrorCallback)completionBlock;
- (void)readWithoutTimeoutWithCompletionHandler:(DataCallback)completionBlock;
- (void)readWithTimeoutWithCompletionHandler:(DataCallback)completionBlock;

+ (NSError*)abstractError;
+ (NSError*)timeoutError;

@property (nonatomic, strong) NSData* terminator;
@property (nonatomic) NSTimeInterval connectingTimeout;
@property (nonatomic) NSTimeInterval readingTimeout;

@end

@interface NSError (TCPClient)

- (BOOL)compareDomainAndCode:(NSError*)error;

@end