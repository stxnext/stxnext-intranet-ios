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
        _socket = nil;
        _connectingTimeout = TCPClientDefaultTimeout;
        _readingTimeout = TCPClientDefaultTimeout;
    }
    
    return self;
}

#pragma mark Connecting
- (void)connectWithCompletionHandler:(ErrorCallback)completionBlock withDisconnectHandler:(DisconnectCallback)disconnectBlock
{
    if (self.isConnected)
        assert(@"TCP Client is already connected.");
    
    _connectionCompletionBlock = completionBlock;
    _disconnectCompletionBlock = disconnectBlock;
    
    _socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError* error;
    
    if (![_socket connectToHost:_hostName onPort:_port error:&error])
    {
        [self connectionDidEnd:error];
        return;
    }
    
    if (self.connectingTimeout > 0)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.connectingTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (![self isConnected])
                [self disconnect];
        });
    }
}

- (void)connectionDidBegin
{
    if (_connectionCompletionBlock)
    {
        ErrorCallback block = _connectionCompletionBlock;
        _connectionCompletionBlock = nil;
        block(nil);
    }
}

- (void)connectionDidEnd:(NSError*)error
{
    if (!_socket)
        return;
    
    _socket.delegate = nil;
    [_socket disconnect];
    _socket = nil;
    
    if (_connectionCompletionBlock)
    {
        ErrorCallback block = _connectionCompletionBlock;
        _connectionCompletionBlock = nil;
        block(error ?: [TCPClient abstractError]);
    }
    
    for (NSNumber* tag in _writeCompletionBlocks.allKeys)
        [self writingDidEnd:tag.longValue withError:error ?: [TCPClient abstractError]];
    
    for (NSNumber* tag in _readCompletionBlocks.allKeys)
        [self readingDidEnd:tag.longValue withData:nil withError:error ?: [TCPClient abstractError]];
    
    if (_disconnectCompletionBlock)
    {
        DisconnectCallback block = _disconnectCompletionBlock;
        _disconnectCompletionBlock = nil;
        block(error);
    }
}

- (NSString*)localAddress
{
    return [NSString stringWithFormat:@"%@:%d", _socket.localHost, _socket.localPort];
}

- (void)disconnect
{
    [self connectionDidEnd:nil];
}

- (BOOL)isConnected
{
    return (_socket && _socket.isConnected);
}

#pragma mark Writing
- (void)write:(NSData*)data withComplectionHandler:(ErrorCallback)completionBlock
{
    if (![self isConnected])
    {
        if (completionBlock)
            completionBlock([TCPClient abstractError]);
        
        return;
    }
    
    @synchronized (self)
    {
        _writeCompletionBlocks[@(_writeCounter)] = completionBlock;
        
        if (_terminator)
        {
            NSMutableData* tempData = [NSMutableData dataWithData:data];
            [tempData appendData:_terminator];
            data = tempData;
        }
        
        NSLog(@"Request: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [_socket writeData:data withTimeout:-1 tag:_writeCounter];
        
        _writeCounter ++;
    }
}

- (void)writingDidEnd:(long)tag withError:(NSError*)error
{
    ErrorCallback block = _writeCompletionBlocks[@(tag)];
    [_writeCompletionBlocks removeObjectForKey:@(tag)];
    
    if (block)
        block(error);
}

#pragma mark Reading
- (void)readWithoutTimeoutWithCompletionHandler:(DataCallback)completionBlock
{
    [self readWithTimeout:TCPClientNoTimeout withCompletionHandler:completionBlock];
}

- (void)readWithTimeoutWithCompletionHandler:(DataCallback)completionBlock
{
    [self readWithTimeout:self.readingTimeout withCompletionHandler:completionBlock];
}

- (void)readWithTimeout:(NSTimeInterval)timeout withCompletionHandler:(DataCallback)completionBlock
{
    if (![self isConnected])
    {
        if (completionBlock)
            completionBlock(nil, [TCPClient abstractError]);
        
        return;
    }
    
    @synchronized (self)
    {
        _readCompletionBlocks[@(_readCounter)] = completionBlock;
        
        if (_terminator)
            [_socket readDataToData:_terminator withTimeout:timeout tag:_readCounter];
        else
            [_socket readDataWithTimeout:timeout tag:_readCounter];
        
        _readCounter ++;
    }
}

- (void)readingDidEnd:(long)tag withData:(NSData*)data withError:(NSError*)error
{
    DataCallback block = _readCompletionBlocks[@(tag)];
    [_readCompletionBlocks removeObjectForKey:@(tag)];
    
    if (block)
        block(data, error);
}

#pragma mark Errors
+ (NSError*)abstractError
{
    static NSError* error = nil;
    return error ?: (error = [NSError errorWithDomain:@"TCPClient" code:-1 userInfo:nil]);
}

+ (NSError*)timeoutError
{
    static NSError* error = nil;
    return error ?: (error = [NSError errorWithDomain:@"TCPClient" code:598 userInfo:nil]);
}

+ (NSError*)mapToCustomErrorFromAsyncSocketError:(NSError*)asyncSocketError
{
    if ([asyncSocketError.domain isEqualToString:AsyncSocketErrorDomain])
    {
        if (asyncSocketError.code == AsyncSocketReadTimeoutError)
            return [TCPClient timeoutError];
    }
    
    return [TCPClient abstractError];
}

#pragma mark AsyncSocket delegate
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSError* error = [TCPClient mapToCustomErrorFromAsyncSocketError:err];
    [self connectionDidEnd:error];
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
    NSLog(@"Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    [self readingDidEnd:tag withData:data withError:nil];
}

- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self writingDidEnd:tag withError:nil];
}

@end

@implementation NSError (TCPClient)

- (BOOL)compareDomainAndCode:(NSError*)error
{
    return [self.domain isEqualToString:error.domain] && self.code == error.code;
}

@end
