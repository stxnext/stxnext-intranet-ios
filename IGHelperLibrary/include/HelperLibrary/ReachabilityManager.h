//
//  MTReachabilityManager.h
//  Intranet
//
//  Created by Adam on 25.03.2014.
//  Copyright (c) 2014 STXNext. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reachability;

@interface ReachabilityManager : NSObject

@property (strong, nonatomic) Reachability *reachability;

#pragma mark - Shared Manager

+ (ReachabilityManager *)sharedManager;

#pragma mark - Class Methods

+ (BOOL)isReachable;
+ (BOOL)isUnreachable;
+ (BOOL)isReachableViaWWAN;
+ (BOOL)isReachableViaWiFi;

@end