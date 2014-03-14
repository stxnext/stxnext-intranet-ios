//
//  TCPClient.h
//  Intranet
//
//  Created by Dawid Żakowski on 14/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef long NSCounter;
typedef void (^ErrorCallback)(NSError* error);
typedef void (^DataCallback)(NSData* data, NSError* error);

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
}

- (id)initWithHostName:(NSString*)hostName withPort:(unsigned int)port;
- (void)connectWithCompletionHandler:(ErrorCallback)completionBlock;
- (void)disconnect;
- (void)write:(NSData*)data withComplectionHandler:(ErrorCallback)completionBlock;
- (void)readWithCompletionHandler:(DataCallback)completionBlock;

@end

/*@interface TCPClientInline : TCPClient
{
    void (^_eventBlock)(NSData* inputData, NSError* error);
}

+ (TCPClientInline*)connectToHostWithName:(NSString*)hostName withPort:(unsigned int)port usingEventHandler:(void (^)(NSData* inputData, NSError* error))eventBlock;

@end*/