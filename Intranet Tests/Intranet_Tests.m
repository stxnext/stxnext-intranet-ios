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

- (void)test_001_cocoaAsyncSocketWithHttpbinJson
{
    AsyncSocket* socket = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError *err = nil;
    
    if (![socket connectToHost:@"httpbin.org" onPort:80 error:&err])
        XCTFail(@"Could not connect to host: %@", err);
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:30.0];
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    if (err)
    {
        XCTFail(@"Could not connect to host: %@", err);
        [self notify:XCTAsyncTestCaseStatusFailed];
    }
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSString* request = @"GET /get HTTP/1.1\r\nHost: httpbin.org\r\n\r\n";
    NSData* data = [request dataUsingEncoding:NSUTF8StringEncoding];
    [sock writeData:data withTimeout:30.0 tag:0];
    [sock readDataWithTimeout:30.0 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (![response hasPrefix:@"HTTP/1.1 200 OK"])
    {
        XCTFail(@"Server response invalid: %@", response);
        [self notify:XCTAsyncTestCaseStatusFailed];
        
        return;
    }
    
    // Validate json
    NSArray* parts = [response componentsSeparatedByString:@"\r\n\r\n"];
    NSString* bodyString = parts.count < 2 ? nil : parts[1];
    NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:bodyData options:0 error:nil];
    NSString* hostField = json[@"headers"][@"Host"];
    
    XCTAssertEqualObjects(hostField, @"httpbin.org", @"Response json field invalid");
    [self notify:XCTAsyncTestCaseStatusSucceeded];
}

@end
