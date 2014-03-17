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

- (void)test_001_tcpClientWithHttpbinJson
{
    __block TCPClient* client = [[TCPClient alloc] initWithHostName:@"httpbin.org" withPort:80];
    
    [client connectWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            [self notify:XCTAsyncTestCaseStatusFailed];
            return;
        }
        
        NSString* request = @"GET /get HTTP/1.1\r\nHost: httpbin.org\r\n\r\n";
        NSData* data = [request dataUsingEncoding:NSUTF8StringEncoding];
        
        [client write:data withComplectionHandler:^(NSError *error) {
            if (error)
            {
                [self notify:XCTAsyncTestCaseStatusFailed];
                return;
            }
            
            [client readWithCompletionHandler:^(NSData *data, NSError *error) {
                if (error)
                {
                    [self notify:XCTAsyncTestCaseStatusFailed];
                    return;
                }
                
                NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                if (![response hasPrefix:@"HTTP/1.1 200 OK"])
                {
                    XCTFail(@"Server response invalid: %@", response);
                    [self notify:XCTAsyncTestCaseStatusFailed];
                    
                    return;
                }
                
                NSArray* parts = [response componentsSeparatedByString:@"\r\n\r\n"];
                NSString* bodyString = parts.count < 2 ? nil : parts[1];
                NSData* bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
                id json = [NSJSONSerialization JSONObjectWithData:bodyData options:0 error:nil];
                NSString* hostField = json[@"headers"][@"Host"];
                
                XCTAssertEqualObjects(hostField, @"httpbin.org", @"Response json field invalid");
                [self notify:XCTAsyncTestCaseStatusSucceeded];
            }];
        }];
    }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:30.0];
}

- (void)test_002_tcpClientWithIntranetLocalServer
{
    __block TCPClient* client = [[TCPClient alloc] initWithHostName:@"10.93.1.12" withPort:8080];
    
    [client connectWithCompletionHandler:^(NSError *error) {
        if (error)
        {
            [self notify:XCTAsyncTestCaseStatusFailed];
            return;
        }
        
        NSString* request = @"{\"request\":{\"request_name\":\"card_decks\"}}\r\n";
        NSData* data = [request dataUsingEncoding:NSUTF8StringEncoding];
        
        [client write:data withComplectionHandler:^(NSError *error) {
            if (error)
            {
                [self notify:XCTAsyncTestCaseStatusFailed];
                return;
            }
            
            [client readWithCompletionHandler:^(NSData *data, NSError *error) {
                if (error)
                {
                    [self notify:XCTAsyncTestCaseStatusFailed];
                    return;
                }
                
                id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                NSArray* decks = json[@"decks"];
                
                if (decks.count > 0)
                    [self notify:XCTAsyncTestCaseStatusSucceeded];
                else
                    [self notify:XCTAsyncTestCaseStatusFailed];
            }];
        }];
    }];
    
    [self waitForStatus:XCTAsyncTestCaseStatusSucceeded timeout:30.0];
}

@end
