//
//  StringTests.m
//  Intranet
//
//  Created by Paweł Urbanowicz on 13.11.2015.
//  Copyright © 2015 STXNext. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSString+IsNilOrEmpty.h"

@interface StringTests : XCTestCase

@end

@implementation StringTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNilString {
    NSString *myString = nil;
    XCTAssertTrue([NSString isNilOrEmpty:myString], @"String is not nil");
}

- (void)testWhitespaceString {
    NSString *myString = @"      ";
    XCTAssertTrue([NSString isNilOrEmpty:myString], @"String is not whitespace");
}

- (void)testEmptyString {
    NSString *myString = @"";
    XCTAssertTrue([NSString isNilOrEmpty:myString], @"String is not empty");
}

@end
