//
//  TCPClient.m
//  Intranet
//
//  Created by Dawid Żakowski on 14/03/2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import "TCPClient.h"

@implementation TCPClient

- (id)initWithHostName:(NSString*)hostName withPort:(unsigned int)port
{
    self = [super init];
    
    if (self)
    {
        _hostName = hostName;
        _port = port;
        _writeCounter = 0;
        _writeCompletionBlocks = [NSMutableDictionary dictionary];
        _readCounter = 0;
        _readCompletionBlocks = [NSMutableDictionary dictionary];
        _socket = [[AsyncSocket alloc] initWithDelegate:self];
    }
    
    return self;
}

#pragma mark Connecting
- (void)connectWithCompletionHandler:(ErrorCallback)completionBlock
{
    NSError* error;
    
    if (![_socket connectToHost:_hostName onPort:_port error:&error])
    {
        if (completionBlock)
            completionBlock(error);
        
        return;
    }
    
    _connectionCompletionBlock = completionBlock;
}

- (void)connectionDidBegin
{
    if (_connectionCompletionBlock)
        _connectionCompletionBlock(nil);
    
    _connectionCompletionBlock = nil;
}

- (void)connectionDidEnd:(NSError*)error
{
    if (_connectionCompletionBlock)
    {
        _connectionCompletionBlock(error ?: [TCPClient abstractError]);
        _connectionCompletionBlock = nil;
    }
    

    for (NSNumber* tag in _writeCompletionBlocks.allKeys)
        [self writingDidEnd:tag.longValue withError:[TCPClient abstractError]];
}

- (void)disconnect
{
    _socket.delegate = nil;
    [_socket disconnect];
    _socket = nil;
    
    [self connectionDidEnd:nil];
}

#pragma mark Writing
- (void)write:(NSData*)data withComplectionHandler:(ErrorCallback)completionBlock
{
    @synchronized (self)
    {
        _writeCompletionBlocks[@(_writeCounter)] = completionBlock;
        [_socket writeData:data withTimeout:-1 tag:_writeCounter];
        
        _writeCounter ++;
    }
}

- (void)writingDidEnd:(long)tag withError:(NSError*)error
{
    ErrorCallback block = _writeCompletionBlocks[@(tag)];
    
    if (block)
        block(error);
    
    [_writeCompletionBlocks removeObjectForKey:@(tag)];
}

#pragma mark Reading
- (void)readWithCompletionHandler:(DataCallback)completionBlock
{
    @synchronized (self)
    {
        _readCompletionBlocks[@(_readCounter)] = completionBlock;
        [_socket readDataWithTimeout:-1 tag:_readCounter];
        
        _readCounter ++;
    }
}

- (void)readingDidEnd:(long)tag withData:(NSData*)data withError:(NSError*)error
{
    DataCallback block = _readCompletionBlocks[@(tag)];
    
    if (block)
        block(data, error);
    
    [_readCompletionBlocks removeObjectForKey:@(tag)];
}

#pragma mark Errors
+ (NSError*)abstractError
{
    static NSError* error = nil;
    return error ?: (error = [NSError errorWithDomain:@"TCPClient" code:-1 userInfo:nil]);
}

#pragma mark AsyncSocket delegate
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    [self connectionDidEnd:err];
}

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    [self connectionDidEnd:nil];
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    [self connectionDidBegin];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self readingDidEnd:tag withData:data withError:nil];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self writingDidEnd:tag withError:nil];
}

/*- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    
}

- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    
}

- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    
}

- (void)onSocketDidSecure:(AsyncSocket *)sock
{
    
}

- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket
{
    
}

- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
  shouldTimeoutReadWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length
{
    
}

- (NSTimeInterval)onSocket:(AsyncSocket *)sock
 shouldTimeoutWriteWithTag:(long)tag
                   elapsed:(NSTimeInterval)elapsed
                 bytesDone:(NSUInteger)length
{
    
}*/

@end

/*@implementation TCPClientInline

- (id)initWithHostName:(NSString*)hostName withPort:(unsigned int)port withEventBlock:(void (^)(NSData* inputData, NSError* error))eventBlock
{
    //self = [super initWithHostName:hostName withPort:port withDelegate:self];
    
    if (self)
    {
        _eventBlock = eventBlock;
    }
    
    return self;
}

+ (TCPClientInline*)connectToHostWithName:(NSString*)hostName withPort:(unsigned int)port usingEventHandler:(void (^)(NSData* inputData, NSError* error))eventBlock
{
    return [[TCPClientInline alloc] initWithHostName:hostName withPort:port withEventBlock:eventBlock];
}

#pragma mark TCPClient delegate
- (void)TCPClient:(TCPClient*)client didReadData:(NSData*)data
{
    if (_eventBlock)
        _eventBlock(data, nil);
}

@end*/

